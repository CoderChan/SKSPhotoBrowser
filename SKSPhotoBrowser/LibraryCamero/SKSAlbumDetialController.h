//
//  SKSAlbumDetialController.h
//  SKSPhotoManagerDemo
//
//  Created by sks on 2020/2/25.
//  Copyright © 2020 三棵树. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SKSAlbumModel.h"
#import "SKSPhotoConfig.h"

NS_ASSUME_NONNULL_BEGIN

@interface SKSAlbumDetialController : UIViewController

/// 前往专辑详情界面
/// @param model 专辑模型
/// @param config 配置信息
/// @param completion 完成
- (instancetype)initWithModel:(SKSAlbumModel *)model Config:(SKSPhotoConfig *)config Completion:(SKSCompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
