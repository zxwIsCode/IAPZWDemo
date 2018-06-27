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

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        _productsPurchased = [[NSMutableArray alloc] initWithCapacity:0];
        _productsRestored = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return self;
}

#pragma mark -
#pragma mark Make a purchase

-(void)buy:(SKProduct *)product
{
    SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}


#pragma mark -
#pragma mark Has purchased products

-(BOOL)hasPurchasedProducts
{

    return (self.productsPurchased.count > 0);
}


#pragma mark -
#pragma mark Has restored products

// Returns whether there are restored purchases
-(BOOL)hasRestoredProducts
{

    return (self.productsRestored.count > 0);
}


#pragma mark -
#pragma mark Restore purchases

-(void)restore
{
    self.productsRestored = [[NSMutableArray alloc] initWithCapacity:0];
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}


#pragma mark -
#pragma mark SKPaymentTransactionObserver methods

// Called when there are trasactions in the payment queue
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for(SKPaymentTransaction * transaction in transactions)
    {
        switch (transaction.transactionState )
        {
            case SKPaymentTransactionStatePurchasing:
                break;
                
            case SKPaymentTransactionStateDeferred:

                break;
            case SKPaymentTransactionStatePurchased:
            {
                self.purchasedID = transaction.payment.productIdentifier;
                [self.productsPurchased addObject:transaction];
                

                if(transaction.downloads && transaction.downloads.count > 0)
                {
                    [self completeTransaction:transaction forStatus:IAPDownloadStarted];
                }
                else
                {
                    [self completeTransaction:transaction forStatus:IAPPurchaseSucceeded];
                }
            }
                break;
            case SKPaymentTransactionStateRestored:
            {
                self.purchasedID = transaction.payment.productIdentifier;
                [self.productsRestored addObject:transaction];
                
                NSLog(@"Restore content for %@",transaction.payment.productIdentifier);
                if(transaction.downloads && transaction.downloads.count > 0)
                {
                    [self completeTransaction:transaction forStatus:IAPDownloadStarted];
                }
                else
                {
                    [self completeTransaction:transaction forStatus:IAPRestoredSucceeded];
                }
            }
                break;
            case SKPaymentTransactionStateFailed:
            {
                self.message = [NSString stringWithFormat:@"Purchase of %@ failed.",transaction.payment.productIdentifier];
                [self completeTransaction:transaction forStatus:IAPPurchaseFailed];
            }
                break;
            default:
                break;
        }
    }
}


- (void)paymentQueue:(SKPaymentQueue *)queue updatedDownloads:(NSArray *)downloads
{
    for (SKDownload* download in downloads)
    {
        switch (download.downloadState)
        {
            case SKDownloadStateActive:
            {
                self.status = IAPDownloadInProgress;
                self.purchasedID = download.transaction.payment.productIdentifier;
                self.downloadProgress = download.progress*100;
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
                NSLog(@"Download was paused");
                break;
                
            case SKDownloadStateFinished:
                NSLog(@"Location of downloaded file %@",download.contentURL);
                [self finishDownloadTransaction:download.transaction];
                break;
                
            case SKDownloadStateWaiting:
                NSLog(@"Download Waiting");
                [[SKPaymentQueue defaultQueue] startDownloads:@[download]];
                break;
                
            default:
                break;
        }
    }
}


- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions
{
    for(SKPaymentTransaction * transaction in transactions)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:IAPZWBuyResultNotificationCancle object:self];
        NSLog(@"%@ was removed from the payment queue.", transaction.payment.productIdentifier);
    }
}


- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    if (error.code != SKErrorPaymentCancelled)
    {
        self.status = IAPRestoredFailed;
        self.message = error.localizedDescription;
        [[NSNotificationCenter defaultCenter] postNotificationName:IAPZWBuyResultNotification object:self];
    }
}


- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    NSLog(@"All restorable transactions have been processed by the payment queue.");
}


#pragma mark -
#pragma mark Complete transaction


-(void)completeTransaction:(SKPaymentTransaction *)transaction forStatus:(NSInteger)status
{
    self.status = status;
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:IAPZWBuyResultNotification object:self];
    }
    
    if (status == IAPDownloadStarted) // 开始下单
    {
        [[SKPaymentQueue defaultQueue] startDownloads:transaction.downloads];
    }
    else // 已经下单购买完成
    {
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    }
}


#pragma mark -
#pragma mark - Handle download transaction

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
        self.status = IAPDownloadSucceeded;
        
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
        [[NSNotificationCenter defaultCenter] postNotificationName:IAPZWBuyResultNotification object:self];
        
        if ([self.productsRestored containsObject:transaction])
        {
            self.status = IAPRestoredSucceeded;
            [[NSNotificationCenter defaultCenter] postNotificationName:IAPZWBuyResultNotification object:self];
        }
        
    }
}

@end
