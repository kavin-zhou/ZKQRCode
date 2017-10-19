//
//  ZKQRScanView.m
//  ZKQRCode
//
//  Created by Zhou Kang on 2017/10/18.
//  Copyright © 2017年 ZK. All rights reserved.
//

#import "ZKQRScanView.h"

@interface ZKQRScanView ()

@property (nonatomic, strong) UIView           *maskView;
@property (nonatomic, strong) UIView           *scanWindow;
@property (nonatomic, strong) UIImageView      *scanNetImageView;

@end

@implementation ZKQRScanView

+ (instancetype)showInView:(UIView *)view {
    ZKQRScanView *scanView = [ZKQRScanView new];
    [view addSubview:scanView];
    scanView.frame = view.bounds;
    [scanView setupMaskView];
    [scanView setupScanWindowView];
    
    return scanView;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    [self addObserver];
}

- (void)addObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)setupMaskView {
    _maskView = [[UIView alloc] init];
    _maskView.backgroundColor = [UIColor clearColor];
    _maskView.frame = [UIScreen mainScreen].bounds;
    [self addSubview:_maskView];
    
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

- (void)setupScanWindowView {
    _scanWindow = [[UIView alloc] init];
    _scanWindow.clipsToBounds = YES;
    [_maskView addSubview:_scanWindow];
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

#pragma mark 开始动画

- (void)startAnimation {
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

- (void)handleDidEnterBackground {
    [_scanNetImageView.layer removeAllAnimations];
}

- (void)handleWillEnterForeground {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self startAnimation];
    });
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
