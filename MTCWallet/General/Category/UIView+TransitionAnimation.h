//
//  UIView+TransitionAnimation.h
//  ZSEthersWallet
//
//  Created by thomasho on 2018/1/3.
//  Copyright © 2018年 lkl. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  动画类型
 */
typedef NS_ENUM(NSUInteger, AnimationType) {
    AnimationType_Fade = 1,                   //淡入淡出
    AnimationType_Push,                       //推挤
    AnimationType_Reveal,                     //揭开
    AnimationType_MoveIn,                     //覆盖
    AnimationType_Cube,                       //立方体
    AnimationType_SuckEffect,                 //吮吸
    AnimationType_OglFlip,                    //翻转
    AnimationType_RippleEffect,               //波纹
    AnimationType_PageCurl,                   //翻页
    AnimationType_PageUnCurl,                 //反翻页
    AnimationType_CameraIrisHollowOpen,       //开镜头
    AnimationType_CameraIrisHollowClose,      //关镜头
    AnimationType_CurlDown,                   //下翻页
    AnimationType_CurlUp,                     //上翻页
    AnimationType_FlipFromLeft,               //左翻转
    AnimationType_FlipFromRight,              //右翻转
};

/**
 *  动画方向
 */
typedef NS_ENUM(NSUInteger, Direction){
    Direction_Left,                 //左
    Direction_Right,                //右
    Direction_Top,                  //顶部
    Direction_Bottom,               //底部
    Direction_Middle,
};

@interface UIView (TransitionAnimation)

/**
 *  动画设置
 *
 *  @param animation    动画
 *  @param durationTime 动画时间
 *  @param subtype      过渡方向
 */
- (void)setAnimationWithType:(AnimationType)animation
                    duration:(float)durationTime
            directionSubtype:(Direction)subtype;

@end
