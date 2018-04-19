//
//  ERPictureViewer.h
//  domo
//
//  Created by yangrenxiang on 2017/2/24.
//  Copyright © 2017年 yangrenxiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
//#import "ERRahmenView.h"
#import "ERPictureViewController.h"
@class ERPictureViewer;

//typedef void(^downloadOriginalImageCompleteBlcok)(NSInteger index ,UIImage *image ,NSString *path);xxxxx

@protocol ERPictureViewerDelegate <NSObject>
//下载

//分享

//收藏

@end

@interface ERPictureViewer : NSObject

/** 加载进度style(默认是菊花) */
@property (nonatomic ,assign) ERProgressStyle progressStyle;
/** 图片下载完成回调 */
//@property (nonatomic ,copy) downloadOriginalImageCompleteBlcok completeBlock;
/**
 图片浏览

 @return self
 */
+ (instancetype)sharedInstance;

/**
 显示选中的Imageview

 @param selectImageView 选中的imageview
 @param picture 图片模型
 @param waterMarkText 水印文字(如果不需要水印则传nil)
 */
- (void)ShowSelectImageViewInWindow:(UIImageView *)selectImageView
                            picture:(ERPicture *)picture
                      waterMarkText:(NSString *)waterMarkText
                      completeBlock:(downloadOriginalImageCompleteBlcok)completeBlock;

/**
 显示多个图片

 @param selectImageView 当前选中的Imageview
 @param index index
 @param images 图片模型数组
 @param waterMarkText 水印文字(如果不需要水印则传nil)
 */
- (void)ShowSelectImageViewInWindow:(UIImageView *)selectImageView
                              index:(NSInteger)index
                             images:(NSArray<ERPicture *> *)images
                      waterMarkText:(NSString *)waterMarkText
                      completeBlock:(downloadOriginalImageCompleteBlcok)completeBlock;

@end




