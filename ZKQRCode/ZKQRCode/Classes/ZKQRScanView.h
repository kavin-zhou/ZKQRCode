//
//  ZKQRScanView.h
//  ZKQRCode
//
//  Created by Zhou Kang on 2017/10/18.
//  Copyright © 2017年 ZK. All rights reserved.
//

#import <UIKit/UIKit.h>

#define HollowRect   (CGRect){kLeftRightMargin, 120.f*WindowZoomScale, SCREEN_WIDTH-kLeftRightMargin*2, SCREEN_WIDTH-kLeftRightMargin*2}
static const CGFloat kLeftRightMargin = 40.f;

@interface ZKQRScanView : UIView

+ (instancetype)showInView:(UIView *)view;
- (void)startAnimation;

@end
