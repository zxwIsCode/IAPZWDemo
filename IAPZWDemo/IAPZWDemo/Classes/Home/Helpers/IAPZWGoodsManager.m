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

#pragma mark - Init

+ (IAPZWGoodsManager *)sharedInstance
{
    static dispatch_once_t onceToken;
    static IAPZWGoodsManager * instance;
    
    dispatch_once(&onceToken, ^{
        instance = [[IAPZWGoodsManager alloc] init];
    });
    return instance;
}


#pragma mark - Private Methods

-(void)requestGetAllGoodsProductIds:(NSArray *)productIds
{
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
        
        [self.allProductIds addObject:model];
        self.availableProducts = [NSMutableArray arrayWithArray:response.products];
    }
    

    if ((response.invalidProductIdentifiers).count > 0)
    {
        model = [[IAPZWGoodsModel alloc] init];
        model.isValid =NO;
        model.productListArr =response.invalidProductIdentifiers;
        [self.allProductIds addObject:model];
    }
    
    self.status = IAPGoodsRequestResponse;
    [[NSNotificationCenter defaultCenter] postNotificationName:IAPZWGoodsRequestNotification object:self];
}

#pragma mark - SKRequestDelegate

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@",error.localizedDescription);
}

- (void)requestDidFinish:(SKRequest *)request {
    
    NSLog(@"requestDidFinish");

}
#pragma mark - Setter & Getter
-(NSMutableArray *)allProductIds {
    if (!_allProductIds) {
        _allProductIds =[NSMutableArray array];
    }
    return _allProductIds;
}
-(NSMutableArray *)invalidProductIds {
    if (!_invalidProductIds) {
        _invalidProductIds =[NSMutableArray array];
    }
    return _invalidProductIds;
}
-(NSMutableArray *)availableProducts {
    if (!_availableProducts) {
        _availableProducts =[NSMutableArray array];
    }
    return _availableProducts;
}



@end
