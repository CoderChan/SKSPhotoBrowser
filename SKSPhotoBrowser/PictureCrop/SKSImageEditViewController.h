//
//  HQImageEditViewController.h
//  CivilAviation
//
//  Created by iOS on 2019/3/29.
//  Copyright © 2019 iOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SKSPhotoConfig.h"

NS_ASSUME_NONNULL_BEGIN

@class SKSImageEditViewController;
typedef void (^SKSEditCompletionBlock)(UIImage *editImage, SKSImageEditViewController *vc);


@interface SKSImageEditViewController : UIViewController

/// 初始化图片裁剪框
/// @param config 配置信息
/// @param originImage 原图
/// @param completion 完成回调
- (instancetype)initWithConfig:(SKSPhotoConfig *)config OriginImage:(UIImage *)originImage Completion:(SKSEditCompletionBlock)completion;

/**
 选取框size
 */
@property (nonatomic, assign) CGSize editViewSize;


/**
 蒙层动画 默认no
 */
@property (nonatomic, assign) BOOL maskViewAnimation;

@end

NS_ASSUME_NONNULL_END
