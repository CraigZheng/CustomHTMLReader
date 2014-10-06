//
//  BookDownloader.m
//  CustomHTMLReader
//
//  Created by Craig Zheng on 5/10/2014.
//  Copyright (c) 2014 cz. All rights reserved.
//

#import "BookDownloader.h"

@interface BookDownloader () <NSURLConnectionDataDelegate>
@property NSURLConnection *booklistUrlConnection; //for downloading a list of bookinfo
@property NSURLConnection *bookInfoUrlConnection; //for downloading each individual bookinfo
@property NSURLConnection *bookChapterUrlConnection; //for downloading a list of chapter
@property NSURLConnection *chapterContentUrlConnection; //for downloading content of a chapter
@property NSMutableData *receivedData;
@property NSURL *currentTargetURL;
@property BookInfo *incompletedBookInfo;
@property BookVolume *incompletedBookVolume;
@property BookChapter *incompletedBookChapter;
@property NSString *debugIndexDataPath;
@property NSString *debugAllSeriesDataPath;
@property NSString *debugBookInfoDataPath;
@property NSString *debugChapterContentDataPath;
@end;

@implementation BookDownloader
@synthesize booklistUrlConnection;
@synthesize bookInfoUrlConnection;
@synthesize bookChapterUrlConnection;
@synthesize chapterContentUrlConnection;
@synthesize receivedData;
@synthesize delegate;
@synthesize currentTargetURL;
@synthesize incompletedBookInfo;
@synthesize incompletedBookVolume;
@synthesize incompletedBookChapter;
@synthesize debugAllSeriesDataPath;
@synthesize debugIndexDataPath;
@synthesize debugBookInfoDataPath;
@synthesize debugChapterContentDataPath;

-(instancetype)init {
    self = [super init];
    if (self) {
        debugIndexDataPath = [[CommonSettings libraryPath] stringByAppendingPathComponent:@"indexSeries.dat"];
        debugAllSeriesDataPath = [[CommonSettings libraryPath] stringByAppendingPathComponent:@"allSeries.dat"];
        debugBookInfoDataPath = [[CommonSettings libraryPath] stringByAppendingPathComponent:@"bookInfo.dat"];
        debugChapterContentDataPath = [[CommonSettings libraryPath] stringByAppendingPathComponent:@"chapterContent.dat"];
    }
    return self;
}

-(void)completeBookInfo:(BookInfo *)bInfo {
    if ([bInfo isCompleted]) {
        [delegate bookInfoCompleted:bInfo successful:YES];
        return;
    }
    incompletedBookInfo = bInfo;
//#ifdef DEBUG
//    NSMutableData *cachedData = [NSMutableData dataWithContentsOfFile:debugBookInfoDataPath];
//    if (cachedData) {
//        NSLog(@"DEBUG - USE CACHE DATA FOR %@", NSStringFromSelector(_cmd));
//        [self parseBookInfoAndNotifyDelegate:cachedData];
//        return;
//    }
//#endif
    if (bInfo.linkToBook) {
        [self cancel];
        bookInfoUrlConnection = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:bInfo.linkToBook] delegate:self startImmediately:YES];
    } else {
        [AppDelegate raiseException:@"Link Empty" withSelector:_cmd];
    }
}

-(void)completeChapterInfo:(BookVolume *)bVolume {
    [self cancel];
    if (!bVolume.linkToVolume) {
        [AppDelegate raiseException:@"Empty linkToVolume" withSelector:_cmd];
        return;
    }
    incompletedBookVolume = bVolume;
    bookChapterUrlConnection = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:bVolume.linkToVolume] delegate:self startImmediately:YES];
}

/**
 Download chapter content for a certain chapter. Content could be either text or a URL to an image.
 */
-(void)downloadChapter:(BookChapter *)chapter {
    [self cancel];
    incompletedBookChapter = chapter;
    if (chapter.linkToChapter) {
//#ifdef DEBUG
//        chapter.linkToChapter = [NSURL URLWithString:@"http://lknovel.lightnovel.cn/main/view/44192.html"];
//        NSMutableData *cachedData = [NSMutableData dataWithContentsOfFile:debugChapterContentDataPath];
//        if (cachedData) {
//            NSLog(@"DEBUG - USE CACHED DATA FOR CHAPTER CONTENT");
//            [self parseChapterContentAndNotifyDelegate:cachedData];
//            return;
//        }
//#endif
        chapterContentUrlConnection = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:chapter.linkToChapter] delegate:self startImmediately:YES];
    } else {
        NSLog(@"Unable to download content for chapter: %@, missing link", chapter);
    }
}

-(void)downloadIndexSeries {
    [self downloadTargetURL:[CommonSettings indexURL]];
}

-(void)downloadAllSeries {
    [self downloadTargetURL:[CommonSettings allSeriesURL]];
}

-(void)downloadTargetURL:(NSURL*)target {
    [self cancel];
    currentTargetURL = target;
#ifdef DEBUG
    NSString *cacheDataPath;
    if ([currentTargetURL isEqual:[CommonSettings indexURL]]) {
        cacheDataPath = debugIndexDataPath;
    } else if ([currentTargetURL isEqual:[CommonSettings allSeriesURL]]) {
        cacheDataPath = debugAllSeriesDataPath;
    }
    NSMutableData *cachedData = [NSMutableData dataWithContentsOfFile: cacheDataPath];
    if (cachedData) {
        NSLog(@"DEBUG - USE CACHED DATA");
        [self parseBooklistAndNotifyDelegate:cachedData];
        return;
    }
#endif
    booklistUrlConnection = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:currentTargetURL] delegate:self startImmediately:YES];
    NSLog(@"");
}

-(void)cancel {
    if (bookInfoUrlConnection)
        [bookInfoUrlConnection cancel];
    if (booklistUrlConnection)
        [booklistUrlConnection cancel];
    if (bookChapterUrlConnection)
        [bookChapterUrlConnection cancel];
    if (chapterContentUrlConnection)
        [chapterContentUrlConnection cancel];
}

#pragma mark - NSURLConnectionDelegate
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    receivedData = [NSMutableData new];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [receivedData appendData:data];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"%@", error);
    if (delegate) {
        if ([currentTargetURL isEqual:[CommonSettings indexURL]]) {
            [delegate indexSeriesDownloaded:nil];
        } else if ([currentTargetURL isEqual:[CommonSettings allSeriesURL]]) {
            [delegate allSeriesDownloaded:nil];
        }
    }
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
#ifdef DEBUG
    if ([currentTargetURL isEqual:[CommonSettings indexURL]])
        [receivedData writeToFile:debugIndexDataPath atomically:YES];
    if ([currentTargetURL isEqual:[CommonSettings allSeriesURL]])
        [receivedData writeToFile:debugAllSeriesDataPath atomically:YES];
    if (connection == bookInfoUrlConnection)
        [receivedData writeToFile:debugBookInfoDataPath atomically:YES];
    if (connection == chapterContentUrlConnection)
        [receivedData writeToFile:debugChapterContentDataPath atomically:YES];
#endif
    
    if (connection == bookInfoUrlConnection) {
        [self parseBookInfoAndNotifyDelegate:receivedData];
        return;
    }
    if (connection == bookChapterUrlConnection) {
        [self parseBookChapterAndNotifyDelegate:receivedData];
        return;
    }
    if (connection == chapterContentUrlConnection) {
        [self parseChapterContentAndNotifyDelegate:receivedData];
        return;
    }
    [self parseBooklistAndNotifyDelegate:receivedData];
    
}

/**
 parse received data and notify delegate based on current target URL
 */
-(void)parseBooklistAndNotifyDelegate:(NSData*)data {
    NSArray *books = [NSMutableArray new];
    if ([currentTargetURL isEqual:[CommonSettings indexURL]]) {
        books = [[BookParser new] parseIndexSeriesBookListData:data];
        [delegate indexSeriesDownloaded:books];
    } else if ([currentTargetURL isEqual:[CommonSettings allSeriesURL]]) {
        books = [[BookParser new] parseAllSereisBookListData:data];
        [delegate allSeriesDownloaded:books];
    }
}

-(void)parseBookInfoAndNotifyDelegate:(NSData*)data {
    NSError *error;
    BookInfo *completedBook = incompletedBookInfo;
    BookParser *parser = [BookParser new];
    HTMLParser *htmlParser = [[HTMLParser alloc] initWithData:data error:&error];
    completedBook = [parser parseBookInfoWithCompletedHTMLNode:[htmlParser body] forBookInfo:completedBook];
    if (![completedBook isCompleted] || error) {
        [delegate bookInfoCompleted:completedBook successful:NO];
        NSLog(@"%@", error);
        return;
    }
    [delegate bookInfoCompleted:completedBook successful:YES];
}

-(void)parseBookChapterAndNotifyDelegate:(NSData*)data {
    NSError *error;
    BookVolume *completedVolume = incompletedBookVolume;
    BookParser *parser = [BookParser new];
    HTMLParser *htmlParer = [[HTMLParser alloc] initWithData:data error:&error];
    completedVolume = [parser parseBookVolumeWithCompletedHTMLNode:[htmlParer body] forBookVolume:completedVolume];
    if (delegate && [delegate respondsToSelector:@selector(chapterListCompleted:successful:)]) {
        if (error) {
            [delegate chapterListCompleted:completedVolume successful:NO];
        }
        else
            [delegate chapterListCompleted:completedVolume successful:YES];
    }
}

-(void)parseChapterContentAndNotifyDelegate:(NSData*)data {
    NSError *error;
    BookChapter *completedChapter = incompletedBookChapter;
    BookParser *parser = [BookParser new];
    HTMLParser *htmlParser = [[HTMLParser alloc] initWithData:data error:&error];
    completedChapter = [parser parserChapterContentWithCompletedHTMLNode:[htmlParser body] forBookChapter:completedChapter];
    if (delegate && [delegate respondsToSelector:@selector(chapterContentDownloadedForChapter:)]) {
        if (!error) {
            NSLog(@"%@", error);
        }
        [delegate chapterContentDownloadedForChapter:completedChapter];
    }
}
@end
