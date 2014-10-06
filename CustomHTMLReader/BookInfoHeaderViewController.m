//
//  BookInfoHeaderViewController.m
//  CustomHTMLReader
//
//  Created by Craig Zheng on 6/10/2014.
//  Copyright (c) 2014 cz. All rights reserved.
//

#import "BookInfoHeaderViewController.h"
#import "UIImageView+WebCache.h"

@interface BookInfoHeaderViewController ()

@end

@implementation BookInfoHeaderViewController
@synthesize coverImageView;
@synthesize myBookInfo;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, 150); //150 as the height
    [coverImageView sd_setImageWithURL:myBookInfo.coverImage placeholderImage:nil]; //placebo image might be a plus in the future
}

@end
