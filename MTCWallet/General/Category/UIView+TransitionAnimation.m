//
//  UIView+TransitionAnimation.m
//  ZSEthersWallet
//
//  Created by thomasho on 2018/1/3.
//  Copyright © 2018年 lkl. All rights reserved.
//

#import "UIView+TransitionAnimation.h"

@implementation UIView (TransitionAnimation)

- (void)setAnimationWithType:(AnimationType)animation
                    duration:(float)durationTime
            directionSubtype:(Direction)subtype
{
    //CATransition实体
    CATransition *transition=[CATransition animation];
    //动画时间
    transition.duration = durationTime;transition.endProgress = 0.5;
    //选择动画过渡方向
    switch (subtype) {
        case Direction_Left:
            transition.subtype = kCATransitionFromLeft;
            break;
            
        case Direction_Right:
            transition.subtype = kCATransitionFromRight;
            break;
            
        case Direction_Top:
            transition.subtype = kCATransitionFromTop;
            break;
            
        case Direction_Bottom:
            transition.subtype = kCATransitionFromBottom;
            break;
            
        case Direction_Middle:
            transition.subtype = kCATruncationMiddle;
            break;
            
        default:
            break;
    }
    
    //选择动画效果
    switch (animation)
    {
        case AnimationType_Fade:
            transition.type = @"fade";
            break;
            
        case AnimationType_Push:
            transition.type = @"push";
            break;
            
        case AnimationType_Reveal:
            transition.type = @"reveal";
            break;
            
        case AnimationType_MoveIn:
            transition.type = @"moveIn";
            break;
            
        case AnimationType_Cube:
            transition.type = @"cube";
            break;
            
        case AnimationType_SuckEffect:
            transition.type = @"suckEffect";
            break;
            
        case AnimationType_OglFlip:
            transition.type = @"oglFlip";
            break;
            
        case AnimationType_RippleEffect:
            transition.type = @"rippleEffect";
            break;
            
        case AnimationType_PageCurl:
            transition.type = @"pageCurl";
            break;
            
        case AnimationType_PageUnCurl:
            transition.type = @"pageUnCurl";
            break;
            
        case AnimationType_CameraIrisHollowOpen:
            transition.type = @"cameraIrisHollowOpen";
            break;
            
        case AnimationType_CameraIrisHollowClose:
            transition.type = @"cameraIrisHollowClose";
            break;
            
        case AnimationType_CurlDown:
            transition.type = @"curlDown";
            break;
            
        case AnimationType_CurlUp:
            transition.type = @"curlUp";
            break;
            
        case AnimationType_FlipFromLeft:
            transition.type = @"flipFromLeft";
            break;

        case AnimationType_FlipFromRight:
            transition.type = @"flipFromRight";
            break;
        default:
            break;
    }
    //动画加到图层上
    
    [self.layer addAnimation:transition forKey:nil];
}

@end
