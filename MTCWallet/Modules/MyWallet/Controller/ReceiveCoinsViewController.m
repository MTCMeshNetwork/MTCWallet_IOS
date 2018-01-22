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

@interface ReceiveCoinsViewController ()<UITextFieldDelegate>

@property (nonatomic, strong) UILabel *ownLb;
@property (nonatomic, strong) UILabel *amountLb;
@property (nonatomic, strong) UITextField *amountTf;
@property (nonatomic, strong) UILabel *addressLb;
@property (nonatomic, strong) UIView *amountView;
@property (nonatomic, strong) UILabel *symbolLb;
@property (nonatomic, strong) UIImageView *QRCodeImgView;
@property (nonatomic, strong) UIButton *copyButton;
@end

@implementation ReceiveCoinsViewController

- (instancetype)initWithWallet:(Wallet*)wallet {
    if (self = [super initWithNibName:nil bundle:nil]) {
        _wallet = wallet;
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
    
    self.title = NSLocalizedString(@"收款地址",nil);
    
//    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithImageNamed:@"share" targe:self action:@selector(shareClick)];
    
    //初始化
    if ([_wallet numberOfAccounts]) {
        self.ownLb.text = [_wallet nicknameForIndex:_wallet.activeAccountIndex];
        self.addressLb.text = [[_wallet addressForIndex:_wallet.activeAccountIndex] checksumAddress];
    }
    
    [self.view addSubview:self.ownLb];
    [self.view addSubview:self.amountView];
    [self.view addSubview:self.amountLb];
    [self.view addSubview:self.addressLb];
    [self.view addSubview:self.amountTf];
    [self.view addSubview:self.symbolLb];
    [self.view addSubview:self.QRCodeImgView];
    [self.view addSubview:self.copyButton];
    
    [self.ownLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.view).offset(NAVIGATION_BAR_HEIGHT);
    }];
    
    [self.addressLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.ownLb.mas_bottom).offset(10);
        make.left.equalTo(self.view).offset(15);
        make.right.equalTo(self.view).offset(-15);
    }];
    
    
//    UIView *lineView = [[UIView alloc] init];
//    lineView.backgroundColor = [UIColor commonGreenColor];
//    [self.view addSubview:lineView];
//    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.right.equalTo(self.view);
//        make.height.equalTo(@8);
//        make.top.equalTo(self.addressLb.mas_bottom).offset(25);
//    }];
    
    [self.amountView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.addressLb.mas_bottom).offset(24);
        make.left.right.equalTo(self.view);
        make.height.equalTo(@60);
    }];
    
    [self.amountLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(self.amountView);
        make.width.equalTo(@80);
    }];
    
    [self.symbolLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.amountView);
        make.width.equalTo(@60);
        make.right.equalTo(self.amountView).offset(-15);
    }];
    
    [self.amountTf mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.amountLb.mas_right);
        make.right.equalTo(self.symbolLb.mas_left).offset(-10);
        make.top.bottom.equalTo(self.amountView);
    }];

    [self.QRCodeImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.amountView.mas_bottom).offset(30);
        make.centerX.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(ScreenWidth-100, ScreenWidth-100));
    }];
    
    [self.copyButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.QRCodeImgView.mas_bottom).offset(30);
        make.left.right.equalTo(self.view);
        make.height.equalTo(@60);
    }];

}

#pragma mark - Private Method
// 分享
- (void)shareClick {
    //to do
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Init
- (UILabel *)ownLb {
    if (!_ownLb) {
        _ownLb = [UILabel new];
        _ownLb.textColor = [UIColor commonOrangeTextColor];
        _ownLb.font = [UIFont systemFontOfSize:25.0f];
        _ownLb.text = @"My Wallet";
        _ownLb.textAlignment = NSTextAlignmentCenter;
        _ownLb.backgroundColor = [UIColor mainThemeColor];
    }
    return _ownLb;
}

- (UILabel *)amountLb {
    if (!_amountLb) {
        _amountLb = [UILabel new];
        _amountLb.text = NSLocalizedString(@"收款金额",nil);
        _amountLb.textColor = [UIColor whiteColor];
        _amountLb.backgroundColor = [UIColor commonBlueColor];
        _amountLb.textAlignment = NSTextAlignmentCenter;
        _amountLb.font = [UIFont systemFontOfSize:15.0f];
    }
    return _amountLb;
}

- (UILabel *)symbolLb {
    if (!_symbolLb) {
        _symbolLb = [UILabel new];
        _symbolLb.text = _wallet.activeToken.symbol;
        _symbolLb.textColor = [UIColor whiteColor];
        _symbolLb.font = [UIFont systemFontOfSize:15.0f];
    }
    return _symbolLb;
}

- (UITextField *)amountTf {
    if (!_amountTf) {
        _amountTf = [UITextField new];
        _amountTf.placeholder = NSLocalizedString(@"收款数量",nil);
        [_amountTf setValue:[UIColor commonlightGrayTextColor] forKeyPath:@"_placeholderLabel.textColor"];
        _amountTf.textColor = [UIColor whiteColor];
        _amountTf.font = [UIFont systemFontOfSize:15.0f];
        _amountTf.textAlignment = NSTextAlignmentRight;
        _amountTf.keyboardType = UIKeyboardTypeDecimalPad;
        [_amountTf addTarget:self action:@selector(textFieldTextChanged:) forControlEvents:UIControlEventEditingChanged];
    }
    return _amountTf;
}

- (UILabel *)addressLb {
    if (!_addressLb) {
        _addressLb = [UILabel new];
        _addressLb.textColor = [UIColor whiteColor];
        _addressLb.font = [UIFont systemFontOfSize:13.0f];
//        _addressLb.text = NSLocalizedString(@"请先新建钱包！",nil);
        _addressLb.lineBreakMode = NSLineBreakByTruncatingMiddle;
        _addressLb.textAlignment = NSTextAlignmentCenter;
    }
    return _addressLb;
}

- (UIView *)amountView {
    if (!_amountView) {
        _amountView = [UIView new];
        _amountView.backgroundColor = [UIColor commonCellcolor];
    }
    return _amountView;
}

//- (UILabel *)addressIconLb {
//    if (!_addressIconLb) {
//        _addressIconLb = [UILabel new];
//        _addressIconLb.userInteractionEnabled = YES;
////        _addressIconLb.text = ICON_FONT_COPY;
//        _addressIconLb.textColor = [UIColor whiteColor];
//        [_addressIconLb setFont:[UIFont fontWithName:@"iconfont" size:35]];
//        [_addressIconLb setText:ICON_FONT_COPY];
//        __weak typeof(self) weakSelf = self;
//        [_addressIconLb addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
//            // 复制
//            showMessage(showTypeSuccess,NSLocalizedString(@"复制成功", nil));
//            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
//            [pasteboard setString:weakSelf.addressLb.text];
//        }];
//    }
//    return _addressIconLb;
//}

//- (UIView *)lineView {
//    if (!_lineView) {
//        _lineView = [UIView new];
//        _lineView.backgroundColor = [UIColor commonCellcolor];
//    }
//    return _lineView;
//}

//- (UILabel *)QRCodeLb {
//    if (!_QRCodeLb) {
//        _QRCodeLb = [UILabel new];
//        _QRCodeLb.text = NSLocalizedString(@"钱包二维码",nil);
//        _QRCodeLb.textColor = [UIColor whiteColor];
//        _QRCodeLb.font = [UIFont systemFontOfSize:16.0f];
//    }
//    return _QRCodeLb;
//}

- (UIImageView *)QRCodeImgView {
    if (!_QRCodeImgView) {
        _QRCodeImgView = [UIImageView new];
        _QRCodeImgView.image = [ZSCreateQRCode createQRCodeWithString:_addressLb.text ViewController:self];
    }
    return _QRCodeImgView;
}

- (UIButton *)copyButton {
    if (!_copyButton) {
        _copyButton = [UIButton new];
        [_copyButton setTitle:NSLocalizedString(@"复制", nil) forState:UIControlStateNormal];
        [_copyButton setBackgroundColor:[UIColor commonPinkColor]];
        [_copyButton addTarget:self action:@selector(copyButtonClicked:)];
    }
    return _copyButton;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)textFieldTextChanged:(UITextField *)tf {
    NSString *icapAddress = [NSString stringWithFormat:@"iban:%@", [_wallet addressForIndex:_wallet.activeAccountIndex].icapAddress];
    NSString *codeString = [NSString stringWithFormat:@"%@?amount=%@&token=%@",icapAddress,tf.text,_wallet.activeToken.symbol];
    _QRCodeImgView.image = [ZSCreateQRCode createQRCodeWithString:codeString ViewController:self];
}

- (IBAction)copyButtonClicked:(id)sender {
    showMessage(showTypeSuccess, NSLocalizedString(@"地址已经复制", nil));
    [[UIPasteboard generalPasteboard] setString:_addressLb.text];
}

@end
