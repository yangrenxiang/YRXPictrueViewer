//
//  ERRahmenView.h
//  domo
//
//  Created by yangrenxiang on 2017/4/12.
//  Copyright © 2017年 yangrenxiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ERProgressView.h"
#import "ERWaterMarkTool.h"
@class ERPicture;

typedef void(^CompleteBlcok)(UIImage *image ,NSString *path);

@protocol ERRahmenViewEventHandlerDelegate <NSObject>

@optional
- (void)handlerShareImageWithModel:(ERPicture *)model;
- (void)handlerDetectorQrcodeWithModel:(ERPicture *)model;

@end

@interface ERRahmenView : UIScrollView
/** 水印文字 */
@property (nonatomic ,copy) NSString *waterMarkText;
/** 图片数据模型 */
@property (nonatomic ,strong) ERPicture *model;
/** 加载进度style */
@property (nonatomic ,assign) ERProgressStyle progressStyle;
/** 下载完成回调 */
@property (nonatomic ,copy) CompleteBlcok completeBlock;
@property (nonatomic ,weak) id <ERRahmenViewEventHandlerDelegate>eventDelegate;
/** 图片frame还原 */
- (void)imgFrameRevert;

@end

@interface ERPicture : NSObject
/** 原图片 */
@property (nonatomic ,strong) UIImage *image;
/** 缩略图 */
@property (nonatomic ,strong) UIImage *thumpic;
/** 下载错误图片名称 */
@property (nonatomic ,copy) NSString *downLoadErrorImageName;
/** 原图URL */
@property (nonatomic ,copy) NSString *imgUrl;
/** 缩略图Url */
@property (nonatomic ,copy) NSString *thumUrl;
/** 解析的二维码字符串 */
@property (nonatomic ,copy) NSString *detectorString;

//****************** IM ************************
/** 下载key (也是消息Id) */
@property (nonatomic ,copy) NSString *downloadkey;
/** 消息会话Id */
@property (nonatomic ,copy) NSString *conversationId;
/** 消息content */
@property (nonatomic ,copy) NSString *msgContent;
//****************** IM ************************

/** 下载进度 */
@property (nonatomic ,assign) CGFloat progress;

/**
 创建图片模型

 @param image 原图
 @param thumpic 缩略图
 @param imgUrl 原图url
 @param thumUrl 缩略图url
 @param downloadkey 下载key
 @param conversationId 会话id
 @return 图片模型
 */
- (instancetype)initWithImage:(UIImage *)image
                      thumpic:(UIImage *)thumpic
                       imgUrl:(NSString *)imgUrl
                      thumUrl:(NSString *)thumUrl
                  downloadkey:(NSString *)downloadkey
               conversationId:(NSString *)conversationId;

@end





