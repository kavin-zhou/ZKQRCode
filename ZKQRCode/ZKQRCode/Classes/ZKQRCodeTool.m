//
//  ZKQRCodeTool.m
//  ZKQRCode
//
//  Created by Zhou Kang on 2017/10/18.
//  Copyright © 2017年 ZK. All rights reserved.
//

#import "ZKQRCodeTool.h"
#import "UIImage+ZKAdd.h"

@implementation ZKQRCodeTool

+ (NSString *)readQRCodeFromImage:(UIImage *)image {
    //1. 初始化扫描仪，设置设别类型和识别质量
    NSDictionary *detectorOptions = @{CIDetectorAccuracy: CIDetectorAccuracyLow, CIDetectorTracking: @true};
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode
                                              context:nil
                                              options:detectorOptions];
    //2. 扫描获取的特征组
    NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
    
    if (!features.count) {
        NSLog(@"没有识别");
        return nil;
    };
    
    //3. 获取扫描结果
    CIQRCodeFeature *feature = features.firstObject;
    NSString *scannedResult = feature.messageString;
    
    return scannedResult;
}

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
    
    /**
     CGAffineTransform transform = CGAffineTransformMakeScale(2, 2);  //scale 为放大倍数
     CIImage *transformImage = [outputImage imageByApplyingTransform:transform];
     */
    
    // 保存
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef imageRef = [context createCGImage:outputImage fromRect:outputImage.extent];
    
    UIImage *qrCodeImage = [UIImage imageWithCGImage:imageRef];
    
    CGFloat imageSize_pixel = imageSize * [UIScreen mainScreen].scale;
    
    // 对图片做处理, 使图片大小合适，清晰，效果好
    
    UIGraphicsBeginImageContext(CGSizeMake(imageSize_pixel, imageSize_pixel));
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(contextRef, kCGInterpolationNone);
    [qrCodeImage drawInRect:CGRectMake(0, 0, imageSize_pixel, imageSize_pixel)];
    UIImage *needImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    needImg = [needImg zk_changeColorTo:tintColor];
    needImg = [needImg zk_addLogoAtCenterWithLogo:topImage];
    
    return needImg;
}

@end
