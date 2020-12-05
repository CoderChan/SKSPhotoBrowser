//
//  SKSPhotoTool.m
//  SKSPhotoManagerDemo
//
//  Created by sks on 2020/2/14.
//  Copyright © 2020 三棵树. All rights reserved.
//

#import "SKSPhotoTool.h"

@interface SKSPhotoTool ()

/// 配置信息
@property (nonatomic) SKSPhotoConfig *config;

@end

@implementation SKSPhotoTool

+ (instancetype)shared
{
    static SKSPhotoTool *_sharedManager = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedManager = [[self alloc] init];
    });
    
    return _sharedManager;
}

#pragma mark - 加载图片、GIF专辑列表
- (void)getAllAlbumsWithConfig:(SKSPhotoConfig *)config Completion:(void (^)(NSArray<SKSAlbumModel *> * _Nonnull))completion {
    
    self.config = config;
    NSMutableArray <SKSAlbumModel *>*albumArray = [NSMutableArray array];
    PHFetchOptions *option = [[PHFetchOptions alloc]init];
    if (!config.allowPickingVideo) {
        option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
    }
    if (!config.allowPickingImage) {
        option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeVideo];
    }
    // 对照片排序，按修改时间升序，默认是YES。如果设置为NO,最新的照片会显示在最前面，内部的拍照按钮会排在第一个
    BOOL needFetchAssets = YES;
    option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:needFetchAssets]];
    
    PHFetchResult *myPhotoStreamAlbum = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumMyPhotoStream options:nil];
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    PHFetchResult *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    PHFetchResult *syncedAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumSyncedAlbum options:nil];
    PHFetchResult *sharedAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumCloudShared options:nil];
    
    NSArray <PHFetchResult *>*allAlbums = @[myPhotoStreamAlbum,smartAlbums,topLevelUserCollections,syncedAlbums,sharedAlbums];
    for (PHFetchResult *subFetchResult in allAlbums) {
        for (PHAssetCollection *subCollection in subFetchResult) {
            
            // 过滤PHCollectionList
            if (![subCollection isKindOfClass:[PHAssetCollection class]]) continue;
            // 过滤空相册
            if (subCollection.estimatedAssetCount <= 0) continue;
            PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:subCollection options:option];
            if (fetchResult.count < 1) continue;
            if (subCollection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumAllHidden) continue;
            if (subCollection.assetCollectionSubtype == 1000000201) continue; //『最近删除』相册
            SKSAlbumModel *model = [self modelWithResult:fetchResult name:subCollection.localizedTitle isCameraRoll:NO needFetchAssets:needFetchAssets];
            [albumArray addObject:model];
        }
    }
    if (completion) {
        completion(albumArray);
    }
}

/// 创建一个专辑
- (SKSAlbumModel *)modelWithResult:(PHFetchResult *)result name:(NSString *)name isCameraRoll:(BOOL)isCameraRoll needFetchAssets:(BOOL)needFetchAssets {
    
    SKSAlbumModel *model = [[SKSAlbumModel alloc] init];
    [model setResult:result needFetchAssets:needFetchAssets];
    model.name = name;
    model.isCameraRoll = isCameraRoll;
    model.count = result.count;
    return model;
}

#pragma mark - 获取全部视频内容
- (void)getAllVideosWithConfig:(SKSPhotoConfig *)config Completion:(void (^)(NSArray<SKSAssetModel *> *))completion {
    completion(@[]);
}

#pragma mark - 获取专辑下的详细图集
- (void)getAssetsFromFetchResult:(PHFetchResult *)result completion:(void (^)(NSArray<SKSAssetModel *> * _Nonnull))completion {
    __weak __block typeof(self) weakSelf = self;
    NSMutableArray *photoArr = [NSMutableArray array];
    [result enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL * _Nonnull stop) {
        SKSAssetModel *model = [weakSelf assetModelWithAsset:asset Config:weakSelf.config];
        if (model) {
            [photoArr addObject:model];
        }
    }];
    if (completion) completion(photoArr);
}

- (SKSAssetModel *)assetModelWithAsset:(PHAsset *)asset Config:(SKSPhotoConfig *)config {
    
    SKSAssetModelMediaType type = [self formatAssetType:asset];
    if (!config.allowPickingVideo && type == SKSAssetModelMediaTypeVideo) return nil;
    if (!config.allowPickingImage && type == SKSAssetModelMediaTypePhoto) return nil;
    if (!config.allowPickingImage && type == SKSAssetModelMediaTypePhotoGif) return nil;
    
    PHAsset *phAsset = (PHAsset *)asset;
    NSString *timeLength = type == SKSAssetModelMediaTypeVideo ? [NSString stringWithFormat:@"%0.0f",phAsset.duration] : @"";
    timeLength = [self getNewTimeFromDurationSecond:timeLength.integerValue];
    SKSAssetModel *model = [SKSAssetModel modelWithAsset:phAsset Type:type TimeLength:timeLength];
    return model;
}


#pragma mark - 快速获取封面图
- (PHImageRequestID)getFastImageWithModel:(PHAsset *)asset PhotoSize:(CGSize)photoSize Completion:(nonnull void (^)(UIImage * _Nonnull, NSDictionary * _Nonnull, BOOL))completion ProgressHandler:(nonnull void (^)(double, NSError * _Nonnull, BOOL * _Nonnull, NSDictionary * _Nonnull))progressHandler {
    
    if (!asset) {
        return -1;
    }
    
    __weak __block typeof(self) weakSelf = self;
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc]init];
    option.resizeMode = PHImageRequestOptionsResizeModeFast;
    option.networkAccessAllowed = YES;
    
    CGFloat screenWidth = UIScreen.mainScreen.bounds.size.width < UIScreen.mainScreen.bounds.size.height ? UIScreen.mainScreen.bounds.size.width : UIScreen.mainScreen.bounds.size.height;
    CGFloat scale = screenWidth >= 700 ? 1.5 : 2;
    photoSize = CGSizeMake(photoSize.width * scale, photoSize.width * scale);
    
    int32_t imageRequestID = [PHImageManager.defaultManager requestImageForAsset:asset targetSize:photoSize contentMode:PHImageContentModeAspectFit options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        
//        NSLog(@"info = %@", info);
        // PHImageResultIsDegradedKey = YES时，低质量图片
        BOOL canclled = [[info objectForKey:PHImageResultIsDegradedKey] boolValue];
        if (!canclled && result) {
            result = [self scaleImage:result toSize:photoSize];
            result = [weakSelf fixOrientation:result];
            if (completion) {
                completion(result, info, [[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
            }
        }
        if ([info objectForKey:PHImageResultIsInCloudKey] && !result) {
            PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
            options.progressHandler = ^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (progressHandler) {
                        progressHandler(progress, error, stop, info);
                    }
                });
            };
            options.networkAccessAllowed = YES;
            @autoreleasepool {
                [PHImageManager.defaultManager requestImageDataForAsset:asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                    NSLog(@"requestImageDataForAsset returned info(%@)", info);
                    UIImage *resultImage = [UIImage imageWithData:imageData];
                    resultImage = [self scaleImage:resultImage toSize:photoSize];
                    resultImage = [self fixOrientation:resultImage];
                    if (completion) {
                        completion(resultImage, info, NO);
                    }
                }];
            }
        }
    }];
    return imageRequestID;
    
}

#pragma mark - 获取原图
- (PHImageRequestID)getOriginImageWithModel:(PHAsset *)asset ProgressHandler:(void (^)(double, NSError * _Nonnull, BOOL * _Nonnull, NSDictionary * _Nonnull))progressHandler Completion:(void (^)(UIImage * _Nonnull))completion {
    
    if (!asset) {
        return -1;
    }
    __weak __block typeof(self) weakSelf = self;
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc]init];
    option.resizeMode = PHImageRequestOptionsResizeModeExact;
    option.networkAccessAllowed = YES;
    option.progressHandler = ^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (progressHandler) {
                progressHandler(progress, error, stop, info);
            }
        });
    };
    if (@available(iOS 13, *)) {
        @autoreleasepool {
            int32_t imageRequestID = [PHImageManager.defaultManager requestImageDataAndOrientationForAsset:asset options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, CGImagePropertyOrientation orientation, NSDictionary * _Nullable info) {
                UIImage *resultImage = [UIImage imageWithData:imageData];
                resultImage = [weakSelf fixOrientation:resultImage];
                completion(resultImage);
            }];
            return imageRequestID;
        }
    } else {
        @autoreleasepool {
            int32_t imageRequestID = [PHImageManager.defaultManager requestImageDataForAsset:asset options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                UIImage *resultImage = [UIImage imageWithData:imageData];
                resultImage = [weakSelf fixOrientation:resultImage];
                completion(resultImage);
            }];
            return imageRequestID;
        }
    }
    
}


#pragma mark - 辅助方法
/// 缩放图片至新尺寸
- (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)size {
    if (image.size.width > size.width) {
        UIGraphicsBeginImageContext(size);
        [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage;
    } else {
        return image;
    }
}

// 转换媒体资源类型
- (SKSAssetModelMediaType)formatAssetType:(PHAsset *)asset {
    
    SKSAssetModelMediaType type = SKSAssetModelMediaTypePhoto;
    PHAsset *phAsset = (PHAsset *)asset;
    
    if (phAsset.mediaType == PHAssetMediaTypeVideo) {
        type = SKSAssetModelMediaTypeVideo;
    }else if (phAsset.mediaType == PHAssetMediaTypeAudio) {
        type = SKSAssetModelMediaTypeAudio;
    }else if (phAsset.mediaType == PHAssetMediaTypeImage) {
        type = SKSAssetModelMediaTypePhoto;
        if (@available(iOS 9.1, *)) {
            if (asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive){
                type = SKSAssetModelMediaTypeLivePhoto;
            }
        }
//        NSLog(@"filename = %@", [phAsset valueForKey:@"filename"]);
        if ([[phAsset valueForKey:@"filename"] hasSuffix:@"GIF"]) {
            type = SKSAssetModelMediaTypePhotoGif;
        }
    }else{
        type = SKSAssetModelMediaTypeUnknow;
    }
    return type;
}

// 计算视频时长
- (NSString *)getNewTimeFromDurationSecond:(NSInteger)duration {
    NSString *newTime;
    if (duration < 10) {
        newTime = [NSString stringWithFormat:@"0:0%zd",duration];
    } else if (duration < 60) {
        newTime = [NSString stringWithFormat:@"0:%zd",duration];
    } else {
        NSInteger min = duration / 60;
        NSInteger sec = duration - (min * 60);
        if (sec < 10) {
            newTime = [NSString stringWithFormat:@"%zd:0%zd",min,sec];
        } else {
            newTime = [NSString stringWithFormat:@"%zd:%zd",min,sec];
        }
    }
    return newTime;
}


/// 修正图片转向-EXIF
- (UIImage *)fixOrientation:(UIImage *)aImage {
    
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}


@end
