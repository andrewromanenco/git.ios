//
//  LocalDAO.m
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


#import "LocalDAO.h"
#import "/usr/include/sqlite3.h"

#define __DB_FILE_NAME__    @"repos.db"
#define __SQL_TABLE__       "CREATE TABLE REPOS(NAME TEXT, URL TEXT, USERNAME TEXT, SIZE int)"
#define __SQL_SELECT__      "SELECT NAME, URL, USERNAME, SIZE FROM REPOS ORDER BY NAME"
#define __SQL_INSERT__      "INSERT INTO REPOS (NAME, URL, USERNAME, SIZE) VALUES(?, ?, ?, ?)"
#define __SQL_DELETE__      "DELETE FROM REPOS WHERE NAME = ?"

@implementation GitRepo

// Using hash as folder name is good enought. User has no access to
// sandbox with files anyway.
- (NSString*)fullPathToThisRepo {
    int hash = abs([[self.name lowercaseString] hash]);
    NSString *folder = [NSString stringWithFormat:@"%d", hash];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    return [documentsDirectory stringByAppendingPathComponent:folder];
}

@end

//
// DAO is as simple as possible. Nobody will have more than
// couple of dozens of repositories.
// "640K ought to be enough for anybody" (c)
//

@interface LocalDAO()

- (sqlite3*)openDatabase;

@end

@implementation LocalDAO

static LocalDAO *dao;
static NSString *dbFile;

#pragma mark Init

+ (LocalDAO*)instance { // Singe threaded environment
    if (!dao) {
        dao = [[LocalDAO alloc] init];
    }
    return dao;
}

- (id) init {
    if (self = [super init]) {
        NSString *appRoot;
        appRoot = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        dbFile = [[NSString alloc] initWithString: [appRoot stringByAppendingPathComponent: __DB_FILE_NAME__]];
        NSFileManager *fm = NSFileManager.defaultManager;
        
        if (![fm fileExistsAtPath:dbFile]) {
            
            const char *dbpath = [dbFile UTF8String];
            sqlite3 *database;
            if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
                char *error;
                if (sqlite3_exec(database, __SQL_TABLE__, NULL, NULL, &error) != SQLITE_OK) {
                    NSLog(@"Table was not created");
                    return nil;
                };
                sqlite3_close(database);
                NSLog(@"DB was created");
            } else {
                NSLog(@"DB file was not created");
                return nil;
            }
            
        } else {
            NSLog(@"DB exists...");
        }
        
    }
    return self;
}

- (sqlite3*)openDatabase {
    const char *dbpath = [dbFile UTF8String];
    sqlite3 *database;
    
    if (sqlite3_open(dbpath, &database) != SQLITE_OK) {
        NSLog(@"Cannot open db");
        return nil;
    }
    
    return database;
}

#pragma mark Read

- (NSArray*)allLocalRepos {
    NSMutableArray *list = [NSMutableArray array];
    sqlite3 *database = [self openDatabase];
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(database, __SQL_SELECT__, -1, &statement, NULL) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            
            GitRepo *r = [[GitRepo alloc] init];
            r.name = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)];
            r.url = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 1)];
            char *username =(char*) sqlite3_column_text(statement, 2);
            if (username == NULL) {
                r.username = nil;
            } else {
                r.username = [[NSString alloc] initWithUTF8String:username];
            }
            r.size = [NSNumber numberWithInt:sqlite3_column_int(statement, 3)];
            [list addObject:r];
            
        }
    }
    
    sqlite3_finalize(statement);
    sqlite3_close(database);
    return list;
}

#pragma mark Modify

- (void)addRepo:(NSString*)name url:(NSString*)url user:(NSString*)userName size:(NSNumber*)size {
    sqlite3 *database = [self openDatabase];
    sqlite3_stmt *statement;
    
    const char* insert = __SQL_INSERT__;
    if (sqlite3_prepare_v2(database, insert, -1, &statement, NULL) == SQLITE_OK) {
        sqlite3_bind_text(statement, 1, [name UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 2, [url UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 3, [userName UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(statement, 4, 1); // not in use foe now
        
        if (sqlite3_step(statement) != SQLITE_DONE) {
            NSLog(@"Insert error");
        }
        
        sqlite3_finalize(statement);
    }
    sqlite3_close(database);
}

- (void)deleteRepo:(NSString*)name {
    sqlite3 *database = [self openDatabase];
    sqlite3_stmt *statement;
    
    const char* insert = __SQL_DELETE__;
    if (sqlite3_prepare_v2(database, insert, -1, &statement, NULL) == SQLITE_OK) {
        sqlite3_bind_text(statement, 1, [name UTF8String], -1, SQLITE_TRANSIENT);
        if (sqlite3_step(statement) != SQLITE_DONE) {
            NSLog(@"Delete error");
        }
        
        sqlite3_finalize(statement);
    }
    sqlite3_close(database);
}

@end
