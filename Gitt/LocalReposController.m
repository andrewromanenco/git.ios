//
//  LocalReposController.m
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


#import "LocalReposController.h"
#import "LocalDAO.h"
#import "BrowseController.h"

#define __SEGUE_ABOUT__     @"segueAbout"
#define __SEGUE_BROWSE__    @"segueBrowse"

@interface LocalReposController ()

- (void)deleteLocalRepo:(GitRepo*)repo;

@end

@implementation LocalReposController {
    bool shouldShowAbout;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {}
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    shouldShowAbout = true;
    self.repos = [[LocalDAO instance] allLocalRepos];
    [self.tableView reloadData];
}

#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.repos count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    GitRepo *repo = [self.repos objectAtIndex:indexPath.row];
    cell.textLabel.text = repo.name;
    cell.detailTextLabel.text = repo.url;
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self performSegueWithIdentifier:__SEGUE_BROWSE__ sender:indexPath];
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        GitRepo *repo = [self.repos objectAtIndex:indexPath.row];
        [self deleteLocalRepo:repo];
    }
}

#pragma mark Segue

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:__SEGUE_ABOUT__]) {
        if (shouldShowAbout) {
            shouldShowAbout = false;
            return true;
        } else {
            return false;
        }
    }
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:__SEGUE_BROWSE__]) {
        BrowseController *controller = (BrowseController *)segue.destinationViewController;
        controller.repo = [self.repos objectAtIndex:((NSIndexPath*)sender).row];
    } else if ([segue.identifier isEqualToString:__SEGUE_ABOUT__]) {
        UIPopoverController *pc = [(UIStoryboardPopoverSegue *)segue popoverController];
        pc.delegate = self;
    }
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    shouldShowAbout = true;
}

#pragma mark Action

- (void)deleteLocalRepo:(GitRepo*)repo {
    const UIAlertView *busy = [[UIAlertView alloc] initWithTitle:@" " message:@" " delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
    UIActivityIndicatorView *progress= [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(125, 50, 30, 30)];
    progress.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    [busy addSubview:progress];
    [progress startAnimating];
    [busy show];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    
    dispatch_async(queue,^{
        NSString *root = [repo fullPathToThisRepo];
        NSError *err;
        [NSFileManager.defaultManager removeItemAtPath:root error:&err];
        NSLog(@"Deleting error: %@", err);
        if (!err) {
            [[LocalDAO instance] deleteRepo:repo.name];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [busy dismissWithClickedButtonIndex:0 animated:YES];
            self.repos = [[LocalDAO instance] allLocalRepos];
            [self.tableView reloadData];
        });
    });
}

@end
