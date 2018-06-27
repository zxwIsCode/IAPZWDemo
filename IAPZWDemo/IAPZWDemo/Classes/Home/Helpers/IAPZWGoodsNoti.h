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
@property (nonatomic, strong) NSMutableArray *productsPurchased;
// 所有支付成功后还未来得及双重验证的的商品Id集合
@property (nonatomic, strong) NSMutableArray *productsRestored;

@property (nonatomic, copy) NSString *message;

@property(nonatomic) float downloadProgress;

@property (nonatomic, copy) NSString *purchasedID;


-(BOOL)hasPurchasedProducts;
-(BOOL)hasRestoredProducts;

+ (IAPZWGoodsNoti *)sharedInstance;
-(void)buy:(SKProduct *)product;

-(void)restore;

@end
