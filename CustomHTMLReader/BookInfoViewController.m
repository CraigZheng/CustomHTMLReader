//
//  BookInfoViewController.m
//  CustomHTMLReader
//
//  Created by Craig Zheng on 6/10/2014.
//  Copyright (c) 2014 cz. All rights reserved.
//

#import "BookInfoViewController.h"
#import "BookInfoHeaderViewController.h"
#import "BookDownloader.h"
#import "UIImageView+WebCache.h"

@interface BookInfoViewController () <BookDownloaderDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UIActionSheetDelegate>
@property BookDownloader *downloader;
@property BookInfoHeaderViewController *headerViewController;
@property NSIndexPath *selectedIndexPath;
@end

@implementation BookInfoViewController
@synthesize myBookInfo;
@synthesize downloader;
@synthesize headerContainerView;
@synthesize headerViewController;
@synthesize volumesCollectionView;
@synthesize selectedIndexPath;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (![myBookInfo isCompleted]) {
        downloader = [BookDownloader new];
        downloader.delegate = self;
        [downloader completeBookInfo:myBookInfo];
    }
    [self presentMyBookInfo];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [downloader cancel];
}

-(void)presentMyBookInfo {
    self.title = myBookInfo.bookName;
    NSLog(@"%@", myBookInfo);
    //add header view to self
    if (!headerViewController) {
        headerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"bookInfoHeaderViewController"];
        [self addChildViewController:headerViewController];
    }
    headerViewController.myBookInfo = myBookInfo;
    for (UIView* view in headerContainerView.subviews) {
        [view removeFromSuperview];
    }
    CGRect headerFrame = headerViewController.view.frame;
    headerFrame.size.width = headerContainerView.frame.size.width;
    headerFrame.size.height = headerContainerView.frame.size.height;
    headerViewController.view.frame = headerFrame;
    [headerContainerView addSubview:headerViewController.view];

    [self reloadCollectionDataInMainThread];
}

#pragma mark - BookDownloaderDelegate
-(void)bookInfoCompleted:(BookInfo *)bInfo successful:(BOOL)success {
    if (success) {
        myBookInfo = bInfo;
    }
    [self presentMyBookInfo];
}

-(void)indexSeriesDownloaded:(NSArray *)indexSeries {
    
}

-(void)allSeriesDownloaded:(NSArray *)allSeries {
    
}

-(void)chapterListCompleted:(BookVolume *)bVolume successful:(BOOL)success {
    if (success) {
        
    }
    [self presentMyBookInfo];
    [self presentActionSheetWithBookVolume:bVolume];
}

-(void)chapterContentDownloadedForChapter:(BookChapter *)chapter {
    NSLog(@"");
}

-(void)reloadCollectionDataInMainThread {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.volumesCollectionView reloadData];
    });
}

-(void)presentActionSheetWithBookVolume:(BookVolume*)bVolume {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Open..." delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles: nil];
    for (BookChapter *chapter in bVolume.chapters) {
        [actionSheet addButtonWithTitle:[NSString stringWithFormat:@"%@", chapter.chapterName]];
    }
    [actionSheet showInView:self.view];
}

#pragma mark - UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != actionSheet.cancelButtonIndex && [actionSheet.title isEqualToString:@"Open..."]) {
        NSLog(@"Clicked %@", [actionSheet buttonTitleAtIndex:buttonIndex]);
    }
}

#pragma mark - UICollectionViewDataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return myBookInfo.volumes.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"volume_cover_cell_identifier";
    UICollectionViewCell *cell = [volumesCollectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    if (cell) {
        BookVolume *volume = [myBookInfo.volumes objectAtIndex:indexPath.row];
//        NSLog(@"%@", volume);
        UIImageView *coverImageView = (UIImageView*) [cell viewWithTag:1];
        UILabel *titleLabel = (UILabel*) [cell viewWithTag:2];
        
        titleLabel.text = volume.volumeName;
        [coverImageView sd_setImageWithURL:volume.volumeCoverImage placeholderImage:nil];
    }
    return cell;
}

#pragma mark - UICollectionViewDelegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    selectedIndexPath = indexPath;
    BookVolume *selectedBookVolume = [myBookInfo.volumes objectAtIndex:selectedIndexPath.row];
    if (![selectedBookVolume isCompleted])
        [downloader completeChapterInfo:selectedBookVolume];
    else
        [self presentActionSheetWithBookVolume:selectedBookVolume];
}
@end
