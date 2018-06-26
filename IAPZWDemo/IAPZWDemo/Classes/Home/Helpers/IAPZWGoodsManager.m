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

// Fetch information about your products from the App Store
-(void)fetchProductInformationForIds:(NSArray *)productIds
{
    self.productRequestResponse = [[NSMutableArray alloc] initWithCapacity:0];
    // Create a product request object and initialize it with our product identifiers
    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithArray:productIds]];
    request.delegate = self;
    
    // Send the request to the App Store
    [request start];
}

#pragma mark - SKProductsRequestDelegate

// Used to get the App Store's response to your request and notifies your observer
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
    
    // The invalidProductIdentifiers array contains all product identifiers not recognized by the App Store.
    // Create an "INVALID PRODUCT IDS" model object.
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

// Called when the product request failed.
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    // Prints the cause of the product request failure
    NSLog(@"Product Request Status: %@",error.localizedDescription);
}



@end
