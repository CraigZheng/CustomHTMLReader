//
//  AppDelegate.h
//  CustomHTMLReader
//
//  Created by Craig Zheng on 29/09/2014.
//  Copyright (c) 2014 cz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

+(void)raiseException:(NSString*)exception withSelector:(SEL)selector;
@end

