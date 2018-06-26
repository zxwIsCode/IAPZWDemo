//
//  IAPZWGoodsViewController.m
//  IAPZWDemo
//
//  Created by XDWY on 2018/6/26.
//  Copyright © 2018年 DaviD. All rights reserved.
//

#import "IAPZWGoodsViewController.h"
#import "IAPZWGoodsTableCell.h"

#import "IAPZWGoodsNoti.h"
#import "IAPZWGoodsManager.h"

@interface IAPZWGoodsViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong)UITableView *tableView;

@property(nonatomic,strong)NSMutableArray *dataArr;

@end

@implementation IAPZWGoodsViewController

#pragma mark - Init
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addAllNoti];
    
    self.tableView.frame =CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT -64);
    [self.view addSubview:self.tableView];

    // Do any additional setup after loading the view.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:IAPZWGoodsRequestNotification
                                                  object:[IAPZWGoodsNoti sharedInstance]];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:IAPZWBuyResultNotification
                                                  object:[IAPZWGoodsNoti sharedInstance]];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:IAPZWBuyResultNotificationCancle
                                                  object:[IAPZWGoodsNoti sharedInstance]];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self fetchProductInformation];
}

#pragma mark - Private Methods

-(void)fetchProductInformation
{
    // Query the App Store for product information if the user is is allowed to make purchases.
    // Display an alert, otherwise.
    if([SKPaymentQueue canMakePayments])
    {
        NSArray *productIds = @[@"1008612345",@"1008611111"];
        [[IAPZWGoodsManager sharedInstance] fetchProductInformationForIds:productIds];
    }
    
    else
    {
        // Warn the user that they are not allowed to make purchases.
        //        [self alertWithTitle:@"Warning" message:@"Purchases are disabled on this device."];
    }
    
    //    NSString *productId =@"1008612345";
    //
    //    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithArray:@[productId]]];
    //    request.delegate = self;
    //    [request start];
    //
    //    [DisplayHelper displayWarningAlert:@"加载中..."];
}

-(void)addAllNoti {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(responseToOrderDatas:)
                                                 name:IAPZWGoodsRequestNotification
                                               object:[IAPZWGoodsManager sharedInstance]];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(responseToAllGoodsIsSuccess:)
                                                 name:IAPZWBuyResultNotification
                                               object:[IAPZWGoodsNoti sharedInstance]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(responseToAllGoodsCancle:)
                                                 name:IAPZWBuyResultNotificationCancle
                                               object:[IAPZWGoodsNoti sharedInstance]];
}

-(void)responseToOrderDatas:(NSNotification *)notification
{
    IAPZWGoodsManager *notificationManager = (IAPZWGoodsManager*)notification.object;
    IAPGoodsRequestStatus status = (IAPGoodsRequestStatus)notificationManager.status;
    
    if (status == IAPGoodsRequestResponse)
    {
//        self.openVipBtn.enabled =YES;
//        self.openVipBtn.backgroundColor =kColorMainGreenColor;
        
        // Set the data source for the Products view
        self.dataArr = notificationManager.availableProducts;
        [self.tableView reloadData];
    }
}

#pragma mark - UITableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    IAPZWGoodsTableCell *cell =[IAPZWGoodsTableCell updateWithTableView:tableView];
    if (cell) {
        cell.backgroundColor =[UIColor whiteColor];
        
        cell.layer.cornerRadius =5;
        if (indexPath.row <self.dataArr.count) {
            cell.aProduct =self.dataArr[indexPath.row];
        }
        // 注意，真正有数据的情况下即传递model时候再设置对应控件的frame
    }
    return cell;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kIAPZWGoodsTableCellHeight;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - Setter & Getter

-(UITableView *)tableView {
    if (!_tableView) {
        _tableView =[[UITableView alloc]init];
        _tableView.delegate =self;
        _tableView.dataSource =self;
        _tableView.separatorStyle =UITableViewCellSeparatorStyleNone;
        
    }
    return _tableView;
}

-(NSMutableArray *)dataArr {
    if (!_dataArr) {
        _dataArr =[NSMutableArray array];
    }
    return _dataArr;
}

@end
