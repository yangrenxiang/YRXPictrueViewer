//
//  ERProgressView.m
//  domo
//
//  Created by yangrenxiang on 2017/4/12.
//  Copyright © 2017年 yangrenxiang. All rights reserved.
//

#import "ERProgressView.h"

@interface ERProgressView ()

/// 菊花、环形、圆
@property (nonatomic ,strong) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic ,strong) CAShapeLayer *annulusLayer;
@property (nonatomic ,strong) CAShapeLayer *roundLayer;
@property (nonatomic ,strong) UIBezierPath *annulusBezierPath;
@property (nonatomic ,strong) UIBezierPath *roundBezierPath;
/// 定时器
@property (nonatomic ,retain) dispatch_source_t timer;
@property (nonatomic ,retain) dispatch_queue_t queue;

@property (nonatomic ,strong) CADisplayLink *displayLink;

/// 环形动画起点、终点
@property (nonatomic ,assign) CGFloat startArc;
@property (nonatomic ,assign) CGFloat endArc;
/// 圆动画起点、终点
@property (nonatomic ,assign) CGFloat roundStartArc;
@property (nonatomic ,assign) CGFloat roundEndArc;

@end

@implementation ERProgressView

+ (void)initialize
{
    ERProgressView *progressView = [self appearance];
    
    /// ERProgressStyleChrysanthemum
    progressView.chrysanthemumTinColor = [UIColor whiteColor];
    progressView.chrysanthemumStyle = UIActivityIndicatorViewStyleWhite;
    
    /// ERProgressStyleNoProgressAnnulus
    progressView.noProgressAnnulusTinColor = [UIColor whiteColor];
    progressView.noProgressAnnulusBorderWidth = 1.0;
    progressView.noProgressAnnulusAngle = M_PI * 3 / 4;
    
    /// ERProgressStyleAnnulus
    progressView.annulusTinColor = [UIColor whiteColor];
    progressView.annulusBorderWidth = 1.0;
    
    ///ERProgressStyleAnnulusAndRound
    progressView.roundTinColor = [UIColor whiteColor];
    
    /// loadError
    progressView.errorText = @"图片加载错误";
    progressView.errorImage = @"errorImage_icon";
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        self.startArc = 0;
    }
    return self;
}

#pragma mark - public method
- (void)startAnimating
{
    switch (self.progressStyle) {
        case ERProgressStyleChrysanthemum:
            //菊花
            [self.activityIndicatorView startAnimating];
            break;
        case ERProgressStyleNoProgressAnnulus:
            self.displayLink.paused = NO;
            break;
        case ERProgressStyleAnnulus:
        case ERProgressStyleAnnulusAndRound:
            break;
        default:
            break;
    }
}

- (void)stopAnimating
{
    switch (self.progressStyle) {
        case ERProgressStyleChrysanthemum:
            //菊花
            [self.activityIndicatorView stopAnimating];
            break;
        case ERProgressStyleNoProgressAnnulus:
        {
            self.displayLink.paused = YES;
            [self.displayLink invalidate];
            _displayLink = nil;
        }
            break;
        case ERProgressStyleAnnulus:
        case ERProgressStyleAnnulusAndRound:
            break;
        default:
            break;
    }
}

- (void)showLoadError
{
    
}

#pragma mark - 绘图
/// 带进度的环形动画
- (void)drawAnnulusWithProgress:(CGFloat)progress
{
    self.annulusLayer.strokeEnd = progress;
}
/// 环形加圆
- (void)drawAnnulusAndRoundWithProgress:(CGFloat)progress
{
    self.roundLayer.strokeEnd = progress;
}
/// 不带进度的环形动画
- (void)drawNoProgressAnnulus
{
    self.annulusLayer.path = self.annulusBezierPath.CGPath;
    //每次调用加9度
    self.startArc += M_PI_4 / 10;
    self.endArc += M_PI_4 / 10;
}

#pragma mark - setter
- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    switch (self.progressStyle) {
        case ERProgressStyleAnnulus:
        {
            [self drawAnnulusWithProgress:_progress];
        }
            break;
        case ERProgressStyleAnnulusAndRound:
        {
            [self drawAnnulusAndRoundWithProgress:_progress];
        }
            break;
        default:
            break;
    }
}

- (void)setProgressStyle:(ERProgressStyle)progressStyle
{
    _progressStyle  = progressStyle;
    switch (progressStyle) {
        case ERProgressStyleAnnulus:
        {
            self.annulusLayer.path = [UIBezierPath bezierPathWithOvalInRect:self.bounds].CGPath;
            self.annulusLayer.strokeStart = 0;
            self.annulusLayer.strokeEnd = 1;
        }
            break;
        case ERProgressStyleAnnulusAndRound:
        {
            self.annulusLayer.path = [UIBezierPath bezierPathWithOvalInRect:self.bounds].CGPath;
            self.roundLayer.path = [UIBezierPath bezierPathWithOvalInRect:self.roundLayer.frame].CGPath;
            self.annulusLayer.strokeStart = 0;
            self.annulusLayer.strokeEnd = 1;
            self.roundLayer.strokeStart = 0;
            self.roundLayer.strokeEnd = 0;
        }
            break;
        case ERProgressStyleNoProgressAnnulus:
        {
            self.endArc = M_PI_2 * 3;
            self.annulusLayer.strokeStart = self.startArc;
            self.annulusLayer.strokeEnd = self.endArc;
        }
            break;
        default:
            break;
    }
}

#pragma mark - getter
- (UIActivityIndicatorView *)activityIndicatorView
{
    if (!_activityIndicatorView) {
        
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:self.chrysanthemumStyle];
        _activityIndicatorView.tintColor = self.chrysanthemumTinColor;
        _activityIndicatorView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
        [self addSubview:_activityIndicatorView];
    }
    return _activityIndicatorView;
}

- (CAShapeLayer *)annulusLayer
{
    if (!_annulusLayer) {
        _annulusLayer = [CAShapeLayer layer];
        _annulusLayer.strokeColor = [UIColor whiteColor].CGColor;
        _annulusLayer.lineWidth = 2.0f;
        _annulusLayer.fillColor = [UIColor clearColor].CGColor;
        _annulusLayer.frame = self.bounds;
        [self.layer addSublayer:_annulusLayer];
    }
    return _annulusLayer;
}
- (CAShapeLayer *)roundLayer
{
    if (!_roundLayer) {
        
        _roundLayer = [CAShapeLayer layer];
        _roundLayer.fillColor = [UIColor whiteColor].CGColor;
        _roundLayer.frame = CGRectMake(2, 2, self.bounds.size.width - 4, self.bounds.size.height - 4);
        [self.layer addSublayer:_roundLayer];
    }
    return _roundLayer;
}

- (UIBezierPath *)annulusBezierPath
{
    _annulusBezierPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2) radius:self.bounds.size.width/2 startAngle:self.startArc endAngle:self.endArc clockwise:YES];
//    _annulusBezierPath = [UIBezierPath bezierPathWithOvalInRect:self.bounds];
    return _annulusBezierPath;
}

- (UIBezierPath *)roundBezierPath
{
//    _roundBezierPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2) radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
    return _roundBezierPath;
}

- (CADisplayLink *)displayLink
{
    if (!_displayLink) {
        
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(drawNoProgressAnnulus)];
        _displayLink.paused = YES;
        [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
    return _displayLink;
}

- (dispatch_source_t)timer
{
    if (!_timer) {
        
        _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self.queue);
        
        dispatch_source_set_timer(_timer, DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
        dispatch_source_set_event_handler(_timer, ^{
            //重绘
            [self setNeedsLayout];
        });
    }
    return _timer;
}

- (dispatch_queue_t)queue
{
    if (!_queue) {
        
        _queue = dispatch_queue_create("com.yrx.progress.queue", NULL);
    }
    return _queue;
}

@end













