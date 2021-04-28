# SKSPhotoBrower
## ☆☆☆ 一行代码实现从相册/相机中取出图片并裁剪 ☆☆☆

###支持cocoapods导入

    pod 'SKSPhotoBrower', '>= 1.0.6'

---------------------------------------------------------------------------------------------------------------

###更改记录：  
2020.11.19 -- init v1.0.0   上传第一版代码    

### 一行代码实现，如下：


    SKSPhotoConfig *config = [[SKSPhotoConfig alloc]initWithDefaultConfig];
    config.editBorderSize = CGSizeMake(200, 200);
    config.pickType = Photo;
    config.isDragEditBorder = NO;
    [SKSPhotoBrowser.shared showInView:self Config:config Completion:^(NSArray<UIImage *> *imageArray, NSString *errorMsg) {
        if (errorMsg.length > 0) {
            NSLog(@"errorMsg = %@", errorMsg);
            return ;
        }
    weakSelf.bigImgView.image = imageArray.firstObject;
    }];

---------------------------------------------------------------------------------------------------------------
