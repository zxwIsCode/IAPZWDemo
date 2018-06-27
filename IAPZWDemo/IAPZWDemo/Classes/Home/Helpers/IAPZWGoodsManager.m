//
//  IAPZWGoodsManager.m
//  IAPZWDemo
//
//  Created by XDWY on 2018/6/26.
//  Copyright © 2018年 DaviD. All rights reserved.
//

#import "IAPZWGoodsManager.h"
#import "IAPZWGoodsModel.h"

#import <StoreKit/StoreKit.h>


@interface IAPZWGoodsManager()<SKRequestDelegate, SKProductsRequestDelegate>
@end
@implementation IAPZWGoodsManager

+ (IAPZWGoodsManager *)sharedInstance
{
    static dispatch_once_t onceToken;
    static IAPZWGoodsManager * storeManagerSharedInstance;
    
    dispatch_once(&onceToken, ^{
        storeManagerSharedInstance = [[IAPZWGoodsManager alloc] init];
    });
    return storeManagerSharedInstance;
}


- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        _availableProducts = [[NSMutableArray alloc] initWithCapacity:0];
        _invalidProductIds = [[NSMutableArray alloc] initWithCapacity:0];
        _productRequestResponse = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return self;
}

#pragma mark Request information

-(void)fetchProductInformationForIds:(NSArray *)productIds
{
    self.productRequestResponse = [[NSMutableArray alloc] initWithCapacity:0];
    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithArray:productIds]];
    request.delegate = self;
    
    [request start];
}

#pragma mark - SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    IAPZWGoodsModel *model = nil;

    if ((response.products).count > 0)
    {
        model = [[IAPZWGoodsModel alloc] init];
        model.isValid =YES;
        model.productListArr =response.products;
        
        [self.productRequestResponse addObject:model];
        self.availableProducts = [NSMutableArray arrayWithArray:response.products];
    }
    

    if ((response.invalidProductIdentifiers).count > 0)
    {
        model = [[IAPZWGoodsModel alloc] init];
        model.isValid =NO;
        model.productListArr =response.invalidProductIdentifiers;
        [self.productRequestResponse addObject:model];
    }
    
    self.status = IAPGoodsRequestResponse;
    [[NSNotificationCenter defaultCenter] postNotificationName:IAPZWGoodsRequestNotification object:self];
}

#pragma mark SKRequestDelegate method

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"Product Request Status: %@",error.localizedDescription);
}



@end
