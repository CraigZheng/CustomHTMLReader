//
//  BookParser.m
//  CustomHTMLReader
//
//  Created by Craig Zheng on 5/10/2014.
//  Copyright (c) 2014 cz. All rights reserved.
//

#import "BookParser.h"
#import "AppDelegate.h"
#import "CommonSettings.h"

@implementation BookParser

-(NSArray *)parseIndexSeriesBookListData:(NSData *)lData {
    NSError *error;
    NSDate *startTime = [NSDate new];
    HTMLParser *parser = [[HTMLParser alloc] initWithData:lData error:&error];
    if (error) {
        NSLog(@"%@", error);
        return nil;
    }
    NSLog(@"Processing Book List Time: %f", [[NSDate new] timeIntervalSinceDate:startTime]);
    
    HTMLNode *bodyNode = [parser body];
    NSArray *bookBlocks = [bodyNode findChildrenOfClass:[CommonSettings indexBookBlock]];
    NSMutableArray *newBooks = [NSMutableArray new];
    for (HTMLNode *bookBlk in bookBlocks) {
        BookInfo *newBook = [self parseBookInfoWithIndexSeriesHTMLNode:bookBlk];
        if (newBook)
            [newBooks addObject:newBook];
    }
    return newBooks;
}

-(NSArray *)parseAllSereisBookListData:(NSData *)lData {
    NSError *error;
    NSDate *startTime = [NSDate new];
    HTMLParser *parser = [[HTMLParser alloc] initWithData:lData error:&error];
    if (error) {
        NSLog(@"%@", error);
        return nil;
    }
    NSLog(@"Processing Book List Time: %f", [[NSDate new] timeIntervalSinceDate:startTime]);
    
    HTMLNode *bodyNode = [parser body];
    NSMutableArray *newBooks = [NSMutableArray new];
    for (HTMLNode *aLink in [bodyNode findChildTags:@"a"]) {
        if ([[aLink getAttributeNamed:@"href"] hasPrefix:[CommonSettings lnHost]] && [[aLink getAttributeNamed:@"href"] rangeOfString:[CommonSettings bookInfoKeyword]].location != NSNotFound) {
            BookInfo *newBk = [self parseBookInfoWithAllSeriesHTMLNode:aLink];
            if (newBk)
                [newBooks addObject:newBk];
        }
    }
    return newBooks;
}

-(BookInfo *)parseBookInfoWithAllSeriesHTMLNode:(HTMLNode*)bNode {
    if ([bNode.tagName isEqualToString:@"a"]) {
        BookInfo *newBook = [BookInfo new];
        NSString *link = [bNode getAttributeNamed:@"href"];
        if ([link rangeOfString:[CommonSettings bookInfoKeyword]].location != NSNotFound) {
            newBook.linkToBook = [NSURL URLWithString:link];
            newBook.bookName = [BookParser cleanupString:bNode.allContents];
            return newBook;
        }
    }
    return nil;
}

-(BookInfo *)parseBookInfoWithIndexSeriesHTMLNode:(HTMLNode *)bNode {
    BookInfo *newBook = [BookInfo new];
    NSArray *allLinks = [bNode findChildTags:@"a"];
    HTMLNode *bookLinkNode;
//    NSLog(@"%@", bNode.rawContents);
    for (HTMLNode *linkNode in allLinks) {
        if ([[linkNode getAttributeNamed:@"href"] rangeOfString:[CommonSettings bookInfoKeyword]].location != NSNotFound) {
            bookLinkNode = linkNode;
            break;
        }
    }
    newBook.linkToBook = [NSURL URLWithString:[bookLinkNode getAttributeNamed:@"href"]];
    newBook.bookName = [BookParser cleanupString:[bookLinkNode allContents]];
    HTMLNode *imgNode = [bNode findChildTag:@"img"];
    //check bookname
    if (newBook.bookName.length <= 0)
        newBook.bookName = [imgNode getAttributeNamed:@"alt"];
    //if still no name is given
    if (newBook.bookName.length <= 0)
        newBook.bookName = [BookParser cleanupString:[bNode allContents]];
    newBook.coverImage = [NSURL URLWithString:[imgNode getAttributeNamed:@"data-cover"]];
    if (newBook.linkToBook)
        return newBook;
    return nil;
}

-(BookInfo *)parseBookInfoWithCompletedHTMLNode:(HTMLNode *)bNode forBookInfo:(BookInfo*)bInfo{
    if (bNode && bInfo) {
#warning todo: parse book info
        
        //parse volume info
        NSArray *volumeBlock = [bNode findChildTags:@"dd"];
        NSMutableArray *volumeList = [NSMutableArray new];
        for (HTMLNode *infoNode in volumeBlock) {
            BookVolume *newVolume = [BookVolume new];
            [bInfo copyPropertiesTo:newVolume];
            //assign new properties to newVolume object
            for (HTMLNode *aLink in [infoNode findChildTags:@"a"]) {
                if ([[aLink getAttributeNamed:@"href"] rangeOfString:[CommonSettings bookVolumeKeyword]].location != NSNotFound) {
                    newVolume.linkToVolume = [NSURL URLWithString:[aLink getAttributeNamed:@"href"]];
                    newVolume.volumeName = [BookParser cleanupString:aLink.contents];
                }
            }
            HTMLNode *imgNode = [infoNode findChildTag:@"img"];
            if (imgNode && [imgNode getAttributeNamed:@"src"].length > 0) {
                newVolume.volumeCoverImage = [NSURL URLWithString:[imgNode getAttributeNamed:@"src"]];
            }
            
            [volumeList addObject:newVolume];
        }
        bInfo.volumes = volumeList;
    }
    return bInfo;
}

-(BookVolume *)parseBookVolumeWithCompletedHTMLNode:(HTMLNode *)vNode forBookVolume:(BookVolume *)bVolume{
    if (vNode && bVolume) {
        NSMutableArray *chapterLinks = [NSMutableArray new];
        for (HTMLNode *aNode in [vNode findChildTags:@"a"]) {
            if ([aNode getAttributeNamed:@"href"].length > 0 && [[aNode getAttributeNamed:@"href"] rangeOfString:[CommonSettings bookChapterKeyword]].location != NSNotFound) {
//                NSLog(@"link raw content %@", aNode.rawContents);
                NSURL *cLink = [NSURL URLWithString:[aNode getAttributeNamed:@"href"]];
                NSString *chapterName = [BookParser cleanupString:[aNode allContents]];
                if (cLink) {
                    BookChapter *newChapter = [BookChapter new];
                    newChapter.chapterName = chapterName;
                    newChapter.linkToChapter = cLink;
                    newChapter.parentBookInfo = bVolume;
                    [chapterLinks addObject:newChapter];
                }
            }
        }
        bVolume.chapters = chapterLinks;
    }
    return bVolume;
}

-(BookChapter *)parserChapterContentWithCompletedHTMLNode:(HTMLNode *)cNode forBookChapter:(BookChapter *)bChapter {
    NSMutableArray *parsedContent = [NSMutableArray new];
    for (HTMLNode *lineNode in [cNode findChildrenOfClass:[CommonSettings contentLineKeyword]]) {
//        NSLog(@"%@ - %@", [CommonSettings contentLineKeyword], [BookParser cleanupString:lineNode.rawContents]);
        [parsedContent addObject:[BookParser cleanupString:lineNode.allContents] ? [BookParser cleanupString:lineNode.allContents] : @""];
        if ([lineNode findChildTags:@"img"].count > 0) {
            for (HTMLNode *imgNode in [lineNode findChildTags:@"img"]) {
                NSString *imgSrc = [[CommonSettings lnImageHost] stringByAppendingPathComponent:[imgNode getAttributeNamed:@"data-cover"]];
                NSURL *imgURL = [NSURL URLWithString:imgSrc];
                if (imgURL) {
                    [parsedContent addObject:imgURL];
//                    NSLog(@"%@ - %@", imgNode.className, imgURL.absoluteString);
                }
            }
        }
    }
    return bChapter;
}

+(NSString*)cleanupString:(NSString*)originalString {
    if (originalString.length <= 0)
        return nil;
    NSString *squashed = [originalString stringByReplacingOccurrencesOfString:@"[ ]+"
                                                             withString:@" "
                                                                options:NSRegularExpressionSearch
                                                                  range:NSMakeRange(0, originalString.length)];
    squashed = [squashed stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    squashed = [squashed stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    squashed = [squashed stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    NSString *final = [squashed stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return final;
}
@end
