//
//  IndexCollectionViewController.m
//  CustomHTMLReader
//
//  Created by Craig Zheng on 5/10/2014.
//  Copyright (c) 2014 cz. All rights reserved.
//

#import "IndexCollectionViewController.h"
#import "BookInfo.h"
#import "BookDownloader.h"
#import "UIImageView+WebCache.h"
#import "BookInfoViewController.h"

@interface IndexCollectionViewController () <BookDownloaderDelegate>
@property BookDownloader *downloader;
@property NSIndexPath *selectedIndexPath;
@property NSArray *bookinfoList;
@end

@implementation IndexCollectionViewController
@synthesize downloader;
@synthesize bookinfoList;
@synthesize selectedIndexPath;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Do any additional setup after loading the view.
    downloader = [BookDownloader new];
    downloader.delegate = self;
    [downloader downloadIndexSeries];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return bookinfoList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *bookCellIdentifier = @"book_cover_cell_identifier";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:bookCellIdentifier forIndexPath:indexPath];
    
    // Configure the cell
    if (cell) {
        
        BookInfo *info = [bookinfoList objectAtIndex:indexPath.row];
        UIImageView *coverImage = (UIImageView*) [cell viewWithTag:1];
        UILabel *titleLabel = (UILabel*) [cell viewWithTag:2];
        
        titleLabel.text = info.bookName;
        [coverImage sd_setImageWithURL:info.coverImage
                          placeholderImage:nil options:indexPath.row == 0 ? SDWebImageRefreshCached : 0];
    }
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    selectedIndexPath = indexPath;
    [self performSegueWithIdentifier:@"go_book_info_view_controller" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"go_book_info_view_controller"] && [segue.destinationViewController isKindOfClass:[BookInfoViewController class]]) {
        BookInfoViewController *incomingViewController = (BookInfoViewController*) segue.destinationViewController;
        incomingViewController.myBookInfo = [bookinfoList objectAtIndex:selectedIndexPath.row];
    }
}

-(void)reloadCollectionDataInMainThread {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView reloadData];
    });
}

#pragma mark - BookDownloaderDelegate
-(void)indexSeriesDownloaded:(NSArray *)indexSeries {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    bookinfoList = indexSeries;
    [self reloadCollectionDataInMainThread];
}

-(void)allSeriesDownloaded:(NSArray *)allSeries {
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

-(void)bookInfoCompleted:(BookInfo *)bInfo successful:(BOOL)success {
    NSLog(@"%@", NSStringFromSelector(_cmd));
}
@end
