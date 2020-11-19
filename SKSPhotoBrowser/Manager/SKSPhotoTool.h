//
//  SKSPhotoTool.h
//  SKSPhotoManagerDemo
//
//  Created by sks on 2020/2/14.
//  Copyright © 2020 三棵树. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import "SKSAlbumModel.h"
#import "SKSPhotoConfig.h"


@interface SKSPhotoTool : NSObject

/// 初始化
+ (instancetype)shared;


#pragma mark - 加载图片、GIF专辑列表
/// 加载图片、GIF专辑列表
/// @param config 配置信息
/// @param completion 完成的回调
- (void)getAllAlbumsWithConfig:(SKSPhotoConfig *)config Completion:(void (^)(NSArray <SKSAlbumModel *>*albumArray))completion;


/// 获取全部视频内容
/// @param config 配置信息
/// @param completion 完成的回调
- (void)getAllVideosWithConfig:(SKSPhotoConfig *)config Completion:(void (^)(NSArray <SKSAssetModel *> *videoArray))completion;


#pragma mark - 获取专辑下的详细图集
/// 获取专辑下的详细图集
/// @param result 结果集
/// @param completion 完成的回调
- (void)getAssetsFromFetchResult:(PHFetchResult *)result completion:(void (^)(NSArray<SKSAssetModel *> *modelArray))completion;


#pragma mark - 加载封面图
///  快速获取低质量模式的封面
/// @param asset 资源
/// @param photoSize 封面尺寸
/// @param completion 完成回调
/// @param progressHandler 加载iCloud图进度回调
- (PHImageRequestID)getFastImageWithModel:(PHAsset *)asset PhotoSize:(CGSize)photoSize Completion:(void (^)(UIImage *photo,NSDictionary *info,BOOL isDegraded))completion ProgressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler;


#pragma mark - 获取原图，包括下载iCloud图
/// 获取原图，包括下载iCloud图
/// @param asset 资源
/// @param completion 完成回调
- (PHImageRequestID)getOriginImageWithModel:(PHAsset *)asset ProgressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler Completion:(void (^)(UIImage *image))completion;

@end


