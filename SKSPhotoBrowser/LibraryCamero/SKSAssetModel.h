//
//  SKSAssetModel.h
//  SKSPhotoManagerDemo
//
//  Created by sks on 2020/2/26.
//  Copyright © 2020 三棵树. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    SKSAssetModelMediaTypeUnknow = -1,
    SKSAssetModelMediaTypePhoto = 0,
    SKSAssetModelMediaTypeLivePhoto = 1,
    SKSAssetModelMediaTypePhotoGif = 2,
    SKSAssetModelMediaTypeVideo = 3,
    SKSAssetModelMediaTypeAudio = 4
} SKSAssetModelMediaType;

/// 专辑下的详情信息模型
@interface SKSAssetModel : NSObject

/// 图片信息
@property (nonatomic) PHAsset *asset;

/// 图片是否选中
@property (nonatomic, assign) BOOL isSelect;

/// 媒体类型
@property (nonatomic, assign) SKSAssetModelMediaType mediaType;

/// 视频二进制
@property (nonatomic) NSData *videoData;

/// 视频类型的时长
@property (nonatomic, copy) NSString *videoTimeLength;

/// 用一个PHAsset，构造一个SKSAssetModel照片模型
+ (instancetype)modelWithAsset:(PHAsset *)asset Type:(SKSAssetModelMediaType)type;

/// 用一个PHAsset，构造一个SKSAssetModel照片模型
+ (instancetype)modelWithAsset:(PHAsset *)asset Type:(SKSAssetModelMediaType)type TimeLength:(NSString *)timeLength;

@end

NS_ASSUME_NONNULL_END
