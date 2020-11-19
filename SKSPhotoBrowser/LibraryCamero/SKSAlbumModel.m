//
//  SKSAlbumModel.m
//  SKSPhotoManagerDemo
//
//  Created by sks on 2020/2/14.
//  Copyright © 2020 三棵树. All rights reserved.
//

#import "SKSAlbumModel.h"
#import "SKSPhotoTool.h"

@implementation SKSAlbumModel

- (void)setResult:(PHFetchResult *)result needFetchAssets:(BOOL)needFetchAssets {
    _result = result;
    if (needFetchAssets) {
        [SKSPhotoTool.shared getAssetsFromFetchResult:result completion:^(NSArray<SKSAssetModel *> * _Nonnull modelArray) {
            self.assetArray = modelArray;
            if (self.selectedModels) {
                [self checkSelectModels];
            }
        }];
    }
}

- (void)setSelectedModels:(NSArray<SKSAssetModel *> *)selectedModels {
    _selectedModels = selectedModels;
    if (_assetArray) {
        [self checkSelectModels];
    }
}

- (void)checkSelectModels {
    self.selectedCount = 0;
    NSMutableSet *selectedAssets = [NSMutableSet setWithCapacity:_selectedModels.count];
    for (SKSAssetModel *model in _selectedModels) {
        [selectedAssets addObject:model.asset];
    }
    for (SKSAssetModel *model in _assetArray) {
        if ([selectedAssets containsObject:model.asset]) {
            self.selectedCount ++;
        }
    }
}

@end


