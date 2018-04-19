//
//  ERProgressView.h
//  domo
//
//  Created by yangrenxiang on 2017/4/12.
//  Copyright © 2017年 yangrenxiang. All rights reserved.
//

#import <UIKit/UIKit.h>

#define YScreenWidth          [[UIScreen mainScreen] bounds].size.width
#define YScreenHeight         [[UIScreen mainScreen] bounds].size.height
#define YAUTO_PX(w)           (((float)(w))/2.0f * (YScreenWidth / 375))

typedef NS_ENUM(NSInteger ,ERProgressStyle) {
    
    ERProgressStyleChrysanthemum             ,  //菊花
    ERProgressStyleNoProgressAnnulus         ,  //不带进度的环形动画
    ERProgressStyleAnnulus                   ,  //带进度的环形动画
    ERProgressStyleAnnulusAndRound           ,  //环加圆
    //默认样式是菊花
    ERProgressStyleDefault = ERProgressStyleChrysanthemum
};

@interface ERProgressView : UIView

/// ERProgressStyleChrysanthemum
@property (nonatomic ,strong) UIColor *chrysanthemumTinColor UI_APPEARANCE_SELECTOR;
@property (nonatomic ,assign) UIActivityIndicatorViewStyle chrysanthemumStyle UI_APPEARANCE_SELECTOR;

/// ERProgressStyleNoProgressAnnulus
@property (nonatomic ,strong) UIColor *noProgressAnnulusTinColor UI_APPEARANCE_SELECTOR;
@property (nonatomic ,assign) CGFloat noProgressAnnulusBorderWidth UI_APPEARANCE_SELECTOR;
@property (nonatomic ,assign) CGFloat noProgressAnnulusRadian UI_APPEARANCE_SELECTOR;
@property (nonatomic ,assign) CGFloat noProgressAnnulusAngle UI_APPEARANCE_SELECTOR;

/// ERProgressStyleAnnulus
@property (nonatomic ,strong) UIColor *annulusTinColor UI_APPEARANCE_SELECTOR;
@property (nonatomic ,assign) CGFloat annulusBorderWidth UI_APPEARANCE_SELECTOR;
@property (nonatomic ,assign) CGFloat annulusRadian UI_APPEARANCE_SELECTOR;

/// ERProgressStyleAnnulusAndRound
@property (nonatomic ,strong) UIColor *roundTinColor UI_APPEARANCE_SELECTOR;
@property (nonatomic ,assign) CGFloat roundRadian UI_APPEARANCE_SELECTOR;

/// loadError
@property (nonatomic ,copy) NSString *errorText UI_APPEARANCE_SELECTOR;
@property (nonatomic ,copy) NSString *errorImage UI_APPEARANCE_SELECTOR;

@property (nonatomic ,assign) CGFloat progress UI_APPEARANCE_SELECTOR;
@property (nonatomic ,assign) ERProgressStyle progressStyle;


/// 开始动画
- (void)startAnimating;
/// 停止动画
- (void)stopAnimating;
/// 显示加载失败显示提示UI
- (void)showLoadError;

@end
