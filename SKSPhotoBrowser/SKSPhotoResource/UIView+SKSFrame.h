//
//  UIView+SKSFrame.h
//  SKSPhotoManagerDemo
//
//  Created by sks on 2020/3/6.
//  Copyright © 2020 三棵树. All rights reserved.
//


#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (SKSFrame)

@property (nonatomic, assign) CGFloat sks_top;
@property (nonatomic, assign) CGFloat sks_bottom;
@property (nonatomic, assign) CGFloat sks_left;
@property (nonatomic, assign) CGFloat sks_right;
@property (nonatomic, assign) CGFloat sks_width;
@property (nonatomic, assign) CGFloat sks_height;
@property (nonatomic, assign) CGFloat sks_centerX;
@property (nonatomic, assign) CGFloat sks_centerY;
@property (nonatomic, assign) CGPoint sks_origin;
@property (nonatomic, assign) CGSize sks_size;

@end

NS_ASSUME_NONNULL_END
