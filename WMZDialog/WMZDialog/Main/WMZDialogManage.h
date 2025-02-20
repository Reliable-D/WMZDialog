//
//  WMZDialogManage.h
//  WMZDialog
//
//  Created by wmz on 2021/4/9.
//  Copyright © 2021 wmz. All rights reserved.
//
#import <UIKit/UIKit.h>
@class WMZDialogParam,WMZDialogParentParam;

typedef void (^DialogCustomParam)(WMZDialogParam* _Nullable param);

NS_ASSUME_NONNULL_BEGIN

@interface WMZDialogManage : NSObject
/// 当前显示的弹窗组
@property (nonatomic, strong) NSMutableDictionary <NSNumber*,UIView*>*dialogInfo;
/// 暗黑模式配色
@property (nonatomic, strong) NSMutableDictionary <NSString* , UIColor*> *darkColorInfo;
/// 全局
@property (nonatomic, strong, readonly) WMZDialogParentParam *globalParam;
/// 设置全局配置
+ (void)settingGlobalConfig:(DialogCustomParam)block;

- (void)setUpManageDefaultParam:(WMZDialogParentParam*)param;

+ (void)setDefaultColorPropertiess:(WMZDialogParentParam*)param;
/// 当前正在显示的弹窗
- (id)currentDialog:(UIView*)normalView;
/// 添加弹窗
/// @param dialog 弹窗视图
/// @param cover 是否覆盖内存缓存
/// @param superView 父类
- (void)addDialog:(id)dialog
            cover:(BOOL)cover
        superView:(UIView*)superView;
/// 删除弹窗
/// @param dialog 弹窗视图
- (void)deleteDialog:(id)dialog;

+ (instancetype)shareInstance;

@end

NS_ASSUME_NONNULL_END
