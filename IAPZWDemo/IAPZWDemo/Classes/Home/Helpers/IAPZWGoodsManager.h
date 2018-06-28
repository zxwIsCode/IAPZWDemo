//
//  IAPZWGoodsManager.h
//  IAPZWDemo
//
//  Created by XDWY on 2018/6/26.
//  Copyright © 2018年 DaviD. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IAPZWGoodsManager : NSObject

typedef NS_ENUM(NSInteger, IAPGoodsRequestStatus)
{
    IAPGoodsFound,
    IAPGoodsNotFound,
    IAPGoodsRequestResponse,
    IAPRequestFailed
};

@property (nonatomic) IAPGoodsRequestStatus status;

// 所有的商品集合
@property (nonatomic, strong) NSMutableArray *allProductIds;

// 无效的商品集合
@property (nonatomic, strong) NSMutableArray *invalidProductIds;

// 有效的商品集合
@property (nonatomic, strong) NSMutableArray *availableProducts;



+ (IAPZWGoodsManager *)sharedInstance;

-(void)requestGetAllGoodsProductIds:(NSArray *)productIds;

@end
