//
//  HQImageEditViewController.m
//  CivilAviation
//
//  Created by iOS on 2019/3/29.
//  Copyright © 2019 iOS. All rights reserved.
//

#import "SKSImageEditViewController.h"
#import "SKSEditImageActionView.h"
#import "SKSEditImageCaptureView.h"
#import "SKSEditImageEditView.h"
#import <Masonry/Masonry.h>
#import "SKSPhotoBrowser.h"

static inline UIEdgeInsets hq_safeAreaInset() {
    if (@available(iOS 11.0, *)) {
        return [UIApplication sharedApplication].keyWindow.safeAreaInsets;
    }
    return UIEdgeInsetsZero;
}

@interface SKSImageEditViewController () <UIScrollViewDelegate, SKSEditImageActionViewDelegate, SKSEditImageEditViewDelegate>

@property (nonatomic, strong) SKSEditImageCaptureView *captureView;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) SKSEditImageActionView *actionView;
@property (nonatomic, strong) SKSEditImageEditView *editView;

@property (nonatomic, assign) NSInteger rotateTimes;
@property (nonatomic, assign) CGSize imageViewOriginSize;

@property (nonatomic, assign) BOOL showNavigationBarWhenPop;

/// 配置信息
@property (nonatomic) SKSPhotoConfig *config;

/**
 截取原图
 */
@property (nonatomic, strong) UIImage *originImage;

/// 回调
@property (nonatomic, copy) SKSEditCompletionBlock completionBlock;

@end

@implementation SKSImageEditViewController

- (instancetype)initWithConfig:(SKSPhotoConfig *)config OriginImage:(UIImage *)originImage Completion:(SKSEditCompletionBlock)completion {
    self = [super init];
    if (self) {
        self.config = config;
        self.originImage = originImage;
        self.completionBlock = completion;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:(55)/255.0f green:(55)/255.0f blue:(55)/255.0f alpha:(1)];
    self.view.layer.masksToBounds = YES;
    
    [self.view addSubview:self.captureView];
    [self.captureView addSubview:self.scrollView];
    [self.scrollView addSubview:self.imageView];
    [self.view addSubview:self.actionView];
    [self.view addSubview:self.editView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [self.captureView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(self.editViewSize.width));
        make.height.equalTo(@(self.editViewSize.height));
        make.centerY.equalTo(self.view).offset(-24 * NumberValue);
        make.centerX.equalTo(self.view);
    }];
    
    [self.actionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(@0);
        make.height.equalTo(@(49 * NumberValue + hq_safeAreaInset().bottom));
    }];
    
    [self.editView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(self.editViewSize.width));
        make.height.equalTo(@(self.editViewSize.height));
        make.top.equalTo(@((CGFloat)(hq_safeAreaInset().top + self.topSpace)));
        make.centerX.equalTo(@0);
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.navigationController.isNavigationBarHidden == NO) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        self.showNavigationBarWhenPop = YES;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.showNavigationBarWhenPop) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.editView maskViewShowWithDuration:.2f];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - UIScrollViewDelegate & 双手拖拽图片缩放
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.config.isEditZoom) {
        [self.editView maskViewHideWithDuration:.2f];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (self.config.isEditZoom) {
        [self.editView maskViewShowWithDuration:.2f];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (self.config.isEditZoom) {
        if (!decelerate) {
            [self.editView maskViewShowWithDuration:.2f];
        }
    }
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    if (self.config.isEditZoom) {
        [self.editView maskViewHideWithDuration:.2f];
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    if (self.config.isEditZoom) {
        return self.imageView;
    }else{
        return nil;
    }
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    if (self.config.isEditZoom) {
        [self.scrollView setZoomScale:scale animated:NO];
        [self.editView maskViewShowWithDuration:.2f];
    }
}

#pragma mark - SKSEditImageActionViewDelegate
- (void)action:(SKSEditImageActionView *)action didClickButton:(UIButton *)button atIndex:(NSInteger)index {
    if (index == 0) { // 旋转
        self.rotateTimes ++;
        self.captureView.rotateTimes = self.rotateTimes;
        [self rotateScrollView:self.rotateTimes];
    } else if (index == 1) {
        // 取消
        [self originAll];
        [self.navigationController popViewControllerAnimated:YES];
        
    } else if (index == 2) {
        // 还原
        [self originAll];
    } else if (index == 3) {
        // 完成
        if (self.scrollView.isDragging || self.scrollView.isDecelerating || self.scrollView.isZoomBouncing) {
            return;
        }
        
        UIImage *image = [self.captureView captureImage];
//        UIImage *originImage = [self.captureView captureOriginalImage];
        if (self.completionBlock) {
            self.completionBlock(image, self);
        }
    }
}

#pragma mark - HQEditImageEditViewDelegate
- (void)editView:(SKSEditImageEditView *)editView anchorPointIndex:(NSInteger)anchorPointIndex rect:(CGRect)rect {
    CGRect imageEditRect = [self.captureView convertRect:rect toView:self.imageView];
    [self.scrollView zoomToRect:imageEditRect animated:YES];
}

#pragma mark - 旋转图片
- (void)rotateScrollView:(NSInteger)times {
    self.view.userInteractionEnabled = NO;
    [UIView animateWithDuration:.3f animations:^{
        self.scrollView.transform = CGAffineTransformRotate(self.scrollView.transform, -M_PI_2);
    } completion:^(BOOL finished) {
        if (self.editViewSize.width != self.editViewSize.height) {
            [self.scrollView setZoomScale:1.f animated:YES];
            [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
            [UIView animateWithDuration:.3f animations:^{
                self.scrollView.frame = CGRectMake(0, 0, self.editViewSize.width, self.editViewSize.height);
                if (times % 2 == 1) {
                    if (self.editViewSize.width * (self.imageViewOriginSize.width/self.imageViewOriginSize.height) >= self.editViewSize.height) {
                        self.imageView.frame = CGRectMake(0, 0, self.editViewSize.width * (self.imageViewOriginSize.width/self.imageViewOriginSize.height), self.editViewSize.width);  //宽拉满
                    } else {
                        self.imageView.frame = CGRectMake(0, 0, self.editViewSize.height, self.editViewSize.height * (self.imageViewOriginSize.height / self.imageViewOriginSize.width)); //高拉满
                    }
                } else {
                    self.imageView.frame = CGRectMake(0, 0, self.imageViewOriginSize.width, self.imageViewOriginSize.height);
                }
            } completion:^(BOOL finished) {
                self.scrollView.contentSize = self.imageView.frame.size;
                self.view.userInteractionEnabled = YES;
            }];
        } else {
            self.view.userInteractionEnabled = YES;
        }
    }];
    
}

- (void)originAll {
    self.rotateTimes = 0;
    self.captureView.rotateTimes = 0;
    [self.scrollView setZoomScale:1];
    self.scrollView.transform = CGAffineTransformIdentity;
    self.scrollView.frame = CGRectMake(0, 0, self.editViewSize.width, self.editViewSize.height);
    self.imageView.frame = CGRectMake(0, 0, self.imageViewOriginSize.width, self.imageViewOriginSize.height);
    self.scrollView.contentSize = self.imageView.frame.size;
    self.scrollView.contentOffset = CGPointMake(0, 0);
}

#pragma mark - override
- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - getter & setter
- (CGFloat)topSpace {
    return (([[UIScreen mainScreen] bounds].size.height) - hq_safeAreaInset().top - hq_safeAreaInset().bottom - 49*2 - self.editViewSize.height)/2.f;
}

- (CGFloat)leftSpace {
    return (([[UIScreen mainScreen] bounds].size.width) - self.editViewSize.width)/2.f;
}

- (CGFloat)rightSpace {
    return (([[UIScreen mainScreen] bounds].size.width) - self.editViewSize.width)/2.f;
}

- (CGFloat)bottomSpace {
    return (([[UIScreen mainScreen] bounds].size.height) - hq_safeAreaInset().top - hq_safeAreaInset().bottom - 49*2 - self.editViewSize.height)/2.f;
}

- (CGSize)editViewSize {
    return self.config.editBorderSize;
}

- (CGSize)imageViewOriginSize {
    CGSize imageSize = self.originImage.size;
    if (self.originImage.size.width == 0) {
        imageSize.width = 200;
    }
    if (self.originImage.size.height == 0) {
        imageSize.height = 200;
    }
        
    if (self.editViewSize.width / imageSize.width > self.editViewSize.height / imageSize.height) {
        return CGSizeMake(self.editViewSize.width, (CGFloat)((imageSize.height / imageSize.width) * self.editViewSize.width)); //宽
    } else {
        return CGSizeMake((CGFloat)((imageSize.width / imageSize.height) *self.editViewSize.height), self.editViewSize.height);  //高
    }
}

- (SKSEditImageCaptureView *)captureView {
    if (!_captureView) {
        _captureView = [[SKSEditImageCaptureView alloc] init];
        _captureView.captureView = self.scrollView;
        _captureView.imageView = self.imageView;
    }
    return _captureView;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 10, self.editViewSize.width, self.editViewSize.height)];
        
        _scrollView.delegate = self;
        _scrollView.layer.masksToBounds = NO;
        
        _scrollView.minimumZoomScale = 1.f;
        _scrollView.maximumZoomScale = 10.f;
        _scrollView.zoomScale = 1.f;
        
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        
        _scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
        
        _scrollView.contentInset = UIEdgeInsetsZero;
        _scrollView.contentSize = CGSizeMake(self.imageViewOriginSize.width, self.imageViewOriginSize.height);
        if (@available(iOS 11.0, *)) {
            _scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }

    }
    return _scrollView;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.imageViewOriginSize.width, self.imageViewOriginSize.height)];
        _imageView.image = self.originImage;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _imageView;
}

- (SKSEditImageActionView *)actionView {
    if (!_actionView) {
        _actionView = [[SKSEditImageActionView alloc] init];
        _actionView.delegate = self;
    }
    return _actionView;
}

- (SKSEditImageEditView *)editView {
    if (!_editView) {
        UIEdgeInsets edgeInsets = UIEdgeInsetsMake(self.topSpace + hq_safeAreaInset().top, self.leftSpace, self.bottomSpace, self.rightSpace);
        CGSize size = CGSizeMake(self.editViewSize.width, self.editViewSize.height);
        _editView = [[SKSEditImageEditView alloc]initWithConfig:self.config Margin:edgeInsets size:size];
        _editView.delegate = self;
        _editView.maskViewAnimation = self.maskViewAnimation;
    }
    return _editView;
}



@end
