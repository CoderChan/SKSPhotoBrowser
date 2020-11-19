//
//  SKSPhotoResource.h
//  SKSPhotoManagerDemo
//
//  Created by sks on 2020/3/6.
//  Copyright © 2020 三棵树. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SKSPhotoResource : NSObject

/// 读取SKSPhotoRes.bundle内的图标资源
/// @param name 图片名
+ (UIImage *)imageNamed:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
