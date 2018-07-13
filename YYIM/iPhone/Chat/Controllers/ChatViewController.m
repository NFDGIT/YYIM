//
//  ChatViewController.m
//  YYIM
//
//  Created by Jobs on 2018/7/10.
//  Copyright © 2018年 Jobs. All rights reserved.
//

#import "ChatViewController.h"
#import "ChatCell.h"
#import "ChatInputView.h"
#import "SocketTool.h"


@interface ChatViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong)UITableView * tableView;


@property (nonatomic,strong)NSMutableArray * datas;

@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self initNavi];
    [self initUI];
    
//    [self refreshData];
    // Do any additional setup after loading the view.
}

-(void)initData{
    _datas = [NSMutableArray array];
    

    
}
-(void)initNavi{
    self.title = @"聊天";
    
}
-(void)initUI{
    
    
    
    
    UIScrollView * scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0,0, self.view.width, ContentHeight)];
    
    [self.view addSubview:scrollView];
    scrollView.backgroundColor  =[UIColor lightGrayColor];
    
    ChatInputView * inputView = [[ChatInputView alloc]initWithFrame:CGRectMake(0, 0, scrollView.width, 50)];
    inputView.top = scrollView.height- inputView.topView.bottom;
    [scrollView addSubview:inputView];
    inputView.inputBlock = ^(NSString *value) {
        [self sendAction:value];
    };
    
    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, scrollView.width, scrollView.height - inputView.topView.height) style:UITableViewStyleGrouped];
    [_tableView registerClass:[ChatCell class] forCellReuseIdentifier:@"cell"];
    [scrollView addSubview:_tableView];
    
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    
    scrollView.contentSize = CGSizeMake(scrollView.width, scrollView.height);

}
-(void)refreshUI{
    [_tableView reloadData];
}

#pragma mark -- 点击事件
-(void)sendAction:(NSString *)msg{
    
    MsgModel * model = [MsgModel new];
    model.Id = @"1";
    model.msg = msg;
    
    
    MsgModel * model1 = [MsgModel new];
    model1.msg = msg;
    
    
    [_datas addObject:model];
    [_datas addObject:model1];
    [[SocketTool share] sendMsg:@"hello swift" msgInfoClass:12];
    
    
    
    [_tableView reloadData];
}


#pragma mark -- delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return _datas.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [tableView cellHeightWithIndexPath:indexPath];
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ChatCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.indexPath = indexPath;
    
    
    
    MsgModel * model = _datas[indexPath.section];
    cell.model = model;
    return cell;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end