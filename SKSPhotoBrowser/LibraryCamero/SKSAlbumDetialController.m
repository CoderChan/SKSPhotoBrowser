//
//  SKSAlbumDetialController.m
//  SKSPhotoManagerDemo
//
//  Created by sks on 2020/2/25.
//  Copyright © 2020 三棵树. All rights reserved.
//

#import "SKSAlbumDetialController.h"
#import "SKSPhotoCollectionCell.h"
#import "SKSImageEditViewController.h"
#import "SKSPhotoTool.h"
#import <Masonry/Masonry.h>


@interface SKSAlbumDetialController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

/// 专辑模型
@property (nonatomic) SKSAlbumModel *model;
/// 网格
@property (nonatomic) UICollectionView *collectionView;
/// 完成的回调
@property (nonatomic, copy) SKSCompletionBlock completionBlock;
/// 配置信息
@property (nonatomic) SKSPhotoConfig *config;
/// 是否横屏
@property (assign,nonatomic) BOOL isLanscape;

/// 防止重复进入编辑界面
@property (nonatomic, assign) BOOL isPushed;

@end

@implementation SKSAlbumDetialController

- (instancetype)initWithModel:(SKSAlbumModel *)model Config:(SKSPhotoConfig *)config Completion:(SKSCompletionBlock)completion {
    self = [super init];
    if (self) {
        self.config = config;
        self.completionBlock = completion;
        self.model = model;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationItem.leftBarButtonItem setTintColor:[UIColor systemBlueColor]];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.model.name;
    [self setupSubViews];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(deviceDidChangeRotate:) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
    [self.navigationController.navigationBar setTranslucent:NO];
}

- (void)deviceDidChangeRotate:(NSNotification *)noti {
    [self.collectionView reloadData];
}


- (void)setupSubViews {
    __weak __block typeof(self) weakSelf = self;

    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(weakSelf.view);
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:weakSelf.model.assetArray.count - 1 inSection:0];
        [weakSelf.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
    });
    
}

#pragma mark - 网格代理
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.model.assetArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SKSAssetModel *model = self.model.assetArray[indexPath.row];
    SKSPhotoCollectionCell *cell = [SKSPhotoCollectionCell sharedCell:collectionView IndexPath:indexPath];
    cell.cellSize = self.cellSize;
    cell.model = model;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    SKSAssetModel *model = self.model.assetArray[indexPath.row];
    SKSPhotoCollectionCell *cell = (SKSPhotoCollectionCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if (self.isPushed) {
        return;
    }
    self.isPushed = YES;
    __weak __block typeof(self) weakSelf = self;
    [SKSPhotoTool.shared getOriginImageWithModel:model.asset ProgressHandler:^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
        cell.progress = !error ? progress : 1;
    } Completion:^(UIImage *image) {
        if (image == nil) { return; }
        if (weakSelf.config.editBorderType == SKSPhotoBorderTypeNone) {
            // 没有编辑框，无须裁剪
            if (weakSelf.completionBlock) {
                weakSelf.completionBlock(@[image], @"");
            }
            weakSelf.isPushed = NO;
        }else{
            // 有编辑框
            SKSImageEditViewController *edit = [[SKSImageEditViewController alloc]initWithConfig:self.config OriginImage:image Completion:^(UIImage * _Nonnull editImage, SKSImageEditViewController * _Nonnull vc) {
                if (weakSelf.completionBlock) {
                    weakSelf.completionBlock(@[editImage], @"");
                }
            }];
            [weakSelf.navigationController pushViewController:edit animated:YES];
            weakSelf.isPushed = NO;
        }
    }];
}

// 每个cell的尺寸
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.cellSize, self.cellSize);
}
// 定义每个Section的四边间距
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(self.collectSpace, self.collectSpace, self.collectSpace, self.collectSpace);
}
//两个cell之间的间距（同一行的cell的间距）
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return self.collectSpace;
}
// 这个是两行cell之间的间距（上下行cell的间距）
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return self.collectSpace;
}

#pragma mark - 其他周期
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationNone;
}

#pragma mark - 懒加载 & 辅助函数
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
        flowLayout.minimumLineSpacing = self.collectSpace;
        flowLayout.minimumInteritemSpacing = self.collectSpace;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.alwaysBounceVertical = YES;
        _collectionView.backgroundColor = [UIColor whiteColor];
        [_collectionView registerClass:[SKSPhotoCollectionCell class] forCellWithReuseIdentifier:NSStringFromClass([SKSPhotoCollectionCell class])];
    }
    return _collectionView;
}

- (BOOL)is_iPhoneX {
    BOOL is_iPhoneX = NO;
    if (@available(iOS 11.0, *)) {
      is_iPhoneX = [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom > 0 ? YES : NO;
    } else {
      is_iPhoneX = NO;
    }
    return is_iPhoneX;
}

- (CGFloat)collectSpace {
    return 3;
}

- (CGFloat)lineCount {
    BOOL isPortrait = UIDevice.currentDevice.orientation == UIInterfaceOrientationPortrait || UIDevice.currentDevice.orientation == UIInterfaceOrientationPortraitUpsideDown;
    isPortrait = self.view.frame.size.width < self.view.frame.size.height ? YES : NO;
    CGFloat defaultCount = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 3 : 4;
    return isPortrait ? defaultCount : defaultCount + 2;
}

- (CGFloat)cellSize {
    CGFloat size = (UIScreen.mainScreen.bounds.size.width - self.collectSpace * (self.lineCount + 1)) / self.lineCount;
    return size;
}

@end
