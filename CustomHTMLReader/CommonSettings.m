//
//  CommonSettings.m
//  CustomHTMLReader
//
//  Created by Craig Zheng on 5/10/2014.
//  Copyright (c) 2014 cz. All rights reserved.
//

#import "CommonSettings.h"

@implementation CommonSettings

+(NSString *)lnHost {
    return @"http://lknovel.lightnovel.cn/";
}

+(NSString *)lnImageHost {
    return [self lnHost];
}

+(NSURL *)indexURL {
    return [NSURL URLWithString:@"http://lknovel.lightnovel.cn/"];
}

+(NSURL *)allSeriesURL {
    return [NSURL URLWithString:@"http://lknovel.lightnovel.cn/main/series_index.html"];
}

#warning SHOULD ALLOW REMOTE CONFIGURATION IN THE FUTURE
+(NSString *)indexBookBlock {
    return @"lk-block";
}

+(NSString *)bookInfoKeyword {
    return @"vollist";
}

+(NSString*)bookVolumeKeyword {
    return @"book";
}

+(NSString *)bookChapterKeyword {
    return @"view";
}

+(NSString *)contentLineKeyword {
    return @"lk-view-line";
}

+(NSString *)contentImageURLKeyword {
    return @"lk-view-img";
}

+(NSString *)libraryPath {
    NSString* path = [NSSearchPathForDirectoriesInDomains(
                                                          NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return path;
}
@end
