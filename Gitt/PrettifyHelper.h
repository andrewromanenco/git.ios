//
//  PrettifyHelper.h
//  Git ios app
//
//  Created by Andrew Romanenco on 2013-07-06.
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
// Helper around google-code-pretify js library.
//
@interface PrettifyHelper : NSObject

// Get render ready html for webview.
// file - full path to file.
// Return html.
+ (NSString*)getHtmlView:(NSString*)file;

@end
