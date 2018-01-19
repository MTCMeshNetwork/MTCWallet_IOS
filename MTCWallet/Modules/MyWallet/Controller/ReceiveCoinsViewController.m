//
//  ReceiveCoinsViewController.m
//  ZSEthersWallet
//
//  Created by thomasho on 2018/1/2.
//  Copyright © 2018年 lkl. All rights reserved.
//

#import "ReceiveCoinsViewController.h"
#import "ZSCreateQRCode.h"

#import <ShareSDK/ShareSDK.h>
#import <ShareSDKUI/ShareSDK+SSUI.h>
#import "Utilities.h"
#import "UIImage+IconFont.h"

@interface ReceiveCoinsViewController ()

@property (nonatomic, strong) UILabel *ownLb;
@property (nonatomic, strong) UILabel *walletAddressLb;
@property (nonatomic, strong) UILabel *addressLb;
@property (nonatomic, strong) UILabel *addressIconLb;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UILabel *QRCodeLb;
@property (nonatomic, strong) UIImageView *QRCodeImgView;
@end

@implementation ReceiveCoinsViewController

- (instancetype)initWithWallet:(Wallet*)wallet {
    if (self = [super initWithNibName:nil bundle:nil]) {
        _wallet = wallet;
        
        NSLog(@"%ld",[_wallet numberOfAccounts]);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor commonBackgroundColor]];
    [self configElements];
}

#pragma make - Private Method
- (void)configElements {
    // 设置导航栏颜色
    [self wr_setNavBarBarTintColor:[UIColor commonGreenColor]];
    [self wr_setNavBarTitleColor:[UIColor whiteColor]];
    self.title = NSLocalizedString(@"收款地址",nil);
    
//    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithImageNamed:@"share" targe:self action:@selector(shareClick)];
    
    //初始化
    if ([_wallet numberOfAccounts]) {
        self.ownLb.text = [_wallet nicknameForIndex:_wallet.activeAccountIndex];
        self.addressLb.text = [[_wallet addressForIndex:_wallet.activeAccountIndex] checksumAddress];
    }
    
    [self.view addSubview:self.ownLb];
    [self.view addSubview:self.walletAddressLb];
    [self.view addSubview:self.addressLb];
    [self.view addSubview:self.addressIconLb];
    [self.view addSubview:self.lineView];
    [self.view addSubview:self.QRCodeLb];
    [self.view addSubview:self.QRCodeImgView];
    
    [self.ownLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.view).offset(NAVIGATION_BAR_HEIGHT);
        make.height.mas_offset(60);
    }];
    
    [self.walletAddressLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.ownLb.mas_bottom).offset(20);
        make.left.equalTo(self.view).offset(15);
    }];
    
    [self.addressLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.walletAddressLb.mas_bottom).offset(10);
        make.left.equalTo(self.view).offset(15);
        make.right.equalTo(self.addressIconLb.mas_left).offset(-5);
    }];
    
    [self.addressIconLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view).offset(-15);
        make.top.equalTo(self.walletAddressLb.mas_top);
        make.size.mas_equalTo(CGSizeMake(35, 35));
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.addressLb.mas_bottom).offset(20);
        make.height.mas_equalTo(@1);
    }];

    [self.QRCodeLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.lineView.mas_bottom).offset(15);
        make.left.equalTo(self.view).offset(15);
    }];

    [self.QRCodeImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.QRCodeLb.mas_bottom).offset(20);
        make.centerX.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(ScreenWidth-100, ScreenWidth-100));
    }];

}

#pragma mark - Private Method
// 分享
- (void)shareClick {
    
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    
    NSArray* imageArray = @[[UIImage imageNamed:@"set"]];
    
    NSString* desc = [NSString stringWithFormat:NSLocalizedString(@"啦啦啦啦啦啦啦",nil)];
    
    [shareParams SSDKSetupShareParamsByText:desc
                                     images:imageArray
                                        url:[NSURL URLWithString:@"http://baidu.com"]
                                      title:NSLocalizedString(@"分享给你",nil)
                                       type:SSDKContentTypeWebPage];
    
    [shareParams SSDKEnableUseClientShare];
    
    [ShareSDK showShareActionSheet:nil items:nil shareParams:shareParams onShareStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end) {
        
        switch (state) {
            case SSDKResponseStateSuccess:
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"分享成功",nil)
                                                                    message:nil
                                                                   delegate:nil
                                                          cancelButtonTitle:NSLocalizedString(@"确定",nil)
                                                          otherButtonTitles:nil];
                [alertView show];
                break;
            }
            case SSDKResponseStateFail:
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"分享失败",nil)
                                                                message:[NSString stringWithFormat:@"%@",error]
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil, nil];
                [alert show];
                break;
            }
            default:
                break;
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Init
- (UILabel *)ownLb {
    if (!_ownLb) {
        _ownLb = [UILabel new];
        _ownLb.textColor = [UIColor whiteColor];
        _ownLb.font = [UIFont systemFontOfSize:22.0f];
        _ownLb.text = @"My Wallet";
        _ownLb.textAlignment = NSTextAlignmentCenter;
        _ownLb.backgroundColor = [UIColor commonGreenColor];
    }
    return _ownLb;
}

- (UILabel *)walletAddressLb {
    if (!_walletAddressLb) {
        _walletAddressLb = [UILabel new];
        _walletAddressLb.text = NSLocalizedString(@"钱包地址",nil);
        _walletAddressLb.textColor = [UIColor whiteColor];
        _walletAddressLb.font = [UIFont systemFontOfSize:15.0f];
    }
    return _walletAddressLb;
}

- (UILabel *)addressLb {
    if (!_addressLb) {
        _addressLb = [UILabel new];
        _addressLb.textColor = [UIColor whiteColor];
        _addressLb.font = [UIFont systemFontOfSize:13.0f];
        _addressLb.text = NSLocalizedString(@"请先新建钱包！",nil);
        _addressLb.lineBreakMode = NSLineBreakByTruncatingMiddle;
    }
    return _addressLb;
}

- (UILabel *)addressIconLb {
    if (!_addressIconLb) {
        _addressIconLb = [UILabel new];
        _addressIconLb.userInteractionEnabled = YES;
//        _addressIconLb.text = ICON_FONT_COPY;
        _addressIconLb.textColor = [UIColor whiteColor];
        [_addressIconLb setFont:[UIFont fontWithName:@"iconfont" size:35]];
        [_addressIconLb setText:ICON_FONT_COPY];
        __weak typeof(self) weakSelf = self;
        [_addressIconLb addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
            // 复制
            showMessage(showTypeSuccess,NSLocalizedString(@"复制成功", nil));
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            [pasteboard setString:weakSelf.addressLb.text];
        }];
    }
    return _addressIconLb;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [UIView new];
        _lineView.backgroundColor = [UIColor commonCellcolor];
    }
    return _lineView;
}

- (UILabel *)QRCodeLb {
    if (!_QRCodeLb) {
        _QRCodeLb = [UILabel new];
        _QRCodeLb.text = NSLocalizedString(@"钱包二维码",nil);
        _QRCodeLb.textColor = [UIColor whiteColor];
        _QRCodeLb.font = [UIFont systemFontOfSize:16.0f];
    }
    return _QRCodeLb;
}

- (UIImageView *)QRCodeImgView {
    if (!_QRCodeImgView) {
        _QRCodeImgView = [UIImageView new];
        _QRCodeImgView.image = [ZSCreateQRCode createQRCodeWithString:_addressLb.text ViewController:self];
    }
    return _QRCodeImgView;
}
@end
