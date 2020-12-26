//
//  AppDelegate.m
//  SKSPhotoManagerDemo
//
//  Created by sks on 2020/2/13.
//  Copyright © 2020 三棵树. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@interface AppDelegate ()

/// 是否强制横屏
@property (nonatomic, assign) BOOL isForceLandscape;

/// 是否强制竖屏
@property (nonatomic, assign) BOOL isForcePortrait;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self initKeyWindow];
    return YES;
}

- (void)initKeyWindow {
    ViewController *home = [[ViewController alloc]init];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:home];
    self.window = [[UIWindow alloc]initWithFrame:UIScreen.mainScreen.bounds];
    self.window.backgroundColor = [UIColor grayColor];
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
//    if (self.isForceLandscape) {
//        return UIInterfaceOrientationMaskLandscape;
//    }else if (self.isForcePortrait) {
//        return UIInterfaceOrientationMaskPortrait;
//    }else{
//        return UIInterfaceOrientationMaskLandscape;
//    }
    return UIInterfaceOrientationMaskPortrait;
}

@end
