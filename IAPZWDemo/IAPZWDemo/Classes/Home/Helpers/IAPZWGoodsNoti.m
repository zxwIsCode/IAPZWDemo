//
//  IAPZWGoodsNoti.m
//  IAPZWDemo
//
//  Created by XDWY on 2018/6/26.
//  Copyright © 2018年 DaviD. All rights reserved.
//

#import "IAPZWGoodsNoti.h"

@implementation IAPZWGoodsNoti

#pragma mark - Init
+ (IAPZWGoodsNoti *)sharedInstance
{
    static dispatch_once_t onceToken;
    static IAPZWGoodsNoti * instance;
    
    dispatch_once(&onceToken, ^{
        instance = [[IAPZWGoodsNoti alloc] init];
    });
    return instance;
}

#pragma mark  - Private Methods

// 下单商品
-(void)buyAllGood:(SKProduct *)product
{
    SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

// 如果存在的话即为上次未来的及验证的订单重新验证（这里没有做相关逻辑）
-(void)restoreAllGoods
{
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}


// 完成支付
-(void)completeTransaction:(SKPaymentTransaction *)transaction forStatus:(NSInteger)status
{
    self.status = status;
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:IAPZWBuyResultNotification object:self];
    }
    
    if (status == IAPZWDownOrderStarted) // 开始下单
    {
        [[SKPaymentQueue defaultQueue] startDownloads:transaction.downloads];
    }
    else // 已经下单购买完成
    {
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    }
}

// 完成下单
- (void)finishDownloadTransaction:(SKPaymentTransaction*)transaction
{
    BOOL allAssetsDownloaded = YES;
    
    
    for (SKDownload* download in transaction.downloads)
    {
        if (download.downloadState != SKDownloadStateCancelled &&
            download.downloadState != SKDownloadStateFailed &&
            download.downloadState != SKDownloadStateFinished )
        {
            allAssetsDownloaded = NO;
            break;
        }
    }
    
    if (allAssetsDownloaded)
    {
        self.status = IAPZWDownOrderSucceeded;
        
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
        [[NSNotificationCenter defaultCenter] postNotificationName:IAPZWBuyResultNotification object:self];
        
        if ([self.goodRestoredIds containsObject:transaction])
        {
            self.status = IAPZWRestoredSucceeded;
            [[NSNotificationCenter defaultCenter] postNotificationName:IAPZWBuyResultNotification object:self];
        }
        
    }
}


#pragma mark - SKPaymentTransactionObserver

// 支付过程中的回调
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for(SKPaymentTransaction * transaction in transactions)
    {
        switch (transaction.transactionState )
        {
            // 1.第一次调起苹果支付框时走这里
            case SKPaymentTransactionStatePurchasing:
                break;
                
            case SKPaymentTransactionStateDeferred:

                break;
                // 2.这里有时会走2次，其中比较关心的一次是 IAPZWBuyGoodsSucceeded 这一次
            case SKPaymentTransactionStatePurchased:
            {
                self.purchasedID = transaction.payment.productIdentifier;
                [self.goodProductIds addObject:transaction];
                

                if(transaction.downloads && transaction.downloads.count > 0)
                {
                    [self completeTransaction:transaction forStatus:IAPZWDownOrderStarted];
                }
                else
                {
                    [self completeTransaction:transaction forStatus:IAPZWBuyGoodsSucceeded];
                }
            }
                break;
            case SKPaymentTransactionStateRestored:
            {
                self.purchasedID = transaction.payment.productIdentifier;
                [self.goodRestoredIds addObject:transaction];
                
                NSLog(@"SKPaymentTransactionStateRestored %@",transaction.payment.productIdentifier);
                if(transaction.downloads && transaction.downloads.count > 0)
                {
                    [self completeTransaction:transaction forStatus:IAPZWDownOrderStarted];
                }
                else
                {
                    [self completeTransaction:transaction forStatus:IAPZWRestoredSucceeded];
                }
            }
                break;
                // 3.测试中会发现有时走这个方法
            case SKPaymentTransactionStateFailed:
            {
                self.errorMsg = [NSString stringWithFormat:@"SKPaymentTransactionStateFailed %@ ",transaction.payment.productIdentifier];
                [self completeTransaction:transaction forStatus:IAPZWBuyGoodsFailed];
            }
                break;
            default:
                break;
        }
    }
}


// 下单过程中的回调（实际测试中好像没有调用的时候）
- (void)paymentQueue:(SKPaymentQueue *)queue updatedDownloads:(NSArray *)downloads
{
    for (SKDownload* download in downloads)
    {
        switch (download.downloadState)
        {
            case SKDownloadStateActive:
            {
                self.status = IAPZWDownOrderProgress;
                self.purchasedID = download.transaction.payment.productIdentifier;
                [[NSNotificationCenter defaultCenter] postNotificationName:IAPZWBuyResultNotification object:self];
            }
                break;
                
            case SKDownloadStateCancelled:
                [[NSFileManager defaultManager] removeItemAtURL:download.contentURL error:nil];
                [self finishDownloadTransaction:download.transaction];
                break;
                
            case SKDownloadStateFailed:
                [[NSFileManager defaultManager] removeItemAtURL:download.contentURL error:nil];
                [self finishDownloadTransaction:download.transaction];
                break;
                
            case SKDownloadStatePaused:
                NSLog(@"SKDownloadStatePaused");
                break;
                
            case SKDownloadStateFinished:
                NSLog(@"SKDownloadStateFinished %@",download.contentURL);
                [self finishDownloadTransaction:download.transaction];
                break;
                
            case SKDownloadStateWaiting:
                NSLog(@"SKDownloadStateWaiting");
                [[SKPaymentQueue defaultQueue] startDownloads:@[download]];
                break;
                
            default:
                break;
        }
    }
}

// 支付页面消失后的回调
- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions
{
    for(SKPaymentTransaction * transaction in transactions)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:IAPZWBuyResultNotificationCancle object:self];
        NSLog(@"%@ removedTransactions", transaction.payment.productIdentifier);
    }
}

// 上次未来得及验证的订单验证后的回调
- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    if (error.code != SKErrorPaymentCancelled)
    {
        self.status = IAPZWRestoredFailed;
        self.errorMsg = error.localizedDescription;
        [[NSNotificationCenter defaultCenter] postNotificationName:IAPZWBuyResultNotification object:self];
    }
}

// 支付完成后的回调
- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    NSLog(@"paymentQueueRestoreCompletedTransactionsFinished");
}



#pragma mark - Setter & Getter

-(NSMutableArray *)goodProductIds {
    if (!_goodProductIds) {
        _goodProductIds =[NSMutableArray array];
    }
    return _goodProductIds;
}
-(NSMutableArray *)goodRestoredIds {
    if (!_goodRestoredIds) {
        _goodRestoredIds =[NSMutableArray array];
    }
    return _goodRestoredIds;
}

@end
