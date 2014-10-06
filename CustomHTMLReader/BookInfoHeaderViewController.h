//
//  BookInfoHeaderViewController.h
//  CustomHTMLReader
//
//  Created by Craig Zheng on 6/10/2014.
//  Copyright (c) 2014 cz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookInfo.h"

@interface BookInfoHeaderViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;

@property BookInfo *myBookInfo;

@end
