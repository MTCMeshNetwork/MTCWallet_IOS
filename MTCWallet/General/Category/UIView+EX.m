//
//  UIView+EX.m
//  LZCommonUtilKits
//
//  Created by thomasho on 2017/12/28.
//  Copyright © 2017年 lkl. All rights reserved.
//

#import "UIView+EX.h"

@implementation UIView (EX)

+ (NSString *)at_identifier {
    return NSStringFromClass([self class]);
}


- (CGSize) size
{
    return self.bounds.size;
}

- (float) left
{
    return self.frame.origin.x;
}

- (void) setLeft:(float)left
{
    CGRect rtFrame = self.frame;
    rtFrame.origin.x = left;
    [self setFrame:rtFrame];
}

- (float) top
{
    return self.frame.origin.y;
}

- (void) setTop:(float)top
{
    CGRect rtFrame = self.frame;
    rtFrame.origin.y = top;
    [self setFrame:rtFrame];
}

- (float) right
{
    return self.left + self.width;
}

- (void) setRight:(float)right
{
    CGRect rtFrame = self.frame;
    rtFrame.origin.x = right - self.width;
    [self setFrame:rtFrame];
}

- (float) bottom
{
    return self.top + self.height;
}

- (void) setBottom:(float)bottom
{
    CGRect rtFrame = self.frame;
    rtFrame.origin.y = bottom - self.height;
    [self setFrame:rtFrame];
}

- (float) width
{
    return self.size.width;
}

- (void) setWidth:(float)width
{
    CGRect rtFrame = self.frame;
    rtFrame.size.width = width;
    [self setFrame:rtFrame];
}

- (float) height
{
    return self.size.height;
}

- (void) setHeight:(float)height
{
    CGRect rtFrame = self.frame;
    rtFrame.size.height = height;
    [self setFrame:rtFrame];
}

@end
