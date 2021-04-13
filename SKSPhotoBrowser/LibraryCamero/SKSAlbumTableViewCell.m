//
//  SKSAlbumTableViewCell.m
//  SKSPhotoManagerDemo
//
//  Created by sks on 2020/2/14.
//  Copyright © 2020 三棵树. All rights reserved.
//

#import "SKSAlbumTableViewCell.h"
#import <Masonry/Masonry.h>
#import "SKSPhotoTool.h"


@interface SKSAlbumTableViewCell ()

/// 专辑封面
@property (nonatomic) UIImageView *coverImgView;

/// 专辑名
@property (nonatomic) UILabel *nameLabel;

/// 数量
@property (nonatomic) UILabel *countLabel;

@end

@implementation SKSAlbumTableViewCell

+ (instancetype)sharedCell:(UITableView *)tableView {
    SKSAlbumTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([self class])];
    if (!cell) {
        cell = [[self alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:NSStringFromClass([self class])];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.selectionStyle = UITableViewCellSelectionStyleDefault;
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [self setupSubViews];
        [self addConstraint];
    }
    
    return self;
}

+ (CGFloat)cellHeight {
    BOOL is_pad = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? YES : NO;
    return is_pad ? 120 : 80;
}

- (void)setAlbumModel:(SKSAlbumModel *)albumModel {
    _albumModel = albumModel;
    _nameLabel.text = albumModel.name;
    _countLabel.text = [NSString stringWithFormat:@"共%@张",@(albumModel.count)];
    __weak __block typeof(self) weakSelf = self;
    SKSAssetModel *assetModel = albumModel.assetArray.lastObject;
    CGSize size = CGSizeMake(SKSAlbumTableViewCell.cellHeight - 20, SKSAlbumTableViewCell.cellHeight);
    [SKSPhotoTool.shared getFastImageWithModel:assetModel.asset PhotoSize:size Completion:^(UIImage * _Nonnull photo, NSDictionary * _Nonnull info, BOOL isDegraded) {
        weakSelf.coverImgView.image = photo;
        
    } ProgressHandler:^(double progress, NSError * _Nonnull error, BOOL * _Nonnull stop, NSDictionary * _Nonnull info) {
        
    }];
}

- (void)setupSubViews {
    [self.contentView addSubview:self.coverImgView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.countLabel];
}

- (void)addConstraint {
    __weak __block typeof(self) weakSelf = self;
    [self.coverImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.mas_left).offset(15);
        make.centerY.equalTo(weakSelf.mas_centerY);
        make.top.equalTo(weakSelf.mas_top).offset(10);
        make.width.equalTo(@([SKSAlbumTableViewCell cellHeight]));
    }];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.coverImgView.mas_right).offset(15);
        make.bottom.equalTo(weakSelf.mas_centerY);
        make.height.equalTo(@20);
    }];
    [self.countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.nameLabel.mas_left);
        make.top.equalTo(weakSelf.mas_centerY).offset(3);
        make.height.equalTo(@16);
    }];
}

- (UIImageView *)coverImgView {
    if (!_coverImgView) {
        _coverImgView = [[UIImageView alloc]init];
        _coverImgView.backgroundColor = [UIColor lightGrayColor];
        _coverImgView.contentMode = UIViewContentModeScaleAspectFill;
        _coverImgView.contentScaleFactor = UIScreen.mainScreen.scale;
        _coverImgView.layer.masksToBounds = YES;
        _coverImgView.autoresizingMask = UIViewAutoresizingFlexibleHeight & UIViewAutoresizingFlexibleWidth;
    }
    return _coverImgView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [UILabel new];
        _nameLabel.textColor = [UIColor blackColor];
        _nameLabel.font = [UIFont boldSystemFontOfSize:16];
    }
    return _nameLabel;
}

- (UILabel *)countLabel {
    if (!_countLabel) {
        _countLabel = [UILabel new];
        _countLabel.textColor = [UIColor grayColor];
        _countLabel.font = [UIFont systemFontOfSize:14];
    }
    return _countLabel;
}

@end
