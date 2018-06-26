//
//  CMHomeViewController.m
//  ComeMoneyHere
//
//  Created by 李保东 on 16/11/15.
//  Copyright © 2016年 DaviD. All rights reserved.
//

#import "CMHomeViewController.h"

#import "IAPZWGoodsViewController.h"





@interface CMHomeViewController ()


@property(nonatomic,strong)NSArray *testArray;

@property(nonatomic,strong)UIButton *comeInBtn;

@end

@implementation CMHomeViewController

#pragma mark - Init

- (void)viewDidLoad {

    [super viewDidLoad];

    self.view.backgroundColor =[UIColor whiteColor];

    [self.view addSubview:self.comeInBtn];
    self.comeInBtn.bounds =CGRectMake(0, 0, 200, 40);
    self.comeInBtn.center =CGPointMake(SCREEN_WIDTH *0.5, SCREEN_HEIGHT *0.5);
    
    self.comeInBtn.backgroundColor =[UIColor redColor];
    

    // Do any additional setup after loading the view.
}



#pragma mark - Private Methods


#pragma mark - Action Methods
-(void)comeInBtnClick:(UIButton *)btn {
    IAPZWGoodsViewController *vc =[[IAPZWGoodsViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark - 子类继承

-(CMNavType)getNavType {
    return CMNavTypeAll;
}

#pragma mark - Setter & Getter
-(UIButton *)comeInBtn {
    if (!_comeInBtn) {
        _comeInBtn =[UIButton buttonWithType:UIButtonTypeCustom];
        [_comeInBtn setTitle:@"IAP支付" forState:UIControlStateNormal];
        [_comeInBtn addTarget:self action:@selector(comeInBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _comeInBtn;
}

@end
