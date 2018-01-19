/**
 *  MIT License
 *
 *  Copyright (c) 2017 Richard Moore <me@ricmoo.com>
 *
 *  Permission is hereby granted, free of charge, to any person obtaining
 *  a copy of this software and associated documentation files (the
 *  "Software"), to deal in the Software without restriction, including
 *  without limitation the rights to use, copy, modify, merge, publish,
 *  distribute, sublicense, and/or sell copies of the Software, and to
 *  permit persons to whom the Software is furnished to do so, subject to
 *  the following conditions:
 *
 *  The above copyright notice and this permission notice shall be included
 *  in all copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
 *  OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 *  THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 *  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 *  DEALINGS IN THE SOFTWARE.
 */

#import "AccountsViewController.h"

#import "AccountTableViewCell.h"
#import "UIColor+hex.h"
#import "Utilities.h"
#import "UIImage+IconFont.h"
#import "BlockButton.h"
#import <Masonry/Masonry.h>
#import "SwitchView.h"
#import "TipVC.h"
#import "PopupPromptView.h"
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
#import "CachedDataStore.h"
#import "ExportWalletVC.h"
#import "NSBundleEX.h"
#import "AppDelegate.h"

@interface AccountsViewController () <AccountTableViewCellDelegate, UITableViewDataSource, UITableViewDelegate,DZNEmptyDataSetSource,DZNEmptyDataSetDelegate> {
    UIView *_backGroundView;
    UIButton *_addButton, *_doneButton, *_doneReorderButton, *_doneRenameButton, *_reorderButton;
    SwitchView *_unitView, *_languageView;
    CachedDataStore *_dataStore;
}

@property (nonatomic,strong) UITableView *tableView;

@end

@implementation AccountsViewController

+ (instancetype) showInController:(UIViewController *)vc wallet:(Wallet *)wallet {
    UIViewController *rootVC = vc.view.window.rootViewController;
    AccountsViewController *accountVC = [[AccountsViewController alloc] initWithWallet:wallet];
    accountVC.delegate = vc;
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:accountVC];
    navVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [rootVC presentViewController:navVC animated:NO completion:^{
       [accountVC animateContentView];
    }];
    return accountVC;
}


- (instancetype)initWithWallet:(Wallet *)wallet {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _wallet = wallet;
        _dataStore = [CachedDataStore sharedCachedDataStoreWithKey:CACHEKEY_APP_DATA];
        /*_addButton = [self addButton:NSLocalizedString(@"编辑", nil) image:nil action:^(UIButton *){
            [_tableView setEditing:NO animated:YES];
            [_wallet addAccountCallback:^(Address *address) {
                NSLog(@"Created: %@", address);
            }];
        }];
        

        _doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                    target:self
                                                                    action:@selector(tapDone)];

        _doneReorderButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                    style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(tapDoneReorder)];
        
        _doneRenameButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(tapDoneRename)];
        
        _reorderButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                            target:self
                                                                            action:@selector(tapReorder)];*/
        
//        self.navigationItem.hidesBackButton = YES;
//        self.navigationItem.leftBarButtonItem = _reorderButton;
        
//        self.navigationItem.rightBarButtonItem = _doneButton;
        
//        self.navigationItem.titleView = [Utilities navigationBarTitleWithString:@"Accounts"];
        

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(notificationAdded:)
                                                     name:WalletAccountAddedNotification
                                                   object:_wallet];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(notificationRemoved:)
                                                     name:WalletAccountRemovedNotification
                                                   object:_wallet];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(tapDone)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:[UIApplication sharedApplication]];

    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if(self.navigationController.topViewController != self)self.navigationController.navigationBar.hidden = NO;
}

- (void)animateContentView {
    [_backGroundView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(0, 100, 0, 0));
    }];
    [UIView animateWithDuration:.3 animations:^{
        [self.view setNeedsLayout];
    }];
}
- (void)hideContentView {
    CGRect frame = _backGroundView.frame;
    frame.origin.x = self.view.size.width;
    [UIView animateWithDuration:0.3 animations:^{
        _backGroundView.frame = frame;
    } completion:^(BOOL finished) {
        [self.navigationController dismissViewControllerAnimated:NO completion:nil];
    }];
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint point = [[touches anyObject] locationInView:self.view];
    if (point.x < 100) {
        [self hideContentView];
    }
}

// @TODO: Figure out why animating these buttons causes them not to show up.

- (void)tapReorder:(UIButton *)sender {
//    [self resignNicknameTextFields];
    
    sender.selected = !sender.isSelected;
//    [self.navigationItem setLeftBarButtonItem:_doneReorderButton animated:NO];
//    [self.navigationItem setRightBarButtonItem:_addButton animated:NO];
    
    // If the "Manage" tab is visible, hide it
    if (_tableView.editing) {
        [_tableView setEditing:NO animated:NO];
    }
    
    [_tableView setEditing:sender.isSelected animated:YES];
}

- (void)tapDoneReorder {
//    [self.navigationItem setLeftBarButtonItem:_reorderButton animated:NO];
//    [self.navigationItem setRightBarButtonItem:_doneButton animated:NO];
    [_tableView setEditing:NO animated:YES];
}

- (void)tapDone {
//    [self resignNicknameTextFields];
    
    if ([_delegate respondsToSelector:@selector(accountsViewControllerDidCancel:)]) {
        [_delegate accountsViewControllerDidCancel:self];
    }
}

- (void)tapRename {
//    [self.navigationItem setLeftBarButtonItem:_doneRenameButton animated:NO];
    [self.navigationItem setRightBarButtonItem:nil animated:NO];
}

- (void)tapDoneRename {
//    [self.navigationItem setLeftBarButtonItem:_reorderButton animated:NO];
//    [self.navigationItem setRightBarButtonItem:_doneButton animated:NO];
//    [self resignNicknameTextFields];
}

- (void)tapAdd {
//    [self.navigationItem setLeftBarButtonItem:_reorderButton animated:NO];
//    [self.navigationItem setRightBarButtonItem:_doneButton animated:NO];
    [_tableView setEditing:NO animated:YES];

    UIViewController *vc = [_wallet addAccountCallback:^(Address *address) {
        NSLog(@"Created: %@", address);
    }];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)tapImport {
    UIViewController *vc = [_wallet importAccountcallback:^(Address *address) {
        
    }];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)notificationAdded: (NSNotification*)note {
    [_tableView reloadData];
}

- (void)notificationRemoved: (NSNotification*)note {
    [_tableView reloadData];
    
    // No accounts left, we no longer have any purpose
    if (_wallet.activeAccountIndex == AccountNotFound) { [self tapDone]; }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - View Life-Cycle

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    
    _backGroundView = [[UIView alloc] init];
    [_backGroundView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:_backGroundView];
    [_backGroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(0, 300, 0, -200));
    }];
    
    UIView *titleView = [[UIView alloc] init];
    [_backGroundView addSubview:titleView];
    [titleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(_backGroundView);
        make.height.equalTo(@100);
    }];
    
    UILabel *lbl = [[UILabel alloc] init];
    lbl.textColor = [UIColor darkGrayColor];
    lbl.text = NSLocalizedString(@"钱包切换", nil);
    [titleView addSubview:lbl];
    [lbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_backGroundView).offset(30);
        make.top.equalTo(_backGroundView).offset(20);
    }];
    
    __weak typeof(self) weakSelf = self;
    BlockButton *editBtn = [BlockButton buttonWithType:UIButtonTypeCustom];
    [editBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [editBtn setTitle:NSLocalizedString(@"编辑", nil) forState:UIControlStateNormal];
    [editBtn setTitle:NSLocalizedString(@"完成", nil) forState:UIControlStateSelected];
    [editBtn addTarget:self action:@selector(tapReorder:)];
    [editBtn setTitleColor:[UIColor commonDarkGrayTextColor] forState:UIControlStateNormal];
    [titleView addSubview:editBtn];
    [editBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_backGroundView).offset(-30);
        make.centerY.equalTo(lbl);
    }];
    
    
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = [UIColor lightGrayColor];
    [titleView addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.left.equalTo(_backGroundView);
        make.height.equalTo(@1);
        make.top.equalTo(editBtn.mas_bottom);
    }];
    
    BlockButton *button = [BlockButton buttonWithType:UIButtonTypeCustom];
    button.titleLabel.font = [UIFont fontWithName:@"iconfont" size:15];
    [button setTitle:[NSString stringWithFormat:@"%@ %@", ICON_FONT_WALLET,NSLocalizedString(@"新建钱包", nil)] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor commonDarkGrayTextColor] forState:UIControlStateNormal];
    [button handleControlEvent:UIControlEventTouchUpInside withBlock:^{
        [weakSelf tapAdd];
    }];
    [titleView addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_backGroundView);
        make.top.equalTo(line.mas_bottom);
        make.height.equalTo(@50);
        make.width.equalTo(_backGroundView).multipliedBy(0.5);
    }];
    
    BlockButton *importbutton = [BlockButton buttonWithType:UIButtonTypeCustom];
    importbutton.titleLabel.font = [UIFont fontWithName:@"iconfont" size:15];
    [importbutton setTitleColor:[UIColor commonDarkGrayTextColor] forState:UIControlStateNormal];
    [importbutton setTitle:[NSString stringWithFormat:@"%@ %@", ICON_FONT_IMPORT,NSLocalizedString(@"导入钱包", nil)] forState:UIControlStateNormal];
    [importbutton handleControlEvent:UIControlEventTouchUpInside withBlock:^{
        [weakSelf tapImport];
    }];
    [titleView addSubview:importbutton];
    [importbutton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_backGroundView);
        make.top.equalTo(line.mas_bottom);
        make.height.equalTo(@50);
        make.width.equalTo(button);
    }];
    
    line = [[UIView alloc] init];
    line.backgroundColor = [UIColor lightGrayColor];
    [titleView addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_backGroundView);
        make.centerY.equalTo(button);
        make.width.equalTo(@1);
        make.height.equalTo(@20);
    }];
    
    line = [[UIView alloc] init];
    line.backgroundColor = [UIColor lightGrayColor];
    [titleView addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.left.equalTo(_backGroundView);
        make.height.equalTo(@1);
        make.bottom.equalTo(importbutton.mas_bottom);
    }];
    
    _unitView = [SwitchView new];
    [_backGroundView addSubview:_unitView];
    
    NSArray *unitArray = @[NSLocalizedString(@"美元",nil),NSLocalizedString(@"人民币",nil)];
    CachedDataStore *dataStore = [CachedDataStore sharedCachedDataStoreWithKey:CACHEKEY_APP_DATA];
    BOOL isDollar = [[dataStore stringForKey:CACHEKEY_APP_DATA_UNIT] isEqualToString:UNIT_DOLLAR];
    [_unitView setSwitchViewTitle:NSLocalizedString(@"货币单位", nil) detail:isDollar?NSLocalizedString(@"美元", nil):NSLocalizedString(@"人民币", nil)];
    
    _languageView = [SwitchView new];
    [_backGroundView addSubview:_languageView];
    NSString *str = [[NSUserDefaults standardUserDefaults] valueForKey:@"myLanguage"];
    if (str.length) {
        [_languageView setSwitchViewTitle:NSLocalizedString(@"语言切换", nil) detail:[str isEqualToString:@"zh-Hans"]?@"简体中文":@"English"];
    }else {
        [_languageView setSwitchViewTitle:NSLocalizedString(@"语言切换", nil) detail:NSLocalizedString(@"默认", nil)];
    }
    
    [_languageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(_backGroundView);
        make.height.mas_equalTo(@45);
    }];
    
    [_unitView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_languageView.mas_top);
        make.left.right.equalTo(_backGroundView);
        make.height.mas_equalTo(_languageView.mas_height);
    }];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,0,0,0) style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.emptyDataSetSource = self;
    _tableView.emptyDataSetDelegate = self;
    _tableView.rowHeight = AccountTableViewCellHeight;
//    _tableView.scrollIndicatorInsets = _tableView.contentInset;
    _tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    _tableView.backgroundColor = [UIColor commonLightGrayTextColor];
    [_backGroundView addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(titleView);
        make.top.equalTo(titleView.mas_bottom);
        make.bottom.equalTo(_unitView.mas_top).offset(-2);
    }];
    
    __weak typeof(SwitchView *) unitView = _unitView;
    [_unitView addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
        [[TipVC showTipType:ShowTipTypeBackup inController:weakSelf] setTitle:NSLocalizedString(@"请选择货币单位", nil) buttons:unitArray onCompletion:^(id value,NSInteger index) {
            if(index) {
                [unitView.detailLb setText:unitArray[index-1]];
                CachedDataStore *dataStore = [CachedDataStore sharedCachedDataStoreWithKey:CACHEKEY_APP_DATA];
                [dataStore setString:index == 1?UNIT_DOLLAR:UNIT_RMB forKey:CACHEKEY_APP_DATA_UNIT];
                void(^runOnMainThead)(void) = ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:WalletAccountBalanceDidChangeNotification object:weakSelf.wallet userInfo:nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:WalletAccountTokenBalanceDidChangeNotification object:weakSelf.wallet userInfo:nil];
                    [weakSelf.tableView reloadData];
                };
                if ( [NSThread isMainThread] )runOnMainThead();
                else dispatch_async( dispatch_get_main_queue(), runOnMainThead);
            }
        }];
    }];
    
    NSArray *languageArray = @[@"简体中文",@"English"];
    __weak typeof(SwitchView *) languageView = _languageView;
    [_languageView addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
        [[TipVC showTipType:ShowTipTypeBackup inController:weakSelf] setTitle:NSLocalizedString(@"请选择系统语言", nil) buttons:languageArray onCompletion:^(id value,NSInteger index) {
            if(index) {
                [languageView.detailLb setText:languageArray[index - 1]];
                // 设置语言
                NSString *language = index == 1?@"zh-Hans":@"en";
                CachedDataStore *dataStore = [CachedDataStore sharedCachedDataStoreWithKey:CACHEKEY_APP_DATA];
                if (![[dataStore stringForKey:CACHEKEY_APP_DATA_LANGUAGE] isEqualToString:language]) {
                    [NSBundle setLanguage:language];
                    [dataStore setString:language forKey:CACHEKEY_APP_DATA_LANGUAGE];
                    ((AppDelegate *)[UIApplication sharedApplication].delegate).runMainController();
                }
            }
        }];
    }];
    
    // @TODO: Check this... Should it return a uint? If not found, does it return -1 or NSNOTFOUND?
    //NSInteger selectedIndex = [_wallet indexForAddress:_wallet.activeAccount];
    //NSLog(@"Wallet: %@ %d %@ ", _wallet, (int)_wallet.numberOfAccounts, [_wallet addressAtIndex:selectedIndex]);
    /*
    if (selectedIndex >= 0) {
        
        // Scroll the current account on the screen
        [_tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:selectedIndex inSection:0]
                                animated:NO
                          scrollPosition:UITableViewScrollPositionTop];
    }
     */

//    UINavigationBar *navigationBar = [Utilities addNavigationBarToView:self.view];
//    navigationBar.items = @[self.navigationItem];
}


#pragma mark - AccountTableViewCellDelegate

- (void)accountTableViewCell:(AccountTableViewCell *)accountTableViewCell changedNickname:(NSString *)nickname {
    NSInteger index = [_tableView indexPathForCell:accountTableViewCell].row;
    [_wallet setNickname:nickname forIndex:index];
    
    if ([_delegate respondsToSelector:@selector(accountsViewController:changedNickname:)]) {
        [_delegate accountsViewController:self changedNickname:index];
    }
}

- (void)accountTableViewCell:(AccountTableViewCell *)accountTableViewCell changedEditingNickname:(BOOL)isEditing {
    if (isEditing) {
        [self tapRename];
    } else {
        [self tapDoneRename];
    }
}

#pragma mark - UITableViewDataSource and UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _wallet.numberOfAccounts;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AccountTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:AccountTableViewCellResuseIdentifier];
    if (!cell) {
        cell = [AccountTableViewCell accountTableCellWithWallet:_wallet];
        cell.delegate = self;
    }
    [cell setupWithAccountIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self resignNicknameTextFields];
    
    if (_wallet.activeAccountIndex == indexPath.row) {
        return;
    }
    if ([_delegate respondsToSelector:@selector(accountsViewController:didSelectAccountIndex:)]) {
        [_delegate accountsViewController:self didSelectAccountIndex:indexPath.row];
    }
    
    [self hideContentView];
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

//- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
//    return proposedDestinationIndexPath;
//}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    [_wallet moveAccountAtIndex:sourceIndexPath.row toIndex:destinationIndexPath.row];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

//- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
//    // If editing, don't show the little red delete circle
//    if (tableView.editing) {
//        return UITableViewCellEditingStyleNone;
//    }
//
//    // Not really delete, but we need to pass this so our "Manage" tab shows up
//    return UITableViewCellEditingStyleDelete;
//}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{

}


- (NSArray<UITableViewRowAction*>*)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {

    void (^handleAction)(UITableViewRowAction*, NSIndexPath*) = ^(UITableViewRowAction *rowAction, NSIndexPath *indexPath) {
        NSLog(@"Action: %@ %@", rowAction, indexPath);
//        [_wallet manageAccountAtIndex:indexPath.row callback:nil];
//        [_wallet manageAccount:((AccountTableViewCell*)[tableView; cellForRowAtIndexPath:indexPath]).address
//                      callback:nil];
         [[TipVC showTipType:ShowTipTypePassword inController:self] setOnCompletion:^(NSString *password,NSInteger idx) {
             if(password) {
                 __weak typeof(self) weakSelf = self;
                 { showMessage(showTypeStatus, NSLocalizedString(@"密码验证中...", nil));}
                 [_wallet verifyTransactionPassword:password index:indexPath.row callBack:^(BOOL unlock) {
                     if (unlock) {
                         showMessage(showTypeNone, nil);
                         [weakSelf showPromptView:indexPath.row password:password];
                     } else {
                         showMessage(showTypeError, NSLocalizedString(@"交易密码错误", nil));
                     }
                 }];
             }
        }];
        


//        [tableView setEditing:NO animated:YES];
    };

    UITableViewRowAction *rowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:NSLocalizedString(@"删除", nil) handler:handleAction];
//    rowAction.backgroundColor = [UIColor colorWithHex:ColorHexToolbarIcon];
    return @[rowAction];
}


#pragma mark - UIScrollViewDelegate

- (void)resignNicknameTextFields {
    [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
    for (AccountTableViewCell *cell in _tableView.visibleCells) {
        [cell setEditingNickname:NO];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self resignNicknameTextFields];
}

//提示操作
- (void)showPromptView:(NSInteger)walletIndex password:(NSString *) password {
    
    PopupPromptView *promptView = [[PopupPromptView alloc] init];
    [promptView showWithAnimation:YES];
    
    __weak typeof(self) weakSelf = self;
    [promptView setBlock:^(NSInteger index) {
        if (index == 1) {
            //备份/导出钱包
            [_wallet exportAccountAtIndex:walletIndex inController:weakSelf password:password callback:^(ExportWalletVC *vc) {
                [weakSelf.navigationController pushViewController:vc animated:YES];
            }];
        }
        else if (index == 2) {
            //确认删除
            [weakSelf.wallet removeAccountAtIndex:walletIndex];
            if ([_delegate respondsToSelector:@selector(accountsViewController:removeAccountIndex:)]) {
                [_delegate accountsViewController:self removeAccountIndex:walletIndex];
            }
        }
    }];
}

#pragma mark - DZNEmptyDataSetDelegate
- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    return [UIImage imageNamed:@"btnAdd"];
}

- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView {
    if (_wallet.numberOfAccounts == 0) {
        return YES;
    }
    return NO;
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    return [[NSAttributedString alloc] initWithString:NSLocalizedString(@"您还没有钱包哦！", nil) attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14],NSForegroundColorAttributeName:[UIColor colorWithHexString:@"666666"]}];
}

- (NSAttributedString *)buttonTitleForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state {
    return [[NSAttributedString alloc] initWithString:NSLocalizedString(@"新建钱包", nil) attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16],NSForegroundColorAttributeName:[UIColor commonBackgroundColor]}];
}

- (void)emptyDataSet:(UIScrollView *)scrollView didTapButton:(UIButton *)button {
    //跳转到新建钱包
    [self tapAdd];
}

- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView{
    return NO;
}

- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView{
    return -38;
}
@end
