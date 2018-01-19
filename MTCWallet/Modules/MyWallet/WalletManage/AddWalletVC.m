//
//  AddWalletVC.m
//  ZSEthersWallet
//
//  Created by thomasho on 2018/1/5.
//  Copyright © 2018年 lkl. All rights reserved.
//

#import "AddWalletVC.h"
#import <Masonry/Masonry.h>
#import "Utilities.h"
#import "BlockButton.h"
#import "DoneWalletVC.h"
#import "WRNavigationBar.h"

@interface AddWalletVC ()<UITextFieldDelegate>

@property (nonatomic,strong) NSMutableDictionary *results;

@end

@implementation AddWalletVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"新建钱包", nil);
    self.tableView.backgroundColor = COLOR_BACKGROUND;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.results = [NSMutableDictionary dictionary];
}

- (void)loadView {
    [super loadView];
    
    [self wr_setNavBarTintColor:[UIColor whiteColor]];
    [self wr_setNavBarTitleColor:[UIColor whiteColor]];
    [self wr_setNavBarBarTintColor:COLOR_GREEN];
    [self wr_setNavBarShadowImageHidden:YES];
    self.navigationController.navigationBarHidden = NO;
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 150)];
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
    lbl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    NSString *redStr = NSLocalizedString(@"一旦丢失将无法找回!", nil);
    NSString *message = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"请妥善保管交易密码，", nil),redStr];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    NSDictionary * attributes = @{NSFontAttributeName : [UIFont systemFontOfSize:13.0],NSForegroundColorAttributeName:[UIColor lightGrayColor], NSParagraphStyleAttributeName : paragraphStyle};
    NSMutableAttributedString *attribtedMessageStr = [[NSMutableAttributedString alloc] initWithString:message];
    [attribtedMessageStr addAttributes:attributes range:NSMakeRange(0, message.length)];
    [attribtedMessageStr addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(message.length-redStr.length, redStr.length)];
    lbl.attributedText = attribtedMessageStr;
    [bottomView addSubview:lbl];
    
    
    __weak AddWalletVC *weakSelf = self;
    BlockButton *button = [[BlockButton alloc] initWithFrame:CGRectMake(25,100, 270, 50)];
    [button handleControlEvent:UIControlEventTouchUpInside withBlock:^{
        [weakSelf.view endEditing:YES];
        if (![weakSelf.results[@(0)] length]) {
            showMessage(showTypeError,NSLocalizedString(@"请输入钱包名称", nil));
            return ;
        }
        if ([weakSelf.results[@(1)] length] < 8) {
            showMessage(showTypeError,NSLocalizedString(@"请设置一个不小于8位的交易密码", nil));
            return ;
        }
        if(![weakSelf.results[@(2)] isEqualToString:self.results[@(1)]]) {
            showMessage(showTypeError,NSLocalizedString(@"两次密码不一致", nil));
            return ;
        }
        weakSelf.onReturn(weakSelf,weakSelf.results[@(0)],weakSelf.results[@(1)],weakSelf.results[@(3)]);
    }];
    [button setTitle:NSLocalizedString(@"确认新建", nil) forState:UIControlStateNormal];
    [button setBackgroundColor:COLOR_GREEN];
    button.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    button.layer.cornerRadius = 5;
    [bottomView addSubview:button];
    
    self.tableView.tableFooterView = bottomView;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self.results setObject:textField.text?:@"" forKey:@(textField.superview.tag)];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.row%2?50:5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 8;
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = (indexPath.row%2)?COLOR_DARK:[UIColor clearColor];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = indexPath.row%2?@"cell":@"noneCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    if (indexPath.row%2) {
        NSInteger idx = indexPath.row/2;
        UILabel *colorLbl = [cell.contentView viewWithTag:100];
        if (!colorLbl) {
            colorLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 50)];
            colorLbl.tag = 100;
            colorLbl.textColor = [UIColor whiteColor];
            colorLbl.textAlignment = NSTextAlignmentCenter;
            [cell.contentView addSubview:colorLbl];
        }
        cell.contentView.tag = idx;
        colorLbl.text = @[NSLocalizedString(@"名称", nil),NSLocalizedString(@"密码", nil),NSLocalizedString(@"重复", nil),NSLocalizedString(@"提示", nil)][idx];
        colorLbl.backgroundColor = @[COLOR_BLUE,COLOR_PINK,COLOR_PINK,COLOR_GREEN][idx];
        UITextField *tf = [cell.contentView viewWithTag:101];
        if (!tf) {
            tf = [[UITextField alloc] initWithFrame:CGRectMake(100, 0, 320-120, 50)];
            tf.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            tf.textColor = [UIColor whiteColor];
            tf.tag = 101;
            tf.placeholder = @" ";
            tf.delegate = self;
            [tf setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
            [cell.contentView addSubview:tf];
        }
        tf.placeholder = @[NSLocalizedString(@"输入钱包名称", nil),NSLocalizedString(@"输入不小于8位的交易密码", nil),NSLocalizedString(@"重复钱包交易密码", nil),NSLocalizedString(@"密码提示（可不填）", nil)][idx];
        tf.text = self.results[@(idx)]?:@"";
    }
    return cell;
}

@end
