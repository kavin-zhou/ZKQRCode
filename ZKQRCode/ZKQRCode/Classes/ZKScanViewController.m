//
//  ZKScanViewController.m
//  ZKQRCode
//
//  Created by ZK on 16/10/17.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import "ZKScanViewController.h"

#define HollowRect   (CGRect){kLeftRightMargin, 120.f*WindowZoomScale, SCREEN_WIDTH-kLeftRightMargin*2, SCREEN_WIDTH-kLeftRightMargin*2}

@interface ZKScanViewController ()<UIAlertViewDelegate,AVCaptureMetadataOutputObjectsDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) UIView           *maskView;
@property (nonatomic, strong) UIView           *scanWindow;
@property (nonatomic, strong) UIImageView      *scanNetImageView;

@end

static const CGFloat kLeftRightMargin = 40.f;

@implementation ZKScanViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupUI];
    [self beginScanning];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleWillEnterForeground) name:Notification_WillEnterForeground object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeAnimation) name:Notification_DidEnterBackground object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // 开始扫描动画
    [self startAnimation];
}

- (void)setupUI
{
    self.navigationController.navigationBar.hidden = YES;
    
    [self setupMaskView];
    [self setupBottomBar];
    [self setupNavView];
    [self setupScanWindowView];
}

-(void)setupNavView
{
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
    [albumBtn addTarget:self action:@selector(myAlbum) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton * flashBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [navBar addSubview:flashBtn];
    flashBtn.size = albumBtn.size;
    flashBtn.right = SCREEN_WIDTH-20.f;
    [flashBtn setImage:[UIImage imageNamed:@"qrcode_scan_btn_flash_down"] forState:UIControlStateNormal];
    flashBtn.contentMode = UIViewContentModeScaleAspectFit;
    [flashBtn addTarget:self action:@selector(openFlash:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setupMaskView
{
    _maskView = [[UIView alloc] init];
    _maskView.backgroundColor = [UIColor clearColor];
    _maskView.frame = [UIScreen mainScreen].bounds;
    [self.view addSubview:_maskView];
    
    // 构建镂空效果
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:_maskView.bounds];
    
    UIBezierPath *hollowPath = [UIBezierPath bezierPathWithRect:HollowRect];
    [path appendPath:hollowPath];
    [path setUsesEvenOddFillRule:YES];
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = path.CGPath;
    shapeLayer.fillRule = kCAFillRuleEvenOdd;
    shapeLayer.fillColor = [[UIColor blackColor] colorWithAlphaComponent:.6].CGColor;
    
    [_maskView.layer addSublayer:shapeLayer];
}

- (void)setupBottomBar
{
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

- (void)setupScanWindowView
{
    _scanWindow = [[UIView alloc] init];
    _scanWindow.clipsToBounds = YES;
    [self.view addSubview:_scanWindow];
    _scanWindow.frame = HollowRect;
    
    UIImageView *topLeft = [[UIImageView alloc] init];
    [_scanWindow addSubview:topLeft];
    topLeft.image = [UIImage imageNamed:@"scan_1"];
    topLeft.size = (CGSize){19.f, 19.f};

    UIImageView *topRight = [[UIImageView alloc] init];
    [_scanWindow addSubview:topRight];
    topRight.image = [UIImage imageNamed:@"scan_2"];
    topRight.size = topLeft.size;
    topRight.right = CGRectGetWidth(_scanWindow.frame);

    UIImageView *bottomLeft = [[UIImageView alloc] init];
    [_scanWindow addSubview:bottomLeft];
    bottomLeft.image = [UIImage imageNamed:@"scan_3"];
    bottomLeft.size = topLeft.size;
    bottomLeft.bottom = CGRectGetHeight(_scanWindow.frame)+2.f;
    
    UIImageView *bottomRight = [[UIImageView alloc] init];
    [_scanWindow addSubview:bottomRight];
    bottomRight.image = [UIImage imageNamed:@"scan_4"];
    bottomRight.size = topLeft.size;
    bottomRight.bottom = CGRectGetHeight(_scanWindow.frame)+2.f;
    bottomRight.right = CGRectGetWidth(_scanWindow.frame);
    
    _scanNetImageView = [[UIImageView alloc] init];
    [_scanWindow addSubview:_scanNetImageView];
    _scanNetImageView.size = _scanWindow.bounds.size;
    _scanNetImageView.bottom = 0;
    _scanNetImageView.image = [UIImage imageNamed:@"scan_net"];
}

- (void)beginScanning
{
    //获取摄像设备
    AVCaptureDevice * device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //创建输入流
    AVCaptureDeviceInput * input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    if (!input) return;
    //创建输出流
    AVCaptureMetadataOutput * output = [[AVCaptureMetadataOutput alloc]init];
    //设置代理 在主线程里刷新
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    //设置有效扫描区域 (横屏计算)
    CGRect scanCrop = [self getEffectiveRectWithScanRect:HollowRect defaultRect:self.view.frame];
    output.rectOfInterest = scanCrop;
    //初始化链接对象
    _session = [[AVCaptureSession alloc]init];
    //高质量采集率
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    
    [_session addInput:input];
    [_session addOutput:output];
    //设置扫码支持的编码格式(如下设置条形码和二维码兼容)
    output.metadataObjectTypes=@[ AVMetadataObjectTypeQRCode,
                                  AVMetadataObjectTypeEAN13Code,
                                  AVMetadataObjectTypeEAN8Code,
                                  AVMetadataObjectTypeCode128Code ];
    
    AVCaptureVideoPreviewLayer * layer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    layer.frame = self.view.layer.bounds;
    [self.view.layer insertSublayer:layer atIndex:0];
    //开始捕获
    [_session startRunning];
}

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    if (metadataObjects.count>0) {
        [_session stopRunning];
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex : 0 ];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"扫描结果" message:metadataObject.stringValue delegate:self cancelButtonTitle:@"退出" otherButtonTitles:@"再次扫描", nil];
        [alert show];
    }
}

#pragma mark-> 我的相册

-(void)myAlbum
{
    NSLog(@"我的相册");
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        //1.初始化相册拾取器
        UIImagePickerController *controller = [[UIImagePickerController alloc] init];
        //2.设置代理
        controller.delegate = self;
        //3.设置资源：
        /**
         UIImagePickerControllerSourceTypePhotoLibrary,相册
         UIImagePickerControllerSourceTypeCamera,相机
         UIImagePickerControllerSourceTypeSavedPhotosAlbum,照片库
         */
        controller.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        //4.随便给他一个转场动画
        controller.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentViewController:controller animated:YES completion:NULL];
        
    }
    else {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"设备不支持访问相册，请在设置->隐私->照片中进行设置！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
}

#pragma mark - Noti

- (void)handleWillEnterForeground
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self startAnimation];
    });
}

#pragma mark-> imagePickerController delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //1.获取选择的图片
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    //2.初始化一个监测器
    CIDetector*detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{ CIDetectorAccuracy : CIDetectorAccuracyHigh }];
    
    [picker dismissViewControllerAnimated:YES completion:^{
        //监测到的结果数组
        NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
        if (features.count >= 1) {
            /**结果对象 */
            CIQRCodeFeature *feature = features.firstObject;
            NSString *scannedResult = feature.messageString;
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"扫描结果" message:scannedResult delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        }
        else{
            UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"该图片没有包含一个二维码！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        }
    }];
}

#pragma mark-> 闪光灯

-(void)openFlash:(UIButton*)button
{
    NSLog(@"闪光灯");
    button.selected = !button.selected;
    if (button.selected) {
        [self turnTorchOn:YES];
    }
    else{
        [self turnTorchOn:NO];
    }
}

#pragma mark-> 我的二维码
-(void)myCodeBtnClick
{
    NSLog(@"我的二维码");
}
#pragma mark-> 开关闪光灯
- (void)turnTorchOn:(BOOL)on
{
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    if (captureDeviceClass != nil) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        
        if ([device hasTorch] && [device hasFlash]){
            
            [device lockForConfiguration:nil];
            if (on) {
                [device setTorchMode:AVCaptureTorchModeOn];
                [device setFlashMode:AVCaptureFlashModeOn];
                
            } else {
                [device setTorchMode:AVCaptureTorchModeOff];
                [device setFlashMode:AVCaptureFlashModeOff];
            }
            [device unlockForConfiguration];
        }
    }
}

#pragma mark 开始动画

- (void)startAnimation
{
    CAAnimation *anim = [_scanNetImageView.layer animationForKey:@"groupAnimation"];
    if (anim) {
        /**
         // 1. 将动画的时间偏移量作为暂停时的时间点
         CFTimeInterval pauseTime = _scanNetImageView.layer.timeOffset;
         // 2. 根据媒体时间计算出准确的启动动画时间，对之前暂停动画的时间进行修正
         CFTimeInterval beginTime = CACurrentMediaTime() - pauseTime;
         // 3. 要把偏移时间清零
         [_scanNetImageView.layer setTimeOffset:0.0];
         // 4. 设置图层的开始动画时间
         [_scanNetImageView.layer setBeginTime:beginTime];
         [_scanNetImageView.layer setSpeed:2.0];
         */
    }
    else {
        CABasicAnimation *scanNetAnimation = [CABasicAnimation animation];
        scanNetAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        scanNetAnimation.keyPath = @"transform.translation.y";
        scanNetAnimation.byValue = @(HollowRect.size.height);
        
        CABasicAnimation *alphaAnimation = [CABasicAnimation animation];
        alphaAnimation.beginTime = 1.7;
        alphaAnimation.duration = 0.3;
        alphaAnimation.keyPath = @"opacity";
        alphaAnimation.fromValue = @(1.f);
        alphaAnimation.toValue = @(0);
        
        CAAnimationGroup *group = [CAAnimationGroup animation];
        group.animations = @[scanNetAnimation, alphaAnimation];
        group.duration = 2.0;
        group.repeatCount = MAXFLOAT;
        group.fillMode = kCAFillModeForwards;
        group.removedOnCompletion = NO;
        
        [_scanNetImageView.layer addAnimation:group forKey:@"groupAnimation"];
    }
}

- (void)removeAnimation
{
    [_scanNetImageView.layer removeAllAnimations];
}

#pragma mark-> 获取扫描区域的比例关系

- (CGRect)getEffectiveRectWithScanRect:(CGRect)scanRect defaultRect:(CGRect)defaultRect
{
    CGFloat x, y, width, height;
    CGFloat defaultWidth = CGRectGetWidth(defaultRect);
    CGFloat defaultHeight = CGRectGetHeight(defaultRect);
    
    x = CGRectGetMinX(HollowRect)/defaultWidth;
    y = CGRectGetMinY(HollowRect)/defaultHeight;
    width = CGRectGetWidth(HollowRect)/defaultWidth;
    height = CGRectGetHeight(HollowRect)/defaultHeight;
    
    /**
     这个CGRect参数和普通的Rect范围不太一样，它的四个值的范围都是0-1，表示比例。
     rectOfInterest都是按照横屏来计算的 所以当竖屏的情况下 x轴和y轴要交换一下。
     宽度和高度设置的情况同理。
     */
    return (CGRect){y, x, height, width};
}

#pragma mark-> 返回
- (void)disMiss
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self disMiss];
    } else if (buttonIndex == 1) {
        [_session startRunning];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
