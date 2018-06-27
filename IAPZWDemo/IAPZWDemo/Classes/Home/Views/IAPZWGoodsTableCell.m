//
//  IAPZWGoodsTableCell.m
//  IAPZWDemo
//
//  Created by XDWY on 2018/6/26.
//  Copyright © 2018年 DaviD. All rights reserved.
//

#import "IAPZWGoodsTableCell.h"

@interface IAPZWGoodsTableCell ()

@property(nonatomic,strong)UILabel *leftLable;

@property(nonatomic,strong)UILabel *rightLable;

@property(nonatomic,strong)UIView *lineView;

@end

@implementation IAPZWGoodsTableCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

+(instancetype)updateWithTableView:(UITableView *)tableView {
    
    static NSString *ID = @"kIAPZWGoodsTableCellId";
    IAPZWGoodsTableCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[IAPZWGoodsTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    return cell;
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self =[super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.leftLable = [[UILabel alloc]init];
        self.rightLable =[[UILabel alloc]init];
        self.lineView =[[UIView alloc]init];
        
        self.leftLable.frame =CGRectMake(10, 0, SCREEN_WIDTH *0.5 -10, kIAPZWGoodsTableCellHeight);
        self.rightLable.frame =CGRectMake(SCREEN_WIDTH *0.5, 0, SCREEN_WIDTH *0.5 -10, kIAPZWGoodsTableCellHeight);
        self.lineView.frame =CGRectMake(0, kIAPZWGoodsTableCellHeight -0.5, SCREEN_WIDTH, 0.5);
        
        self.leftLable.textColor =[UIColor blackColor];
        self.leftLable.font =[UIFont systemFontOfSize:15 *kAppScale];
        self.leftLable.textAlignment =NSTextAlignmentLeft;
        
        self.rightLable.textColor =[UIColor blackColor];
        self.rightLable.font =[UIFont systemFontOfSize:15 *kAppScale];
        self.rightLable.textAlignment =NSTextAlignmentRight;
        
        self.lineView.backgroundColor =UIColorFromHexValue(0xdddddd);
        
        [self.contentView addSubview:self.leftLable];
        [self.contentView addSubview:self.rightLable];
        [self.contentView addSubview:self.lineView];
    }
    return self;
}


-(void)setAProduct:(SKProduct *)aProduct {
    _aProduct =aProduct;
    self.leftLable.text = aProduct.localizedTitle;
    self.rightLable.text =aProduct.productIdentifier;
}


@end
