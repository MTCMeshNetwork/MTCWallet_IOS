//
//  ImportWalletVC.m
//  ZSEthersWallet
//
//  Created by thomasho on 2018/1/5.
//  Copyright © 2018年 lkl. All rights reserved.
//

#import "ImportWalletVC.h"
#import <Masonry/Masonry.h>
#import "BlockButton.h"
#import "Utilities.h"
#import "WRNavigationBar.h"
#import "ScanQRCodeViewController.h"

NSString *const TextViewTableViewCellResuseIdentifier = @"TextViewTableViewCellResuseIdentifier";
NSString *const TextFieldTableViewCellResuseIdentifier = @"TextFieldTableViewCellResuseIdentifier";
const CGFloat TextViewTableViewCellHeight = 130.0f;
const CGFloat TextFieldTableViewCellHeight = 60.0f;

NSString *textViewPlaceHolder(NSInteger index) {
    return @[NSLocalizedString(@"在此输入助记词，用空格分隔", nil),NSLocalizedString(@"在此粘贴以太坊钱包Keystore文件内容。或通过生成keystore内容的二维码，扫描录入。", nil),NSLocalizedString(@"在此输入明文私钥", nil)][index];
}

NSArray *textFiledPlaceHolder(NSInteger index) {
    return @[
             @[
               @[@"m/44'/66'/0'/0/0",@"m/44'/66'/0'/0/0",@"m/44'/66'/0'/0/0"],
               NSLocalizedString(@"输入钱包名称", nil),
               NSLocalizedString(@"设置交易密码", nil),
               NSLocalizedString(@"重复交易密码", nil),
               NSLocalizedString(@"输入密码提示（可不填）", nil)],
             @[
                 NSLocalizedString(@"输入钱包名称", nil),
                 NSLocalizedString(@"Keystore密码", nil)],
             @[
                 NSLocalizedString(@"输入钱包名称", nil),
                 NSLocalizedString(@"设置交易密码", nil),
                 NSLocalizedString(@"重复交易密码", nil),
                 NSLocalizedString(@"输入密码提示（可不填）", nil)],
             ][index];
}

@implementation Mnemonic
@end

@implementation KeyStore
@end

@implementation PrivateKey
@end


@interface ImportWalletVC ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,UITextViewDelegate,UITextFieldDelegate> {
    UIScrollView *_pageScrollView;
    UIView *_titleView;
    UIView *_lineView;
    NSIndexPath *_indexPath;
}
@property (nonatomic, strong) Mnemonic *mnemonic;
@property (nonatomic, strong) KeyStore *keyStore;
@property (nonatomic, strong) PrivateKey *privateKey;
@property (nonatomic, strong) NSMutableDictionary *textViewDic;

@end

@implementation ImportWalletVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"导入钱包", nil);
    
    self.mnemonic = [Mnemonic new];
    self.keyStore = [KeyStore new];
    self.privateKey = [PrivateKey new];
    
    self.textViewDic = [NSMutableDictionary dictionaryWithCapacity:3];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadView {
    [super loadView];
    
    [self wr_setNavBarShadowImageHidden:YES];
    
    UIView *titleView = [UIView new];
    _titleView = titleView;
    [titleView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:titleView];
    [titleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.left.equalTo(self.view);
        make.top.equalTo(@64);
        make.height.equalTo(@50);
    }];
    
    UIScrollView *horizontalScrollView = [[UIScrollView alloc]init];
    _pageScrollView = horizontalScrollView;
    
    __weak typeof(self) weakSelf = self;
    void(^tapButton)(UIButton *) = ^ (UIButton *btn) {
        for (UIButton *b in btn.superview.subviews) {
            [b setSelected:NO];
        }
        [btn setSelected:YES];
        [weakSelf scrollView:horizontalScrollView page:btn.tag];
    };
    
    
    for (int i=0;i<3;i++) {
        BlockButton *btn = [BlockButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:@[NSLocalizedString(@"助记词", nil),NSLocalizedString(@"官方钱包", nil),NSLocalizedString(@"明文私钥", nil)][i] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:15];
        btn.tag = i;
        [btn setTitleColor:[UIColor colorWithHexString:@"ed6f2d"] forState:UIControlStateSelected];
        [btn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [btn handleControlEvent:UIControlEventTouchUpInside withBlock:tapButton];
        [titleView addSubview:btn];
    }
    [titleView.subviews mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:50 leadSpacing:30 tailSpacing:30];
    [titleView.subviews mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@48);
        make.top.equalTo(titleView);
    }];
    
    UIView *line = [UIView new];
    line.backgroundColor = [UIColor colorWithWhite:0xf5 alpha:1];
    [self.view addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_titleView).insets(UIEdgeInsetsMake(48, 0, 1, 0));
    }];
    
    _lineView = [[UIView alloc] init];
    [_lineView setBackgroundColor:[UIColor colorWithHexString:@"ed6f2d"]];
    [self.view addSubview:_lineView];
    [_lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@0);
        make.bottom.equalTo(titleView);
        make.height.equalTo(@2);
        make.width.equalTo(titleView).multipliedBy(1/3.);
    }];
    
    
    horizontalScrollView.backgroundColor = [UIColor orangeColor];
    horizontalScrollView.pagingEnabled =YES;
    horizontalScrollView.delegate = self;
    // 添加scrollView添加到父视图，并设置其约束
    [self.view addSubview:horizontalScrollView];
    [horizontalScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.left.mas_equalTo(titleView);
        make.top.mas_equalTo(titleView.mas_bottom);
        make.bottom.mas_equalTo(self.view);
    }];
    // 设置scrollView的子视图，即过渡视图contentSize，并设置其约束
    UIView *horizontalContainerView = [[UIView alloc]init];
    [horizontalScrollView addSubview:horizontalContainerView];
    [horizontalContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(horizontalScrollView);
        make.height.equalTo(horizontalScrollView);
    }];
    //过渡视图添加子视图
    UIView *previousView =nil;
    for (int i =0; i < 3; i++)
    {
        UITableView *table = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        table.backgroundColor = COLOR_BACKGROUND;
        table.tag = i;
        table.delegate = self;
        table.dataSource = self;
        table.tableFooterView = [self buttonView:NSLocalizedString(@"确认导入", nil) tag:i onCompletion:^(UIButton *btn) {
            if (btn.tag == 0) {
                showMessage(showTypeStatus, NSLocalizedString(@"正在导入...", nil));
                weakSelf.didImportMnemonic(weakSelf,weakSelf.mnemonic);
            }else if(btn.tag == 1) {
                showMessage(showTypeStatus, NSLocalizedString(@"正在导入...", nil));
                weakSelf.didImportKeystore(weakSelf,weakSelf.keyStore);
            }else {
                showMessage(showTypeStatus, NSLocalizedString(@"正在导入...", nil));
                weakSelf.didImportPrivateKey(weakSelf,weakSelf.privateKey);
            }
        }];
        
        //添加到父视图，并设置过渡视图中子视图的约束
        [horizontalContainerView addSubview:table];
        [table mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.and.bottom.equalTo(horizontalContainerView);
            make.width.equalTo(horizontalScrollView);
            
            if (previousView)
            {
                make.left.mas_equalTo(previousView.mas_right);
            }
            else
            {
                make.left.mas_equalTo(0);
            }
        }];
        
        previousView = table;
    }
    // 设置过渡视图的右距（此设置将影响到scrollView的contentSize）
    [horizontalContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(previousView.mas_right);
    }];
    
    BlockButton *btn = [[BlockButton alloc] initWithFrame:CGRectMake(0, 0, 60, 40)];
    [btn setTitle:NSLocalizedString(@"扫描", nil) forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor commonWhiteColor] forState:UIControlStateNormal];
    [btn handleControlEvent:UIControlEventTouchUpInside withBlock:^{
        ScanQRCodeViewController *scanVC = [[ScanQRCodeViewController alloc] init];
        scanVC.block = ^(NSString *text) {
            int page = _pageScrollView.contentOffset.x/_pageScrollView.frame.size.width;
            UITextView *tv = [weakSelf.textViewDic objectForKey:@(page)];
            tv.text = text;
            [weakSelf textViewDidChange:tv];
        };
        [weakSelf.navigationController pushViewController:scanVC animated:YES];
    }];
    UIBarButtonItem *scanItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItems = @[scanItem];
}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView != _pageScrollView) {
        return;
    }
    int page = _pageScrollView.contentOffset.x/_pageScrollView.frame.size.width;
    for (UIButton *b in _titleView.subviews) {
        [b setSelected:b.tag == page];
    }
    [self scrollView:_pageScrollView page:page];
}

- (void) scrollView:(UIScrollView *)scroll page:(NSInteger)page {
    //CGFloat distance = scroll.contentOffset.x / scroll.contentSize.width;
    [scroll setContentOffset:CGPointMake(self.view.bounds.size.width * page, scroll.contentOffset.y) animated:YES]; //设置scrollview的显示为当前滑动到的页面
    [_lineView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(page * scroll.frame.size.width/3.0));
        make.bottom.equalTo(_titleView);
        make.height.equalTo(@2);
        make.width.equalTo(_titleView).multipliedBy(1/3.0);
    }];
}
#pragma mark - keyboard
- (void)keyboardWillShow:(NSNotification *)aNotification {
    NSDictionary* info = [aNotification userInfo];
    // 注意不要用UIKeyboardFrameBeginUserInfoKey，第三方键盘可能会存在高度不准，相差40高度的问题
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    // 修改滚动天和tableView的contentInset
    for (UITableView *view in [_pageScrollView.subviews[0] subviews]) {
        if ([view isKindOfClass:[UITableView class]]) {
            view.contentInset = UIEdgeInsetsMake(0, 0, kbSize.height, 0);
            view.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, kbSize.height, 0);
            
            // 跳转到当前点击的输入框所在的cell
//            [UIView animateWithDuration:0.2 animations:^{
//                [view scrollToRowAtIndexPath:_indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
//            }];
        }
    }
}

- (void)keyboardWillBeHidden:(NSNotification *)aNotification {
    for (UITableView *view in [_pageScrollView.subviews[0] subviews]) {
        if ([view isKindOfClass:[UITableView class]]) {
            view.contentInset = UIEdgeInsetsZero;
            view.scrollIndicatorInsets = UIEdgeInsetsZero;
        }
    }
}

#pragma mark - table delegate

- (UITableViewCell *)textViewCell:(NSString *)placeHolder onCompletion:(void (^)(UITextView *))block {
    UITableViewCell *cell  = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TextViewTableViewCellResuseIdentifier];
    UIView *bg = [UIView new];
    bg.layer.borderColor = [UIColor colorWithWhite:0xe4/255. alpha:1].CGColor;
    bg.layer.borderWidth = 1;
    [cell.contentView addSubview:bg];
    [bg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(cell.contentView).insets(UIEdgeInsetsMake(10, 10, 10, 10));
    }];
    
    UITextView *textView = [UITextView new];
    textView.text = placeHolder;
    textView.delegate = self;
    textView.textColor = [UIColor colorWithWhite:0x99/255. alpha:1];
    [cell.contentView addSubview:textView];
    [textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(bg).insets(UIEdgeInsetsMake(8, 8, 8, 8));
    }];
    block(textView);
    return cell;
}

- (UITableViewCell *)textFiledCell:(id)placeHolder onCompletion:(void (^)(UITextField *))block {
    UITableViewCell *cell  = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TextFieldTableViewCellResuseIdentifier];
    UITextField *tf = [UITextField new];
    if ([placeHolder isKindOfClass:[NSArray class]]) {
        tf.placeholder = [placeHolder firstObject];
    }else {
        tf.placeholder = placeHolder;
    }
    tf.delegate = self;
    [tf addTarget:self action:@selector(textfieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [cell.contentView addSubview:tf];
    [tf mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(cell.contentView).insets(UIEdgeInsetsMake(10, 10, 10, 10));
    }];
    block(tf);
    return cell;
}

- (UIView *)buttonView:(NSString *)title tag:(NSUInteger)tag onCompletion:(void (^)(UIButton *))block {
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
    BlockButton *btn = [BlockButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:NSLocalizedString(@"确认导入", nil)];
    [btn setBackgroundColor:COLOR_GREEN];
    btn.layer.cornerRadius = 5;
    btn.tag = tag;
    [btn handleControlEvent:UIControlEventTouchUpInside withBlock:block];
    [v addSubview:btn];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(v).insets(UIEdgeInsetsMake(20, 30, 20, 30));
    }];
    return v;
}

//- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
//    [self.view endEditing:YES];
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (tableView.tag) {
        case 0:
            return 6;
        case 1:
            return 3;
        case 2:
            return 5;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.row == 0? 130 : 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    if (indexPath.row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:TextViewTableViewCellResuseIdentifier];
        if (!cell) {
            NSInteger tag = tableView.tag;
            cell = [self textViewCell:textViewPlaceHolder(tableView.tag) onCompletion:^(UITextView *textView) {
                [self.textViewDic setObject:textView forKey:@(tag)];
                [self textViewDidChange:textView];
            }];
        }
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:TextFieldTableViewCellResuseIdentifier];
        if (!cell) {
            NSInteger page = tableView.tag;
            cell = [self textFiledCell:[textFiledPlaceHolder(tableView.tag) objectAtIndex:indexPath.row-1] onCompletion:^(UITextField *tf) {
                switch (page) {
                    case 0:
                        if (indexPath.row == 3 || indexPath.row == 4) {
                            tf.secureTextEntry = YES;
                        } else {
                            tf.secureTextEntry = NO;
                        }
                        break;
                    case 1:
                        if (indexPath.row == 2) {
                            tf.secureTextEntry = YES;
                        } else {
                            tf.secureTextEntry = NO;
                        }
                        break;
                    case 2:
                        if (indexPath.row == 3 || indexPath.row == 2) {
                            tf.secureTextEntry = YES;
                        } else {
                            tf.secureTextEntry = NO;
                        }
                        break;
                }
            }];
        }
    }
    if (tableView.tag == 0 && indexPath.row == 1) {
        BlockButton *btn = [BlockButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:@">" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor commonTextColor] forState:UIControlStateNormal];
        NSArray *arr = [textFiledPlaceHolder(tableView.tag) objectAtIndex:0];
        [btn handleControlEvent:UIControlEventTouchUpInside withBlock:^{
            NSLog(@"to do %@",arr);
        }];
        cell.accessoryView = btn;
    }else {
        cell.accessoryView = nil;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.contentView.tag = indexPath.row;
    return cell;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if (0 == textView.tag) {
        textView.text = @"";
    }
    textView.tag = 1;
}

- (void)textViewDidChange:(UITextView *)textView {
    int page = _pageScrollView.contentOffset.x/_pageScrollView.frame.size.width;
    switch (page) {
        case 0:
            self.mnemonic.mnemonics = textView.text;
            break;
        case 1:
            self.keyStore.json = textView.text;
            break;
        case 2:
            self.privateKey.key = textView.text;
            break;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}
- (IBAction)textfieldDidChange:(UITextField *)textFiled {
    int page = _pageScrollView.contentOffset.x/_pageScrollView.frame.size.width;
    NSInteger tag = textFiled.superview.tag;
    if (page == 0) {
        switch (tag) {
            case 2:
                self.mnemonic.name = textFiled.text;
                break;
            case 3:
                self.mnemonic.pwd = textFiled.text;
                break;
            case 4:
                self.mnemonic.pwdRetry = textFiled.text;
                break;
            case 5:
                self.mnemonic.hint = textFiled.text;
                break;
        }
    }else if (page == 1) {
        switch (tag) {
            case 1:
                self.keyStore.name = textFiled.text;
                break;
            case 2:
                self.keyStore.pwd = textFiled.text;
                break;
        }
    }else if (page == 2) {
        switch (tag) {
            case 1:
                self.privateKey.name = textFiled.text;
                break;
            case 2:
                self.privateKey.pwd = textFiled.text;
                break;
            case 3:
                self.privateKey.pwdRetry = textFiled.text;
                break;
            case 4:
                self.mnemonic.hint = textFiled.text;
                break;
        }
    }
}

@end
