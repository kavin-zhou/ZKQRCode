//
//  ZKCodeGenerator.m
//  ZKQRCode
//
//  Created by ZK on 16/10/18.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import "ZKCodeGenerator.h"
#import "UIImage+ZKAdd.h"

@implementation ZKCodeGenerator

+ (UIImage *)qrImageForString:(NSString *)string
                    imageSize:(CGFloat)imageSize
                     topImage:(UIImage *)topImage
                    tintColor:(UIColor *)tintColor
{
    NSString *urlString = string;
    NSData *data = [urlString dataUsingEncoding:NSUTF8StringEncoding]; // NSISOLatin1StringEncoding 编码
    
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setValue:data forKey:@"inputMessage"];
    
    CIImage *outputImage = filter.outputImage;
    
    CGAffineTransform transform = CGAffineTransformMakeScale(2, 2); // scale 为放大倍数
    CIImage *transformImage = [outputImage imageByApplyingTransform:transform];
    
    // 保存
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef imageRef = [context createCGImage:transformImage fromRect:transformImage.extent];
    
    UIImage *qrCodeImage = [UIImage imageWithCGImage:imageRef];
    
    // 对图片做处理, 使图片大小合适，清晰，效果好
    
    UIGraphicsBeginImageContext(CGSizeMake(imageSize, imageSize));
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(contextRef, kCGInterpolationNone);
    [qrCodeImage drawInRect:CGRectMake(0, 0, imageSize, imageSize)];
    UIImage *needImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    needImg = [needImg zk_changeColorTo:[UIColor yellowColor]];
    
    return needImg;
}

@end
