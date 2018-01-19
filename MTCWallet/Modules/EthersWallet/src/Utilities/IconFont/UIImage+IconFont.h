//
//  UIImage+IconFont.h
//  ZSEthersWallet
//
//  Created by thomasho on 2018/1/5.
//  Copyright © 2018年 lkl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IconInfo.h"
#import "IconFont.h"

@interface UIImage (IconFont)

+ (UIImage *)iconWithInfo:(IconInfo *)info;

@end
