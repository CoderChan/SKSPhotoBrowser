//
//  SKSPhotoConfig.m
//  SKSPhotoManagerDemo
//
//  Created by sks on 2020/2/13.
//  Copyright © 2020 三棵树. All rights reserved.
//

#import "SKSPhotoConfig.h"

@implementation SKSPhotoConfig


- (instancetype)initWithDefaultConfig {
    self = [super init];
    if (self) {
        self.pickType = CameroAndPhoto;
        self.editBorderType = SquareBorder;
        self.editBorderSize = CGSizeMake(300, 400);
        self.photoCount = 1;
        self.allowPickingImage = YES;
        self.allowPickingVideo = NO;
        self.isDragEditBorder = YES;
        self.isEditZoom = YES;
    }
    return self;
}

@end
