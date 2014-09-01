//
//  AdvancedSearchViewController.m
//  ZhuZhan
//
//  Created by 汪洋 on 14-8-28.
//
//

#import "AdvancedSearchViewController.h"
#import "UIViewController+MJPopupViewController.h"
#import "ProjectApi.h"
#import "SaveConditionsViewController.h"
#import "AppDelegate.h"
#import "HomePageViewController.h"
@interface AdvancedSearchViewController ()

@end

@implementation AdvancedSearchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //LeftButton设置属性
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftButton setFrame:CGRectMake(0, 0, 29, 28.5)];
    [leftButton setBackgroundImage:[UIImage imageNamed:@"icon_04.png"] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(leftBtnClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftButtonItem;
    
    //RightButton设置属性
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightButton setFrame:CGRectMake(0, 0, 50, 19.5)];
    [rightButton setTitle:@"保存" forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(rightBtnClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
    self.title = @"高级搜索";
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 568)];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    _tableView.backgroundColor = RGBCOLOR(239, 237, 237);
    _tableView.separatorStyle = NO;
    [self.view addSubview:_tableView];
    
    dataDic = [[NSMutableDictionary alloc] init];
    [dataDic setValue:@"" forKey:@"keywords"];
    [dataDic setValue:@"" forKey:@"landDistrict"];
    [dataDic setValue:@"" forKey:@"landProvince"];
    [dataDic setValue:@"" forKey:@"projectStage"];
    [dataDic setValue:@"" forKey:@"projectCategory"];
    
    viewArr = [[NSMutableArray alloc] init];
    [ProjectApi GetSearchConditionsWithBlock:^(NSMutableArray *posts, NSError *error) {
        if (!error) {
            showArr = posts;
            for(int i=0;i<posts.count;i++){
                conditionsView = [ConditionsView setFram:posts[i]];
                [viewArr insertObject:conditionsView atIndex:0];
            }
            [_tableView reloadData];
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //恢复tabBar
    AppDelegate* app=[AppDelegate instance];
    HomePageViewController* homeVC=(HomePageViewController*)app.window.rootViewController;
    [homeVC homePageTabBarRestore];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //隐藏tabBar
    AppDelegate* app=[AppDelegate instance];
    HomePageViewController* homeVC=(HomePageViewController*)app.window.rootViewController;
    [homeVC homePageTabBarHide];
}

-(void)leftBtnClick{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)rightBtnClick{
    saveView = [[SaveConditionsViewController alloc] init];
    [saveView.view setFrame:CGRectMake(0, 0, 271, 173)];
    saveView.delegate = self;
    saveView.dataDic = dataDic;
    [self presentPopupViewController:saveView animationType:MJPopupViewAnimationFade];
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
    return 2+showArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row == 0){
        return  355;
    }else if (indexPath.row == 1){
        return 44;
    }else{
        if(viewArr.count !=0){
            conditionsView = [viewArr objectAtIndex:indexPath.row-2];
            //NSLog(@"===>%f",conditionsView.frame.size.height);
            if(conditionsView.frame.size.height <44){
                return 44;
            }else{
                return conditionsView.frame.size.height;
            }
        }else{
            return 0;
        }
    }
}

//哪几行可以编辑
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row == 0){
        return NO;
    }else if(indexPath.row == 1){
        return NO;
    }
    return YES;
}

//继承该方法时,左右滑动会出现删除按钮(自定义按钮),点击按钮时的操作
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"editingStyle ==> %d",editingStyle);
    /*if (editingStyle == UITableViewCellEditingStyleDelete){
        [self.arr removeObjectAtIndex:indexPath.row];
        NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
        [self.tableview deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    }else {
        //我们实现的是在所选行的位置插入一行，因此直接使用了参数indexPath
        NSArray *insertIndexPaths = [NSArray arrayWithObjects:indexPath,nil];
        //同样，将数据加到list中，用的row
        [self.arr insertObject:@"新添加的行" atIndex:0];
        [tableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationRight];
    }*/
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0){
        NSString *CellIdentifier = [NSString stringWithFormat:@"AdvancedSearchConditionsTableViewCell"];
        AdvancedSearchConditionsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if(!cell){
            cell = [[AdvancedSearchConditionsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        cell.dic = dataDic;
        cell.delegate = self;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }else if (indexPath.row == 1){
        NSString *CellIdentifier = [NSString stringWithFormat:@"Cell"];
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if(!cell){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(55, 7, 100, 30)];
        label.text = @"个人搜索条件";
        label.font = [UIFont systemFontOfSize:12];
        [cell.contentView setBackgroundColor:RGBCOLOR(242, 242, 242)];
        [cell.contentView addSubview:label];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 11.5, 19, 21)];
        [imageView setImage:[UIImage imageNamed:@"项目－高级搜索－2_15a-19"]];
        [cell.contentView addSubview:imageView];
        return cell;
    }else{
        NSString *stringcell = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:stringcell];
        if(!cell){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:stringcell] ;
        }
        for(int i=0;i<cell.contentView.subviews.count;i++) {
            [((UIView*)[cell.contentView.subviews objectAtIndex:i]) removeFromSuperview];
        }
        [cell.contentView setBackgroundColor:[UIColor whiteColor]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if(viewArr.count !=0){
            conditionsView = [viewArr objectAtIndex:indexPath.row-2];
            [cell.contentView addSubview:conditionsView];
        }
        return cell;
    }
    
    return nil;
}

-(void)multipleChose:(int)index{
    if(index == 0){
        multipleChoseView = [[MultipleChoiceViewController alloc] init];
        multipleChoseView.arr = [[NSMutableArray alloc] initWithObjects:@"工业",@"酒店及餐饮",@"商务办公",@"住宅/经济适用房",@"公用事业设施（教育、医疗、科研、基础建设等）",@"其他", nil];
        [multipleChoseView.view setFrame:CGRectMake(0, 0, 260, 310)];
        multipleChoseView.flag = 0;
        multipleChoseView.delegate = self;
        [self presentPopupViewController:multipleChoseView animationType:MJPopupViewAnimationFade];
    }else{
        multipleChoseView = [[MultipleChoiceViewController alloc] init];
        multipleChoseView.arr = [[NSMutableArray alloc] initWithObjects:@"土地信息阶段",@"主体设计阶段",@"主体施工阶段",@"装修阶段", nil];
        [multipleChoseView.view setFrame:CGRectMake(0, 0, 260, 310)];
        multipleChoseView.flag = 1;
        multipleChoseView.delegate = self;
        [self presentPopupViewController:multipleChoseView animationType:MJPopupViewAnimationFade];
    }
}

-(void)setTextFieldStr:(NSString *)str index:(int)index{
    if(index == 0){
        [dataDic setValue:str forKey:@"keywords"];
    }else{
        [dataDic setValue:str forKey:@"landDistrict"];
    }
    [_tableView reloadData];
}

-(void)choiceData:(NSMutableArray *)arr index:(int)index{
    NSMutableString *string = [[NSMutableString alloc] init];
    NSString *aStr = nil;
    for(int i=0;i<arr.count;i++){
        if(![[arr objectAtIndex:i] isEqualToString:@""]){
            [string appendString:[NSString stringWithFormat:@"%@,",[arr objectAtIndex:i]]];
        }
    }
    if(string.length !=0){
        aStr = [string substringToIndex:([string length]-1)];
        if(index == 0){
            [dataDic setObject:aStr forKey:@"projectStage"];
        }else{
            [dataDic setObject:aStr forKey:@"projectCategory"];
        }
    }
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
    [_tableView reloadData];
}


-(void)backMChoiceViewController{
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
}

-(void)backView{
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
}
@end
