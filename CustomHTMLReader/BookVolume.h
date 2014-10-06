//
//  BookVolume.h
//  CustomHTMLReader
//
//  Created by Craig Zheng on 5/10/2014.
//  Copyright (c) 2014 cz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BookInfo.h"

@interface BookVolume : BookInfo
@property NSString *volumeName;
@property NSURL *linkToVolume;
@property NSURL *volumeCoverImage;
@property NSArray *chapters;
@end
