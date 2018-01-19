//
//  AppDelegate.m
//  ZSEthersWallet
//
//  Created by thomasho on 2017/12/28.
//  Copyright © 2017年 lkl. All rights reserved.
//

#import "AppDelegate.h"
#import "ZSBaseNavigationViewController.h"
#import "MainStartHomeViewController.h"

#import <ShareSDKConnector/ShareSDKConnector.h>
#import <ShareSDK/ShareSDK.h>

//微信SDK头文件
#import "WXApi.h"

//腾讯开放平台（对应QQ和QQ空间）SDK头文件
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>

//新浪微博SDK头文件
#import "WeiboSDK.h"

//设置Nav的返回按钮文字，打印当前viewDidLoad
#import "UIViewController+viewDidLoad.h"

#import "Wallet.h"
#import "OptionsVC.h"
#import "Utilities.h"
#import "NSBundleEX.h"

#import "CachedDataStore.h"

@interface AppDelegate () {
    Wallet *_wallet;
}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    CachedDataStore *dataStore = [CachedDataStore sharedCachedDataStoreWithKey:CACHEKEY_APP_DATA];
    if ([dataStore stringForKey:CACHEKEY_APP_DATA_LANGUAGE].length) {
        [NSBundle setLanguage:[dataStore stringForKey:CACHEKEY_APP_DATA_LANGUAGE]];
    }
    if (![dataStore stringForKey:CACHEKEY_APP_DATA_UNIT].length) {
        [dataStore setObject:@"¥" forKey:CACHEKEY_APP_DATA_UNIT];
    }
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleCustom];
    [SVProgressHUD setBackgroundColor:[UIColor blackColor]];
    [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeGradient];
    
    __weak typeof(self) weakSelf = self;
    _runMainController = ^{
        MainStartHomeViewController *homeVC = [[MainStartHomeViewController alloc] init];
        ZSBaseNavigationViewController *nav = [[ZSBaseNavigationViewController alloc] initWithRootViewController:homeVC];
        [weakSelf.window setRootViewController:nav];
    };
    
    _wallet = [Wallet walletWithKeychainKey:@"sharedWallet"];
    if (_wallet.activeAccountIndex == NSNotFound) {
        NSString *heading = NSLocalizedString(@"创建或导入您的钱包", @"Hey Buddy, Come On, Create/Reback your wallet");
        NSArray<NSString*> *options = @[
                                        NSLocalizedString(@"新建钱包", @"Create New Account"),
                                        NSLocalizedString(@"导入钱包", @"Import Existing Account")
                                        ];
        OptionsVC *config = [OptionsVC optionWithHeading:heading subheading:nil messages:@[ICON_FONT_WALLET,ICON_FONT_IMPORT] options:options];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:config];
        self.window.rootViewController = nav;
        config.onOption = ^(OptionsVC *vc, NSUInteger index) {
            if (index == 0) {
                [vc.navigationController pushViewController:[_wallet addAccountCallback:^(Address *address) {
                    weakSelf.runMainController();
                }] animated:YES];
            } else {
                [vc.navigationController pushViewController:[_wallet importAccountcallback:^(Address *address) {
                    weakSelf.runMainController();
                }] animated:YES];
            }
        };
        
    }else {
        _runMainController();
    }
    
//    [self initShareSDK];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


//ToDo：待修改
- (void)initShareSDK
{
    [ShareSDK registerApp:@"iosv1101"
     
          activePlatforms:@[
                            @(SSDKPlatformTypeSinaWeibo),
                            @(SSDKPlatformTypeWechat),
                            @(SSDKPlatformTypeQQ),
                            ]
                 onImport:^(SSDKPlatformType platformType)
     {
         switch (platformType)
         {
             case SSDKPlatformTypeSinaWeibo:
                 [ShareSDKConnector connectWeibo:[WeiboSDK class]];
                 break;
                 
             case SSDKPlatformTypeWechat:
                 [ShareSDKConnector connectWeChat:[WXApi class]];
                 break;
                 
             case SSDKPlatformTypeQQ:
                 [ShareSDKConnector connectQQ:[QQApiInterface class] tencentOAuthClass:[TencentOAuth class]];
                 break;

             default:
                 break;
         }
     }
          onConfiguration:^(SSDKPlatformType platformType, NSMutableDictionary *appInfo)
     {
         
         switch (platformType)
         {
             case SSDKPlatformTypeSinaWeibo:
                 //设置新浪微博应用信息,其中authType设置为使用SSO＋Web形式授权
                 [appInfo SSDKSetupSinaWeiboByAppKey:@"568898243"
                                           appSecret:@"38a4f8204cc784f81f9f0daaf31e02e3"
                                         redirectUri:@"http://www.sharesdk.cn"
                                            authType:SSDKAuthTypeBoth];
                 break;
                 
             case SSDKPlatformTypeWechat:
                 [appInfo SSDKSetupWeChatByAppId:@"wx4868b35061f87885"
                                       appSecret:@"64020361b8ec4c99936c0e3999a9f249"];
                 break;
                 
             case SSDKPlatformTypeQQ:
                 [appInfo SSDKSetupQQByAppId:@"100371282"
                                      appKey:@"aed9b0303e3ed1e27bae87c33761161d"
                                    authType:SSDKAuthTypeBoth];
                 
                 break;
                 
             default:
                 break;
         }
     }];
}
@end
