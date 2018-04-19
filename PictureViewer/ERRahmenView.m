//
//  ERRahmenView.m
//  domo
//
//  Created by yangrenxiang on 2017/4/12.
//  Copyright © 2017年 yangrenxiang. All rights reserved.
//

#import "ERRahmenView.h"
#import "AFNetworking.h"
#import "UIImageView+ERWebCache.h"
#import "PAIMApiMessage.h"
#import "PAActionSheet.h"
#import "ERPhotoLibarayTool.h"
#import "SGQRCodeAlbumManager.h"

@interface ERRahmenView () <UIScrollViewDelegate ,PAActionSheetDelegate>
/// 展示图片
@property (nonatomic ,strong) UIImageView *photoImageView;
/// 蒙层
@property (nonatomic ,strong) UIView *trackMatteView;
/// 加载进度
@property (nonatomic ,strong) ERProgressView *progressView;

@end

@implementation ERRahmenView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
//        self.scrollEnabled = NO;
        //设置最大倍数
        self.maximumZoomScale = 2.0;
        //设置最小倍数
        self.minimumZoomScale = 1.0;
        self.delegate = self;
        
        self.backgroundColor = [UIColor clearColor];

        [self addSubview:self.photoImageView];
        [self addSubview:self.trackMatteView];

    }
    return self;
}

- (void)imgFrameRevert
{
    if (self.zoomScale > 1.0) {
        [self setZoomScale:1.0];
    }
}

#pragma mark - private
- (void)startDownloadOriginalImage
{
    //开始下载全量图片
    [self startDownloadTask];
}

- (void)startDownloadTask
{
    //开始加载动画
    [self startLoadAnimating];
    __weak typeof(self)weakSelf = self;
    if (self.model.imgUrl && self.model.imgUrl.length) {
        NSURL *imgUrl = [NSURL URLWithString:self.model.imgUrl];
        [self.photoImageView ERsd_setImageWithPreviousCachedImageWithURL:imgUrl placeholderImage:self.model.thumpic options:SDWebImageProgressiveDownload progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            
            NSLog(@"加载进度:%.2f",(float)receivedSize/expectedSize);
        } completed:^(UIImage *image, NSError *error, ERSDImageCacheType cacheType, NSURL *imageURL) {
            if (error) {
                NSLog(@"error:%@",error.description);
            }
            dispatch_async(dispatch_get_main_queue(), ^{
//                if (weakSelf.completeBlock && image) {
//                    weakSelf.completeBlock(image ,imageURL.absoluteString);
//                }
                weakSelf.model.image = image;
                [weakSelf stopLoadAnimating];
            });
        }];
    }else if(self.model.downloadkey && self.model.conversationId){
        __weak typeof(self)weakSelf = self;
        //加载IM图片资源
        [[PAIMApiMessage shareInstance] downloadMwPhotoImageByMsgId:self.model.downloadkey conversationId:self.model.conversationId successBlock:^(NSString *path, UIImage *image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (weakSelf.completeBlock && image) {
                    weakSelf.completeBlock(image ,path);
                }
                weakSelf.model.image = image;
                weakSelf.photoImageView.image = image;
                [weakSelf stopLoadAnimating];
            });

            [kNotificationCenter pa_postNotificationOnMainThreadWithName:kNotifyConversationRefreshed object:nil userInfo:@{@"conversationId":self.model.conversationId}];
        } failedBlock:^{
            dispatch_async(dispatch_get_main_queue(), ^{
               [weakSelf stopLoadAnimating];
            });
        }];
    }else {
        [self stopLoadAnimating];
    }
}

- (void)startLoadAnimating
{
    self.trackMatteView.hidden = NO;
    [self.progressView startAnimating];
}

- (void)stopLoadAnimating
{
    self.trackMatteView.hidden = YES;
    [self.progressView stopAnimating];
    if (!self.photoImageView.image) {
        self.photoImageView.image = [UIImage imageNamed:@"DefaultImage_icon"];
    }
}

#pragma mark - event
- (void)longPressAction:(UILongPressGestureRecognizer *)gesture
{
    if (!self.photoImageView.image) {
        return;
    }
    if (gesture.state == UIGestureRecognizerStateBegan &&
        !self.waterMarkText) {
        //长按手势开始响应
//        PAActionSheet *sheet = [[PAActionSheet alloc] initWithDelegate:self CancelTitle:@"取消" OtherTitles:@"保存到相册", nil];
        PAActionSheet *sheet = [[PAActionSheet alloc] initWithDelegate:self CancelTitle:@"取消" OtherTitles:@"保存到相册",@"发送给朋友",(self.model.detectorString?@"识别图中二维码":nil), nil];
        [sheet show];
    }
}

- (void)actionSheet:(PAActionSheet *)actionSheet clickedButtonTitle:(NSString *)btnTitle
{
    if ([btnTitle isEqualToString:@"保存到相册"]) {
        [self saveImageToPhotosAlbum];
    }else if ([btnTitle isEqualToString:@"发送给朋友"]) {
        if (self.eventDelegate && [self.eventDelegate respondsToSelector:@selector(handlerShareImageWithModel:)]) {
            [self.eventDelegate handlerShareImageWithModel:self.model];
        }
    }else if ([btnTitle isEqualToString:@"识别图中二维码"]) {
        if (self.eventDelegate && [self.eventDelegate respondsToSelector:@selector(handlerDetectorQrcodeWithModel:)]) {
            [self.eventDelegate handlerDetectorQrcodeWithModel:self.model];
        }
    }
}

- (void)saveImageToPhotosAlbum
{
    [self startLoadAnimating];
    __weak typeof(self)weakSelf = self;
    [[ERPhotoLibarayTool new] saveImageToPhotosAlbumWithImage:self.photoImageView.image finished:^(BOOL isSuc, NSString *msg) {
        [weakSelf stopLoadAnimating];
        if (isSuc) {
            kShowSuccessText(@"保存到相册成功");
        }else {
            kShowErrorText(msg);
        }
    }];
}



#pragma mark - setter/getter
- (void)setModel:(ERPicture *)model
{
    if (!model) return;
    if (![model isKindOfClass:[ERPicture class]]) return;
    
    _model = model;
    if (model.image) {
        
        self.photoImageView.image = model.image;
    }else if (model.thumpic) {
    
        self.photoImageView.image = model.thumpic;
        [self startDownloadOriginalImage];
    }else {
        
        self.photoImageView.image = [UIImage imageNamed:model.downLoadErrorImageName];
        [self startDownloadOriginalImage];
    }
}

- (void)setProgressStyle:(ERProgressStyle)progressStyle
{
    _progressStyle = progressStyle;
    self.progressView.progressStyle = _progressStyle;
}

- (void)setWaterMarkText:(NSString *)waterMarkText
{
    if (!waterMarkText) {
        return;
    }
    _waterMarkText = waterMarkText;
    [ERWaterMarkTool showWaterMarkInView:self.photoImageView displaySize:self.photoImageView.bounds.size waterMarkText:self.waterMarkText angle:15];
}

- (UIImageView *)photoImageView
{
    if (!_photoImageView) {
        
        _photoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
        _photoImageView.contentMode = UIViewContentModeScaleAspectFit;
        
        UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
        [_photoImageView addGestureRecognizer:longGesture];
        _photoImageView.userInteractionEnabled = YES;
    }
    return _photoImageView;
}

- (UIView *)trackMatteView
{
    if (!_trackMatteView) {
        
        _trackMatteView = [[UIView alloc] initWithFrame:self.bounds];
        _trackMatteView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        _trackMatteView.hidden = YES;
        [_trackMatteView addSubview:self.progressView];
    }
    return _trackMatteView;
}

- (ERProgressView *)progressView
{
    if (!_progressView) {
        
        _progressView = [[ERProgressView alloc] initWithFrame:CGRectMake(0, 0, YAUTO_PX(80), YAUTO_PX(80))];
        _progressView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        _progressView.progressStyle = self.progressStyle;
     }
    return _progressView;
}

#pragma mark - UIScrollViewDelegate
/// 只有实现了该方法，scrollView的缩放手势才能触发
- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.photoImageView;
}
/// 当缩放手势结束后，回到原位置
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
//    [scrollView setZoomScale:1.0 animated:NO];
}

@end

@implementation ERPicture

- (instancetype)initWithImage:(UIImage *)image
                      thumpic:(UIImage *)thumpic
                       imgUrl:(NSString *)imgUrl
                      thumUrl:(NSString *)thumUrl
                  downloadkey:(NSString *)downloadkey
               conversationId:(NSString *)conversationId
{
    if (self = [super init]) {
        
        self.image = image;
        self.thumpic = thumpic;
        self.imgUrl = imgUrl;
        self.thumUrl = thumUrl;
        self.downloadkey = downloadkey;
        self.conversationId = conversationId;
        self.downLoadErrorImageName = @"DefaultImage_icon";
    }
    return self;
}

- (void)setImage:(UIImage *)image
{
    _image = image;
    if (!image) {
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        self.detectorString = [SGQRCodeAlbumManager detectorQRCodeFromImage:image];
    });
}

@end
