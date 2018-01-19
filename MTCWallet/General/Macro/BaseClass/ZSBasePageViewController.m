//
//  ZSBasePageViewController.m
//  ZSEthersWallet
//
//  Created by thomasho on 2017/12/28.
//  Copyright © 2017年 lkl. All rights reserved.
//

#import "ZSBasePageViewController.h"

@interface ZSBasePageViewController ()

@property (nonatomic, strong) UIView *navBarHairlineImageView;
@end

@implementation ZSBasePageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // 设置导航栏颜色
    [self wr_setNavBarBarTintColor:[UIColor commonBackgroundColor]];
    // 设置初始导航栏透明度
    [self wr_setNavBarBackgroundAlpha:1];
//    // 设置导航栏按钮和标题颜色
//    [self wr_setNavBarTintColor:[UIColor whiteColor]];
    [self wr_setNavBarTitleColor:[[UIColor commonWhiteColor] colorWithAlphaComponent:1]];
    
    self.navBarHairlineImageView = [self findHairlineImageViewUnder:self.navigationController.navigationBar];
    [self.view setBackgroundColor:[UIColor whiteColor]];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navBarHairlineImageView.hidden = YES;
}

#pragma mark - Private Method
- (UIImageView *)findHairlineImageViewUnder:(UIView *)view {
    if ([view isKindOfClass:UIImageView.class] && view.bounds.size.height <= 1.0) {
        return (UIImageView *)view;
    }
    for (UIView *subview in view.subviews) {
        UIImageView *imageView = [self findHairlineImageViewUnder:subview];
        if (imageView) {
            return imageView;
        }
    }
    return nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    NSString *className = NSStringFromClass([self class]);
    NSLog(@"内存警告!!! VC = %@",className);
}


- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
