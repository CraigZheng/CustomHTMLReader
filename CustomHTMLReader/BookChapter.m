//
//  BookChapter.m
//  CustomHTMLReader
//
//  Created by Craig Zheng on 6/10/2014.
//  Copyright (c) 2014 cz. All rights reserved.
//

#import "BookChapter.h"

@implementation BookChapter

-(NSString *)description {
    return [NSString stringWithFormat:@"%@: %@ - %@", [super description], self.chapterName, self.linkToChapter.absoluteString];
}
@end
