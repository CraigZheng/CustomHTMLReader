//
//  ChapterContentViewController.m
//  CustomHTMLReader
//
//  Created by Craig Zheng on 6/10/2014.
//  Copyright (c) 2014 cz. All rights reserved.
//

#import "ChapterContentViewController.h"
#import "UIImageView+WebCache.h"

@interface ChapterContentViewController () <UITableViewDataSource, UITableViewDelegate>
@property NSMutableDictionary *imageSizeForURL;
@property CGPoint contentOffSet;
@end

@implementation ChapterContentViewController
@synthesize myBookChapter;
@synthesize contentTableView;
@synthesize imageSizeForURL;
@synthesize contentOffSet;

static NSString *textLineIdentifier = @"text_line_identifier";
static NSString *imgLineIdentifier = @"image_line_identifier";


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    imageSizeForURL = [NSMutableDictionary new];
}

#pragma mark - UITableViewDataSource
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    id content = [myBookChapter.chapterContent objectAtIndex:indexPath.row];
    if ([content isKindOfClass:[NSString class]]) {
        cell = [tableView dequeueReusableCellWithIdentifier:textLineIdentifier];
        
        UITextView *contentTextView = (UITextView*) [cell.contentView viewWithTag:1];
        contentTextView.text = content;
    } else if ([content isKindOfClass:[NSURL class]]) {
        cell = [tableView dequeueReusableCellWithIdentifier:imgLineIdentifier];
        UIImageView *imgView = (UIImageView*) [cell.contentView viewWithTag:1];
        [imgView sd_setImageWithPreviousCachedImageWithURL:content andPlaceholderImage:nil options:2 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            NSValue *size = [NSValue valueWithCGSize:image.size];
            [imageSizeForURL setObject:size forKey:imageURL.absoluteString];
            if (cacheType == SDImageCacheTypeNone)
                [contentTableView reloadData];
        }];
        
//        BOOL imgExists = [[SDWebImageManager sharedManager] cachedImageExistsForURL:content];
//        if (imgExists) {
//        } else {
//            [imgView sd_setImageWithURL:content completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//                NSValue *size = [NSValue valueWithCGSize:image.size];
//                [imageSizeForURL setObject:size forKey:imageURL.absoluteString];
//            }];
//        }
    }
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
        height = 40;
        SDWebImageManager *imageManager = [SDWebImageManager sharedManager];
        if ([imageManager cachedImageExistsForURL:content]) {
            NSString *filePath = [imageManager.imageCache defaultCachePathForKey:[imageManager cacheKeyForURL:content]];
            UIImage *tempImage = [UIImage imageWithContentsOfFile:filePath];
            CGFloat ratio = tempImage.size.height / tempImage.size.width;
            height = self.view.frame.size.width * ratio;
        }
    }
    return MAX(height, tableView.rowHeight);
}

@end
