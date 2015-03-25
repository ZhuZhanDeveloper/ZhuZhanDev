//
//  ALLProjectViewController.m
//  ZhuZhan
//
//  Created by 孙元侃 on 15/3/25.
//
//

#import "ALLProjectViewController.h"
#import "AppDelegate.h"
#import "HomePageViewController.h"
#import "ProjectApi.h"
#import "ProgramDetailViewController.h"
#import "UIScrollView+MJRefresh.h"
@interface ALLProjectViewController ()

@end

@implementation ALLProjectViewController
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //恢复tabBar
    AppDelegate* app=[AppDelegate instance];
    HomePageViewController* homeVC=(HomePageViewController*)app.window.rootViewController;
    [homeVC homePageTabBarRestore];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //    //隐藏tabBar
    AppDelegate* app=[AppDelegate instance];
    HomePageViewController* homeVC=(HomePageViewController*)app.window.rootViewController;
    [homeVC homePageTabBarHide];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    [self initNavi];
    startIndex = 0;
    isReload = NO;
    showArr = [[NSMutableArray alloc] init];
    
    self.tableView.backgroundColor = RGBCOLOR(239, 237, 237);
    self.tableView.separatorStyle = NO;
    //集成刷新控件
    [self setupRefresh];
    [self firstNetWork];
}

- (void)setupRefresh
{
    // 1.下拉刷新(进入刷新状态就会调用self的headerRereshing)
    [self.tableView addHeaderWithTarget:self action:@selector(headerRereshing)];
    [self.tableView addFooterWithTarget:self action:@selector(footerRereshing)];
}

#pragma mark 开始进入刷新状态
- (void)headerRereshing
{
    [ProjectApi GetListWithBlock:^(NSMutableArray *posts, NSError *error) {
        if(!error){
            startIndex = 0;
            [showArr removeAllObjects];
            showArr = posts;
            isReload = NO;
            if(showArr.count == 0){
                [MyTableView reloadDataWithTableView:self.tableView];
                [MyTableView hasData:self.tableView];
            }else{
                [MyTableView removeFootView:self.tableView];
                [self.tableView reloadData];
            }
        }else{
            [LoginAgain AddLoginView:NO];
        }
        [self.tableView headerEndRefreshing];
    }startIndex:0 noNetWork:^{
        [self.tableView headerEndRefreshing];
        [ErrorView errorViewWithFrame:CGRectMake(0, 64, 320, 568-64) superView:self.view reloadBlock:^{
            [self headerRereshing];
        }];
    }];
    [self.tableView addFooterWithTarget:self action:@selector(footerRereshing)];
}

- (void)footerRereshing
{
    [ProjectApi GetListWithBlock:^(NSMutableArray *posts, NSError *error) {
        if(!error){
            startIndex++;
            [showArr addObjectsFromArray:posts];
            if(showArr.count == 0){
                [MyTableView reloadDataWithTableView:self.tableView];
                [MyTableView hasData:self.tableView];
            }else{
                [MyTableView removeFootView:self.tableView];
                [self.tableView reloadData];
            }
        }else{
            [LoginAgain AddLoginView:NO];
        }
        [self.tableView footerEndRefreshing];
    }startIndex:startIndex+1 noNetWork:^{
        [self.tableView footerEndRefreshing];
        [ErrorView errorViewWithFrame:CGRectMake(0, 64, 320, 568-64) superView:self.view reloadBlock:^{
            [self footerRereshing];
        }];
    }];
}

-(void)firstNetWork{
    self.tableView.scrollEnabled = NO;
    sectionHeight = 0;
    loadingView = [LoadingView loadingViewWithFrame:CGRectMake(0, 0, 320, 568) superView:self.view];
    [ProjectApi GetListWithBlock:^(NSMutableArray *posts, NSError *error) {
        if(!error){
            showArr = posts;
            sectionHeight = 50;
            isReload = NO;
            if(showArr.count == 0){
                [MyTableView reloadDataWithTableView:self.tableView];
                [MyTableView hasData:self.tableView];
            }else{
                [MyTableView removeFootView:self.tableView];
                [self.tableView reloadData];
            }
            [LoadingView removeLoadingView:loadingView];
            self.tableView.scrollEnabled = YES;
            loadingView = nil;
        }else{
            //[LoginAgain AddLoginView];
        }
    } startIndex:startIndex noNetWork:^{
        self.tableView.scrollEnabled = NO;
        [LoadingView removeLoadingView:loadingView];
        loadingView = nil;
        [ErrorView errorViewWithFrame:CGRectMake(0, 64, 320, 568-64) superView:self.view reloadBlock:^{
            self.tableView.scrollEnabled = YES;
            [self firstNetWork];
        }];
    }];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return showArr.count;
}

//push去展示页前将tabbar隐藏
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ProgramDetailViewController* vc=[[ProgramDetailViewController alloc]init];
    projectModel *model = showArr[indexPath.row];
    vc.projectId = model.a_id;
    vc.isFocused = model.isFocused;
    [self.navigationController pushViewController:vc animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [NSString stringWithFormat:@"ProjectTableViewCell"];
    ProjectTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    projectModel *model = showArr[indexPath.row];
    if(!cell){
        cell = [[ProjectTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier model:model fromView:@"project"];
    }
    cell.indexRow=indexPath.row;
    cell.delegate = self;
    cell.model = model;
    cell.selectionStyle = NO;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 290;
}
-(void)addProjectCommentView:(int)index{
    projectModel *model = showArr[index];
    PorjectCommentTableViewController *projectCommentView = [[PorjectCommentTableViewController alloc] init];
    projectCommentView.projectId = model.a_id;
    projectCommentView.projectName = model.a_projectName;
    [self.navigationController pushViewController:projectCommentView animated:YES];
}
-(void)initNavi{
    UIButton* button=[[UIButton alloc]initWithFrame:CGRectMake(0,5,25,22)];
    [button setImage:[GetImagePath getImagePath:@"013"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:button];
    self.navigationItem.title=@"全部项目";
}

-(void)back{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
