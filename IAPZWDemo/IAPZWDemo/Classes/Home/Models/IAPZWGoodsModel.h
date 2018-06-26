//
//  IAPZWGoodsModel.h
//  IAPZWDemo
//
//  Created by XDWY on 2018/6/26.
//  Copyright © 2018年 DaviD. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IAPZWGoodsModel : NSObject

@property(nonatomic,copy)NSString *productName;
@property(nonatomic,copy)NSString *productIds;
// 是否有效，无效是NO，有效是YES
@property(nonatomic,assign)BOOL isValid;

@property(nonatomic,strong)NSArray *productListArr;

@end
