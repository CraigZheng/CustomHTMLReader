//
//  BookInfo.m
//  CustomHTMLReader
//
//  Created by Craig Zheng on 5/10/2014.
//  Copyright (c) 2014 cz. All rights reserved.
//

#import "BookInfo.h"
#import "NSObjectUtil.h"

@implementation BookInfo

-(BOOL)isCompleted {
#warning bookDescription not ready
    if (self.bookName && self.linkToBook && self.coverImage /*&& self.bookDescription*/ && self.volumes.count > 0) {
        return YES;
    }
    return NO;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"Name: %@ - Description: %@ - Link: %@ - Img: %@ - %d volumes", self.bookName, self.bookDescription, self.linkToBook.absoluteString, self.coverImage.absoluteString, self.volumes.count];
}

-(instancetype)createCopy {
    BookInfo *newBook = [BookInfo new];
    NSDictionary *properties = [NSObjectUtil classPropsFor:self.class];
    for (NSString *key in properties.allKeys) {
        @try {
            [newBook setValue:[self valueForKey:key] forKey:key];
        }
        @catch (NSException *exception) {
            NSLog(@"%@", exception);
        }
    }
    return newBook;
}

-(void)copyPropertiesTo:(BookInfo*)bInfo {
    NSDictionary *properties = [NSObjectUtil classPropsFor:self.class];
    for (NSString *key in properties.allKeys) {
        @try {
            [bInfo setValue:[self valueForKey:key] forKey:key];
        }
        @catch (NSException *exception) {
            NSLog(@"%@", exception);
        }
    }
}
@end
