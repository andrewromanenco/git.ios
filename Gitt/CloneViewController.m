//
//  CloneViewController.m
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


#import "CloneViewController.h"
#import "GitActionController.h"
#import "LocalDAO.h"

#define __OK__                      @"Ok"

#define __ERROR_REQUIRED_FIELDS__   @"Both name and url are required"
#define __ERROR_PROTOCOL__          @"Url must start with http:// or https://"
#define __ERROR_DUPLICATE__         @"This repo name already exists"

#define __PREFIX_HTTP__             @"http://"
#define __PREFIX_HTTPS__            @"https://"

#define __SEGUE_GIT_ACTION__        @"segueGitAction"

@interface CloneViewController ()

- (void)alertWithMessage:(NSString*)message;

@end

@implementation CloneViewController

#pragma mark User action

- (IBAction)actionClone:(id)sender
{
    NSString *name = [self.tfRepoName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *url = [self.tfRepoUrl.text lowercaseString];

    if (([name  length] == 0)||[url  length] == 0) {
        [self alertWithMessage:__ERROR_REQUIRED_FIELDS__];
        return;
    }
    if (![url hasPrefix:__PREFIX_HTTP__]&&![url hasPrefix:__PREFIX_HTTPS__]) {
        [self alertWithMessage:__ERROR_PROTOCOL__];
        return;
    }
    LocalDAO * dao = [LocalDAO instance];
    NSArray *allRepos = [dao allLocalRepos];
    NSString *newName = [name lowercaseString];
    for (GitRepo *r in allRepos) {
        if ([newName isEqualToString:[r.name lowercaseString]]) {
            [self alertWithMessage:__ERROR_DUPLICATE__];
            return;
        }
    }
    [self performSegueWithIdentifier:__SEGUE_GIT_ACTION__ sender:self];
}

#pragma mark Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:__SEGUE_GIT_ACTION__]) {
        GitActionController *controller = segue.destinationViewController;
        
        GitRepo *repo = [[GitRepo alloc] init];
        repo.name = self.tfRepoName.text;
        repo.url = self.tfRepoUrl.text;
        repo.username = self.tfUserName.text;
        repo.password = self.tfPassword.text;
        
        controller.repo = repo;
        controller.command = clone;
    }
}

#pragma mark Util

- (void)alertWithMessage:(NSString*)message {
    [[[UIAlertView alloc]
      initWithTitle:@""
      message:message
      delegate:nil
      cancelButtonTitle:__OK__
      otherButtonTitles: nil] show];
}

#pragma mark Keyboard

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.tfRepoName) {
        [self.tfRepoUrl becomeFirstResponder];
    } else if (textField == self.tfRepoUrl) {
        [self.tfUserName becomeFirstResponder];
    } else if (textField == self.tfUserName) {
        if ([self.tfUserName.text length] == 0) {
            [textField resignFirstResponder];
        } else {
            [self.tfPassword becomeFirstResponder];
        }
    } else if (textField == self.tfPassword) {
        [textField resignFirstResponder];
        [self actionClone:nil];
    }
    return YES;
}

@end
