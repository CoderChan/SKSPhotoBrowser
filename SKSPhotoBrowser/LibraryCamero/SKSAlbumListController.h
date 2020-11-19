//
//  SKSAlbumListController.h
//  SKSPhotoManagerDemo
//
//  Created by sks on 2020/2/13.
//  Copyright © 2020 三棵树. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "SKSPhotoConfig.h"

NS_ASSUME_NONNULL_BEGIN

/// 图片专辑列表
@interface SKSAlbumListController : UIViewController

/**
 初始化拍照界面
 @param config 拍照类型
 @return 当前对象
 */
- (instancetype)initWithConfig:(SKSPhotoConfig *)config Completion:(SKSCompletionBlock)completion;




@end

NS_ASSUME_NONNULL_END
