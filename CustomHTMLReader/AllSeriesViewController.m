//
//  AllSeriesViewController.m
//  CustomHTMLReader
//
//  Created by Craig Zheng on 5/10/2014.
//  Copyright (c) 2014 cz. All rights reserved.
//

#import "AllSeriesViewController.h"
#import "HTMLNode.h"
#import "HTMLParser.h"

@interface AllSeriesViewController ()

@end

@implementation AllSeriesViewController
@synthesize contentTextView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSDate *startTime = [NSDate new];
    NSError *error;
    HTMLParser *parser = [[HTMLParser alloc] initWithContentsOfURL:[NSURL URLWithString:@"http://lknovel.lightnovel.cn/main/series_index.html"] error:&error];
    if (error) {
        NSLog(@"%@", error);
        return;
    }
    
    HTMLNode *bodyNode = [parser body];
    NSLog(@"Body Processing Time = %f", [[NSDate new] timeIntervalSinceDate:startTime]);
    startTime = [NSDate new];
    
    NSMutableString *content = [NSMutableString new];
    for (HTMLNode *linkNode  in [bodyNode findChildTags:@"a"]) {
        if ([linkNode getAttributeNamed:@"href"] && [linkNode allContents].length > 0)
            [content appendFormat:@"\n%@ - %@", [linkNode getAttributeNamed:@"href"], [linkNode allContents]];
    }
    contentTextView.text = content;
    NSLog(@"Text Processing Time = %f", [[NSDate new] timeIntervalSinceDate:startTime]);
}

@end
