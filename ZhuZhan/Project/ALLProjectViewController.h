//
//  ALLProjectViewController.h
//  ZhuZhan
//
//  Created by 孙元侃 on 15/3/25.
//
//

#import <UIKit/UIKit.h>
#import "LoadingView.h"
#import "ProjectTableViewCell.h"

@interface ALLProjectViewController : UITableViewController<ProjectTableViewCellDelegate>{
    NSMutableArray *showArr;
    int startIndex;
    LoadingView *loadingView;
    int sectionHeight;
    BOOL isReload;
}

@end
