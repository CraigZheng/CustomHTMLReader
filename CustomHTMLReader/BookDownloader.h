//
//  BookDownloader.h
//  CustomHTMLReader
//
//  Created by Craig Zheng on 5/10/2014.
//  Copyright (c) 2014 cz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "BookInfo.h"
#import "BookParser.h"
#import "BookVolume.h"
#import "CommonSettings.h"

@protocol BookDownloaderDelegate <NSObject>
-(void)indexSeriesDownloaded:(NSArray*)indexSeries;
-(void)allSeriesDownloaded:(NSArray*)allSeries;
-(void)bookInfoCompleted:(BookInfo*)bInfo successful:(BOOL)success;
@optional
-(void)chapterListCompleted:(BookVolume*)bVolume successful:(BOOL)success;
-(void)chapterContentDownloadedForChapter:(BookChapter*)chapter;
@end
@interface BookDownloader : NSObject
@property id<BookDownloaderDelegate> delegate;

-(void)downloadAllSeries;
-(void)downloadIndexSeries;
-(void)completeBookInfo:(BookInfo*)bInfo; //many book info won't be completed after downloaded for the 1st time, this method will find and fill all the missing parts
-(void)completeChapterInfo:(BookVolume*)bVolume;
-(void)downloadChapter:(BookChapter*)chapter;
-(void)cancel;
@end
