//
//  IAPZWGoodsNoti.h
//  IAPZWDemo
//
//  Created by XDWY on 2018/6/26.
//  Copyright © 2018年 DaviD. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <StoreKit/StoreKit.h>


@interface IAPZWGoodsNoti : NSObject<SKPaymentTransactionObserver>

typedef NS_ENUM(NSInteger, IAPPurchaseNotificationStatus)
{
    IAPPurchaseFailed,
    IAPPurchaseSucceeded,
    IAPRestoredFailed,
    IAPRestoredSucceeded,
    IAPDownloadStarted,
    IAPDownloadInProgress,
    IAPDownloadFailed,
    IAPDownloadSucceeded
};

@property (nonatomic) IAPPurchaseNotificationStatus status;

// 所有的下单后的商品Id集合
@property (nonatomic, strong) NSMutableArray *goodProductIds;
// 所有支付成功后还未来得及双重验证的的商品Id集合
@property (nonatomic, strong) NSMutableArray *goodRestoredIds;

@property (nonatomic, copy) NSString *errorMsg;

// 当前支付的商品Id
@property (nonatomic, copy) NSString *purchasedID;


+ (IAPZWGoodsNoti *)sharedInstance;
// 下单商品
-(void)buyAllGood:(SKProduct *)product;
// 如果存在的话即为上次未来的及验证的订单重新验证（这里没有做相关逻辑）
-(void)restoreAllGoods;

@end
