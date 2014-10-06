//
//  ViewController.m
//  CustomHTMLReader
//
//  Created by Craig Zheng on 29/09/2014.
//  Copyright (c) 2014 cz. All rights reserved.
//

/*
 one single page with text and image
 */

#import "PageViewController.h"
#import "HTMLNode.h"
#import "HTMLParser.h"

@interface PageViewController ()

@end

@implementation PageViewController
@synthesize textView;


-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSDate *startTime = [NSDate new];
    
    NSError *error;
    HTMLParser *parser = [[HTMLParser alloc] initWithContentsOfURL:[NSURL URLWithString:@"http://lknovel.lightnovel.cn/main/view/8454.html"] error:&error];
    if (error) {
        NSLog(@"%@", error);
        return;
    }
    HTMLNode *bodyNode = [parser body];
    NSLog(@"Body Processing Time: %f", [[NSDate new] timeIntervalSinceDate:startTime]);
    startTime = [NSDate new];
    
    NSArray *lineClass = [bodyNode findChildTags:@"div"];
    NSMutableString *textContent = [NSMutableString new];
    for (HTMLNode *lineNode in lineClass) {
        if ([lineNode.className isEqualToString:@"lk-view-img"]) {
            [textContent appendFormat:@"%@\n", lineNode.rawContents];
        } else if ([lineNode.className isEqualToString:@"lk-view-line"])
            [textContent appendFormat:@"%@\n", [lineNode contents]];
    }
    
    textView.text = textContent;
    NSLog(@"Text Processing Time: %f seconds", [[NSDate new] timeIntervalSinceDate:startTime]);
}

@end
