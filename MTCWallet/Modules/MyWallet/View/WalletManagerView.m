//
//  WalletManagerView.m
//  ZSEthersWallet
//
//  Created by L on 2018/1/7.
//  Copyright © 2018年 lkl. All rights reserved.
//

#import "WalletManagerView.h"
#import "ZSCustomButton.h"
#import "SwitchView.h"

#define PopupViewWith  ScreenWidth * 0.7

@interface WalletManagerView ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) SwitchView *unitView, *languageView;
@end

@implementation WalletManagerView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        [self configElements];
    }
    return self;
}


#pragma mark - Private Method
- (void)configElements {
    
    self.frame = ScreenBounds;
    
    [self addSubview:self.backgroundView];
    [self.backgroundView addSubview:self.popupView];
    
    [self.popupView addSubview:self.titleLb];
    [self.popupView addSubview:self.editButton];
    [self.popupView addSubview:self.createBtn];
    [self.popupView addSubview:self.importBtn];
    [self.popupView addSubview:self.tableView];
    [self.popupView addSubview:self.unitView];
    [self.popupView addSubview:self.languageView];

    [self.popupView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ScreenWidth - PopupViewWith);
        make.top.right.bottom.equalTo(self);
    }];
    
    [self.titleLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.popupView).offset(15);
        make.top.mas_equalTo(40);
    }];

    [self.editButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.popupView.mas_right).offset(-15);
        make.centerY.equalTo(self.titleLb);
    }];

    //等间距布局
    [@[self.createBtn, self.importBtn] mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:0 leadSpacing:0 tailSpacing:0];
    
    [@[self.createBtn, self.importBtn] mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLb.mas_bottom).offset(10);
        make.width.mas_equalTo(self.createBtn.mas_width);
        make.height.mas_equalTo(@45);
    }];

    [self.languageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self.popupView);
        make.height.mas_equalTo(@45);
    }];
    
    [self.unitView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.languageView.mas_top);
        make.left.right.equalTo(self.popupView);
        make.height.mas_equalTo(self.languageView.mas_height);
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.createBtn.mas_bottom);
        make.left.right.equalTo(self.popupView);
        make.bottom.equalTo(self.unitView.mas_top).offset(-2);
    }];
}

- (void)managerButtonClick:(UIButton *)sender {
    switch (sender.tag) {
        case 1:
        {
            //编辑
            self.tableView.editing = !self.tableView.editing;
            if (self.tableView.editing) {
                [self.editButton setTitle:NSLocalizedString(@"完成",nil)];
            }
            else {
                [self.editButton setTitle:NSLocalizedString(@"编辑",nil)];
            }
            break;
        }
            
        case 2:
        {
            //新建钱包
            break;
        }
            
        case 3:
        {
            //导入钱包
            break;
        }
            
        default:
            break;
    }
    
}

#pragma mark - 弹出视图方法
- (void)showWithAnimation:(BOOL)animation {
    //1. 获取当前应用的主窗口
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    [keyWindow addSubview:self];
    if (animation) {
        // 动画前初始位置
        CGRect rect = self.popupView.frame;
        rect.origin.x = ScreenWidth - PopupViewWith;
        self.popupView.frame = rect;

        // 浮现动画
        [UIView animateWithDuration:0.3 animations:^{
            CGRect rect = self.popupView.frame;
            rect.origin.x -= ScreenWidth - PopupViewWith;
            self.popupView.frame = rect;
        }];
    }
}

//#pragma mark - 关闭视图方法
- (void)dismissWithAnimation:(BOOL)animation {
    // 关闭动画
    [UIView animateWithDuration:0.2 animations:^{
        CGRect rect = self.popupView.frame;
        rect.origin.x += ScreenWidth - PopupViewWith;
        self.popupView.frame = rect;

        self.backgroundView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.backgroundView removeFromSuperview];
        [self removeFromSuperview];
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;{
    return 5;
}

#pragma mark - TableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[UITableViewCell at_identifier]];
    cell.textLabel.text = @"dfad";
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
//    // 首先修改model
//    [self.books removeObjectAtIndex:indexPath.row];
//    // 之后更新view
//    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}


#pragma mark - Init
- (UIView *)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [[UIView alloc] initWithFrame:ScreenBounds];
        _backgroundView.backgroundColor = [UIColor clearColor];
        _backgroundView.userInteractionEnabled = YES;

        __weak typeof(self) weakSelf = self;
        [_backgroundView addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
            [weakSelf dismissWithAnimation:YES];
        }];
    }
    return _backgroundView;
}

- (UIView *)popupView {
    if (!_popupView) {
        _popupView = [[UIView alloc] initWithFrame:CGRectMake(ScreenWidth - PopupViewWith, 0, PopupViewWith, ScreenHeight)];
        _popupView.backgroundColor = [UIColor whiteColor];
    }
    return _popupView;
}

- (UILabel *)titleLb {
    if (!_titleLb) {
        _titleLb = [UILabel new];
        _titleLb.text = NSLocalizedString(@"钱包切换",nil);
        _titleLb.font = [UIFont systemFontOfSize:18.0f];
        _titleLb.textColor = [UIColor blackColor];
    }
    return _titleLb;
}

- (UIButton *)editButton {
    if (!_editButton) {
        _editButton = [UIButton buttonWithtitle:NSLocalizedString(@"编辑",nil) titleColor:[UIColor commonTextColor] fontSize:15.0f BackgroundColor:[UIColor clearColor] targe:self action:@selector(managerButtonClick:)];
        [_editButton setTag:0x01];
    }
    return _editButton;
}

- (ZSCustomButton *)createBtn {
    if (!_createBtn) {
        _createBtn = [ZSCustomButton buttonWithType:ZSCustomButtonImageLeft title:NSLocalizedString(@"新建钱包",nil) titleColor:[UIColor commonTextColor] fontSize:15.0f imageName:@"set" backgroundColor:[UIColor clearColor] targe:self action:@selector(managerButtonClick:)];
        [_createBtn setTag:0x02];
        [_createBtn setShowLineType:ShowLineType_Top];
        [_createBtn setShowLineType:ShowLineType_Right];
        [_createBtn setShowLineType:ShowLineType_Bottom];
    }
    return _createBtn;
}

- (ZSCustomButton *)importBtn {
    if (!_importBtn) {
        _importBtn = [ZSCustomButton buttonWithType:ZSCustomButtonImageLeft title:NSLocalizedString(@"导入钱包",nil) titleColor:[UIColor commonTextColor] fontSize:15.0f imageName:@"set" backgroundColor:[UIColor clearColor] targe:self action:@selector(managerButtonClick:)];
        [_importBtn setTag:0x03];
        [_importBtn setShowLineType:ShowLineType_Top];
        [_importBtn setShowLineType:ShowLineType_Bottom];
    }
    return _importBtn;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [_tableView setBackgroundColor:[UIColor commonLightGrayTextColor]];
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:[UITableViewCell at_identifier]];
    }
    return _tableView;
}

- (SwitchView *)unitView {
    if (!_unitView) {
        _unitView = [SwitchView new];
        [_unitView setSwitchViewTitle:NSLocalizedString(@"货币单位",nil) detail:NSLocalizedString(@"美元",nil)];
    }
    return _unitView;
}

- (SwitchView *)languageView {
    if (!_languageView) {
        _languageView = [SwitchView new];
        [_languageView setSwitchViewTitle:NSLocalizedString(@"语言切换",nil) detail:NSLocalizedString(@"简体中文",nil)];
    }
    return _languageView;
}
@end
