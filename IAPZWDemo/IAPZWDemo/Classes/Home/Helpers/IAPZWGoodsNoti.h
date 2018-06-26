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

+ (IAPZWGoodsNoti *)sharedInstance;

@end
