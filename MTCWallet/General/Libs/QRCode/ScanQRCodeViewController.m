//
//  ScanQRCodeViewController.m
//  ZSEthersWallet
//
//  Created by L on 2018/1/5.
//  Copyright © 2018年 lkl. All rights reserved.
//

#import "ScanQRCodeViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "Utilities.h"

#define kScreenScale    (ScreenWidth/320)
#define kBgImgX             45 * kScreenScale
#define kBgImgY             90 * kScreenScale
#define kBgImgWidth         230 * kScreenScale
#define kScrollLineHeight   2 * kScreenScale

@interface ScanQRCodeViewController ()<AVCaptureMetadataOutputObjectsDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    UIImageView *bgImgView;
    UIImageView *scrollLineView;
    UILabel     *lbContent;
    UIButton    *openPhotoBtn;
    
    NSInteger serviceUpId;
    
    BOOL isStop;
}

@property (strong, nonatomic) AVCaptureSession *session;
@property (strong, nonatomic) CADisplayLink *link;
@property (assign, nonatomic) BOOL up;

@end

@implementation ScanQRCodeViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //判断是否有相机权限
    AVAuthorizationStatus authStatus =  [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied)
    {
        [self showAlertMessage:NSLocalizedString(@"开启相机才能扫描二维码哦",nil) cancelTitle:NSLocalizedString(@"残忍拒绝",nil) cancelClicked:nil confirmTitle:NSLocalizedString(@"去开启",nil) confirmClicked:^{

            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if ([[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url options:nil completionHandler:nil];
            }
        }];
        return;
    }
    
    [self.session startRunning];
    //计时器添加到循环中去
    [self.link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    
    if (isStop) {
        [self.session stopRunning];
        [self.link removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.session stopRunning];
    if (self.link) {
        [self.link invalidate];
        self.link = nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor commonBackgroundColor]];
    [self.navigationItem setTitle:NSLocalizedString(@"二维码",nil)];
    _up = YES;
    
    [self session];
    [self initWithSubViews];
    
}

- (CADisplayLink *)link{
    
    if (!_link) {
        _link = [CADisplayLink displayLinkWithTarget:self selector:@selector(LineAnimation)];
    }
    return _link;
}
#pragma mark - 线条运动的动画
- (void)LineAnimation
{
    if (_up == YES)
    {
        CGFloat y = scrollLineView.frame.origin.y;
        y += 2;
        [scrollLineView setFrame:CGRectMake(kBgImgX, y, kBgImgWidth, kScrollLineHeight)];
        if (y >= (kBgImgY+kBgImgWidth-kScrollLineHeight))
        {
            _up = NO;
        }
    }else{
        CGFloat y = scrollLineView.frame.origin.y;
        y -= 2;
        [scrollLineView setFrame:CGRectMake(kBgImgX, y, kBgImgWidth, kScrollLineHeight)];
        if (y <= kBgImgY)
        {
            _up = YES;
        }
    }
}

- (void)initWithSubViews
{
    bgImgView = [[UIImageView alloc]initWithFrame:CGRectMake(kBgImgX, kBgImgY, kBgImgWidth, kBgImgWidth)];
    [self.view addSubview:bgImgView];
    [bgImgView setImage:[UIImage imageNamed:@"icon_two_box"]];
    
    scrollLineView = [[UIImageView alloc]initWithFrame:CGRectMake(kBgImgX, kBgImgY, kBgImgWidth, kScrollLineHeight)];
    [self.view addSubview:scrollLineView];
    [scrollLineView setImage:[UIImage imageNamed:@"icon_two_line"]];
    
    lbContent = [[UILabel alloc] init];
    [self.view addSubview:lbContent];
    [lbContent setText:NSLocalizedString(@"将二维码放入框内，即可自动扫描",nil)];
    [lbContent setFont:[UIFont systemFontOfSize:14.0]];
    [lbContent setTextColor:[UIColor whiteColor]];
    [lbContent setTextAlignment:NSTextAlignmentCenter];
    
    openPhotoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:openPhotoBtn];
    [openPhotoBtn setTitle:NSLocalizedString(@"从相册选取",nil) forState:UIControlStateNormal];
    [openPhotoBtn setTintColor:[UIColor whiteColor]];
    [openPhotoBtn.titleLabel setFont:[UIFont systemFontOfSize:16.0]];
    
    [openPhotoBtn addTarget:self action:@selector(openPhoto) forControlEvents:UIControlEventTouchUpInside];
    
    [self subViewsLayout];
}

- (void)subViewsLayout
{
    [lbContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(bgImgView.mas_bottom).offset(10);
        make.left.and.right.equalTo(self.view);
        make.height.mas_equalTo(@20);
    }];
    
    [openPhotoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lbContent.mas_bottom).offset(20);
        make.centerX.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(100, 30));
    }];
}

- (AVCaptureSession *)session
{
    if (!_session)
    {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:NULL];
        if (input == nil) {
            return nil;
        }
        
        AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc]init];
        [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        
        AVCaptureSession *session = [[AVCaptureSession alloc]init];
        [session setSessionPreset:AVCaptureSessionPresetHigh];
        if ([session canAddInput:input]) {
            [session addInput:input];
        }
        if ([session canAddOutput:output]) {
            [session addOutput:output];
        }
        
        output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
        
        AVCaptureVideoPreviewLayer *previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:session];
        [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
        previewLayer.frame = self.view.bounds;
        [self.view.layer insertSublayer:previewLayer atIndex:0];
        
        CGRect rect = CGRectMake(kBgImgY/ScreenHeight, kBgImgX/ScreenWidth, kBgImgWidth/ScreenHeight, kBgImgWidth/ScreenWidth);
        output.rectOfInterest = rect;
        
        UIView *maskView = [[UIView alloc] initWithFrame:self.view.bounds];
        maskView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
        [self.view addSubview:maskView];
        UIBezierPath *rectPath = [UIBezierPath bezierPathWithRect:self.view.bounds];
        [rectPath appendPath:[[UIBezierPath bezierPathWithRoundedRect:CGRectMake(kBgImgX, kBgImgY, kBgImgWidth, kBgImgWidth) cornerRadius:1] bezierPathByReversingPath]];
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.path = rectPath.CGPath;
        maskView.layer.mask = shapeLayer;
        
        _session = session;
    }
    return _session;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 调用相册

- (void)openPhoto
{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        return;
    }
    
    UIImagePickerController *ipc = [[UIImagePickerController alloc]init];
    ipc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    ipc.delegate = self;
    ipc.allowsEditing = YES;
    [self presentViewController:ipc animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate

//相册获取的照片进行处理
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *pickImage = info[UIImagePickerControllerOriginalImage];
    NSData *imageData = UIImagePNGRepresentation(pickImage);
    CIImage *ciImage = [CIImage imageWithData:imageData];
    
    //从选中的图片中读取二维码数据
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy: CIDetectorAccuracyHigh}];
    
    NSArray *feature = [detector featuresInImage:ciImage];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    if (feature.count) {
        for (CIQRCodeFeature *result in feature) {
            if ([result isKindOfClass:[CIQRCodeFeature class]]) {
                NSString *urlStr = ((CIQRCodeFeature *)result).messageString;
                
                [self showInSafariWithURLMessage:urlStr Success:^(NSString *token) {
                    
                } Failure:^(NSError *error) {
                    showMessage(showTypeError, NSLocalizedString(@"该信息不是钱包地址",nil));
                }];
                
                break;
            }
        }
    }
    else{
        isStop = YES;
        showMessage(showTypeError, NSLocalizedString(@"无法识别该二维码",nil));
    }
}


#pragma mark - AVCaptureMetadataOutputObjectsDelegate
// 扫描到数据时会调用
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if (metadataObjects.count > 0) {
        AVMetadataMachineReadableCodeObject *obj = [metadataObjects lastObject];
        if (obj) {
            [self showInSafariWithURLMessage:[obj stringValue] Success:^(NSString *token) {
                
            } Failure:^(NSError *error) {
                showMessage(showTypeError, NSLocalizedString(@"该信息不是钱包地址", nil));
            }];
        }
    }
}

//判断钱包地址规则
- (void)showInSafariWithURLMessage:(NSString *)message Success:(void (^)(NSString *token))success Failure:(void (^)(NSError *error))failure{
    
    if ([self inputShouldLetterOrNum:message]) {
        success(@"成功跳转");
        
        if (self.block) {
            self.block(message);
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        NSError *error;
        failure(error);
    }
}

//字母或数字
- (BOOL)inputShouldLetterOrNum:(NSString *)inputString {
    if (inputString.length == 0) return NO;
    NSString *regex =@"[a-zA-Z0-9]*";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    return [pred evaluateWithObject:inputString];
}

@end
