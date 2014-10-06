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
#import "ChapterContentViewController.h"

#import "UIImageView+WebCache.h"

@interface BookInfoViewController () <BookDownloaderDelegate, UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate>
@property BookDownloader *downloader;
@property BookInfoHeaderViewController *headerViewController;
@property BookVolume *selectedBookVolume;
@property BookChapter *selectedChapter;
@property NSIndexPath *selectedIndexPath;
@end

@implementation BookInfoViewController
@synthesize myBookInfo;
@synthesize downloader;
@synthesize headerContainerView;
@synthesize headerViewController;
@synthesize selectedIndexPath;
@synthesize volumeListTableView;
@synthesize selectedBookVolume;
@synthesize selectedChapter;

static NSString *cellIdentifier = @"volume_cell_identifier";

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
    [self presentChapterContentViewControllerWithBookChapter:chapter];
}

-(void)reloadCollectionDataInMainThread {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.volumeListTableView reloadData];
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
        selectedChapter = [selectedBookVolume.chapters objectAtIndex:buttonIndex];
        if ([selectedChapter isCompleted]) {
            [self presentChapterContentViewControllerWithBookChapter:selectedChapter];
        } else
            [downloader downloadChapter:selectedChapter];
    }
}

-(void)presentChapterContentViewControllerWithBookChapter:(BookChapter*)chapter {
    selectedChapter = chapter;
    ChapterContentViewController *contentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"chapter_content_view_controller"];
    contentViewController.myBookChapter = chapter;
    [self.navigationController pushViewController:contentViewController animated:YES];
}

#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return myBookInfo.volumes.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (cell) {
        BookVolume *bVolume = [myBookInfo.volumes objectAtIndex:indexPath.row];
        UIImageView *coverImageView = (UIImageView*) [cell.contentView viewWithTag:1];
        UILabel *titleLabel = (UILabel*) [cell.contentView viewWithTag:2];
        
        [coverImageView sd_setImageWithURL:bVolume.volumeCoverImage placeholderImage:nil];
        titleLabel.text = bVolume.volumeName;
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return tableView.rowHeight;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

#pragma mark - UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    selectedIndexPath = indexPath;
    selectedBookVolume = [myBookInfo.volumes objectAtIndex:selectedIndexPath.row];
    if (![selectedBookVolume isCompleted])
        [downloader completeChapterInfo:selectedBookVolume];
    else
        [self presentActionSheetWithBookVolume:selectedBookVolume];
}

#pragma mark - PrepareForSegue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"go_chapter_view_controller"] && [segue.destinationViewController isKindOfClass:[ChapterContentViewController class]]) {
        ChapterContentViewController *incomingViewController = (ChapterContentViewController*) segue.destinationViewController;
        incomingViewController.myBookChapter = selectedChapter;
    }
}

@end
