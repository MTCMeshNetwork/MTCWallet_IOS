//
//  UIBarButtonItem+BackExtension.h
//  ZSEthersWallet
//
//  Created by thomasho on 2017/12/28.
//  Copyright © 2016年 lkl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (BackExtension)

+ (UIBarButtonItem *)itemWithImageNamed:(NSString *)imageNamed targe:(id)targe action:(SEL)action;

@end
