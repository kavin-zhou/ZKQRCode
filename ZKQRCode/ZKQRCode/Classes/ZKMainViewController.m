//
//  ZKMainViewController.m
//  ZKQRCode
//
//  Created by ZK on 16/10/17.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import "ZKMainViewController.h"
#import "ZKScanViewController.h"
#import "ZKCodeGenerator.h"

@interface ZKMainViewController ()

@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIButton *scanBtn;
@property (nonatomic, strong) UIButton *createBtn;
@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation ZKMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupUI];
}

- (void)setupUI
{
    _textField = [[UITextField alloc] init];
    _textField.backgroundColor = [[UIColor brownColor] colorWithAlphaComponent:.7];
    [self.view addSubview:_textField];
    _textField.layer.masksToBounds = YES;
    _textField.size = (CGSize){200.f, 60.f};
    
    _scanBtn = [self setupBtnWithTitle:@"扫一扫" selector:@selector(scanBtnClick)];
    _createBtn = [self setupBtnWithTitle:@"创建二维码图片" selector:@selector(createBtnClick)];
    
    _imageView = [[UIImageView alloc] init];
    _imageView.userInteractionEnabled = YES;
    [self.view addSubview:_imageView];
    _imageView.size = (CGSize){200.f, 200.f};
    _imageView.backgroundColor = [UIColor clearColor];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    [_imageView addGestureRecognizer:longPress];
}

- (UIButton *)setupBtnWithTitle:(NSString *)title selector:(SEL)selector
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.view addSubview:button];
    button.backgroundColor = [[UIColor orangeColor] colorWithAlphaComponent:.6];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:16.f];
    button.size = _textField.size;
    
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    _textField.top = 100.f;
    _textField.centerX = self.view.centerX;
    
    _scanBtn.top = CGRectGetMaxY(_textField.frame) + 20.f;
    _scanBtn.centerX = self.view.centerX;
    
    _createBtn.top = CGRectGetMaxY(_scanBtn.frame) + 10.f;
    _createBtn.centerX = self.view.centerX;
    
    _imageView.top = CGRectGetMaxY(_createBtn.frame) + 30.f;
    _imageView.centerX = self.view.centerX;
}

#pragma mark - Actions

- (void)scanBtnClick
{
    ZKScanViewController *scanVC = [[ZKScanViewController alloc] init];
    [self.navigationController pushViewController:scanVC animated:YES];
}

- (void)createBtnClick
{
    UIImage *topImage = [UIImage imageNamed:@"me"];
    UIImage *tempImage = [ZKCodeGenerator qrImageForString:_textField.text imageSize:400 topImage:topImage tintColor:[UIColor brownColor]];
    _imageView.image = tempImage;
}

#pragma mark - Gesture

- (void)handleLongPress:(UILongPressGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        
        if(_imageView.image) {
            //1. 初始化扫描仪，设置设别类型和识别质量
            CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{ CIDetectorAccuracy : CIDetectorAccuracyLow, CIDetectorTracking: @YES}];
            //2. 扫描获取的特征组
            NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:_imageView.image.CGImage]];
            
            if (!features.count) {
                NSLog(@"没有识别");
                return;
            };
            
            //3. 获取扫描结果
            CIQRCodeFeature *feature = features.firstObject;
            NSString *scannedResult = feature.messageString;
            UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"扫描结果" message:scannedResult delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        }
        else {
            UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"扫描结果" message:@"您还没有生成二维码" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        }
    }
}

@end
