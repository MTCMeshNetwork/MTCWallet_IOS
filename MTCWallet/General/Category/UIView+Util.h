//
//  UIView+Uti.h
//  launcher
//
//  Created by thomasho on 2017/12/28.
//  Copyright © 2017年 lkl. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^GestureActionBlock)(UIGestureRecognizer *gestureRecoginzer);

@interface UIView (Util)

/**
 *  要扩张的尺寸
 */
@property (nonatomic, assign) CGSize expandSize;

/**
 *  @brief  添加tap手势
 *
 *  @param block 代码块
 */
- (void)addTapActionWithBlock:(GestureActionBlock)block;

#pragma mark -- 添加动画
- (void)addAnimationForView;
@end
