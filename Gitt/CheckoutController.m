//
//  CheckoutController.m
//  Git ios app
//
//  Created by Andrew Romanenco on 2013-07-03.
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


#import "CheckoutController.h"
#import "ObjectiveGit/ObjectiveGit.h"
#import "GitActionController.h"

#define __BRANCH_PREFIX__       @"refs/remotes"
#define __TAG_PREFIX__          @"refs/tags"

#define __SEGUE_GIT_ACTION__    @"segueGitAction"

@interface CheckoutController ()

@end

@implementation CheckoutController {
    
    NSMutableArray *branches;
    NSMutableArray *tags;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	NSString *root = [self.repo fullPathToThisRepo];
    NSURL *url = [NSURL fileURLWithPath:root];
    
    NSError *err;
    GTRepository *git = [GTRepository repositoryWithURL:url error:&err];
    
    if (!err) {
        NSArray *refs = [git referenceNamesWithError:&err];
        branches = [NSMutableArray array];
        tags = [NSMutableArray array];
        for (NSString *r in refs) {
            if ([r hasPrefix:__BRANCH_PREFIX__]) {
                [branches addObject:r];
            }
            if ([r hasPrefix:__TAG_PREFIX__]) {
                [tags addObject:r];
            }
        }
    }
}

#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return ([branches count] == 0?0:1) + ([tags count] == 0?0:1);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ((section == 1)||[branches count] == 0) {
        return [tags count];
    } else {
        return [branches count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSArray *data;
    if ((indexPath.section == 1)||[branches count] == 0) {
        data = tags;
    } else {
        data = branches;
    }
    NSString *name = [data objectAtIndex:indexPath.row];
    cell.textLabel.text = [name lastPathComponent];
    
    return cell;
}

#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self performSegueWithIdentifier:__SEGUE_GIT_ACTION__ sender:indexPath];
}

#pragma mark Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    GitActionController *controller = segue.destinationViewController;
    controller.command = checkout;
    controller.repo = self.repo;
    
    NSArray *data;
    NSIndexPath *indexPath = (NSIndexPath*)sender;
    if ((indexPath.section == 1)||[branches count] == 0) {
        data = tags;
    } else {
        data = branches;
    }
    controller.checkoutTo = [data objectAtIndex:indexPath.row];
}

@end
