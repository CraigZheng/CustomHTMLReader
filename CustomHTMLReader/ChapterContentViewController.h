//
//  ChapterContentViewController.h
//  CustomHTMLReader
//
//  Created by Craig Zheng on 6/10/2014.
//  Copyright (c) 2014 cz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookChapter.h"

@interface ChapterContentViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *contentTableView;

@property BookChapter *myBookChapter;
@end
