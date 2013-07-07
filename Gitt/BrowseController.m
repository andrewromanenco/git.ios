//
//  BrowseController.m
//  Git ios app
//
//  Created by Andrew Romanenco on 2013-06-27.
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


#import "BrowseController.h"
#import "SourceViewController.h"
#import "ObjectiveGit/ObjectiveGit.h"
#import "CheckoutController.h"
#import "GitActionController.h"

#define __SEGUE_CHECKOUT__      @"segueCheckout"
#define __SEGUE_GIT_ACTION__    @"segueGitAction"
#define __SEGUE_SOURCE__        @"segueViewSource"

@interface BrowseController ()

- (void)readCurrentFolder;
- (bool)isFolder:(NSString*)path;

@end

@implementation BrowseController {
    
    NSString *root;
    NSString *currentDir;
    int deep;
    NSArray *list;
    UIAlertView *busy;
    bool refreshNextShow;
    
}

#pragma mark Init

- (void)viewDidLoad
{
    [super viewDidLoad];
    refreshNextShow = YES;
	root = [self.repo fullPathToThisRepo];
}

- (void)viewWillAppear:(BOOL)animated {
    if (refreshNextShow) {
        refreshNextShow = NO;
        
        currentDir = root;
        deep = 0;
        [self readCurrentFolder];
        
        NSURL *repoUrl = [NSURL fileURLWithPath:root];
        NSError *err;
        GTRepository *git = [GTRepository repositoryWithURL:repoUrl error:&err];
        if (!err) {
            NSString *currentBranch = [git currentRefNameWithError:&err];
            self.title = [NSString stringWithFormat:@"%@ (%@)", self.repo.name, [currentBranch lastPathComponent]];
        } else {
            self.title = self.repo.name;
        }
        [self.tableView reloadData];
    }
}

- (void)readCurrentFolder {
    list = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:currentDir error:nil];
    list = [NSMutableArray arrayWithArray:list];
    
    if (deep == 0) {
        [(NSMutableArray*)list removeObject:@".git"]; // user should not browse in .git
    } else {
        [(NSMutableArray*)list insertObject:@".." atIndex:0];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [list count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    NSString *item = [list objectAtIndex:indexPath.row];
    NSString *path = [currentDir stringByAppendingPathComponent:item];
    if ([self isFolder:path]) {
        cell.textLabel.text = [NSString stringWithFormat:@"/%@", item];
    } else {
        cell.textLabel.text = item;
    }
    return cell;
}

#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (deep && indexPath.row == 0) { // upper dir .. is always first
        deep--;
        currentDir = [currentDir stringByDeletingLastPathComponent];
        [self readCurrentFolder];
        [self.tableView reloadData];
    } else {
        NSString *path = [currentDir stringByAppendingPathComponent:[list objectAtIndex:indexPath.row]];
        if ([self isFolder:path]) {
            deep++;
            currentDir = path;
            [self readCurrentFolder];
            [self.tableView reloadData];
        } else {
            [self performSegueWithIdentifier:__SEGUE_SOURCE__ sender:path];
        }
    }
}

#pragma mark Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:__SEGUE_SOURCE__]) {
        
        SourceViewController *controller = segue.destinationViewController;
        controller.path = sender;
        
    } else if ([segue.identifier isEqualToString:__SEGUE_CHECKOUT__]) {
        
        CheckoutController *controller = segue.destinationViewController;
        controller.repo = self.repo;
        
    } else if ([segue.identifier isEqualToString:__SEGUE_GIT_ACTION__]) {
        
        GitActionController *controller = segue.destinationViewController;
        controller.repo = self.repo;
        controller.command = pull;
        
    }
}

#pragma mark Action

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:// Checkout
            refreshNextShow = YES; // refresh next time
            [self performSegueWithIdentifier:__SEGUE_CHECKOUT__ sender:nil];
            break;
            
        case 1:// Pull
            refreshNextShow = YES;
            [self performSegueWithIdentifier:__SEGUE_GIT_ACTION__ sender:nil];
            break;
    }
}

- (IBAction)actionMenu:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:@"Cancel"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"Checkout...", @"Pull from origin", nil];
    [actionSheet showInView:self.view];
}

- (bool)isFolder:(NSString*)path {
    BOOL isDir;
    [NSFileManager.defaultManager fileExistsAtPath:path isDirectory:&isDir];
    return isDir;
}

@end
