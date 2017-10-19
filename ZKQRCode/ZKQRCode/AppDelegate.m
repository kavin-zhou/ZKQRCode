//
//  AppDelegate.m
//  ZKQRCode
//
//  Created by ZK on 16/10/17.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import "AppDelegate.h"
#import "ZKMainViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    _window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _window.backgroundColor = [UIColor whiteColor];
    [_window makeKeyAndVisible];
 
    ZKMainViewController *mainVC = [[ZKMainViewController alloc] init];
    UINavigationController *navc = [[UINavigationController alloc] initWithRootViewController:mainVC];
    _window.rootViewController = navc;
    
    return YES;
}

@end
