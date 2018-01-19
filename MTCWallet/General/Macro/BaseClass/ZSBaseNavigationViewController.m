//
//  ZSBaseNavigationViewController.m
//  ZSEthersWallet
//
//  Created by thomasho on 2017/12/29.
//  Copyright © 2017年 lkl. All rights reserved.
//

#import "ZSBaseNavigationViewController.h"

@interface ZSBaseNavigationViewController ()

@end

@implementation ZSBaseNavigationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    self.navigationBar.tintColor = [UIColor commonBackgroundColor];
    [self.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName:[UIFont systemFontOfSize:20.0f]}];
//    [self.navigationBar setTranslucent:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*直接重写A.backBarButtonItem，因为left按钮导致侧滑失效,点击区域
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{   //拦截所有push进来的子控制器
    if(self.viewControllers.count > 0)
    {
        viewController.hidesBottomBarWhenPushed = YES;
        viewController.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithImageNamed:@"back" targe:self action:@selector(backUp)];
    }
    [super pushViewController:viewController animated:animated];
    
}

- (void)backUp
{
    [self popViewControllerAnimated:YES];
}*/

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
