//
//  DoneWalletVC.m
//  ZSEthersWallet
//
//  Created by thomasho on 2018/1/5.
//  Copyright © 2018年 lkl. All rights reserved.
//

#import "DoneWalletVC.h"
#import <ethers/Account.h>
#import <ethers/SecureData.h>
#import "Utilities.h"
#import <Masonry/Masonry.h>
#import "ZSCreateQRCode.h"
#import "BlockButton.h"
#import "TipVC.h"
#import "ExportWalletVC.h"
#import "UIImage+IconFont.h"

@interface DoneWalletVC () {
    NSString *_password;
    UIButton *_backupButton,*_laterButton;
}
@property (nonatomic,strong) Account *account;
@end

@implementation DoneWalletVC

- (instancetype)initWithAccount:(Account *)a password:(NSString *)password {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        _account  = a;
        _password = password;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.backgroundColor = [UIColor commonTextColor];
    self.tableView.contentInset = UIEdgeInsetsMake(-20, 0, 0, 0);
    
    __weak DoneWalletVC *weakSelf = self;
    [_account encryptSecretStorageJSON:_password callback:^(NSString *json) {
        weakSelf.json = json;
        [_backupButton setEnabled:YES];
        [_laterButton setEnabled:YES];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
}

- (void)loadView {
    [super loadView];
    
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320,570)];
    [headView setBackgroundColor:[UIColor colorWithHexString:@"494950"]];
    self.tableView.tableHeaderView = headView;
    
    BlockButton *button = [BlockButton buttonWithType:UIButtonTypeCustom];
    button.userInteractionEnabled = NO;
    button.titleLabel.font = [UIFont systemFontOfSize:25];
    [button setImage:[UIImage iconWithInfo:IconInfoMake(ICON_FONT_DONE, 40, [UIColor greenColor])] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [button setTitle:NSLocalizedString(@" 创建成功", nil) forState:UIControlStateNormal];
    [headView addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(headView);
        make.height.equalTo(@90);
    }];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
    [line setBackgroundColor:[UIColor lightGrayColor]];
    [headView addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(headView);
        make.top.equalTo(button.mas_bottom);
        make.height.equalTo(@1);
    }];
    
//    UILabel *iconLbl = [[UILabel alloc] initWithFrame:CGRectMake(250, 0, 40, 40)];
//    [iconLbl setFont:[UIFont fontWithName:@"iconfont" size:30]];
//    [iconLbl setText:ICON_FONT_COPY];
//    [iconLbl setTextColor:[UIColor lightGrayColor]];
//    [headView addSubview:iconLbl];
    button = [BlockButton buttonWithType:UIButtonTypeCustom];
    button.titleLabel.font = [UIFont fontWithName:@"iconfont" size:30];
    [button setTitle:ICON_FONT_COPY forState:UIControlStateNormal];
    [button setTitleColor:[UIColor commonDarkGrayTextColor] forState:UIControlStateNormal];
    [button handleControlEvent:UIControlEventTouchUpInside withBlock:^{
        [[UIPasteboard generalPasteboard] setString:_account.address.checksumAddress];
        showMessage(showTypeSuccess, NSLocalizedString(@"复制成功", nil));
    }];
    [headView addSubview:button];
    
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(25, 0, 200, 40)];
    lbl.numberOfLines = 0;
    lbl.textColor = [UIColor whiteColor];
    lbl.font = [UIFont systemFontOfSize:15];
    lbl.text = [NSString stringWithFormat:@"%@\n%@",NSLocalizedString(@"钱包地址", nil),_account.address.checksumAddress];
    [headView addSubview:lbl];
    [lbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(headView).offset(30);
        make.top.equalTo(line).offset(50);
        make.right.equalTo(headView).offset(-30-70);
        make.height.equalTo(@60);
    }];
    
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(lbl.mas_centerY);
        make.right.equalTo(headView).offset(-30);
        make.width.height.equalTo(@40);
    }];
    
    UILabel *codeInfo = [[UILabel alloc] init];
    codeInfo.textColor = [UIColor whiteColor];
    codeInfo.text = NSLocalizedString(@"钱包二维码", nil);
    [headView addSubview:codeInfo];
    [codeInfo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(headView).offset(30);
        make.top.equalTo(lbl.mas_bottom).offset(30);
        make.height.equalTo(@20);
    }];
    
    UIImageView *codeIv = [[UIImageView alloc] initWithImage:[ZSCreateQRCode createQRCodeWithString:_account.address.checksumAddress ViewController:self]];
    [headView addSubview:codeIv];
    [codeIv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(lbl);
        make.top.equalTo(codeInfo.mas_bottom).offset(10);
        make.width.height.equalTo(@130);
    }];
    
    UILabel *nameLbl = [[UILabel alloc] init];
    nameLbl.textColor = [UIColor whiteColor];
    nameLbl.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"钱包名称", nil),_name];
    [headView addSubview:nameLbl];
    [nameLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(lbl);
        make.top.equalTo(codeIv.mas_bottom).offset(50);
        make.height.equalTo(@20);
    }];
    
//    UILabel *pwdLbl = [[UILabel alloc] init];
//    pwdLbl.textColor = [UIColor whiteColor];
//    pwdLbl.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"交易密码", nil),_password];
//    [headView addSubview:pwdLbl];
//    [pwdLbl mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(lbl);
//        make.top.equalTo(nameLbl.mas_bottom).offset(30);
//        make.height.equalTo(@20);
//    }];
    
    UILabel *hintLbl = [[UILabel alloc] init];
    hintLbl.textColor = [UIColor whiteColor];
    hintLbl.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"密码提示", nil),_hint?:@""];
    [headView addSubview:hintLbl];
    [hintLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(lbl);
        make.top.equalTo(nameLbl.mas_bottom).offset(30);
        make.height.equalTo(@20);
    }];
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 250)];
    [bottomView setBackgroundColor:[UIColor commonTextColor]];
    self.tableView.tableFooterView = bottomView;

    __weak DoneWalletVC *weakSelf = self;
    BlockButton *backup = [BlockButton buttonWithType:UIButtonTypeCustom];
    [backup setEnabled:NO];
    _backupButton = backup;
    [backup handleControlEvent:UIControlEventTouchUpInside withBlock:^{
        [[TipVC showTipType:ShowTipTypeBackup inController:weakSelf] setTitle:NSLocalizedString(@"请选择备份/导出钱包方式", nil) buttons:@[NSLocalizedString(@"助记词",nil),NSLocalizedString(@"Keystore",nil),NSLocalizedString(@"明文私钥",nil)] onCompletion:^(id value,NSInteger index) {
            if (index) {
                ExportWalletVC *exportVC = nil;
                    if (index == 1) {
                        exportVC = [ExportWalletVC export:weakSelf.account.mnemonicPhrase withType:ExportTypeMnmenic];
                    }else if (index == 2) {
                        exportVC = [ExportWalletVC export:weakSelf.json withType:ExportTypeKeyStore];
                    }else if(index == 3) {
                        exportVC = [ExportWalletVC export:[SecureData dataToHexString:weakSelf.account.privateKey] withType:ExportTypePrivateKey];
                    }
                    [weakSelf.navigationController pushViewController:exportVC animated:YES];
            }
        }];
    }];
    [backup setBackgroundColor:COLOR_GREEN];
    backup.layer.cornerRadius = 5;
    [backup setTitle:NSLocalizedString(@"备份/导出钱包", nil) forState:UIControlStateNormal];
    [bottomView addSubview:backup];
    [backup mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(bottomView).insets(UIEdgeInsetsMake(0, 30, 0, 30));
        make.top.equalTo(bottomView).offset(30);
        make.height.equalTo(@50);
    }];
    
    BlockButton *later = [BlockButton buttonWithType:UIButtonTypeCustom];
    [later setEnabled:NO];
    _laterButton = later;
    [later setTitle:NSLocalizedString(@"稍后再说", nil) forState:UIControlStateNormal];
    [later handleControlEvent:UIControlEventTouchUpInside withBlock:^{
        [weakSelf.navigationController popToRootViewControllerAnimated:YES];
    }];
    [bottomView addSubview:later];
    [later mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.height.with.equalTo(backup);
        make.top.equalTo(backup.mas_bottom).offset(20);
    }];
    
    UILabel *tipLbl = [[UILabel alloc] init];
    [tipLbl setTextColor:COLOR_WARNING];
    tipLbl.numberOfLines = 0;
    tipLbl.font = [UIFont systemFontOfSize:15];
    tipLbl.text = NSLocalizedString(@"强烈建议备份并妥善保管MTC秘钥和钱包交易密码，否则一旦丢失将无法找回！", nil);
    [bottomView addSubview:tipLbl];
    [tipLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(backup);
        make.top.equalTo(later.mas_bottom);
        make.bottom.equalTo(bottomView).offset(-30);
    }];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

@end
