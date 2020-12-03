//
//  HQEditImageActionView.h
//  CivilAviation
//
//  Created by iOS on 2019/3/29.
//  Copyright © 2019 iOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Masonry/Masonry.h>

NS_ASSUME_NONNULL_BEGIN

@class SKSEditImageActionView;
@protocol SKSEditImageActionViewDelegate <NSObject>

- (void)action:(SKSEditImageActionView *)action didClickButton:(UIButton *)button atIndex:(NSInteger)index;

@end

@interface SKSEditImageActionView : UIView

@property (nonatomic, weak) id <SKSEditImageActionViewDelegate> delegate;

/// 旋转图标
//@property (nonatomic, strong) UIButton *rotateButton;
/// 取消
@property (nonatomic, strong) UIButton *cancelButton;
/// 还原
@property (nonatomic, strong) UIButton *originButton;
/// 完成
@property (nonatomic, strong) UIButton *finishButton;

@end

NS_ASSUME_NONNULL_END
