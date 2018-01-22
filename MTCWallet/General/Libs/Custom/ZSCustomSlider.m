//
//  ZSCustomSlider.m
//  ZSEthersWallet
//
//  Created by L on 2018/1/5.
//  Copyright © 2018年 lkl. All rights reserved.
//

#import "ZSCustomSlider.h"

@implementation ZSCustomSlider

-(id)initWithFrame:(CGRect)frame
{
    if (self=[super initWithFrame:frame]) {
        [self normalSettings];
        [self loadGradientLayers];
    }
    return self;
}

-(void)normalSettings{
    self.minimumTrackTintColor=[UIColor clearColor];
    self.maximumTrackTintColor=[UIColor clearColor];
}

-(void)loadGradientLayers{
    self.colorArray = @[(id)[[UIColor greenColor] CGColor],
                        (id)[[UIColor redColor] CGColor],
                        ];
    self.colorLocationArray = @[@0.3, @0.7];
    [self.gradientLayer removeFromSuperlayer];
    self.gradientLayer =  [CAGradientLayer layer];
//    self.gradientLayer.frame = CGRectMake(2,-2,self.frame.size.width-2,10);
    self.gradientLayer.frame = CGRectMake(2,10,ScreenWidth-100,10);
    self.gradientLayer.masksToBounds = YES;
//    self.gradientLayer.cornerRadius = 10;
    [self.gradientLayer setLocations:self.colorLocationArray];
    [self.gradientLayer setColors:self.colorArray];
    [self.gradientLayer setStartPoint:CGPointMake(0, 0)];
    [self.gradientLayer setEndPoint:CGPointMake(1, 0)];
    [self.layer insertSublayer:self.gradientLayer atIndex:0];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self loadGradientLayers];
}

@end
