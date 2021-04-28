//
//  SKSPhotoConfig.m
//  SKSPhotoManagerDemo
//
//  Created by sks on 2020/2/13.
//  Copyright © 2020 三棵树. All rights reserved.
//

#import "SKSPhotoConfig.h"

@implementation SKSPhotoConfig


+ (instancetype)defaultConfig {
    SKSPhotoConfig *config = [SKSPhotoConfig new];
    config.pickType = SKSPhotoPickTypePhoto;
    config.editBorderType = SKSPhotoBorderTypeSquare;
    config.editBorderSize = CGSizeMake(300, 300);
    config.photoCount = 1;
    config.allowPickingImage = YES;
    config.allowPickingVideo = NO;
    config.isDragEditBorder = YES;
    config.isEditZoom = YES;
    return  config;
}

@end
