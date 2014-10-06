//
//  ChapterContentViewController.m
//  CustomHTMLReader
//
//  Created by Craig Zheng on 6/10/2014.
//  Copyright (c) 2014 cz. All rights reserved.
//

#import "ChapterContentViewController.h"

@interface ChapterContentViewController () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation ChapterContentViewController
@synthesize myBookChapter;

static NSString *textLineIdentifier = @"text_line_identifier";
static NSString *imgLineIdentifier = @"image_line_identifier";


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - UITableViewDataSource
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    id content = [myBookChapter.chapterContent objectAtIndex:indexPath.row];
    if ([content isKindOfClass:[NSString class]]) {
        cell = [tableView dequeueReusableCellWithIdentifier:textLineIdentifier];
        
        UITextView *contentTextView = (UITextView*) [cell.contentView viewWithTag:1];
        contentTextView.text = content;
    } else if ([content isKindOfClass:[NSURL class]])
        cell = [tableView dequeueReusableCellWithIdentifier:imgLineIdentifier];
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return myBookChapter.chapterContent.count;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    id content = [myBookChapter.chapterContent objectAtIndex:indexPath.row];
    CGFloat height = tableView.rowHeight;
    if ([content isKindOfClass:[NSString class]]) {
        @autoreleasepool {
            UITextView *hiddenTV = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 1)];
            hiddenTV.hidden = YES;
            [self.view addSubview:hiddenTV];
            hiddenTV.text = content;
            hiddenTV.font = [UIFont systemFontOfSize:14];
            height = [hiddenTV sizeThatFits:CGSizeMake(hiddenTV.frame.size.width, MAXFLOAT)].height;
            [hiddenTV removeFromSuperview];
        }
    } else if ([content isKindOfClass:[NSURL class]]) {
        height = tableView.rowHeight;
    }
    return MAX(height, tableView.rowHeight);
}

#pragma mark - UITableViewDelegate

@end
