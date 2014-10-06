//
//  BookInfo.h
//  CustomHTMLReader
//
//  Created by Craig Zheng on 5/10/2014.
//  Copyright (c) 2014 cz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BookInfo : NSObject

@property NSString *bookName;
@property NSString *bookDescription;
@property NSString *author;
@property NSString *illusion;
@property NSString *publisher;
@property NSInteger views;
@property NSDate *updatedAt;

@property NSURL *bookCoverImage;
@property NSURL *linkToBook;
@property NSArray *volumes;

-(BOOL)isCompleted;
-(instancetype)createCopy;
-(void)copyPropertiesTo:(BookInfo*)bInfo;
@end
