//
//  CloneController.m
//  Git ios app
//
//  Created by Andrew Romanenco on 2013-06-26.
//  Copyright (c) 2013 Andrew Romanenco. All rights reserved.
//
//  This file is part of Git ios app.
//
//  GitApp is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  GitApp is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with GitApp.  If not, see <http://www.gnu.org/licenses/>.
//


#import "GitActionController.h"
#import "ObjectiveGit/ObjectiveGit.h"

#define __AUTH_ERROR__ @"Authentication failed"
#define __PATH_ERROR__ @"Repo not found. Check url"

@interface GitActionController ()

- (void)cloneRemote;
- (void)checkoutReference;
- (void)prepareToPullFromRemote;
- (void)pullRemoteWithPassword:(NSString*)password;

-(void)showAlertForError:(NSError*)error;

@end

@implementation GitActionController {
    bool freshStart;
}

#pragma mark Init and Start

- (void)viewDidLoad {
    freshStart = YES;
}

- (void)viewDidAppear:(BOOL)animated { // We start thread only after view is shown
    [super viewDidAppear:animated];
    
    if (!freshStart) return;
    freshStart = NO;
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    
    if ((self.command == pull)&&[self.repo.username length] > 0) {
        [self prepareToPullFromRemote];
    } else {
        dispatch_async(queue,^{
            switch (self.command) {
                case clone:
                    [self cloneRemote];
                    break;
                case checkout:
                    [self checkoutReference];
                    break;
                case pull:
                    [self pullRemoteWithPassword:nil];
                    break;
                default:
                    break;
            }
        });
    }
}

-(void)showAlertForError:(NSError*)error {
    NSString *message = error.localizedFailureReason;
    //hack to detect authentication fail
    NSRange range = [error.localizedFailureReason rangeOfString:@"401"];
    if (range.location != NSNotFound) {
        message = __AUTH_ERROR__;
    }
    range = [error.localizedFailureReason rangeOfString:@"404"];
    if (range.location != NSNotFound) {
        message = __PATH_ERROR__;
    }
    [[[UIAlertView alloc]
      initWithTitle:@"*ERROR*"
      message:message
      delegate:nil
      cancelButtonTitle:@"Ok"
      otherButtonTitles: nil] show];
}

#pragma mark Git operations

- (void)cloneRemote {
    NSLog(@"Cloning...");
    
    void (^transferProgressBlock)(const git_transfer_progress *) = ^(const git_transfer_progress *progress) {
        if (progress->total_objects > 0) {
            float received = (float)progress->received_objects;
            float total = (float)progress->total_objects;
            float done = received/total;
            dispatch_async(dispatch_get_main_queue(), ^{
                self.uiProgressBar.progress = done;
            });
        }
	};
	void (^checkoutProgressBlock)(NSString *, NSUInteger, NSUInteger) = ^(NSString *path, NSUInteger completedSteps, NSUInteger totalSteps) {
		if (totalSteps > 0) {
            float completed = (float)completedSteps;
            float total = (float)totalSteps;
            float done = completed/total;
            dispatch_async(dispatch_get_main_queue(), ^{
                self.uiProgressBar.progress = done;
            });
        }
	};
    
    NSString *localFilePath = [self.repo fullPathToThisRepo];
    
    NSURL *originURL = [NSURL URLWithString: self.repo.url];    
	NSURL *workdirURL = [NSURL fileURLWithPath:localFilePath];
    [NSFileManager.defaultManager removeItemAtURL:workdirURL error:nil]; //delete just in case
    
	NSError *err;
    
    if (([self.repo.username length] > 0)||([self.repo.password length] > 0)) {
        [GTRepository cloneFromURL:originURL toWorkingDirectory:workdirURL barely:NO withCheckout:YES error:&err transferProgressBlock:transferProgressBlock checkoutProgressBlock:checkoutProgressBlock asUser:self.repo.username withPassword:self.repo.password];
    } else {
        [GTRepository cloneFromURL:originURL toWorkingDirectory:workdirURL barely:NO withCheckout:YES error:&err transferProgressBlock:transferProgressBlock checkoutProgressBlock:checkoutProgressBlock];
    }

    if (err) {
        [[NSFileManager defaultManager] removeItemAtURL:workdirURL error:nil];
    } else {
        LocalDAO *dao = [LocalDAO instance];
        [dao addRepo:self.repo.name url:self.repo.url user:self.repo.username size:[NSNumber numberWithInt:1]]; // no size yet
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (err) {
            [self showAlertForError:err];
        } else {
            // We are good. Just go back to all repos list
            [(UINavigationController *)self.presentingViewController  popToRootViewControllerAnimated:YES];
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    });
    
    NSLog(@"Clone done.");
}

- (void)checkoutReference {
    NSString *localFilePath = [self.repo fullPathToThisRepo];
    NSURL *url = [NSURL fileURLWithPath:localFilePath];
    
    NSError *err;
    GTRepository *git = [GTRepository repositoryWithURL:url error:&err];
    
    void (^checkoutProgressBlock)(NSString *, NSUInteger, NSUInteger) = ^(NSString *path, NSUInteger completedSteps, NSUInteger totalSteps) {
		if (totalSteps > 0) {
            float completed = (float)completedSteps;
            float total = (float)totalSteps;
            float done = completed/total;
            dispatch_async(dispatch_get_main_queue(), ^{
                self.uiProgressBar.progress = done;
            });
        }
	};
    
    [git checkout:self.checkoutTo error:&err checkoutProgressBlock:checkoutProgressBlock];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (err) {
            [self showAlertForError:err];
        } else {
            if (self.command == checkout) { //hack: when called from checkout only
                [(UINavigationController *)self.presentingViewController  popViewControllerAnimated:NO];
            }
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    });

    
}

// App does not save passwords. Request one if required.
- (void)prepareToPullFromRemote {
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@""
                          message:[NSString stringWithFormat:@"%@ password:", self.repo.username]
                          delegate:self
                          cancelButtonTitle:@"Cancel"
                          otherButtonTitles: @"Pull", nil];
    alert.alertViewStyle = UIAlertViewStyleSecureTextInput;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) { //just cancel
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        UITextField *password = [alertView textFieldAtIndex:0];
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
        dispatch_async(queue,^{
            [self pullRemoteWithPassword:password.text];
        });
    }
}

- (void)pullRemoteWithPassword:(NSString*)password {
    NSString *localFilePath = [self.repo fullPathToThisRepo];
    NSURL *url = [NSURL fileURLWithPath:localFilePath];
    
    void (^transferProgressBlock)(const git_transfer_progress *) = ^(const git_transfer_progress *progress) {
        if (progress->total_objects > 0) {
            float received = (float)progress->received_objects;
            float total = (float)progress->total_objects;
            float done = received/total;
            dispatch_async(dispatch_get_main_queue(), ^{
                self.uiProgressBar.progress = done;
            });
        }
	};
    
    NSError *err;
    GTRepository *git = [GTRepository repositoryWithURL:url error:&err];
    if (!err) {
        NSString *currentRef = [git currentRefNameWithError:nil];
        if (password) {
            [git fetchFromRemote:nil transferProgressBlock:transferProgressBlock error:&err asUser:self.repo.username withPassword:password];
        } else {
            [git fetchFromRemote:nil transferProgressBlock:transferProgressBlock error:&err];
        }
        if (!err) {
            self.checkoutTo = currentRef;
            [self checkoutReference]; // must recheckout to show changes
            return;
        }
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [self showAlertForError:err];
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

@end
