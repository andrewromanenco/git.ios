//
//  SyntaxHelper.h
//  Git ios app
//
//  Created by Andrew Romanenco on 2013-07-02.
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
// Util to work with SyntaxHelper js lib.
//
@interface SyntaxHelper : NSObject

// Get brush name for given file.
// file - path to file.
// Brush name is extension is mapped, or nil.
+ (NSString*)brushForFile:(NSString*)file;

// Format html with content of source file provided.
//
// file - path to file.
//
// Ready to render html.
+ (NSString*)getHtmlView:(NSString*)file withBrush:(NSString*)brush;

@end
