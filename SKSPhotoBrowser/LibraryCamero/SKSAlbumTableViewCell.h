//
//  SKSAlbumTableViewCell.h
//  SKSPhotoManagerDemo
//
//  Created by sks on 2020/2/14.
//  Copyright © 2020 三棵树. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SKSAlbumModel.h"

NS_ASSUME_NONNULL_BEGIN

/// 专辑列表cell
@interface SKSAlbumTableViewCell : UITableViewCell

// 专辑模型
@property (nonatomic) SKSAlbumModel *albumModel;
// 高度
+ (CGFloat)cellHeight;
// 初始化
+ (instancetype)sharedCell:(UITableView *)tableView;

@end

NS_ASSUME_NONNULL_END
