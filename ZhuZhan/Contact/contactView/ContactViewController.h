//
//  ContactViewController.h
//  ZhuZhan
//
//  Created by 汪洋 on 14-8-5.
//  Copyright (c) 2014年 zpzchina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XHPathCover.h"
#import "ACTimeScroller.h"
#import "ShowViewController.h"


@interface ContactViewController : UITableViewController<ACTimeScrollerDelegate,XHPathCoverDelegate,showControllerDelegate>{
    NSMutableArray *_datasource;
    ACTimeScroller *_timeScroller;
     NSMutableArray *chooseArray ;
    
}
@property (nonatomic, strong) XHPathCover *pathCover;
@property (nonatomic,strong) NSArray *comments;
@property (nonatomic,strong) ShowViewController *panVC;

@end
