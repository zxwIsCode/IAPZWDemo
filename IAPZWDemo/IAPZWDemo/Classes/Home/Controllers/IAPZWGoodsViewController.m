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

// 是否是生产状态
#define kIsProduction 0

@interface IAPZWGoodsViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong)UITableView *tableView;

@property(nonatomic,strong)NSMutableArray *dataArr;

@end

@implementation IAPZWGoodsViewController

#pragma mark - Init
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addAllNoti];
    
    self.tableView.frame =CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT -64);
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
    
    // 获取所有的商品信息
    [self getAllAppleProductInfoDatas];
}

#pragma mark - Private Methods
-(void)addAllNoti {
    
    // 获取商品信息通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(responseToOrderDatas:)
                                                 name:IAPZWGoodsRequestNotification
                                               object:[IAPZWGoodsManager sharedInstance]];
    
    // 是否下单成功的通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(responseToAllGoodsIsSuccess:)
                                                 name:IAPZWBuyResultNotification
                                               object:[IAPZWGoodsNoti sharedInstance]];
    // 取消支付的通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(responseToAllGoodsCancle:)
                                                 name:IAPZWBuyResultNotificationCancle
                                               object:[IAPZWGoodsNoti sharedInstance]];
}
// 获取所有的商品信息
-(void)getAllAppleProductInfoDatas
{
    // Query the App Store for product information if the user is is allowed to make purchases.
    // Display an alert, otherwise.
    if([SKPaymentQueue canMakePayments])
    {
        [[DisplayHelper shareDisplayHelper]showLoading:self.view noteText:@"加载商品中..."];
        // 正确方式为从后台获取,这里本地写死商品id
        NSArray *productIds = @[@"1008612345",@"1008611111"];
        [[IAPZWGoodsManager sharedInstance] requestGetAllGoodsProductIds:productIds];
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [[DisplayHelper shareDisplayHelper]hideLoading:self.view];
//
//        });
        
    }
    
    else
    {
        
    }

}



-(void)responseToOrderDatas:(NSNotification *)notification
{
    IAPZWGoodsManager *goodsManager = (IAPZWGoodsManager*)notification.object;
    IAPGoodsRequestStatus status = goodsManager.status;
    
    [[DisplayHelper shareDisplayHelper]hideLoading:self.view];
    
    if (status == IAPGoodsRequestResponse)
    {

        
        self.dataArr = goodsManager.availableProducts;
        [self.tableView reloadData];
    }
}

-(void)responseToAllGoodsIsSuccess:(NSNotification *)notification
{
    IAPZWGoodsNoti *goodsNoti = (IAPZWGoodsNoti *)notification.object;
    IAPZWToBuyOrDownOrderStatus status = goodsNoti.status;
    
    [[DisplayHelper shareDisplayHelper]hideLoading:self.view];
    switch (status)
    {
        case IAPZWBuyGoodsFailed: // 下单失败，沙河模式下必现流程为本地登录正常AppId，正常下单时必现，正常为把正常AppId给退出
            [DisplayHelper displayWarningAlert:@"下单失败!"];
            
            break;
        case IAPZWRestoredSucceeded:
            
        {
            
        }
            break;
        case IAPZWRestoredFailed:
          
            break;
        case IAPZWDownOrderStarted:
        {
            [[DisplayHelper shareDisplayHelper]hideLoading:self.view];
           
        }
            break;
        case IAPZWDownOrderProgress:
        {
            
        }
            break;
        case IAPZWDownOrderSucceeded:
        {
            
        }
            break;
            
        case IAPZWBuyGoodsSucceeded: // 支付成功
        {
            
            [self completeAllDownOrderIsSuccess:goodsNoti.purchasedID];
            
           
        }
            break;
        default:
            //            [DisplayHelper displayWarningAlert:@"未知问题等!"];
            
            break;
    }
}

-(void)responseToAllGoodsCancle:(NSNotification *)notification {
    
    [[DisplayHelper shareDisplayHelper]hideLoading:self.view];
}

- (void)completeAllDownOrderIsSuccess:(NSString *)productIdentifier {

    NSData *receiptData = [NSData dataWithContentsOfURL:[[NSBundle mainBundle] appStoreReceiptURL]];
    NSString *receipt = [receiptData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    [[DisplayHelper shareDisplayHelper]hideLoading:self.view];
    if ([receipt length] > 0 && [productIdentifier length] > 0) {

        /**
         可以将receipt发给服务器进行购买验证
         */
        
        [self sendRequestReceiptToAppStore:receipt];
        
        
        
    }
    //    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

-(void)sendRequestReceiptToAppStore:(NSString *)receipt
{
    NSError *error;
    NSDictionary *requestContents = @{@"receipt-data": receipt};
    NSData *requestData = [NSJSONSerialization dataWithJSONObject:requestContents options:0 error:&error];
    
    if (!requestData) {
        
    }else{
        
    }
    //    NSURL *storeURL;
    //#ifdef DEBUG
    //    storeURL = [NSURL URLWithString:@"https://sandbox.itunes.apple.com/verifyReceipt"];
    //#else
    //    storeURL = [NSURL URLWithString:@"https://buy.itunes.apple.com/verifyReceipt"];
    //#endif
    
    NSURL *storeURL;
    if (kIsProduction) {
        storeURL = [NSURL URLWithString:@"https://buy.itunes.apple.com/verifyReceipt"];
    }else {
        storeURL = [NSURL URLWithString:@"https://sandbox.itunes.apple.com/verifyReceipt"];
    }
    
    NSMutableURLRequest *storeRequest = [NSMutableURLRequest requestWithURL:storeURL];
    [storeRequest setHTTPMethod:@"POST"];
    [storeRequest setHTTPBody:requestData];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    WS(ws);
    [NSURLConnection sendAsynchronousRequest:storeRequest queue:queue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               if (connectionError) {
                                   /* 处理error */
                               } else {
                                   NSError *error;
                                   NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                                   if (!jsonResponse) { // 出错的情况
                                       /* 处理error */
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           [DisplayHelper displayWarningAlert:@"支付失败!"];
                                       });

                                   }else{
                                       /* 处理验证结果 */
                                       if ([[jsonResponse allKeys]containsObject:@"status"]) {
                                           NSString *statusStr =jsonResponse[@"status"];
                                           if ([statusStr intValue] ==0) { // 成功后发服务器进行第二层验证
                                               // 重发我们自己服务器的验证
                                               [ws requestPayIsSuccess:receipt];
                                           }else {
                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                   if ([statusStr intValue] ==21002) { // 请求过于频繁，有刷单嫌疑，需重发服务器
                                                       // 重发我们自己服务器的验证
                                                       [ws requestPayIsSuccess:receipt];
                                                   }else { // 其他失败的情况
                                                       [DisplayHelper displayWarningAlert:@"支付失败!"];
                                                   }
                                                   
                                               });
                                               
                                           }
                                           
                                       }
                                       
                                   }
                               }
                           }];
    
}

// 重发我们自己服务器的验证
-(void)requestPayIsSuccess:(NSString *)receipt {
    
    // 这里简单0.5秒后模拟请求我们服务器成功的步骤
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [DisplayHelper displaySuccessAlert:@"支付成功!"];
    });
    
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
    
    if (indexPath.row < self.dataArr.count) {
        
        SKProduct *product = self.dataArr[0];
        [[IAPZWGoodsNoti sharedInstance] buyAllGood:product];
        [[DisplayHelper shareDisplayHelper]showLoading:self.view];
        
    }
    
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
