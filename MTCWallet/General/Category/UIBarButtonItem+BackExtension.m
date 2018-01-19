//
//  UIBarButtonItem+BackExtension.m
//  ZSEthersWallet
//
//  Created by thomasho on 2017/12/28.
//  Copyright © 2016年 lkl. All rights reserved.
//

#import "UIBarButtonItem+BackExtension.h"

@implementation UIBarButtonItem (BackExtension)

+ (UIBarButtonItem *)itemWithImageNamed:(NSString *)imageNamed targe:(id)targe action:(SEL)action
{
    UIButton *button = [[UIButton alloc] init];
    [button setBackgroundImage:[UIImage imageNamed:imageNamed] forState:UIControlStateNormal];
    
    button.frame = CGRectMake(0, 0, button.currentBackgroundImage.size.width, button.currentBackgroundImage.size.height);
    
    [button addTarget:targe action:action forControlEvents:UIControlEventTouchUpInside];
    
    return [[UIBarButtonItem alloc] initWithCustomView:button];
}

@end
