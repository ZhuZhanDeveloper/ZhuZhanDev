//
//  ProjectTableViewController.m
//  ZhuZhan
//
//  Created by 汪洋 on 14-8-26.
//
//

#import "ProjectTableViewController.h"
#import "ProjectApi.h"
#import "projectModel.h"
#import "LoginModel.h"
#import "ProjectStage.h"
#import "ProjectTableViewCell.h"
#import "MJRefresh.h"
#import "ConnectionAvailable.h"
#import "MBProgressHUD.h"
#import "ProgramDetailViewController.h"
#import "ErrorView.h"
#import "ProjectSqlite.h"
#import "LocalProjectModel.h"
#import "MyTableView.h"
#import "ALLProjectViewController.h"
@interface ProjectTableViewController ()

@end

@implementation ProjectTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName,[UIFont fontWithName:@"GurmukhiMN-Bold" size:19], NSFontAttributeName,
                                                                     nil]];
    
    //RightButton设置属性
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightButton setFrame:CGRectMake(0, 0, 60, 36.5)];
    //[rightButton setBackgroundImage:[GetImagePath getImagePath:@"项目-首页_03a"] forState:UIControlStateNormal];
    [rightButton setTitle:@"项目专题" forState:UIControlStateNormal];
    rightButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [rightButton addTarget:self action:@selector(rightBtnClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 155, 30)];
    [bgView setBackgroundColor:[UIColor clearColor]];
    UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [searchBtn setFrame:CGRectMake(0, 0, 155, 30)];
    [searchBtn setBackgroundImage:[GetImagePath getImagePath:@"项目-首页_08a"] forState:UIControlStateNormal];
    [searchBtn addTarget:self action:@selector(serachClick) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:searchBtn];
    
    UIImageView *searchImage = [[UIImageView alloc] initWithFrame:CGRectMake(10, 8, 15, 15)];
    [searchImage setImage:[GetImagePath getImagePath:@"搜索结果_09a"]];
    [bgView addSubview:searchImage];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, 120, 30)];
    label.textColor = [UIColor whiteColor];
    label.text = @"寻找项目，发现机会";
    label.font = [UIFont systemFontOfSize:12];
    [bgView addSubview:label];
    self.navigationItem.titleView = bgView;
    
    startIndex = 0;
    isReload = NO;
    showArr = [[NSMutableArray alloc] init];
    
    self.tableView.backgroundColor = RGBCOLOR(239, 237, 237);
    self.tableView.separatorStyle = NO;
    //集成刷新控件
    [self setupRefresh];
    [self firstWork];
}

-(void)firstWork{
    NSMutableArray* localDatas=[ProjectSqlite loadList];
    if (!localDatas.count) {
        self.tableView.scrollEnabled = NO;
        sectionHeight = 0;
        loadingView = [LoadingView loadingViewWithFrame:CGRectMake(0, 0, 320, 568) superView:self.view];
        [ProjectApi GetRecommenddProjectsWithBlock:^(NSMutableArray *posts, NSError *error) {
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
                [self firstWork];
            }];
        }];
    }else{
        self.tableView.scrollEnabled = NO;
        sectionHeight = 0;
        isReload = YES;
        loadingView = [LoadingView loadingViewWithFrame:CGRectMake(0, 0, 320, 568) superView:self.view];
        [self requestSingleProgram:[ProjectSqlite loadList]];
    }
}

-(void)requestSingleProgram:(NSMutableArray*)datas{
    NSString* projectIds=@"";
    for (int i=0; i<datas.count; i++) {
        projectIds=[[NSString stringWithFormat:i?@"%@,":@"%@",projectIds] stringByAppendingString:[datas[i] a_projectId]];
    }
    if (datas.count) {
        [ProjectApi LocalProjectWithBlock:^(NSMutableArray *posts, NSError *error) {
            if (!error) {
                showArr = posts;
                sectionHeight = 50;
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
                [LoginAgain AddLoginView:NO];
            }
        } projectIds:projectIds noNetWork:^{
            self.tableView.scrollEnabled = NO;
            [LoadingView removeLoadingView:loadingView];
            loadingView = nil;
            [ErrorView errorViewWithFrame:CGRectMake(0, 64, 320, 568-64) superView:self.view reloadBlock:^{
                self.tableView.scrollEnabled = YES;
                [self firstWork];
            }];
        }];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)serachClick{
     SearchViewController *searchView = [[SearchViewController alloc] init];
    [self.navigationController pushViewController:searchView animated:YES];
}

/**
 *  集成刷新控件
 */
- (void)setupRefresh
{
    // 1.下拉刷新(进入刷新状态就会调用self的headerRereshing)
    [self.tableView addHeaderWithTarget:self action:@selector(headerRereshing)];
    //[_tableView headerBeginRefreshing];
    
    NSMutableArray* localDatas=[ProjectSqlite loadList];
    if(localDatas.count ==0){
        //2.上拉加载更多(进入刷新状态就会调用self的footerRereshing)
        [self.tableView addFooterWithTarget:self action:@selector(footerRereshing)];
    }
}

#pragma mark 开始进入刷新状态
- (void)headerRereshing
{
    NSMutableArray* localDatas=[ProjectSqlite loadList];
    if (!localDatas.count) {
        [ProjectApi GetRecommenddProjectsWithBlock:^(NSMutableArray *posts, NSError *error) {
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
    }else{
        [self.tableView removeFooter];
        NSArray* datas=[ProjectSqlite loadList];
        NSString* projectIds=@"";
        for (int i=0; i<datas.count; i++) {
            projectIds=[[NSString stringWithFormat:i?@"%@,":@"%@",projectIds] stringByAppendingString:[datas[i] a_projectId]];
        }
        if (datas.count) {
            [ProjectApi LocalProjectWithBlock:^(NSMutableArray *posts, NSError *error) {
                if(!error){
                    startIndex = 0;
                    [showArr removeAllObjects];
                    showArr = posts;
                    isReload = YES;
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
            } projectIds:projectIds noNetWork:^{
                [self.tableView headerEndRefreshing];
                [ErrorView errorViewWithFrame:CGRectMake(0, 64, 320, 568-64) superView:self.view reloadBlock:^{
                    [self headerRereshing];
                }];
            }];
        }
    }
}

- (void)footerRereshing
{
    if(!isReload){
        [ProjectApi GetRecommenddProjectsWithBlock:^(NSMutableArray *posts, NSError *error) {
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
    }else{
        NSMutableArray* localDatas=[ProjectSqlite loadList];
        if(localDatas.count ==0){
            [ProjectApi GetRecommenddProjectsWithBlock:^(NSMutableArray *posts, NSError *error) {
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
    }
}

-(void)rightBtnClick{
    TopicsTableViewController *topicsview = [[TopicsTableViewController alloc] init];
    [self.navigationController pushViewController:topicsview animated:YES];
}

#pragma mark - Table view data source

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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section == 0){
        return 50;
    }
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 290;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(section == 0){
        UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 291.5, 50)];
        [bgView setBackgroundColor:RGBCOLOR(239, 237, 237)];

//        UILabel* countLabel=[[UILabel alloc] initWithFrame:CGRectMake(-38, 10, 160, 20)];
//        countLabel.font = [UIFont fontWithName:@"GurmukhiMN" size:17];
//        countLabel.textColor = BlueColor;
//        countLabel.textAlignment = NSTextAlignmentCenter;
//        countLabel.text = [NSString stringWithFormat:@"%d",showArr.count];
//        //[bgView addSubview:countLabel];
        
        UILabel *tempLabel = [[UILabel alloc] initWithFrame:CGRectMake(18, 25, 160, 20)];
        tempLabel.font = [UIFont fontWithName:@"GurmukhiMN" size:13];
        tempLabel.textColor = GrayColor;
//        tempLabel.textAlignment = NSTextAlignmentCenter;
        NSMutableArray* localDatas=[ProjectSqlite loadList];
        if(localDatas.count !=0){
            if(isReload){
                tempLabel.text = [NSString stringWithFormat:@"历史浏览记录"];
                
                UIButton* allProjectBtn=[UIButton buttonWithType:UIButtonTypeSystem];
                [allProjectBtn setTitle:@"查看全部项目" forState:UIControlStateNormal];
                allProjectBtn.frame=CGRectMake(227, 15, 79, 40);
//                allProjectBtn.titleLabel.textColor=RGBCOLOR(110,121,183);
                [allProjectBtn setTitleColor:BlueColor forState:UIControlStateNormal];
                allProjectBtn.titleLabel.font = [UIFont fontWithName:@"GurmukhiMN" size:13];
                [allProjectBtn addTarget:self action:@selector(allProjectBtnClicked) forControlEvents:UIControlEventTouchUpInside];
                [bgView addSubview:allProjectBtn];
                
                UIView* view=[[UIView alloc]initWithFrame:CGRectMake(228, 42, 76, 1)];
                view.backgroundColor=BlueColor;
                [bgView addSubview:view];

            }else{
                tempLabel.text = [NSString stringWithFormat:@"推荐项目"];
            }
        }else{
            tempLabel.text = [NSString stringWithFormat:@"推荐项目"];
        }
        [bgView addSubview:tempLabel];
        
        
        return bgView;
    }
    return nil;
}

-(void)allProjectBtnClicked{
    ALLProjectViewController* vc=[[ALLProjectViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)addProjectCommentView:(int)index{
    projectModel *model = showArr[index];
    PorjectCommentTableViewController *projectCommentView = [[PorjectCommentTableViewController alloc] init];
    projectCommentView.projectId = model.a_id;
    projectCommentView.projectName = model.a_projectName;
    [self.navigationController pushViewController:projectCommentView animated:YES];
}
@end
