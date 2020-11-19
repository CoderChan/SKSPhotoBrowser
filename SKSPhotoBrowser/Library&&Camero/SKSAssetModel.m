//
//  SKSAssetModel.m
//  SKSPhotoManagerDemo
//
//  Created by sks on 2020/2/26.
//  Copyright © 2020 三棵树. All rights reserved.
//

#import "SKSAssetModel.h"

#pragma mark - SKSAssetModel的实现
@implementation SKSAssetModel

+ (instancetype)modelWithAsset:(PHAsset *)asset Type:(SKSAssetModelMediaType)type {
    SKSAssetModel *model = [[SKSAssetModel alloc] init];
    model.asset = asset;
    model.isSelect = NO;
    model.mediaType = type;
    return model;
}

+ (instancetype)modelWithAsset:(PHAsset *)asset Type:(SKSAssetModelMediaType)type TimeLength:(NSString *)timeLength {
    SKSAssetModel *model = [self modelWithAsset:asset Type:type];
    model.videoTimeLength = timeLength;
    return model;
}

@end
