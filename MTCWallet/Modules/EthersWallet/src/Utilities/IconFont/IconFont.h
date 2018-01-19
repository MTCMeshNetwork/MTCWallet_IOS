//
//  IconFont.h
//  ZSEthersWallet
//
//  Created by thomasho on 2018/1/5.
//  Copyright © 2018年 lkl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IconInfo.h"

#define IconInfoMake(text, imageSize, imageColor) [IconInfo iconInfoWithText:text size:imageSize color:imageColor]

@interface IconFont : NSObject

+ (UIFont *)fontWithSize: (CGFloat)size;
+ (void)setFontName:(NSString *)fontName;

@end
