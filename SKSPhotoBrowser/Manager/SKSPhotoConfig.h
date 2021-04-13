//
//  SKSPhotoConfig.h
//  SKSPhotoManagerDemo
//
//  Created by sks on 2020/2/13.
//  Copyright © 2020 三棵树. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    CameroAndPhoto = 0,  // 拍摄和相册一起
    Camero = 1,          // 拍摄选图
    Photo = 2            // 相册里选择
} SKSPhotoPickType;

typedef enum : NSUInteger {
    NoneBorder = 0,       // 没有边框
    SquareBorder = 1,     // 矩形边框
    CircleBorder = 2      // 圆形边框
} SKSPhotoBorderType;

/// 完成的回调
typedef void (^SKSCompletionBlock)(NSArray <UIImage *>*imageArray, NSString *errorMsg);

/// RGB
#define SKSPhoto_RGBACOLOR(R,G,B,A) [UIColor colorWithRed:(R)/255.0f green:(G)/255.0f blue:(B)/255.0f alpha:(A)]


@interface SKSPhotoConfig : NSObject

/// 初始化
+ (instancetype)defaultConfig;

- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)new NS_UNAVAILABLE;

/// 选择来源，默认矩形框：SquareBorder
@property (nonatomic, assign) SKSPhotoPickType pickType;

/// 裁剪框的形式。NoneBorder：没有边框，SquareBorder：矩形边框，CircleBorder： 圆形边框
@property (nonatomic, assign) SKSPhotoBorderType editBorderType;

/// 编辑框宽高尺寸，默认300 : 300，⚠️根据需求设比例，绝对不能高于屏幕宽高
@property (nonatomic, assign) CGSize editBorderSize;

/// 选择多少张图片，默认1张
@property (nonatomic, assign) NSInteger photoCount;

/// 是否允许选择图片，默认YES
@property (nonatomic, assign) BOOL allowPickingImage;

/// 是否允许选择视频，默认NO
@property (nonatomic, assign) BOOL allowPickingVideo;

/// ⚠️编辑框是否固定，还是可以拖动。默认：YES
@property (nonatomic, assign) BOOL isDragEditBorder;

/// ⚠️编辑框内的图片是否可以缩放
@property (nonatomic, assign) BOOL isEditZoom;

@end

NS_ASSUME_NONNULL_END
