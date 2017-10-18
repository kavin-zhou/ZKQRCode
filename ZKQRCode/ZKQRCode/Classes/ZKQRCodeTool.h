//
//  ZKQRCodeTool.h
//  ZKQRCode
//
//  Created by Zhou Kang on 2017/10/18.
//  Copyright © 2017年 ZK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZKQRCodeTool : NSObject

+ (NSString *)readQRCodeFromImage:(UIImage *)image;

+ (UIImage *)qrImageForString:(NSString *)string
                    imageSize:(CGFloat)imageSize
                     topImage:(UIImage *)topImage
                    tintColor:(UIColor *)tintColor;
+ (void)turnTorchOn:(BOOL)on;

@end
