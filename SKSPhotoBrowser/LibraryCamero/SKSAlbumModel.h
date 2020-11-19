//
//  SKSAlbumModel.h
//  SKSPhotoManagerDemo
//
//  Created by sks on 2020/2/14.
//  Copyright © 2020 三棵树. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import "SKSAssetModel.h"

NS_ASSUME_NONNULL_BEGIN

/// 专辑信息模型
@interface SKSAlbumModel : NSObject

/// 相册名
@property (nonatomic, copy) NSString *name;

/// 相册数量，会过滤0张图的相册
@property (nonatomic, assign) NSInteger count;

/// 原始资源
@property (nonatomic) PHFetchResult <PHAsset *>*result;

@property (nonatomic, strong) NSArray <SKSAssetModel *>*assetArray;
@property (nonatomic, strong) NSArray <SKSAssetModel *>*selectedModels;
@property (nonatomic, assign) NSUInteger selectedCount;

@property (nonatomic, assign) BOOL isCameraRoll;

- (void)setResult:(PHFetchResult *)result needFetchAssets:(BOOL)needFetchAssets;

@end

NS_ASSUME_NONNULL_END
