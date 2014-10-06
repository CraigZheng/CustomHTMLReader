//
//  VolumnViewController.m
//  CustomHTMLReader
//
//  Created by Craig Zheng on 29/09/2014.
//  Copyright (c) 2014 cz. All rights reserved.
//

#import "VolumnViewController.h"
#import "HTMLNode.h"
#import "HTMLParser.h"

@interface VolumnViewController ()

@end

@implementation VolumnViewController
@synthesize textView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSError *error;
    HTMLParser *parser = [[HTMLParser alloc] initWithContentsOfURL:[NSURL URLWithString:@"http://lknovel.lightnovel.cn/main/book/1127.html"] error:&error];
    
    HTMLNode *bodyNode = [parser body];
    NSMutableString *content = [NSMutableString new];
    
    [content appendFormat:@"%@", [[bodyNode allContents] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    textView.text = content;
}
@end
