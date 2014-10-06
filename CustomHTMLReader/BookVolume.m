//
//  BookVolume.m
//  CustomHTMLReader
//
//  Created by Craig Zheng on 5/10/2014.
//  Copyright (c) 2014 cz. All rights reserved.
//

#import "BookVolume.h"

@implementation BookVolume

-(BOOL)isCompleted {
    if (self.bookName && self.linkToBook && self.bookCoverImage) {
        if (self.volumeName && self.linkToVolume && self.volumeCoverImage && self.chapters.count > 0)
            return YES;
    }
    return NO;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"%@ - Volume Name: %@", [super description], self.volumeName];
}
@end
