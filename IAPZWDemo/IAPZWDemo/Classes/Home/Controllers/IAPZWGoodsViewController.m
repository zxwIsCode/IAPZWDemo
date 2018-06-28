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
    
    [self fetchProductInformation];
}

#pragma mark - Private Methods

-(void)fetchProductInformation
{
    // Query the App Store for product information if the user is is allowed to make purchases.
    // Display an alert, otherwise.
    if([SKPaymentQueue canMakePayments])
    {
        // 这里本地写死商品id，正确方式为从后台获取
        NSArray *productIds = @[@"1008612345",@"1008611111"];
        [[IAPZWGoodsManager sharedInstance] requestGetAllGoodsProductIds:productIds];
    }
    
    else
    {
        
    }

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

        self.dataArr = notificationManager.availableProducts;
        [self.tableView reloadData];
    }
}

-(void)responseToAllGoodsIsSuccess:(NSNotification *)notification
{
    IAPZWGoodsNoti *purchasesNotification = (IAPZWGoodsNoti *)notification.object;
    IAPPurchaseNotificationStatus status = (IAPPurchaseNotificationStatus)purchasesNotification.status;
    
    [[DisplayHelper shareDisplayHelper]hideLoading:self.view];
    switch (status)
    {
        case IAPPurchaseFailed: // 下单失败，沙河模式下必现流程为本地登录正常AppId，正常下单时必现，正常为把正常AppId给退出
            [DisplayHelper displayWarningAlert:@"下单失败!"];
            
            break;
        case IAPRestoredSucceeded:
            
        {
            
        }
            break;
        case IAPRestoredFailed:
          
            break;
        case IAPDownloadStarted:
        {
            [[DisplayHelper shareDisplayHelper]hideLoading:self.view];
           
        }
            break;
        case IAPDownloadInProgress:
        {
            
        }
            break;
        case IAPDownloadSucceeded:
        {
            
        }
            break;
            
        case IAPPurchaseSucceeded: // 支付成功
        {
            
            [self dl_completeTransaction:purchasesNotification.purchasedID];
            
           
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

- (void)dl_completeTransaction:(NSString *)productIdentifier {
    //    NSString *productIdentifier = transaction.payment.productIdentifier;
    NSData *receiptData = [NSData dataWithContentsOfURL:[[NSBundle mainBundle] appStoreReceiptURL]];
    NSString *receipt = [receiptData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    [[DisplayHelper shareDisplayHelper]hideLoading:self.view];
    if ([receipt length] > 0 && [productIdentifier length] > 0) {

        /**
         可以将receipt发给服务器进行购买验证
         */
        
        [self dl_validateReceiptWiththeAppStore:receipt];
        
        
        
    }
    //    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

-(void)dl_validateReceiptWiththeAppStore:(NSString *)receipt
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
                                   if (!jsonResponse) {
                                       /* 处理error */
//                                       LHRPayResultViewController *vc =[[LHRPayResultViewController alloc]init];
//                                       vc.isSuccess =NO;
//                                       [ws.navigationController pushViewController:vc animated:YES];
                                   }else{
                                       /* 处理验证结果 */
                                       if ([[jsonResponse allKeys]containsObject:@"status"]) {
                                           NSString *statusStr =jsonResponse[@"status"];
                                           if ([statusStr intValue] ==0) { // 成功发服务器
                                               [ws requestPayIsSuccess:receipt];
                                           }else {
                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                   if ([statusStr intValue] ==21002) { // 重发机制
                                                       [ws requestPayIsSuccess:receipt];
                                                       //                                                       [DisplayHelper displayWarningAlert:@"沙河模式却发线上"];
                                                   }else {
//                                                       LHRPayResultViewController *vc =[[LHRPayResultViewController alloc]init];
//                                                       vc.isSuccess =NO;
//                                                       [ws.navigationController pushViewController:vc animated:YES];
                                                   }
                                                   
                                               });
                                               
                                           }
                                           
                                       }
                                       
                                   }
                               }
                           }];
    
}

-(void)requestPayIsSuccess:(NSString *)receipt {
    
    // 参数初始化
    CMHttpRequestModel *model =[[CMHttpRequestModel alloc]init];
    
    
    // 参数包装
//    model.appendUrl = kSettingPay_SetIapCertificate;
//    model.headerType = JNCHttpHeaderType_Default;
    
//    [model.paramDic setValue:[LHRUserHelper userModelData].userId forKey:@"userId"];
    if (kIsProduction) {
        [model.paramDic setValue:@(YES) forKey:@"chooseEnv"];
    }else {
        [model.paramDic setValue:@(NO) forKey:@"chooseEnv"];
    }
    NSString *receiptStr =[receipt stringByReplacingOccurrencesOfString:@"" withString:@"\r\n"];
    [model.paramDic setValue:receiptStr forKey:@"receipt"];
    
    
    WS(ws);
    model.callback =^(CMHttpResponseModel *result, NSError *error) {
        
        if (result.state ==CMReponseCodeState_Success) {// 成功,做自己的逻辑
            DDLog(@"%@",result.data);
            NSDictionary *dataDic =(NSDictionary *)result.data;
            if ([dataDic.allKeys  containsObject:@"isSuccess"]) {
                
            }
            
            
            
            
        }else {
            
        }
        
        
    };
    // 发送网络请求
    [[CMHTTPSessionManager sharedHttpSessionManager] sendHttpRequestParam:model];
    
    
    
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
