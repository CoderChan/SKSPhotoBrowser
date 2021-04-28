# SKSPhotoBrower
## ☆☆☆ 一行代码实现从相册/相机中取出图片并裁剪 ☆☆☆

###支持cocoapods导入

    pod 'SKSPhotoBrower', '>= 1.0.7'

---------------------------------------------------------------------------------------------------------------

###更改记录：  
2020.11.19 -- init v1.0.0   上传第一版代码    

![](https://github.com/CoderChan/SKSPhotoBrowser/blob/main/IMG_6048.JPG?raw=true)
![](https://github.com/CoderChan/SKSPhotoBrowser/blob/main/IMG_6046.jpg?raw=true)

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
