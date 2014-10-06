//
//  BookInfoViewController.h
//  CustomHTMLReader
//
//  Created by Craig Zheng on 6/10/2014.
//  Copyright (c) 2014 cz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookInfo.h"
#import "BookVolume.h"

@interface BookInfoViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIView *headerContainerView;
@property (weak, nonatomic) IBOutlet UICollectionView *volumesCollectionView;
@property BookInfo *myBookInfo;

@end
