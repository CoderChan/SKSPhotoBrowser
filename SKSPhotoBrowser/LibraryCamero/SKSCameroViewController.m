//
//  SKSCameroViewController.m
//  SKSPhotoManagerDemo
//
//  Created by sks on 2020/2/13.
//  Copyright © 2020 三棵树. All rights reserved.
//

#import "SKSCameroViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "SKSImageEditViewController.h"
#import "SKSPhotoResource.h"
#import <Masonry/Masonry.h>

@interface SKSCameroViewController ()

/// 配置信息
@property (nonatomic) SKSPhotoConfig *config;

/// 完成的回调
@property (nonatomic, copy) SKSCompletionBlock completionBlock;

/**
 *  核心
 */
@property (nonatomic, strong) AVCaptureSession* session;
/**
 *  输入设备
 */
@property (nonatomic, strong) AVCaptureDeviceInput* videoInput;
/**
 *  照片输出流
 */
@property (nonatomic, strong) AVCaptureStillImageOutput* stillImageOutput;
/**
 *  预览图层
 */
@property (nonatomic, strong) AVCaptureVideoPreviewLayer* previewLayer;

/**
 *  最后的缩放比例
 */
@property(nonatomic,assign)CGFloat effectiveScale;

/// 背景
@property (nonatomic, strong) UIView *backView;

/// 取消按钮
@property (nonatomic) UIButton *cancleButton;

/// 拍摄按钮
@property (nonatomic) UIButton *takeButton;

/// 数据异常的提示
@property (strong,nonatomic) UILabel *emptyLabel;
/// 数据异常时的图片
@property (strong,nonatomic) UIImageView *emptyImgView;
/// 异常时的按钮点击
@property (nonatomic) UIButton *emptyButton;
/// 点击缺省页按钮
@property (nonatomic, copy) void (^clickBlock)(void);

@end

@implementation SKSCameroViewController

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
    self.title = @"拍摄";
    [self setupSubViews];
}

- (void)setupSubViews {
    self.view.backgroundColor = SKSPhoto_RGBACOLOR(55, 55, 55, 1);
    BOOL is_pad = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? YES : NO;
    
    self.backView = [[UIView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:self.backView];
    
    // 自己定义一个和原生的相机一样的按钮
    CGFloat registerSize = 70;
    self.takeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.takeButton.frame = CGRectMake(self.view.frame.size.width / 2 - registerSize/2, self.view.frame.size.height - [self bottonHeight] + 5, registerSize, registerSize);
    [self.takeButton setImage:[self imageWithImage:[SKSPhotoResource imageNamed:@"sks_photo_take_camero"] imageColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    [self.takeButton addTarget:self action:@selector(btnRegisterClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.takeButton];
    
    self.cancleButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.cancleButton.frame = CGRectMake(is_pad ? 50 : 23, self.view.frame.size.height - [self bottonHeight] + 5, 40, registerSize);
    [self.cancleButton setTitle:@"取消" forState:UIControlStateNormal];
    self.cancleButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.cancleButton setTintColor:[UIColor whiteColor]];
    [self.cancleButton addTarget:self action:@selector(cancleAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.cancleButton];
    
    [self checkCameroAuthorization];
    
}

- (void)addLayerAction {
    
    BOOL is_pad = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? YES : NO;
    if (self.config.editBorderType == SquareBorder) {
        CGFloat left = is_pad ? 80 : 35;
        CGFloat width = self.view.frame.size.width - left * 2;
        CGFloat height = width / 0.75;
        UIImageView *layerIcon = [[UIImageView alloc]initWithImage:[SKSPhotoResource imageNamed:@"sks_photo_border"]];
        layerIcon.frame = CGRectMake(left, (self.view.frame.size.height - height) / 2, width, height);
        layerIcon.layer.position = CGPointMake(self.view.frame.size.width / 2, (self.view.frame.size.height - [self bottonHeight]) / 2);
        [self.view.layer addSublayer:layerIcon.layer];
    }else if (self.config.editBorderType == CircleBorder){
        
    }else {
        // 没有边框，全景
    }
}

- (void)checkCameroAuthorization {
    __weak __block typeof(self) weakSelf = self;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusNotDetermined) {
        // 还没做出选择
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if (granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                   [weakSelf initAVCaptureSession]; //设置相机属性
                });
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf showEmptyViewWithButtonTitle:@"检查设置" Message:@"暂无相机拍摄权限" ClickBlock:^{
                        [UIApplication.sharedApplication openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                    }];
                });
            }
        }];
    }else if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
        // 之前拒绝了
        [self showEmptyViewWithButtonTitle:@"检查设置" Message:@"暂无相机拍摄权限" ClickBlock:^{
            [UIApplication.sharedApplication openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }];
    }else{
        // 允许访问
        if (self.config.editBorderType != NoneBorder) {
            [self addLayerAction];
        }
        [self initAVCaptureSession]; //设置相机属性
    }
}


- (void)showEmptyViewWithButtonTitle:(NSString *)title Message:(NSString *)message ClickBlock:(void (^)(void))clickBlock {
    
    self.clickBlock = clickBlock;
    self.emptyLabel.text = message;
    self.takeButton.enabled = NO;
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


#pragma mark - 设置相机
- (void)initAVCaptureSession
{
    self.effectiveScale = 1.0f;
    self.session = [[AVCaptureSession alloc] init];
    [self.session setSessionPreset:AVCaptureSessionPresetHigh];
    [self.session startRunning];
    
    NSError *error;
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // 更改这个设置的时候必须先锁定设备，修改完后再解锁，否则崩溃
    [device lockForConfiguration:nil];
    //设置闪光灯为自动
    if ([device isFlashModeSupported:AVCaptureFlashModeAuto]) {
        [device setFlashMode:AVCaptureFlashModeAuto];
    }
    
    [device unlockForConfiguration];
    
    self.videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:device error:&error];
    AVCaptureVideoDataOutput *captureOutput = [[AVCaptureVideoDataOutput alloc] init];
    if (error) {
        [self showEmptyViewWithButtonTitle:nil Message:error.localizedDescription ClickBlock:^{
            
        }];
        return;
    }
    
    [self hideMessageAction];
    
    
    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    // 输出设置。AVVideoCodecJPEG   输出jpeg格式图片
    NSDictionary * outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG, AVVideoCodecKey, nil];
    [self.stillImageOutput setOutputSettings:outputSettings];
    
    if ([self.session canAddInput:self.videoInput]) {
        [self.session addInput:self.videoInput];
    }
    if ([self.session canAddOutput:captureOutput]) {
        [self.session addOutput:captureOutput];
    }
    if ([self.session canAddOutput:self.stillImageOutput]) {
        [self.session addOutput:self.stillImageOutput];
    }
    
    // 初始化预览图层
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    self.previewLayer.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    self.backView.layer.masksToBounds = YES;
    [self.backView.layer addSublayer:self.previewLayer];
    
}

- (AVCaptureVideoOrientation)avOrientationForDeviceOrientation:(UIDeviceOrientation)deviceOrientation
{
    AVCaptureVideoOrientation result = (AVCaptureVideoOrientation)deviceOrientation;
    if ( deviceOrientation == UIDeviceOrientationLandscapeLeft )
        result = AVCaptureVideoOrientationLandscapeRight;
    else if ( deviceOrientation == UIDeviceOrientationLandscapeRight )
        result = AVCaptureVideoOrientationLandscapeLeft;
    return result;
}

- (void)btnRegisterClicked {
    AVCaptureConnection *stillImageConnection = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    UIDeviceOrientation curDeviceOrientation = [[UIDevice currentDevice] orientation];
    AVCaptureVideoOrientation avcaptureOrientation = [self avOrientationForDeviceOrientation:curDeviceOrientation];
    [stillImageConnection setVideoOrientation:avcaptureOrientation];
    [stillImageConnection setVideoScaleAndCropFactor:self.effectiveScale];
    
    __weak __block typeof(self) weakSelf = self;
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:stillImageConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        
        if (!error) {
            NSData *jpegData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            [self makeImageView:jpegData];
        }else{
            NSString *reason = [NSString stringWithFormat:@"成像失败：%@" , error.localizedDescription];
            weakSelf.completionBlock(@[], reason);
        }
    }];
}

//拍照之后调到相册编辑框界面
-(void)makeImageView:(NSData*)data {
    UIImage *image = [UIImage imageWithData:data];
    image = [self imageWithRightOrientation:image];
    __weak __block typeof(self) weakSelf = self;
    SKSImageEditViewController *editVC = [[SKSImageEditViewController alloc]initWithConfig:self.config OriginImage:image Completion:^(UIImage * _Nonnull editImage, SKSImageEditViewController * _Nonnull vc) {
        if (weakSelf.completionBlock) {
            weakSelf.completionBlock(@[editImage], @"");
            [vc.navigationController dismissViewControllerAnimated:YES completion:nil];
        }
    }];
    [self.navigationController pushViewController:editVC animated:YES];
}

- (void)cancleAction {
    [self.session stopRunning];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - 其他周期
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    if (self.session) {
        [self.session startRunning];
    }
}

- (void)viewDidDisappear:(BOOL)animated{
    
    [super viewDidDisappear:YES];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    if (self.session) {
        [self.session stopRunning];
    }
}



- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)is_iPhoneX {
    BOOL is_X = NO;
    if (@available(iOS 11.0, *)) {
        is_X = [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom > 0 ? YES : NO;
    } else {
        is_X = NO;
    }
    return is_X;
}

- (CGFloat)bottonHeight {
    return [self is_iPhoneX] ? 88 : 80;
}

- (void)hideMessageAction {
    
}

- (UIImage *)imageWithImage:(UIImage *)image imageColor:(UIColor *)imageColor {
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0f);
    [imageColor setFill];
    CGRect bounds = CGRectMake(0, 0, image.size.width, image.size.height);
    UIRectFill(bounds);
    [image drawInRect:bounds blendMode:kCGBlendModeDestinationIn alpha:1.0f];
    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return tintedImage;
}

- (UIImage *)imageWithRightOrientation:(UIImage *)aImage {
      
    UIImageOrientation imageOrientation = aImage.imageOrientation;
    // No-op if the orientation is already correct
    if (imageOrientation == UIImageOrientationUp)
        return aImage;
      
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
      
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
              
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
              
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
      
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
              
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
      
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
              
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
      
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    NSLog(@"图片方向1 = %ld",img.imageOrientation);
    return img;
}

#pragma mark - 懒加载
- (UILabel *)emptyLabel
{
    if (!_emptyLabel) {
        _emptyLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _emptyLabel.font = [UIFont systemFontOfSize:15];
        _emptyLabel.textAlignment = NSTextAlignmentCenter;
        _emptyLabel.numberOfLines = 0;
        _emptyLabel.textColor = [UIColor whiteColor];
    }
    return _emptyLabel;
}
- (UIImageView *)emptyImgView
{
    if (!_emptyImgView) {
        _emptyImgView = [[UIImageView alloc]initWithFrame:CGRectZero];
        _emptyImgView.image = [SKSPhotoResource imageNamed:@"sks_empty_white"];
    }
    return _emptyImgView;
}

- (UIButton *)emptyButton {
    if (!_emptyButton) {
        _emptyButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _emptyButton.hidden = YES;
        _emptyButton.backgroundColor = SKSPhoto_RGBACOLOR(119, 210, 248, 1);
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
