//
//  CustomHTMLReaderTests.m
//  CustomHTMLReaderTests
//
//  Created by Craig Zheng on 29/09/2014.
//  Copyright (c) 2014 cz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "BookDownloader.h"
#import "BookParser.h"
#import "CommonSettings.h"

@interface CustomHTMLReaderTests : XCTestCase <BookDownloaderDelegate>
@property NSString *pathToIndexSeriesData;
@property NSString *pathToAllSeriesData;
@property BookInfo *completedBookInfo;
@property BookChapter *bookChapter;
@property BOOL downloadComplete;
@property NSInteger count;
@property NSArray *allBooks;
@property NSArray *indexBooks;
@end

@implementation CustomHTMLReaderTests
@synthesize pathToIndexSeriesData;
@synthesize pathToAllSeriesData;
@synthesize bookChapter;
@synthesize downloadComplete;
@synthesize completedBookInfo;
@synthesize allBooks;
@synthesize indexBooks;
@synthesize count;

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    downloadComplete = NO;
    NSString* path = [NSSearchPathForDirectoriesInDomains(
                                                          NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    pathToIndexSeriesData = [path stringByAppendingPathComponent:@"indexSeries.dat"];
    pathToAllSeriesData = [path stringByAppendingPathComponent:@"allSeries.dat"];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}



- (void)testBookParserForIndexSeries {
    //check local cache for data
    NSData *data = [NSData dataWithContentsOfFile:pathToIndexSeriesData];
    if (!data) {
        data = [NSData dataWithContentsOfURL:[CommonSettings indexURL]];
        if (data) {
            [data writeToFile:pathToIndexSeriesData atomically:YES];
        } else return;
    }
    NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);

    BookParser *parser = [BookParser new];
    NSArray *bookList = [parser parseIndexSeriesBookListData:data];
    NSLog(@"%@\n%@", [bookList firstObject], [bookList lastObject]);
    XCTAssert(bookList.count > 0, @"Parse Result is empty");
}

-(void)testBookParserForAllSeries {
    //check cache
    NSData *data = [NSData dataWithContentsOfFile:pathToAllSeriesData];
    if (!data) {
        data = [NSData dataWithContentsOfURL:[CommonSettings allSeriesURL]];
        if (data) {
            [data writeToFile:pathToAllSeriesData atomically:YES];
        } else return;
    }

    BookParser *parser = [BookParser new];
    NSArray *bookList = [parser parseAllSereisBookListData:data];
//    for (BookInfo *bk in bookList) {
//        NSLog(@"%@", bk);
//    }
    NSLog(@"%@\n%@", [bookList firstObject], [bookList lastObject]);
    XCTAssert(bookList.count > 0, @"Parse Result is empty");
}

-(void)testBookDownloaderForIndexSeries {
    BookDownloader *downloader = [BookDownloader new];
    downloader.delegate = self;
    downloadComplete = NO;
    indexBooks = nil;
    [downloader downloadIndexSeries];
    count = 0;
    while (!downloadComplete && count <= 5) {
        [NSThread sleepForTimeInterval:1.0];
        count ++;
    }
    XCTAssert(indexBooks.count > 0, @"Downloaded Index Series is empty");
    XCTAssert([indexBooks.firstObject bookName].length > 0, @"First object has no name");
    XCTAssert([indexBooks.lastObject bookName].length > 0, @"Last object has no name");

}

-(void)testBookInfoCreateCopy {
    BookInfo *originalBook = [BookInfo new];
    originalBook.bookName = @"1235";
    originalBook.bookCoverImage = [NSURL URLWithString:@"http://www.baidu.com"];
    originalBook.views = 50;
    originalBook.linkToBook = [NSURL URLWithString:@"http://www.google.com"];
    BookInfo *copiedBook = [originalBook createCopy];
    XCTAssertEqualObjects(originalBook.bookName, copiedBook.bookName);
    XCTAssertEqualObjects(originalBook.linkToBook, copiedBook.linkToBook);
}

-(void)testBookDownloaderForAllSeries {
    BookDownloader *downloader = [BookDownloader new];
    downloader.delegate = self;
    downloadComplete = NO;
    allBooks = nil;
    [downloader downloadAllSeries];
    count = 0;
    while (!downloadComplete && count <= 0) {
        [NSThread sleepForTimeInterval:1.];
        count ++;
    }
    XCTAssert([allBooks.firstObject bookName].length > 0, @"First object has no name");
    XCTAssert([allBooks.lastObject bookName].length > 0, @"Last object has no name");

}

-(void)testBookDownloaderForCompleteBookInfo {
    BookInfo *bookInfo = [BookInfo new];
    bookInfo.linkToBook = [NSURL URLWithString:@"http://lknovel.lightnovel.cn/main/vollist/183.html"];
    BookDownloader *downloader = [BookDownloader new];
    downloader.delegate = self;
    downloadComplete = NO;
    count = 0;
    [downloader completeBookInfo:bookInfo];
    while (!downloadComplete && count <= 5) {
        [NSThread sleepForTimeInterval:1.];
        count ++;
    }
    XCTAssert([completedBookInfo isCompleted], @"Bookinfo not completed");
}

-(void)testBookDownloaderForCompletedBookChapter {
    bookChapter = [BookChapter new];
    bookChapter.linkToChapter = [NSURL URLWithString:@"http://lknovel.lightnovel.cn/main/view/20666.html"];
    BookDownloader *downloader = [BookDownloader new];
    downloader.delegate = self;
    downloadComplete = NO;
    count = 0;
    [downloader downloadChapter:bookChapter];
    while (!downloadComplete && count <= 8) {
        [NSThread sleepForTimeInterval:1.];
        count ++;
    }
    XCTAssert(bookChapter.chapterContent.count > 0, @"Chapter content after parsing is empty");
}

#pragma mark - BookDownloaderDelegate
-(void)indexSeriesDownloaded:(NSArray *)indexSeries {
    downloadComplete = YES;
    XCTAssert(indexSeries.count > 0, @"Downloaded Index Series is empty");
    indexBooks = indexSeries;
}

-(void)allSeriesDownloaded:(NSArray *)allSeries {
    downloadComplete = YES;
    XCTAssert(allSeries.count > 0, @"Download of all series returned empty result");
    allBooks = allSeries;
}

-(void)bookInfoCompleted:(BookInfo *)bInfo successful:(BOOL)success {
    XCTAssertTrue(success, @"Failed to complete book info");
    completedBookInfo = bInfo;
}

-(void)chapterContentDownloadedForChapter:(BookChapter *)chapter {
    bookChapter = chapter;
    downloadComplete = YES;
}
@end
