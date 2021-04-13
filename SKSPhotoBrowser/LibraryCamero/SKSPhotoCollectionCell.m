//
//  SKSPhotoCollectionCell.m
//  SKSPhotoManagerDemo
//
//  Created by sks on 2020/2/26.
//  Copyright © 2020 三棵树. All rights reserved.
//

#import "SKSPhotoCollectionCell.h"
#import <Masonry/Masonry.h>
#import "SKSPhotoTool.h"
#import "SKSAnimationView.h"

@interface SKSPhotoCollectionCell ()

/// 图片
@property (nonatomic) SKSAnimationView *coverImgView;

@property (nonatomic, copy) NSString *representedAssetIdentifier;

@property (nonatomic, assign) int32_t imageRequestID;

@property (nonatomic) UIView *bottomView;

@property (nonatomic) UILabel *timeLengthLabel;

@end

@implementation SKSPhotoCollectionCell

+ (instancetype)sharedCell:(UICollectionView *)collectionView IndexPath:(NSIndexPath *)indexPath {
    SKSPhotoCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([SKSPhotoCollectionCell class]) forIndexPath:indexPath];
    if (!cell) {
        cell = [[self alloc]init];
    }
    return cell;
}

- (void)setCellSize:(CGFloat)cellSize {
    _cellSize = cellSize;
}

- (void)setProgress:(double)progress {
    _progress = progress;
    _bottomView.hidden = NO;
    NSLog(@"progress = %g", progress);
    _timeLengthLabel.text = [NSString stringWithFormat:@"iCloud下载中%g%%", progress * 100];
    if (_progress == 1) {
        if (_model.mediaType == SKSAssetModelMediaTypePhotoGif) {
            _bottomView.hidden = NO;
            _timeLengthLabel.text = @"GIF";
        }else{
            _bottomView.hidden = YES;
        }
    }
}



- (void)setOringinImage:(UIImage *)oringinImage {
    _oringinImage = oringinImage;
    self.coverImgView.image = oringinImage;
}

- (void)setModel:(SKSAssetModel *)model {
    _model = model;
    self.representedAssetIdentifier = model.asset.localIdentifier;
    __weak __block typeof(self) weakSelf = self;
    CGSize size = CGSizeMake(self.cellSize, self.cellSize);
    int32_t imageRequestID = [SKSPhotoTool.shared getFastImageWithModel:model.asset PhotoSize:size Completion:^(UIImage * _Nonnull photo, NSDictionary * _Nonnull info, BOOL isDegraded) {
        
        if ([weakSelf.representedAssetIdentifier isEqualToString:model.asset.localIdentifier]) {
            weakSelf.coverImgView.image = photo;
            weakSelf.oringinImage = photo;
        }else{
            [PHImageManager.defaultManager cancelImageRequest:weakSelf.imageRequestID];
        }
    } ProgressHandler:^(double progress, NSError * _Nonnull error, BOOL * _Nonnull stop, NSDictionary * _Nonnull info) {
        
    }];
    if (imageRequestID && self.imageRequestID && imageRequestID != self.imageRequestID) {
        [PHImageManager.defaultManager cancelImageRequest:self.imageRequestID];
    }
    self.imageRequestID = imageRequestID;
    if (model.mediaType == SKSAssetModelMediaTypePhotoGif) {
        self.bottomView.hidden = NO;
        self.timeLengthLabel.text = @"GIF";
    }else{
        self.bottomView.hidden = YES;
    }
    
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor lightGrayColor];
        [self setupSubViews];
        [self addConstraint];
    }
    return self;
}

- (void)setupSubViews {
    [self.contentView addSubview:self.coverImgView];
    [self.contentView addSubview:self.bottomView];
    [self.bottomView addSubview:self.timeLengthLabel];
}

- (void)addConstraint {
    __weak __block typeof(self) weakSelf = self;
    [self.coverImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(weakSelf);
    }];
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.contentView);
        make.bottom.equalTo(weakSelf.contentView);
        make.right.equalTo(weakSelf.contentView);
        make.height.equalTo(@(17));
    }];
}

#pragma mark - 懒加载
/// 图片封面
- (SKSAnimationView *)coverImgView {
    if (!_coverImgView) {
        _coverImgView = [[SKSAnimationView alloc]init];
        _coverImgView.backgroundColor = [UIColor lightGrayColor];
        _coverImgView.contentMode = UIViewContentModeScaleAspectFill;
        _coverImgView.contentScaleFactor = UIScreen.mainScreen.scale;
        _coverImgView.layer.masksToBounds = YES;
        _coverImgView.autoresizingMask = UIViewAutoresizingFlexibleHeight & UIViewAutoresizingFlexibleWidth;
    }
    return _coverImgView;
}

- (UIView *)bottomView {
    if (_bottomView == nil) {
        UIView *bottomView = [[UIView alloc] initWithFrame:CGRectZero];
        bottomView.backgroundColor = SKSPhoto_RGBACOLOR(108, 108, 108, 0.8);
        _bottomView = bottomView;
    }
    return _bottomView;
}

- (UILabel *)timeLengthLabel {
    if (_timeLengthLabel == nil) {
        UILabel *timeLength = [[UILabel alloc] initWithFrame:CGRectMake(8, 0, self.frame.size.width, 17)];
        timeLength.font = [UIFont boldSystemFontOfSize:11];
        timeLength.textColor = [UIColor whiteColor];
        timeLength.textAlignment = NSTextAlignmentLeft;
        _timeLengthLabel = timeLength;
    }
    return _timeLengthLabel;
}

@end
