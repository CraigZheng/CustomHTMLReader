//
//  BookParser.h
//  CustomHTMLReader
//
//  Created by Craig Zheng on 5/10/2014.
//  Copyright (c) 2014 cz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BookInfo.h"
#import "BookVolume.h"
#import "BookChapter.h"
#import "HTMLNode.h"
#import "HTMLParser.h"

@interface BookParser : NSObject
-(NSArray*)parseIndexSeriesBookListData:(NSData*)lData;
-(NSArray*)parseAllSereisBookListData:(NSData*)lData;
//-(NSArray*)parseBookVolumeListData:(NSData*)lData;
-(BookInfo*)parseBookInfoWithIndexSeriesHTMLNode:(HTMLNode*)bNode;
-(BookInfo*)parseBookInfoWithCompletedHTMLNode:(HTMLNode*)bNode forBookInfo:(BookInfo*)bInfo;
-(BookVolume*)parseBookVolumeWithCompletedHTMLNode:(HTMLNode*)vNode forBookVolume:(BookVolume*)bVolume;
-(BookChapter*)parserChapterContentWithCompletedHTMLNode:(HTMLNode*)cNode forBookChapter:(BookChapter*)bChapter;
@end
