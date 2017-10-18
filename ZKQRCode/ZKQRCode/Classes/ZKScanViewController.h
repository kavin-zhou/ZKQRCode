//
//  ZKScanViewController.h
//  ZKQRCode
//
//  Created by ZK on 16/10/17.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZKScanViewController;

@protocol ZKScanViewControllerDelegate <NSObject>

@optional

- (void)scanViewController:(ZKScanViewController *)scanViewController
     didOutputResultString:(NSString *)resultString;

@end

@interface ZKScanViewController : UIViewController

@property (nonatomic, weak) id <ZKScanViewControllerDelegate> delegate;

@end
