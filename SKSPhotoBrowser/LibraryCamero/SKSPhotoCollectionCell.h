//
//  SKSPhotoCollectionCell.h
//  SKSPhotoManagerDemo
//
//  Created by sks on 2020/2/26.
//  Copyright © 2020 三棵树. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SKSAlbumModel.h"

NS_ASSUME_NONNULL_BEGIN

/// 一个专辑下的图片详情cell
@interface SKSPhotoCollectionCell : UICollectionViewCell


/// cell尺寸
@property (nonatomic, assign) CGFloat cellSize;

/// 图片模型
@property (nonatomic) SKSAssetModel *model;

/// 下载进度
@property (nonatomic, assign) double progress;

/// 下载后的原图
@property (nonatomic) UIImage *oringinImage;

/// 初始化
+ (instancetype)sharedCell:(UICollectionView *)collectionView IndexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
