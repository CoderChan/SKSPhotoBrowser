//
//  HQEditImageEditView.h
//  CivilAviation
//
//  Created by iOS on 2019/4/1.
//  Copyright © 2019 iOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SKSPhotoConfig.h"

NS_ASSUME_NONNULL_BEGIN
@class SKSEditImageEditView;
@protocol SKSEditImageEditViewDelegate <NSObject>

- (void)editView:(SKSEditImageEditView *)editView anchorPointIndex:(NSInteger)anchorPointIndex rect:(CGRect)rect;

@end

@interface SKSEditImageEditView : UIView

/// 初始化编辑框
/// @param config 配置项
/// @param margin 边框
/// @param size 尺寸
- (instancetype)initWithConfig:(SKSPhotoConfig *)config Margin:(UIEdgeInsets)margin size:(CGSize)size;

/// 编辑代理
@property (nonatomic, weak) id <SKSEditImageEditViewDelegate> delegate;

/// 蒙版
@property (nonatomic, strong) UIView *maskView;

/// 编辑框内的透明区域
@property (nonatomic, strong) UIView *preView;

/// 分割线
@property (nonatomic, strong) UIView *lineWrap;

/// 编辑框内的透明区域，内部4个拖动边边角角
@property (nonatomic, strong) UIView *imageWrap;

@property (nonatomic, assign) CGSize previewSize;
@property (nonatomic, assign) UIEdgeInsets margin;
@property (nonatomic, assign) BOOL maskViewAnimation;

- (void)maskViewShowWithDuration:(CGFloat)duration;
- (void)maskViewHideWithDuration:(CGFloat)duration;

@end

NS_ASSUME_NONNULL_END
