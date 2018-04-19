//
//  ERPictureViewController.h
//  Enrich
//
//  Created by 杨仁祥 on 2018/3/31.
//  Copyright © 2018年 PingAn. All rights reserved.
//

#import "ERBaseViewController.h"
#import "ERRahmenView.h"

typedef void(^downloadOriginalImageCompleteBlcok)(NSInteger index ,UIImage *image ,NSString *path);

@interface ERPictureViewController : ERBaseViewController

/** 加载进度style(默认是菊花) */
@property (nonatomic ,assign) ERProgressStyle progressStyle;
/** 图片下载完成回调 */
@property (nonatomic ,copy) downloadOriginalImageCompleteBlcok completeBlock;


- (void)ShowSelectImageViewInWindow:(UIImageView *)selectImageView
                              index:(NSInteger)index
                             images:(NSArray<ERPicture *> *)images
                      waterMarkText:(NSString *)waterMarkText;

@end
