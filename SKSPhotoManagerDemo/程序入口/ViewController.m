//
//  HomeViewController.m
//  SKSPhotoManagerDemo
//
//  Created by sks on 2020/2/13.
//  Copyright © 2020 三棵树. All rights reserved.
//

#import "ViewController.h"
#import "SKSPhotoBrowser.h"
#import <Masonry/Masonry.h>

@interface ViewController ()

/// 展示的大图
@property (nonatomic) UIImageView *bigImgView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"SKSPhotoBrowserDemo";
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupSubViews];
}

- (void)setupSubViews {
    
    CGFloat width = 300;
    self.bigImgView = [[UIImageView alloc]initWithFrame:CGRectZero];
    self.bigImgView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:self.bigImgView];
    [self.bigImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(@80);
        make.width.equalTo(@(width));
        make.height.equalTo(@(width * 1.1));
    }];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake((self.view.frame.size.width - 100) / 2, 200, 100, 44);
    button.backgroundColor = [UIColor redColor];
    button.layer.cornerRadius = 22;
    [button setTitle:@"选择图片" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [button addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)buttonClick {
    
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"选择图片" message:@"请在SKSPhotoConfig配置各种设置" preferredStyle:UIAlertControllerStyleAlert];
    __weak __block typeof(self) weakSelf = self;
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        SKSPhotoConfig *config = [SKSPhotoConfig defaultConfig];
        config.pickType = SKSPhotoPickTypeCamero;
        config.editBorderSize = CGSizeMake(250, 250);
        [SKSPhotoBrowser.shared showInView:self Config:config Completion:^(NSArray<UIImage *> * _Nonnull imageArray, NSString * _Nonnull errorMsg) {
            if (errorMsg.length > 0) {
                NSLog(@"errorMsg = %@", errorMsg);
                return ;
            }
            weakSelf.bigImgView.image = imageArray.firstObject;
        }];
    }];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"从相册中选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        SKSPhotoConfig *config = [SKSPhotoConfig defaultConfig];
        config.editBorderSize = CGSizeMake(200, 200);
        config.pickType = SKSPhotoPickTypePhoto;
        config.isDragEditBorder = NO;
        [SKSPhotoBrowser.shared showInView:self Config:config Completion:^(NSArray<UIImage *> *imageArray, NSString *errorMsg) {
            if (errorMsg.length > 0) {
                NSLog(@"errorMsg = %@", errorMsg);
                return ;
            }
            weakSelf.bigImgView.image = imageArray.firstObject;
        }];
    }];
    
    UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alertC addAction:action1];
    [alertC addAction:action2];
    [alertC addAction:action3];
    [self presentViewController:alertC animated:YES completion:^{
        
    }];
}

@end
