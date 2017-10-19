//
//  ZKScanViewController.m
//  ZKQRCode
//
//  Created by ZK on 16/10/17.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import "ZKScanViewController.h"
#import "ZKQRCodeTool.h"
#import "ZKQRScanView.h"

@interface ZKScanViewController () <UIAlertViewDelegate, AVCaptureMetadataOutputObjectsDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) ZKQRScanView *scanView;

@end

@implementation ZKScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
    [self beginScanning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_scanView startAnimation];
}

- (void)setupViews {
    self.navigationController.navigationBar.hidden = YES;
    _scanView = [ZKQRScanView showInView:self.view];
    [self setupBottomBar];
    [self setupNavView];
}

-(void)setupNavView {
    UIView *navBar = [[UIView alloc] init];
    [self.view addSubview:navBar];
    navBar.frame = (CGRect){0, 30.f, SCREEN_WIDTH, 64.f};
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [navBar addSubview:backBtn];
    backBtn.left = 20.f;
    backBtn.size = (CGSize){navBar.height, navBar.height};
    [backBtn setImage:[UIImage imageNamed:@"qrcode_scan_titlebar_back_nor"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(disMiss) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton * albumBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [navBar addSubview:albumBtn];
    albumBtn.size = (CGSize){48.f, navBar.height};
    albumBtn.centerX = navBar.centerX;
    [albumBtn setImage:[UIImage imageNamed:@"qrcode_scan_btn_photo_down"] forState:UIControlStateNormal];
    albumBtn.contentMode = UIViewContentModeCenter;
    [albumBtn addTarget:self action:@selector(openAlbum) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton * flashBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [navBar addSubview:flashBtn];
    flashBtn.size = albumBtn.size;
    flashBtn.right = SCREEN_WIDTH-20.f;
    [flashBtn setImage:[UIImage imageNamed:@"qrcode_scan_btn_flash_down"] forState:UIControlStateNormal];
    flashBtn.contentMode = UIViewContentModeScaleAspectFit;
    [flashBtn addTarget:self action:@selector(openFlash:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setupBottomBar {
    UIView *bottomBar = [[UIView alloc] init];
    bottomBar.backgroundColor = [UIColor clearColor];
    bottomBar.size = (CGSize){SCREEN_WIDTH, 100.f};
    bottomBar.top = CGRectGetMaxY(HollowRect)+25.f;
    [self.view addSubview:bottomBar];
    
    UILabel *tipLabel = [[UILabel alloc] init];
    [bottomBar addSubview:tipLabel];
    tipLabel.textAlignment = NSTextAlignmentCenter;
    tipLabel.font = [UIFont systemFontOfSize:AutoFitFontSize(13)];
    tipLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:.8];
    tipLabel.text = @"放入框内, 自动扫描";
    tipLabel.size = (CGSize){bottomBar.width, 30.f};
    
    UIButton *myCodeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [bottomBar addSubview:myCodeBtn];
    [myCodeBtn setTitle:@"我的二维码" forState:UIControlStateNormal];
    [myCodeBtn setTitleColor:RGBCOLOR(20, 120, 227) forState:UIControlStateNormal];
    myCodeBtn.titleLabel.font = [UIFont systemFontOfSize:AutoFitFontSize(15)];
    myCodeBtn.size = (CGSize){100.f, 30.f};
    myCodeBtn.centerX = bottomBar.centerX;
    myCodeBtn.top = CGRectGetMaxY(tipLabel.frame)+5.f;
    [myCodeBtn addTarget:self action:@selector(myCodeBtnClick) forControlEvents:UIControlEventTouchUpInside];
}

- (void)beginScanning {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    if (!input) {
        return;
    };
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    //设置代理 在主线程里刷新
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    //设置有效扫描区域 (横屏计算)
    CGRect scanCrop = [self getEffectiveRectWithScanRect:HollowRect defaultRect:self.view.frame];
    output.rectOfInterest = scanCrop;
    _session = [[AVCaptureSession alloc] init];
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    [_session addInput:input];
    [_session addOutput:output];
    
    output.metadataObjectTypes = @[ AVMetadataObjectTypeQRCode,
                                    AVMetadataObjectTypeEAN13Code,
                                    AVMetadataObjectTypeEAN8Code,
                                    AVMetadataObjectTypeCode128Code ];
    
    AVCaptureVideoPreviewLayer *layer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    layer.frame = self.view.layer.bounds;
    [self.view.layer insertSublayer:layer atIndex:0];
    
    [_session startRunning];
}

#pragma mark - <AVCaptureMetadataOutputObjectsDelegate>

- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if (!metadataObjects.count) {
        return;
    }
    [_session stopRunning];
    AVMetadataMachineReadableCodeObject *metadataObject = metadataObjects.firstObject;
    NSString *resultStr = metadataObject.stringValue;
    if ([self.delegate respondsToSelector:@selector(scanViewController:didOutputResultString:)]) {
        [self.delegate scanViewController:self didOutputResultString:resultStr];
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"扫描结果" message:resultStr delegate:self cancelButtonTitle:@"退出" otherButtonTitles:@"再次扫描", nil];
    [alert show];
}

#pragma mark - Album

- (void)openAlbum {
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *controller = [[UIImagePickerController alloc] init];
        controller.delegate = self;
        /**
         UIImagePickerControllerSourceTypePhotoLibrary,相册
         UIImagePickerControllerSourceTypeCamera,相机
         UIImagePickerControllerSourceTypeSavedPhotosAlbum,照片库
         */
        controller.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        controller.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentViewController:controller animated:YES completion:NULL];
    }
    else {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"设备不支持访问相册，请在设置->隐私->照片中进行设置！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
}

#pragma mark - imagePickerController delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:^{
        NSString *scanResultStr = [ZKQRCodeTool readQRCodeFromImage:image];
        if (!scanResultStr.length) {
            UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"该图片没有包含一个二维码！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
            return;
        }
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"扫描结果" message:scanResultStr delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }];
}

#pragma mark - 闪光灯

-(void)openFlash:(UIButton*)button {
    NSLog(@"闪光灯");
    button.selected = !button.selected;
    if (button.selected) {
        [ZKQRCodeTool turnTorchOn:true];
    }
    else{
        [ZKQRCodeTool turnTorchOn:false];
    }
}

#pragma mark - 我的二维码
-(void)myCodeBtnClick {
    NSLog(@"我的二维码");
}

#pragma mark - 获取扫描区域的比例关系

- (CGRect)getEffectiveRectWithScanRect:(CGRect)scanRect defaultRect:(CGRect)defaultRect {
    CGFloat x, y, width, height;
    CGFloat defaultWidth = CGRectGetWidth(defaultRect);
    CGFloat defaultHeight = CGRectGetHeight(defaultRect);
    
    x = CGRectGetMinX(HollowRect) / defaultWidth;
    y = CGRectGetMinY(HollowRect) / defaultHeight;
    width = CGRectGetWidth(HollowRect) / defaultWidth;
    height = CGRectGetHeight(HollowRect) / defaultHeight;
    
    /**
     这个CGRect参数和普通的Rect范围不太一样，它的四个值的范围都是0-1，表示比例。
     rectOfInterest都是按照横屏来计算的 所以当竖屏的情况下 x轴和y轴要交换一下。
     宽度和高度设置的情况同理。
     */
    return (CGRect){y, x, height, width};
}

#pragma mark - 返回
- (void)disMiss {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self disMiss];
    }
    else if (buttonIndex == 1) {
        [_session startRunning];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
