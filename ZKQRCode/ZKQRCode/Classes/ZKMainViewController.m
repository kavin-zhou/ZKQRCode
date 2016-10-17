//
//  ZKMainViewController.m
//  ZKQRCode
//
//  Created by ZK on 16/10/17.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import "ZKMainViewController.h"
#import "ZKScanViewController.h"

@interface ZKMainViewController ()

@property (nonatomic, strong) UIButton *scanBtn;

@end

@implementation ZKMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupUI];
}

- (void)setupUI
{
    _scanBtn = [[UIButton alloc] init];
    _scanBtn.backgroundColor = [[UIColor orangeColor] colorWithAlphaComponent:.6];
    [_scanBtn setTitle:@"扫一扫" forState:UIControlStateNormal];
    [_scanBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _scanBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16.f];
    _scanBtn.size = (CGSize){80.f, 80.f};
    [self.view addSubview:_scanBtn];
    
    [_scanBtn addTarget:self action:@selector(scanBtnClick) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    _scanBtn.left = 10.f;
    _scanBtn.top = 100.f;
}

#pragma mark - Actions

- (void)scanBtnClick
{
    ZKScanViewController *scanVC = [[ZKScanViewController alloc] init];
    [self.navigationController pushViewController:scanVC animated:YES];
}

@end
