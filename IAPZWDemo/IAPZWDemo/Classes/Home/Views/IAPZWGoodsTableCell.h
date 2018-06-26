//
//  IAPZWGoodsTableCell.h
//  IAPZWDemo
//
//  Created by XDWY on 2018/6/26.
//  Copyright © 2018年 DaviD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IAPZWGoodsModel.h"

#import <StoreKit/StoreKit.h>


#define kIAPZWGoodsTableCellHeight 100 *kAppScale

@interface IAPZWGoodsTableCell : UITableViewCell

+(instancetype)updateWithTableView:(UITableView *)tableView;

@property(nonatomic,strong)IAPZWGoodsModel *goodsModel;

@property(nonatomic,strong)SKProduct *aProduct;

@end
