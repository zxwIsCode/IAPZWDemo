//
//  IAPZWGoodsNoti.m
//  IAPZWDemo
//
//  Created by XDWY on 2018/6/26.
//  Copyright © 2018年 DaviD. All rights reserved.
//

#import "IAPZWGoodsNoti.h"

@implementation IAPZWGoodsNoti

+ (IAPZWGoodsNoti *)sharedInstance
{
    static dispatch_once_t onceToken;
    static IAPZWGoodsNoti * instance;
    
    dispatch_once(&onceToken, ^{
        instance = [[IAPZWGoodsNoti alloc] init];
    });
    return instance;
}

@end
