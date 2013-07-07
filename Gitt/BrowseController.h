//
//  BrowseController.h
//  Git iso app
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


#import <UIKit/UIKit.h>
#import "LocalDAO.h"

//
// File listing from sandbox file storage.
//
@interface BrowseController : UITableViewController <UIActionSheetDelegate, UIAlertViewDelegate>

@property(strong) GitRepo *repo;
@property(strong) NSString *path;

- (IBAction)actionMenu:(id)sender;

@end
