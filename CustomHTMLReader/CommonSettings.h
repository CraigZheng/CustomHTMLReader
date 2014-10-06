//
//  CommonSettings.h
//  CustomHTMLReader
//
//  Created by Craig Zheng on 5/10/2014.
//  Copyright (c) 2014 cz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommonSettings : NSObject

+(NSString*)lnHost;
+(NSString*)lnImageHost;
+(NSURL*)indexURL;
+(NSURL*)allSeriesURL;
+(NSString*)indexBookBlock;
+(NSString*)bookInfoKeyword;
+(NSString*)bookVolumeKeyword;
+(NSString*)bookChapterKeyword;
+(NSString*)contentLineKeyword;
+(NSString*)contentImageURLKeyword;
+(NSString*)libraryPath;
@end
