//
//  ERPictureViewer.m
//  domo
//
//  Created by yangrenxiang on 2017/2/24.
//  Copyright © 2017年 yangrenxiang. All rights reserved.
//

#import "ERPictureViewer.h"
#import "ERViewControllerTool.h"

@interface ERPictureViewer ()
@end

@implementation ERPictureViewer

static ERPictureViewer *pictureViewer = nil;
static dispatch_once_t onceToken;

+ (instancetype)sharedInstance
{
    dispatch_once(&onceToken, ^{
        
        pictureViewer = [[ERPictureViewer alloc] init];
    });
    return pictureViewer;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.progressStyle = ERProgressStyleChrysanthemum;
    }
    return self;
}

#pragma mark - public Method
- (void)ShowSelectImageViewInWindow:(UIImageView *)selectImageView
                            picture:(ERPicture *)picture
                      waterMarkText:(NSString *)waterMarkText
                      completeBlock:(downloadOriginalImageCompleteBlcok)completeBlock
{
    if (!picture) return;
    [self ShowSelectImageViewInWindow:selectImageView index:0 images:@[picture] waterMarkText:waterMarkText completeBlock:completeBlock];
}

- (void)ShowSelectImageViewInWindow:(UIImageView *)selectImageView
                              index:(NSInteger)index
                             images:(NSArray<ERPicture *> *)images
                      waterMarkText:(NSString *)waterMarkText
                      completeBlock:(downloadOriginalImageCompleteBlcok)completeBlock
{
    UIViewController *topVc = [ERViewControllerTool topVisibleViewController];
    if (!topVc) {
        return;
    }
    ERPictureViewController *vc = [[ERPictureViewController alloc] init];
    ERBaseNavigationController *nav = [[ERBaseNavigationController alloc] initWithRootViewController:vc];
    nav.definesPresentationContext = YES;
    [nav setModalPresentationStyle:UIModalPresentationCustom];
    vc.progressStyle = self.progressStyle;
    vc.completeBlock = completeBlock;
    [vc ShowSelectImageViewInWindow:selectImageView index:index images:images waterMarkText:waterMarkText];
    [topVc presentViewController:nav animated:NO completion:nil];
}

@end


