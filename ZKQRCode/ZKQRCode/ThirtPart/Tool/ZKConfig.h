//
//  ZKConfig.h
//  ZKIM
//
//  Created by ZK on 16/9/13.
//  Copyright © 2016年 ZK. All rights reserved.
//

#import <Foundation/Foundation.h>

#define _applicationContext [ApplicationContext sharedContext]
#define _loginUser          [AuthData loginUser]

#define RGBCOLOR(r,g,b)     [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1] //RGB进制颜色值
#define RGBACOLOR(r,g,b,a)  [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)] //RGBA进制颜色值
#define HexColor(hexValue)  [UIColor colorWithRed:((float)(((hexValue) & 0xFF0000) >> 16))/255.0 green:((float)(((hexValue) & 0xFF00) >> 8))/255.0 blue:((float)((hexValue) & 0xFF))/255.0 alpha:1]   //16进制颜色值，如：#000000 , 注意：在使用的时候hexValue写成：0x000000

#define GlobalGreenColor   RGBCOLOR(31.f, 185.f, 34.f)
#define GlobalBGColor      RGBCOLOR(239.f, 239.f, 245.f)
#define GlobalChatBGColor      RGBCOLOR(230.f, 230.f, 230.f)

#ifdef __OBJC__
#ifdef DEBUG
#define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define DLog(...)
#endif
#endif

extern NSString *const kAppKey_EM;
extern NSString *const UserDefaultKey_LoginUser;
extern NSString *const UserDefaultKey_LoginResult;
extern NSString *const Notification_LoginSuccess;
extern NSString *const UserDefaultKey_timeDifference;
extern NSString *const Notification_WillEnterForeground;
extern NSString *const Notification_DidEnterBackground;



