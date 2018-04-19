//
//  ERPictureViewController.m
//  Enrich
//
//  Created by 杨仁祥 on 2018/3/31.
//  Copyright © 2018年 PingAn. All rights reserved.
//

#import "ERPictureViewController.h"
#import "ERQRFinishedHandlerViewController.h"

#import "ERIMSDKManager.h"
#import "ERIMApiMessageManager.h"
#import "ERViewControllerTool.h"
#import "ERQRCodeManager.h"
#import "ERQRCodeInfoModel.h"
#import "ERMoreFuncTool.h"

extern NSString * const ERShareToTJAddressBookSuccessNotification; // 分享到団金通讯录成功的通知
extern NSString * const ERMsgRetransmitSuccessNotification;//消息转发成功通知
@interface ERPictureViewController () <UIScrollViewDelegate ,ERRahmenViewEventHandlerDelegate>

//滚动视图
@property (nonatomic ,strong) UIScrollView *scrollView;
//用来做动画的imageview
@property (nonatomic ,strong) UIImageView *animateImageView;
//
@property (nonatomic ,assign) CGRect frame;
//图片模型数组
@property (nonatomic ,strong) NSArray <ERPicture *>*images;
//当前显示的index
@property (nonatomic ,assign) NSInteger curIndex;
//当前选中
@property (nonatomic ,weak) UIImageView *selectImageView;
//水印文字
@property (nonatomic ,copy) NSString *waterMarkText;

@end

@implementation ERPictureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialize];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
}

- (void)initialize
{
    [self mc_setNavStyle];
    self.view.backgroundColor = [UIColor blackColor];
    self.view.alpha = 0;
    [self.view addSubview:self.scrollView];
    
    [kNotificationCenter addObserver:self selector:@selector(shareProductSuccess:) name:ERShareToTJAddressBookSuccessNotification object:nil];
    [kNotificationCenter addObserver:self selector:@selector(shareProductSuccess:) name:ERMsgRetransmitSuccessNotification object:nil];
    
    [self setup];
}

- (void)setup
{
    //    if (!selectImageView) return;
    if (self.curIndex > self.images.count - 1) {
        NSLog(@">>>>下标越界<<<<");
        return;
    }
    
    [self.scrollView setContentOffset:CGPointMake(self.curIndex * self.scrollView.bounds.size.width, 0)];
    [self setupPictures];
    [self startAnimating];
}

- (void)ShowSelectImageViewInWindow:(UIImageView *)selectImageView
                              index:(NSInteger)index
                             images:(NSArray<ERPicture *> *)images
                      waterMarkText:(NSString *)waterMarkText
{
    _selectImageView = selectImageView;
    _curIndex = index;
    _images = images;
    _waterMarkText = waterMarkText;
}

#pragma mark - private Method
- (void)setupPictures
{
    __weak typeof(self)weakSelf = self;
    [self.images enumerateObjectsUsingBlock:^(ERPicture * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![obj isKindOfClass:[ERPicture class]]) *stop = YES;
        
        ERRahmenView *rahmenView = [[ERRahmenView alloc] initWithFrame:CGRectMake(idx * self.scrollView.bounds.size.width, 0, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height)];
        rahmenView.progressStyle = self.progressStyle;
        rahmenView.model = obj;
        rahmenView.waterMarkText = weakSelf.waterMarkText;
        rahmenView.eventDelegate = self;
        [rahmenView setCompleteBlock:^(UIImage *image ,NSString *path){
            if (weakSelf.completeBlock) {
                weakSelf.completeBlock(idx ,image ,path);
            }
        }];
        [self.scrollView addSubview:rahmenView];
    }];
    
    self.scrollView.contentSize = CGSizeMake(self.images.count * self.scrollView.bounds.size.width, 0);
}

- (void)startAnimating
{
    self.scrollView.hidden = NO;
    self.animateImageView.hidden = YES;
    [UIView animateWithDuration:0.2 animations:^{
        self.view.alpha = 1;
    } completion:nil];
}

- (void)disappearInWindow
{
    [self.scrollView removeFromSuperview];
    self.scrollView.delegate = nil;
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)tapHandle:(UITapGestureRecognizer *)tap
{
    [self disappearInWindow];
}

#pragma mark - 二维码
//检查扫描结果
- (void)checkOutQrResult:(NSString *)qr_resultString
{
    __weak typeof(self)weakSelf = self;
    [[ERQRCodeManager sharedManager] checkQrcodeResult:qr_resultString callBack:^(id objModel, BOOL isSuc, NSError *error) {
        if (objModel && [objModel isKindOfClass:[ERQRCodeInfoModel class]]) {
            ERQRCodeInfoModel *model = objModel;
            switch (model.infoType) {
                case ERQrCodeInfoTypeGroup:
                    [weakSelf handlerGroupQrcodeInfoWithGroupId:model.detectorString];
                    break;
                case ERQrCodeInfoTypeContact:
                    [weakSelf handlerPersonalQrcodeInfoWithImUserId:model.detectorString];
                    break;
                case ERQrCodeInfoTypeUrl:
                    [weakSelf qrcodeResultHandlerCompleteEntryIntoHandlerVC:model.detectorString type:3];
                    break;
                case ERQrCodeInfoTypeNone:
                    [weakSelf qrcodeResultHandlerCompleteEntryIntoHandlerVC:model.detectorString type:2];
                    break;
            }
        }
    }];
}

//处理群二维码
- (void)handlerGroupQrcodeInfoWithGroupId:(NSString *)imGroupId
{
    //判断是否是群成员
    if ([[ERIMApiMessageManager sharedManager] isMemberForGroupId:imGroupId]) {
        PAIMApiGroupInfoModel *groupModel = [PAIMApiMessage fetchGroupInfoByGroupID:[ERIMTransformIdTool generateLocalGroupIdFromNetGroupId:imGroupId]];
        //是群成员，直接进入聊天
        NSString *conversationChatter = [ERIMTransformIdTool generateLocalGroupIdFromNetGroupId:imGroupId];
        NSString *chatTitle = groupModel.nickName;
        if (!chatTitle) {
            kShowMessageToView(@"二维码识别失败，请重试", self.view);
            return;
        }
        
        [self qrcodeScanCompleteEntryIntoMessage:@{
                                                   @"jid":conversationChatter
                                                   ,@"title":chatTitle,
                                                   @"chat_Type":@(GROUP_CHAT),
                                                   }];
    }else {
        //不是群成员，则进入中间处理页面
        [self qrcodeResultHandlerCompleteEntryIntoHandlerVC:imGroupId type:1];
    }
}
//处理个人二维码
- (void)handlerPersonalQrcodeInfoWithImUserId:(NSString *)imUserId
{
    if (!imUserId) {
        kShowMessageToView(@"二维码扫描失败，请重试", self.view);
        return;
    }
    __block NSMutableDictionary *conversationDic = [[NSMutableDictionary alloc] init];
    [conversationDic setObject:[ERIMTransformIdTool generateLocalIMUserJidFromOriginJid:imUserId byChatType:CHAT]  forKey:@"jid"];
    [conversationDic setObject:@(CHAT) forKey:@"chat_Type"];
    //判断是否是好友
    if ([[ERIMApiMessageManager sharedManager] isFriendForImUserId:imUserId]) {
        PAIMApiFriendModel *friendModel = [PAIMApiFriends fetchFriendInfoByFriendID:[ERIMTransformIdTool generateLocalIMUserJidFromOriginJid:imUserId byChatType:CHAT]];
        NSString *realName = friendModel.nickName.length?friendModel.nickName:friendModel.name;
        [conversationDic setObject:realName?:@"" forKey:@"title"];
        //是好友,则直接进入聊天
        [self qrcodeScanCompleteEntryIntoMessage:conversationDic];
    }else {
        //不是好友，则先添加好友再进入聊天
        kShowLoadingMessageToView(@"", self.view);
        __weak typeof(self)weakSelf = self;
        [[ERIMSDKManager sharedManager] addFriendWithUserId:nil imUserId:imUserId finishBlock:^(BOOL isSuc, NSError *error) {
            kHiddenHUDFromView(weakSelf.view);
            if (isSuc) {
                PAIMApiFriendModel *friendModel = [PAIMApiFriends fetchFriendInfoByFriendID:[ERIMTransformIdTool generateLocalIMUserJidFromOriginJid:imUserId byChatType:CHAT]];
                NSString *realName = friendModel.nickName.length?friendModel.nickName:friendModel.name;
                [conversationDic setObject:realName?:@"" forKey:@"title"];
                //好友添加成功，进入聊天
                [weakSelf qrcodeScanCompleteEntryIntoMessage:conversationDic];
            }else {
                kShowMessageToView(@"二维码扫描失败,请重试", weakSelf.view);
            }
        }];
    }
}

- (void)qrcodeResultHandlerCompleteEntryIntoHandlerVC:(NSString *)resultString type:(NSInteger)type
{
    ERQRFinishedHandlerViewController *finishedVC = [[ERQRFinishedHandlerViewController alloc] init];
    finishedVC.fromVC = self;
    switch (type) {
        case 1:
            finishedVC.qr_resultData = resultString;
            break;
        case 2:
            finishedVC.qr_barCodeString = resultString;
            break;
        case 3:
            finishedVC.baseUrl = resultString;
            break;
    }
    [self.navigationController pushViewController:finishedVC animated:YES];
    
    __weak typeof(self)weakSelf = self;
    [finishedVC setPrepareEnterChatRoomCallback:^(NSDictionary *dic) {
        [weakSelf qrcodeScanCompleteEntryIntoMessage:dic];
    }];
}

//二维码扫描完成进入聊天页面
- (void)qrcodeScanCompleteEntryIntoMessage:(NSDictionary *)conversationDic
{
    [ERMoreFuncTool sendMessageToJid:conversationDic[@"jid"] chatTitle:conversationDic[@"title"] userId:0 chatType:[conversationDic[@"chat_Type"] integerValue] showInViewController:self isFromMsgListToChatRoom:NO];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;
{
    NSLog(@"xxxxxxxxxx");
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(imgFrameRevert)];
    
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    NSLog(@"xxxxxxxxxx%.f",scrollView.contentOffset.x);
    NSLog(@"======xxxxxxxxxx");
}

#pragma mark - ERRahmenViewEventHandlerDelegate
- (void)handlerShareImageWithModel:(ERPicture *)model
{
    ERRetransmitModel *reModel = [[ERRetransmitModel alloc] init];
    reModel.msg_image = model.image;
    reModel.msg_type = MESSAGE_IMAGE;
    [[ERIMApiMessageManager sharedManager] shareToTjeWithRetransmitModel:reModel fromViewController:nil];
}
- (void)handlerDetectorQrcodeWithModel:(ERPicture *)model
{
    NSString *resultString = model.detectorString;
    [self checkOutQrResult:resultString];
}

#pragma mark - notify
//分享成功
- (void)shareProductSuccess:(NSNotification *)notify
{
    if (!notify.object || ![notify.object isKindOfClass:[ERRetransmitModel class]]) {
        return;
    }
    ERRetransmitModel *msgModel = notify.object;
    if (![msgModel.fromObj isEqual:self]) {
        return;
    }
    kShowSuccessTextToView(@"已发送", self.view);
}

#pragma mark - getter/setter
- (UIImageView *)animateImageView
{
    if (!_animateImageView) {
        _animateImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    }
    return _animateImageView;
}

- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        
        _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.pagingEnabled = YES;
        _scrollView.bounces = YES;
        _scrollView.delegate = self;
        _scrollView.hidden = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandle:)];
        _scrollView.userInteractionEnabled = YES;
        [_scrollView addGestureRecognizer:tap];
    }
    return _scrollView;
}

- (BOOL)fd_prefersNavigationBarHidden
{
    return YES;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)dealloc
{
    [kNotificationCenter removeObserver:self];
}

@end
