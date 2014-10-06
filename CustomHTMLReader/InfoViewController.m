//
//  InfoViewController.m
//  CustomHTMLReader
//
//  Created by Craig Zheng on 29/09/2014.
//  Copyright (c) 2014 cz. All rights reserved.
//

#import "InfoViewController.h"
#import "HTMLParser.h"
#import "HTMLNode.h"

@interface InfoViewController ()

@end

@implementation InfoViewController
@synthesize textView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSError *error;
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://lknovel.lightnovel.cn/main/vollist/332.html"]];
    NSDate *startTime = [NSDate new];
    HTMLParser *parser = [[HTMLParser alloc] initWithData:data error:&error];
    if (error) {
        NSLog(@"%@", error);
        return;
    }
    NSMutableString *content = [NSMutableString new];
    HTMLNode *bodyNode = [parser body];
    NSLog(@"Body Processing Time: %f", [[NSDate new] timeIntervalSinceDate:startTime]);
    startTime = [NSDate new];
    
    NSArray *linkArray = [bodyNode findChildTags:@"a"];
    for (HTMLNode *linkNode  in linkArray) {
        if ([linkNode getAttributeNamed:@"href"] && [linkNode allContents].length > 0)
            [content appendFormat:@"\n%@ - %@", [linkNode getAttributeNamed:@"href"], [linkNode allContents]];
    }
    
    textView.text = content;
}

@end
