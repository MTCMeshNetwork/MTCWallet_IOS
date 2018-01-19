//
//  TransferAccountsTableViewCell.m
//  ZSEthersWallet
//
//  Created by L on 2018/1/5.
//  Copyright © 2018年 lkl. All rights reserved.
//

#import "TransferAccountsTableViewCell.h"
#import "ZSCustomSlider.h"
#import "ZSCustomButton.h"

#define ZSCustomButtonW 35
@interface TransferAccountsTableViewCell () <UITextFieldDelegate>

@end

@implementation TransferAccountsTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView setBackgroundColor:[UIColor commonCellcolor]];
        
        self.txtField = [[ZSCustomTextField alloc] init];
        [self.contentView addSubview:self.txtField];
        [self.txtField setTextColor:[UIColor whiteColor]];
        [self.txtField setFont:[UIFont systemFontOfSize:13.0f]];
        self.txtField.placeholder = NSLocalizedString(@"请填入...",nil);
        self.txtField.delegate = self;
        // "通过KVC修改占位文字的颜色"
        [self.txtField setValue:[UIColor commonWhiteColor] forKeyPath:@"_placeholderLabel.textColor"];

        [self.txtField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(15);
            make.height.mas_equalTo(self.contentView);
            make.right.equalTo(self.contentView).offset(-50);
        }];
    }
    return self;
}

//点击return 按钮 去掉
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)setTransferAccountsTableViewCellType:(TableViewCellType)type {
    switch (type) {
        case TableViewCellType_None:
        {
            
            break;
        }
            
        case TableViewCellType_Image:
        {
            self.scanImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"scan"]];
            [self.contentView addSubview:self.scanImgView];
            [self.scanImgView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self.contentView).offset(-10);
                make.centerY.equalTo(self.contentView);
                make.size.mas_equalTo(CGSizeMake(30, 30));
            }];
            break;
        }
            
        case TableViewCellType_Text:
        {
            self.promptLb = [UILabel new];
            [self.contentView addSubview:self.promptLb];
            self.promptLb.textColor = [UIColor whiteColor];
            self.promptLb.font = [UIFont systemFontOfSize:14.0f];
            [self.promptLb mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self.contentView).offset(-10);
                make.centerY.equalTo(self.contentView);
            }];
            break;
        }
            
        default:
            break;
    }
};

@end


#pragma mark ========= 矿工奖励
@interface TransferAccountsAwardTableViewCell ()

@property (nonatomic, strong) ZSCustomSlider *slider;
@property (nonatomic, strong) UILabel *leftLb;
@property (nonatomic, strong) UILabel *promptLb;
@property (nonatomic, strong) UILabel *rightLb;
@end

@implementation TransferAccountsAwardTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView setBackgroundColor:[UIColor commonBackgroundColor]];
        
        self.slider = [[ZSCustomSlider alloc] init];
        [self.contentView addSubview:self.slider];
        self.slider.minimumValue = 1;
        self.slider.maximumValue = 200;
        self.slider.value = 20;
        [self.slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(50);
            make.right.equalTo(self.contentView).offset(-50);
            make.centerY.equalTo(self.contentView).offset(-8);
        }];
        
        self.promptLb = [UILabel new];
        [self.contentView addSubview:self.promptLb];
        self.promptLb.text = @"20 gwei";
        self.promptLb.textColor = [UIColor whiteColor];
        self.promptLb.font = [UIFont systemFontOfSize:14.0f];
        [self.promptLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.slider.mas_bottom).offset(15);
            make.centerX.equalTo(self.contentView);
        }];
        
        self.leftLb = [UILabel new];
        [self.contentView addSubview:self.leftLb];
        self.leftLb.text = NSLocalizedString(@"慢", nil);
        self.leftLb.textColor = [UIColor whiteColor];
        self.leftLb.font = [UIFont systemFontOfSize:14.0f];
        [self.leftLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.promptLb.mas_top);
            make.left.equalTo(self.slider.mas_left);
        }];
        
        self.rightLb = [UILabel new];
        [self.contentView addSubview:self.rightLb];
        self.rightLb.text = NSLocalizedString(@"快", nil);
        self.rightLb.textColor = [UIColor whiteColor];
        self.rightLb.font = [UIFont systemFontOfSize:14.0f];
        [self.rightLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.promptLb.mas_top);
            make.right.equalTo(self.slider.mas_right);
        }];
    }
    return self;
}

- (void)sliderValueChanged:(UISlider *)sender {
    self.promptLb.text = [NSString stringWithFormat:@"%d gwei",(int)sender.value];
    if (self.blockValue) {
        self.blockValue((int)sender.value);
    }
}

- (void)updateValue:(NSString *)value {
    self.slider.value = value.integerValue;
    self.promptLb.text = [NSString stringWithFormat:@"%@ gwei",value];
}
@end

#pragma mark ========= network
@interface TransferAccountsNetWorkTableViewCell ()

@property (nonatomic, strong) UILabel *netLb;
@property (nonatomic, strong) UILabel *advanceLb;
@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, strong) ZSCustomButton *selectbutton;
@end

@implementation TransferAccountsNetWorkTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self.contentView setBackgroundColor:[UIColor commonBackgroundColor]];
        
        [self.contentView addSubview:self.netLb];
        [self.contentView addSubview:self.advanceLb];
        [self.contentView addSubview:self.segmentedControl];
        
        [self.netLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(15);
            make.centerY.equalTo(self.contentView);
        }];
        
        [self.segmentedControl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView).offset(-15);
            make.centerY.equalTo(self.contentView);
        }];
        
        [self.advanceLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.segmentedControl.mas_left).offset(-10);
            make.centerY.equalTo(self.contentView);
        }];
        
//        NSArray *titleArr = @[@"Node",@"Mesh"];
//        for (int i = 0; i < 2; i ++) {
//            ZSCustomButton *netButton = [ZSCustomButton buttonWithType:ZSCustomButtonImageTop title:titleArr[i] titleColor:[UIColor whiteColor] fontSize:12.0f imageName:@"" backgroundColor:[UIColor clearColor] targe:self action:@selector(netWorkClick:)];
//            [netButton setImage:[UIImage at_imageWithColor:[UIColor whiteColor] size:CGSizeMake(ZSCustomButtonW, ZSCustomButtonW)] forState:UIControlStateNormal];
//            [self.contentView addSubview:netButton];
//            
//            netButton.tag = i;
//            
//            if (i == 0) {
//                [netButton setImage:[UIImage at_imageWithColor:[UIColor commonGreenColor] size:CGSizeMake(ZSCustomButtonW, ZSCustomButtonW)] forState:UIControlStateNormal];
//                netButton.selected = YES;
//                self.selectbutton = netButton;
//            }
//            [netButton mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.left.equalTo(self.netLb.mas_right).offset(5 + (ZSCustomButtonW + 20) * i);
//                make.centerY.equalTo(self.contentView);
//            }];
//        }
    }
    return self;
}

#pragma mark - Private Method
- (void)segmentedControlClick:(UISegmentedControl *)sender {
    if (self.block) {
        self.block(sender.selectedSegmentIndex);
    }
}

- (void)netWorkClick:(ZSCustomButton *)sender {
    if (!sender.isSelected) {
        self.selectbutton.selected = !self.selectbutton.selected;
        [self.selectbutton setImage:[UIImage at_imageWithColor:[UIColor whiteColor] size:CGSizeMake(ZSCustomButtonW, ZSCustomButtonW)] forState:UIControlStateNormal];
        sender.selected = !sender.selected;
        [sender setImage:[UIImage at_imageWithColor:[UIColor commonGreenColor] size:CGSizeMake(ZSCustomButtonW, ZSCustomButtonW)] forState:UIControlStateNormal];
        self.selectbutton = sender;
    }
}

#pragma mark - Init
- (UILabel *)netLb {
    if (!_netLb) {
        _netLb = [UILabel new];
        _netLb.text = @"Network";
        _netLb.textColor = [UIColor commonWhiteColor];
        _netLb.font = [UIFont systemFontOfSize:14.0f];
    }
    return _netLb;
}

- (UILabel *)advanceLb {
    if (!_advanceLb) {
        _advanceLb = [UILabel new];
        _advanceLb.text = @"Advance";
        _advanceLb.textColor = [UIColor commonWhiteColor];
        _advanceLb.font = [UIFont systemFontOfSize:14.0f];
    }
    return _advanceLb;
}

- (UISegmentedControl *)segmentedControl {
    if (!_segmentedControl) {
        _segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"ON",@"OFF"]];
        _segmentedControl.selectedSegmentIndex = 1;
        _segmentedControl.tintColor = [UIColor commonGreenColor];
        [_segmentedControl addTarget:self action:@selector(segmentedControlClick:) forControlEvents:UIControlEventValueChanged];
    }
    return _segmentedControl;
}
@end


#pragma mark ========= 总计耗费
@interface TransferTotalCostTableViewCell ()

@property (nonatomic, strong) UILabel *totalLb;
@property (nonatomic, strong) UILabel *costLb;

@end

@implementation TransferTotalCostTableViewCell
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView setBackgroundColor:[UIColor commonCellcolor]];
        
        self.totalLb = [UILabel new];
        [self.contentView addSubview:self.totalLb];
        self.totalLb.text = @"总计耗费";
        self.totalLb.textColor = [UIColor whiteColor];
        self.totalLb.font = [UIFont systemFontOfSize:20.0f];
        [self.totalLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(15);
            make.centerY.equalTo(self.contentView);
        }];
        
        self.costLb = [UILabel new];
        [self.contentView addSubview:self.costLb];
        self.costLb.text = @"0.0";
        self.costLb.textColor = [UIColor whiteColor];
        self.costLb.font = [UIFont systemFontOfSize:20.0f];
        [self.costLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView).offset(-15);
            make.centerY.equalTo(self.contentView);
        }];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTotalCostData:) name:@"updateTotalCostData" object:nil];
    }
    return self;
}

- (void)updateTotalCostData:(NSNotification *)noti {
    if (noti.object) {
        self.costLb.text = noti.object;
    }
}
@end

#pragma mark ========= 交易密码
@interface TransferAccountsPasswordTableViewCell ()

@property (nonatomic, strong) UILabel *pwLb;
//@property (nonatomic, strong) UIButton *forgetBtn;
@end

@implementation TransferAccountsPasswordTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.pwLb = [UILabel new];
        [self.contentView addSubview:self.pwLb];
        self.pwLb.backgroundColor = [UIColor commonRedColor];
        self.pwLb.text = NSLocalizedString(@"密码",nil);
        self.pwLb.textColor = [UIColor whiteColor];
        self.pwLb.font = [UIFont systemFontOfSize:15.0f];
        self.pwLb.textAlignment = NSTextAlignmentCenter;
        [self.pwLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.bottom.equalTo(self.contentView);
            make.width.mas_equalTo(@60);
        }];
        
//        self.forgetBtn = [UIButton buttonWithtitle:NSLocalizedString(@"忘记密码？",nil) titleColor:[UIColor commonWhiteColor] fontSize:14.0f BackgroundColor:[UIColor commonCellcolor] targe:self action:@selector(forgetBtnClick)];
//        [self.contentView addSubview:self.forgetBtn];
//        [self.forgetBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.right.equalTo(self.contentView).offset(-10);
//            make.centerY.equalTo(self.contentView);
//        }];
        self.txtField.secureTextEntry = YES;
        [self.txtField mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.pwLb.mas_right).offset(10);
            make.centerY.equalTo(self.contentView);
            make.right.equalTo(self.contentView);
        }];
    }
    return self;
}

//- (void)forgetBtnClick {
//    NSLog(@"忘记密码操作");
//}
@end
