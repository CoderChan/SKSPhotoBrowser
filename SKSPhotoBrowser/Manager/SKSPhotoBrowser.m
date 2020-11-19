//
//  SKSPhotoManager.m
//  SKSPhotoManagerDemo
//
//  Created by sks on 2020/2/13.
//  Copyright © 2020 三棵树. All rights reserved.
//

#import "SKSPhotoBrowser.h"
#import <Photos/Photos.h>
#import "SKSAlbumListController.h"
#import "SKSCameroViewController.h"


@interface SKSPhotoBrowser()

/// 配置信息
@property (nonatomic) SKSPhotoConfig *config;
/// 回调
@property (nonatomic, copy) SKSCompletionBlock completion;
///  弹出的控制器
@property (nonatomic) UIViewController *fromController;

@end

@implementation SKSPhotoBrowser

+ (instancetype)shared
{
    static SKSPhotoBrowser *_sharedManager = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedManager = [[self alloc] init];
    });
    
    return _sharedManager;
}

#pragma mark - 弹出选择框
- (void)showInView:(UIViewController *)controller Config:(SKSPhotoConfig *)config Completion:(SKSCompletionBlock)completion {
    
    if (config.editBorderType == CircleBorder) {
        completion(@[], @"暂不支持圆形裁剪框");
        return;
    }
    if (config.editBorderSize.width >= UIScreen.mainScreen.bounds.size.width) {
        completion(@[], @"裁剪宽度不能大于屏幕宽度");
        return;
    }
    if (config.editBorderSize.height >= UIScreen.mainScreen.bounds.size.height) {
        completion(@[], @"裁剪高度不能大于屏幕高度");
        return;
    }
    
    self.config = config;
    self.completion = completion;
    self.fromController = controller;
    
    // 根据类型弹出对应的选择器
    if (self.config.pickType == Camero) {
        [self presentCameroAction];
    }else{
        [self presentPhotoAction];
    }
    
}

- (void)presentCameroAction {
    
    SKSCameroViewController *photoAlbum = [[SKSCameroViewController alloc]initWithConfig:self.config Completion:^(NSArray<UIImage *> * _Nonnull imageArray, NSString * _Nonnull errorMsg) {
        if (self.completion) {
            self.completion(imageArray, errorMsg);
        }
    }];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:photoAlbum];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.fromController presentViewController:nav animated:YES completion:nil];
}


- (void)presentPhotoAction {
    __weak __block typeof(self) weakSelf = self;
    SKSAlbumListController *photoAlbum = [[SKSAlbumListController alloc]initWithConfig:self.config Completion:^(NSArray<UIImage *> * _Nonnull imageArray, NSString * _Nonnull errorMsg) {
        if (weakSelf.completion) {
            weakSelf.completion(imageArray, errorMsg);
            [weakSelf.fromController.navigationController dismissViewControllerAnimated:YES completion:nil];
        }
    }];

    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:photoAlbum];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.fromController presentViewController:nav animated:YES completion:nil];
}


@end
