//
//  UIView+SKSFrame.m
//  SKSPhotoManagerDemo
//
//  Created by sks on 2020/3/6.
//  Copyright © 2020 三棵树. All rights reserved.
//

#import "UIView+SKSFrame.h"

@implementation UIView (SKSFrame)

- (CGFloat)sks_top {
    return self.frame.origin.y;
}

- (void)setSks_top:(CGFloat)sks_top {
    CGRect rect = self.frame;
    rect.origin.y = sks_top;
    self.frame = rect;
}

- (CGFloat)sks_bottom {
    return CGRectGetMaxY(self.frame);
}

- (void)setSks_bottom:(CGFloat)sks_bottom {
    CGRect rect = self.frame;
    rect.origin.y = sks_bottom - rect.size.height;
    self.frame = rect;
}

- (CGFloat)sks_left {
    return self.frame.origin.x;
}

- (void)setSks_left:(CGFloat)sks_left {
    CGRect rect = self.frame;
    rect.origin.x = sks_left;
    self.frame = rect;
}

- (CGFloat)sks_right {
    return CGRectGetMaxX(self.frame);
}

- (void)setSks_right:(CGFloat)sks_right {
    CGRect rect = self.frame;
    rect.origin.x = sks_right - rect.size.width;
    self.frame = rect;
}

- (CGFloat)sks_width {
    return self.frame.size.width;
}

- (void)setSks_width:(CGFloat)sks_width {
    CGRect rect = self.frame;
    rect.size.width = sks_width;
    self.frame = rect;
}

- (CGFloat)sks_height {
    return self.frame.size.height;
}

- (void)setSks_height:(CGFloat)sks_height {
    CGRect rect = self.frame;
    rect.size.height = sks_height;
    self.frame = rect;
}

- (CGFloat)sks_centerX {
    return self.center.x;
}

- (void)setSks_centerX:(CGFloat)sks_centerX {
    self.center = CGPointMake(sks_centerX, self.center.y);
}

- (CGFloat)sks_centerY {
    return self.center.y;
}

- (void)setSks_centerY:(CGFloat)sks_centerY {
    self.center = CGPointMake(self.center.x, sks_centerY);
}

- (CGPoint)sks_origin {
    return self.frame.origin;
}

- (void)setSks_origin:(CGPoint)sks_origin {
    CGRect rect = self.frame;
    rect.origin = sks_origin;
    self.frame = rect;
}

- (CGSize)sks_size {
    return self.frame.size;
}

- (void)setSks_size:(CGSize)sks_size {
    CGRect rect = self.frame;
    rect.size = sks_size;
    self.frame = rect;
}

@end
