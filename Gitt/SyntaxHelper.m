//
//  SyntaxHelper.m
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


#import "SyntaxHelper.h"

@implementation SyntaxHelper

static NSArray *mapping;

+ (NSString*)brushForFile:(NSString*)file {
    if (!mapping) {
        mapping = [NSArray arrayWithObjects:
                   @"Bash,bash,sh",
                   @"CSharp,cs",
                   @"ColdFusion",
                   @"Cpp,m,h,cpp,c,hpp,cc",
                   @"Css,css",
                   @"Delphi,pas",
                   @"Diff,diff",
                   @"Erlang,erl",
                   @"Groovy,groovy",
                   @"JScript,js",
                   @"Java,java",
                   @"JavaFX",
                   @"Perl,pl",
                   @"Php,php",
                   @"Plain,txt,cfg,config,md",
                   @"PowerShell,ps1,psm1,cmd",
                   @"Python,py",
                   @"Ruby,rb",
                   @"Sass,sass",
                   @"Scala,scala",
                   @"Sql,sql",
                   @"Vb",
                   @"Xml,xml,html,htm",
                   nil];
    }
    NSString *ext = [file pathExtension];
    if (ext) {
        for (NSString *item in mapping) {
            NSArray *map = [item componentsSeparatedByString:@","];
            for (int i = 1; i < [map count]; i++) {
                if ([ext isEqualToString:[map objectAtIndex:i]]) {
                    return map[0];
                }
            }
        }
    }
    return @"Plain"; //for now always return something
    
}

// User template to replace tokens with actual info.
// {{SORUCE}}       - content for soruce file.
// {{BRUSH_NAME}}   - name of brush.
// {{BRUSH_ID}}     - id for js.
+ (NSString*)getHtmlView:(NSString*)file withBrush:(NSString*)brush {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"sourceview" ofType:@"html"];
    
    NSError *error = nil;
    NSString *template = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSString *source = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"Can not load template %@", error);
        return error.localizedFailureReason;
    } else {
        template = [template stringByReplacingOccurrencesOfString:@"{{BRUSH_NAME}}" withString:brush];
        template = [template stringByReplacingOccurrencesOfString:@"{{BRUSH_ID}}" withString:[brush lowercaseString]];
        return [template stringByReplacingOccurrencesOfString:@"{{SOURCE}}" withString:[source stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"]];
    }
}

@end
