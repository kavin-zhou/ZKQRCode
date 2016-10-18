//
//  ZKCodeGenerator.h
//  ZKQRCode
//
//  Created by ZK on 16/10/18.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZKCodeGenerator : NSObject

+ (UIImage *)qrImageForString:(NSString *)string
                    imageSize:(CGFloat)imageSize
                     topImage:(UIImage *)topImage
                    tintColor:(UIColor *)tintColor;

@end
