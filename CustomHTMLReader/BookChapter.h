//
//  BookChapter.h
//  CustomHTMLReader
//
//  Created by Craig Zheng on 6/10/2014.
//  Copyright (c) 2014 cz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BookInfo.h"

@interface BookChapter : NSObject
@property BookInfo *parentBookInfo;
@property NSString *chapterName;
@property NSURL *linkToChapter;
@property NSArray *chapterContent;

-(BOOL)isCompleted;
@end
