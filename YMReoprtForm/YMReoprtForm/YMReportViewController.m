//
//  YMReportViewController.m
//  YMReoprtForm
//
//  Created by Yormo on 2019/11/9.
//  Copyright © 2019 com.yormo.YMReoprtForm. All rights reserved.
//

#import "YMReportViewController.h"
#import "LPDQuoteImagesView.h"
#import "ZXReasonTableViewCell.h"
#define MAX_LIMIT_NUMS 20
#define HMColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface YMReportViewController () <UITextViewDelegate, LPDQuoteImagesViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) UILabel *placeHolderLabel;
@property (weak, nonatomic) IBOutlet UILabel *limitWordLable;
@property (weak, nonatomic) IBOutlet UIStackView *stackView;
@property (weak, nonatomic) IBOutlet UIView *screenshotView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *screenshotContainViewHeight;
@property (weak, nonatomic) IBOutlet UIView *submitButton;
@property (weak, nonatomic) IBOutlet UIView *disableSumbit;
@property (weak, nonatomic) IBOutlet UILabel *reportReasonLabel;

@property (weak, nonatomic) IBOutlet UIView *reasonButtonView;
@property (weak, nonatomic) IBOutlet UITableView *reasonTableView;
@property (strong, nonatomic) NSArray *reportReason;
@property (weak, nonatomic) IBOutlet UIView *reasonView;
@property (assign, nonatomic) NSInteger selectReasonIndex;

@property (nonatomic, strong) LPDQuoteImagesView *selectedImgView;
@property (nonatomic, assign) BOOL tabBarHidden;

@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *phoneField;
@property (strong, nonatomic) NSArray *imageArray;
@property (strong, nonatomic) NSMutableArray *imagePathArray;
@property (nonatomic, assign) int uploadingNumber;

@end

@implementation YMReportViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"举报";
    self.selectReasonIndex = -1;
    self.textView.delegate = self;
    self.textView.textContainerInset = UIEdgeInsetsMake(10, 15, 10, 15);
    self.limitWordLable.text = [NSString stringWithFormat:@"%d/%d", 0, MAX_LIMIT_NUMS];
    self.imagePathArray = [NSMutableArray new];
    self.stackView.layer.backgroundColor = [UIColor redColor].CGColor;
    [self.reasonTableView registerClass:[ZXReasonTableViewCell class] forCellReuseIdentifier:@"ZXReasonTableViewCell"];
    self.reportReason = @[ @"色情相关", @"政治谣言", @"诈骗或垃圾信息", @"骚扰或人身攻击", @"其他" ];

    [self.textView addSubview:self.placeHolderLabel];
    @try {
        [_textView setValue:self.placeHolderLabel forKey:@"_placeholderLabel"];
    } @catch (NSException *exception) {
    } @finally {
    }
    
    LPDQuoteImagesView *view3 = [[LPDQuoteImagesView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, RELATIVE_VALUE(190)) withCountPerRowInView:3 cellMargin:8];
    view3.backgroundColor = HMColorFromRGB(0xFFFFFF);
    view3.collectionView.scrollEnabled = NO;
    view3.isShowTakePhotoSheet = YES;
    view3.delegate = self;
    self.selectedImgView = view3;
    view3.maxSelectedCount = 6;
    [self.screenshotView addSubview:view3];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.submitButton.layer addSublayer:[self gradientLayelWithView:self.submitButton]];
        [self.reasonButtonView.layer addSublayer:[self gradientLayelWithView:self.reasonButtonView]];
    });
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarHidden = self.tabBarController.tabBar.hidden;
    self.tabBarController.tabBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.tabBarController.tabBar.hidden = self.tabBarHidden;
}

- (CAGradientLayer *)gradientLayelWithView:(UIView *)view {
    CAGradientLayer *gl = [CAGradientLayer layer];
    gl.frame = view.bounds;
    gl.startPoint = CGPointMake(0.5, 0);
    gl.endPoint = CGPointMake(0.5, 1);
    gl.colors = @[(__bridge id)[UIColor colorWithRed:74/255.0 green:111/255.0 blue:255/255.0 alpha:1.0].CGColor, (__bridge id)[UIColor colorWithRed:145/255.0 green:125/255.0 blue:255/255.0 alpha:1.0].CGColor];
    gl.locations = @[@(0), @(1.0f)];
    UIGraphicsBeginImageContextWithOptions(gl.frame.size, NO, 0);
        [gl renderInContext:UIGraphicsGetCurrentContext()];
    return gl;
}

#pragma mark - --------- 根据选中的图片个数来调节高度  ---------
- (void)getSelectedPhotos:(NSMutableArray *)selectedPhotos {
    if (selectedPhotos.count >= 4) {
        self.screenshotContainViewHeight.constant = 131 + 80;
    } else {
        self.screenshotContainViewHeight.constant = 131;
    }
    self.imageArray = [selectedPhotos copy];
}

- (UILabel *)placeHolderLabel {
    if (_placeHolderLabel == nil) {
        UILabel *placeHolderLabel = [[UILabel alloc] init];
        placeHolderLabel.text = @"请详细描述你所遇到的情况，以便客服人员快速为你进行处理";
        placeHolderLabel.numberOfLines = 0;
        placeHolderLabel.textColor = HMColorFromRGB(0x999999);
        placeHolderLabel.font = [UIFont systemFontOfSize:13];
        [placeHolderLabel sizeToFit];
        _placeHolderLabel = placeHolderLabel;
    }
    return _placeHolderLabel;
}

#pragma mark UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    if (textView.text.length > MAX_LIMIT_NUMS) {
        textView.text = [textView.text substringToIndex:MAX_LIMIT_NUMS];
    }
    self.limitWordLable.text = [NSString stringWithFormat:@"%lu/%d", (unsigned long)[textView.text length], MAX_LIMIT_NUMS];
    [self updateSubmitButtonState];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSString *str = [NSString stringWithFormat:@"%@%@", textView.text, text];
    if (str.length > MAX_LIMIT_NUMS) {
        NSRange rangeIndex = [str rangeOfComposedCharacterSequenceAtIndex:MAX_LIMIT_NUMS];
        if (rangeIndex.length == 1) {
            textView.text = [str substringToIndex:MAX_LIMIT_NUMS];
            self.limitWordLable.text = [NSString stringWithFormat:@"%lu/%d", (unsigned long)textView.text.length, MAX_LIMIT_NUMS];
        } else {
            NSRange rangeRange = [str rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, MAX_LIMIT_NUMS)];
            textView.text = [str substringWithRange:rangeRange];
        }
        return NO;
    }
    return YES;
}


#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.reportReason.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZXReasonTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ZXReasonTableViewCell" forIndexPath:indexPath];
    cell.nameLabel.text = self.reportReason[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectReasonIndex = indexPath.row;
}

- (IBAction)selectReason:(id)sender {
    self.reasonView.hidden = NO;
}

- (IBAction)closeReasonView:(id)sender {
    self.reasonView.hidden = YES;
    if (self.selectReasonIndex >= 0) {
        self.reportReasonLabel.text = self.reportReason[self.selectReasonIndex];
    }
    [self updateSubmitButtonState];
}

- (IBAction)submit:(id)sender {
    if (!self.disableSumbit.hidden) {
        return;
    }
    if (self.imageArray && self.imageArray.count > 0) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)updateSubmitButtonState {
    if (self.selectReasonIndex > -1 && self.textView.text.length > 0) {
        self.disableSumbit.hidden = YES;
    } else {
        self.disableSumbit.hidden = NO;
    }
}

@end
