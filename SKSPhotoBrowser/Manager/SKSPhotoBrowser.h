//
//  SKSPhotoBrowser.h
//  SKSPhotoManagerDemo
//
//  Created by sks on 2020/2/13.
//  Copyright © 2020 三棵树. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SKSPhotoConfig.h"

@interface SKSPhotoBrowser : NSObject

/// 初始化
+ (instancetype)shared;

/// 弹出相册选择框
/// @param controller 从哪个控制器弹出
/// @param config 配置信息
/// @param completion 回调
- (void)showInView:(UIViewController *)controller Config:(SKSPhotoConfig *)config Completion:(SKSCompletionBlock)completion;

@end


