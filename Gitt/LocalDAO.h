//
//  LocalDAO.h
//  Gitt
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


#import <Foundation/Foundation.h>

//
// Git repository data model.
//
@interface GitRepo : NSObject

@property(strong) NSString *name;
@property(strong) NSString *url;
@property(strong) NSString *username;
@property(strong) NSNumber *size;

// not for persistence.
@property(strong) NSString *password;

// Get full path to the folder with this git repo.
- (NSString*)fullPathToThisRepo;

@end

//
// DAO implementation based on SQLite.
// Support basic operations as data volume is very small.
//
@interface LocalDAO : NSObject

// Get dao instance.
+ (LocalDAO*)instance;

// Get all available repositories.
//
// Returns an array with GitRepo instances.
- (NSArray*)allLocalRepos;

// Save new repo.
//
// name     - Friendly name to be displayed.
// url      - http(s) url.
// userName - Not nil if authentication is required.
// size     - Repo folder size.
//
- (void)addRepo:(NSString*)name url:(NSString*)url user:(NSString*)userName size:(NSNumber*)size;

// Delete repo.
//
// name - Repo name to delete.
//
- (void)deleteRepo:(NSString*)name;

@end
