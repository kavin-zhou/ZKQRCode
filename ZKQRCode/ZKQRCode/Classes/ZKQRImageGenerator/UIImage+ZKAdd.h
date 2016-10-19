//
//  UIImage+ZKAdd.h
//  ZKQRCode
//
//  Created by ZK on 16/10/18.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import <UIKit/UIKit.h>

#define HexColor(hexValue)  [UIColor colorWithRed:((float)(((hexValue) & 0xFF0000) >> 16))/255.0 green:((float)(((hexValue) & 0xFF00) >> 8))/255.0 blue:((float)((hexValue) & 0xFF))/255.0 alpha:1]   //16进制颜色值，如：#000000 , 注意：在使用的时候hexValue写成：0x000000

@interface UIImage (ZKAdd)

- (UIImage *)zk_changeColorTo:(UIColor *)color;

@end
