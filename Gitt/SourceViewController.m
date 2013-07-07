//
//  SourceViewController.m
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


#import "SourceViewController.h"
#import "PrettifyHelper.h"

@interface SourceViewController ()

@end

@implementation SourceViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = [self.path lastPathComponent];

    /*
     
     *** Leave this code here until syntax highlighter work well in ios ***
     
    NSString *brush = [SyntaxHelper brushForFile:self.path];
    NSString *sourceHtml = [SyntaxHelper getHtmlView:self.path withBrush:brush];
    //NSLog(@"%@", sourceHtml);
    
    NSURL *url = [NSURL fileURLWithPath:
                  [[NSBundle mainBundle] pathForResource:@"syntaxhighlighter/index" ofType:@"html"]
                  ];
    [self.webView loadHTMLString:sourceHtml baseURL:url];'
     
     */
    
    NSString *sourceHtml = [PrettifyHelper getHtmlView:self.path];
    NSURL *url = [NSURL fileURLWithPath:
                  [[NSBundle mainBundle] pathForResource:@"google-code-prettify/prettify" ofType:@"css"]
                  ];
    [self.webView loadHTMLString:sourceHtml baseURL:url];
}

@end
