//
//  SKSAlbumListController.m
//  SKSPhotoManagerDemo
//
//  Created by sks on 2020/2/13.
//  Copyright © 2020 三棵树. All rights reserved.
//

#import "SKSAlbumListController.h"
#import <Photos/Photos.h>
#import <Masonry/Masonry.h>
#import "SKSImageEditViewController.h"
#import "SKSAlbumModel.h"
#import "SKSPhotoTool.h"
#import "SKSPhotoResource.h"
#import "SKSAlbumTableViewCell.h"
#import "SKSAlbumDetialController.h"


@interface SKSAlbumListController ()<UITableViewDataSource,UITableViewDelegate>

/// 配置信息
@property (nonatomic) SKSPhotoConfig *config;

/// 完成的回调
@property (nonatomic, copy) SKSCompletionBlock completionBlock;

/// 专辑表格
@property (nonatomic) UITableView *tableView;

/// 专辑数据源
@property (nonatomic, copy) NSArray <SKSAlbumModel *> *albumArray;

/// 数据异常的提示
@property (strong,nonatomic) UILabel *emptyLabel;
/// 数据异常时的图片
@property (strong,nonatomic) UIImageView *emptyImgView;
/// 异常时的按钮点击
@property (nonatomic) UIButton *emptyButton;
/// 点击缺省页按钮
@property (nonatomic, copy) void (^clickBlock)(void);

@end

@implementation SKSAlbumListController

- (instancetype)initWithConfig:(SKSPhotoConfig *)config Completion:(SKSCompletionBlock)completion {
    self = [super init];
    if (self) {
        self.config = config;
        self.completionBlock = completion;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"所有专辑";
    self.view.backgroundColor = [UIColor whiteColor];
    [self checkPhotoAuthorization];
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancleAction)];
    [self.navigationItem.leftBarButtonItem setTintColor:[UIColor systemBlueColor]];
    self.navigationController.navigationBarHidden = NO;
}


// 1、检查权限
- (void)checkPhotoAuthorization {
    
    __weak __block typeof(self) weakSelf = self;
    PHAuthorizationStatus status = PHPhotoLibrary.authorizationStatus;
    if ((status == PHAuthorizationStatusRestricted || status == PHAuthorizationStatusDenied)) {
        [self showEmptyAction];
    }else if (status == PHAuthorizationStatusNotDetermined) {
        // 首次询问
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf setupSubViews];
                });
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf showEmptyAction];
                });
            }
        }];
    }else {
        [self setupSubViews];
    }
}

- (void)showEmptyAction {
    [self showEmptyViewWithButtonTitle:@"检测设置" Message:@"暂无相册访问权限" ClickBlock:^{
        [UIApplication.sharedApplication openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }];
}

- (void)showEmptyViewWithButtonTitle:(NSString *)title Message:(NSString *)message ClickBlock:(void (^)(void))clickBlock {
    
    self.clickBlock = clickBlock;
    self.emptyLabel.text = message;
    CGFloat lockSize = UIScreen.mainScreen.bounds.size.width * 0.45;
    
    [self.emptyButton setTitle:title forState:UIControlStateNormal];
    [self.view addSubview:self.emptyImgView];
    [self.view addSubview:self.emptyLabel];
    [self.view addSubview:self.emptyButton];
    self.emptyLabel.hidden = NO;
    self.emptyImgView.hidden = NO;
    self.emptyButton.hidden = title.length > 0 ? NO : YES;
    [self.emptyImgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.view).offset(-64);
        make.width.equalTo(@(lockSize));
        make.height.equalTo(@(lockSize));
    }];
    
    [self.emptyButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.emptyImgView.mas_bottom).offset(8);
        make.centerX.equalTo(self.view.mas_centerX);
        make.width.equalTo(@(180));
        make.height.equalTo(@(44));
    }];
    
    CGFloat leftOff = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 120 : 30;
    [self.emptyLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
      make.top.equalTo(self.emptyButton.mas_bottom).offset(15);
      make.centerX.equalTo(self.emptyImgView.mas_centerX);
      make.left.equalTo(self.view.mas_left).offset(leftOff);
    }];
    
}

- (void)hideEmptyViewAction {
    self.emptyLabel.hidden = YES;
    self.emptyImgView.hidden = YES;
    self.emptyButton.hidden = YES;
}

// 2、加载子控件
- (void)setupSubViews {
    [self.navigationController.navigationBar setTranslucent:NO];
    [self.view addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self refreshAlbumListAction];
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

- (void)cancleAction {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)refreshAlbumListAction {
    __weak __block typeof(self) weakSelf = self;
    [SKSPhotoTool.shared getAllAlbumsWithConfig:self.config Completion:^(NSArray<SKSAlbumModel *> * _Nonnull albumArray) {
        NSLog(@"专辑数量 = %@", @(albumArray.count));
        self.albumArray = albumArray;
        [self.tableView reloadData];
        if (albumArray.count == 0) {
            [self showEmptyViewWithButtonTitle:nil Message:@"暂无有图片的相册专辑" ClickBlock:nil];
            return ;
        }
        SKSAlbumModel *model = self.albumArray.firstObject;
        SKSAlbumDetialController *album = [[SKSAlbumDetialController alloc]initWithModel:model Config:weakSelf.config Completion:^(NSArray<UIImage *> * _Nonnull imageArray, NSString * _Nonnull errorMsg) {
            if (weakSelf.completionBlock) {
                weakSelf.completionBlock(imageArray, errorMsg);
            }
        }];
        [weakSelf.navigationController pushViewController:album animated:NO];
    }];
}

#pragma mark - 表格代理
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.albumArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SKSAlbumTableViewCell *cell = [SKSAlbumTableViewCell sharedCell:tableView];
    SKSAlbumModel *model = self.albumArray[indexPath.row];
    cell.albumModel = model;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    __weak __block typeof(self) weakSelf = self;
    SKSAlbumModel *model = self.albumArray[indexPath.row];
    SKSAlbumDetialController *album = [[SKSAlbumDetialController alloc]initWithModel:model Config:self.config Completion:^(NSArray<UIImage *> * _Nonnull imageArray, NSString * _Nonnull errorMsg) {
        if (weakSelf.completionBlock) {
            weakSelf.completionBlock(imageArray, errorMsg);
        }
    }];
    [self.navigationController pushViewController:album animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [SKSAlbumTableViewCell cellHeight];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headView = [UIView new];
    return headView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footView = [UIView new];
    return footView;
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


#pragma mark - 懒加载
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _tableView.backgroundColor = [UIColor clearColor];
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIApplicationBackgroundFetchIntervalNever;
        } else {
            self
            .automaticallyAdjustsScrollViewInsets = NO;
        }
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
    }
    return _tableView;
}

- (NSArray<SKSAlbumModel *> *)albumArray {
    if (!_albumArray) {
        _albumArray = [NSMutableArray array];
    }
    return _albumArray;
}

- (UILabel *)emptyLabel
{
    if (!_emptyLabel) {
        _emptyLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _emptyLabel.font = [UIFont systemFontOfSize:15];
        _emptyLabel.textAlignment = NSTextAlignmentCenter;
        _emptyLabel.numberOfLines = 0;
        _emptyLabel.textColor = SKSPhoto_RGBACOLOR(81, 81, 81, 1);
    }
    return _emptyLabel;
}
- (UIImageView *)emptyImgView
{
    if (!_emptyImgView) {
        _emptyImgView = [[UIImageView alloc]initWithFrame:CGRectZero];
        _emptyImgView.image = [SKSPhotoResource imageNamed:@"sks_empty_black"];
    }
    return _emptyImgView;
}

- (UIButton *)emptyButton {
    if (!_emptyButton) {
        _emptyButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _emptyButton.hidden = YES;
        _emptyButton.backgroundColor = SKSPhoto_RGBACOLOR(81, 81, 81, 1);
        [_emptyButton addTarget:self action:@selector(emptyButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [_emptyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _emptyButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        _emptyButton.layer.cornerRadius = 22.f;
        _emptyButton.layer.masksToBounds = YES;
    }
    return _emptyButton;
}

- (void)emptyButtonClick:(UIButton *)sender {
    if (self.clickBlock) {
        self.clickBlock();
    }
}


@end
