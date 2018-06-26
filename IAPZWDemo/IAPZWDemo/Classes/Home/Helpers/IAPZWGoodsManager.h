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

@property (nonatomic, strong) NSMutableArray *productRequestResponse;

@property (nonatomic, strong) NSMutableArray *invalidProductIds;


@property (nonatomic, strong) NSMutableArray *availableProducts;



+ (IAPZWGoodsManager *)sharedInstance;

-(void)fetchProductInformationForIds:(NSArray *)productIds;

-(NSString *)titleMatchingProductIdentifier:(NSString *)identifier;


@end
