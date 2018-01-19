//
//  UIView+BorderLine.h
//  ZSEthersWallet
//
//  Created by thomasho on 2018/1/4.
//  Copyright © 2018年 lkl. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ShowLineType) {
    ShowLineType_Top,     //上
    ShowLineType_Left,    //左
    ShowLineType_Bottom,  //下
    ShowLineType_Right,   //右
};

@interface UIView (BorderLine)

- (void)setShowLineType:(ShowLineType)type;

@end
