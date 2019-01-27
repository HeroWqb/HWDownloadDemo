//
//  HWSettingVC.m
//  HWProject
//
//  Created by wangqibin on 2018/4/26.
//  Copyright © 2018年 wangqibin. All rights reserved.
//

#import "HWSettingVC.h"

@interface HWSettingVC ()

@property (nonatomic, weak) UITextField *textField;

@end

@implementation HWSettingVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navTitle = @"设置";
    
    [self creatControl];
}

- (void)creatControl
{
    CGFloat controlX = 30.f;
    CGFloat controlYPadding = 50.f;
    CGFloat controlW = KMainW - controlX * 2;
    CGFloat controlH = 44.f;
    
    // 设置最大并发数
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(controlX, controlYPadding, controlW, controlH)];
    UILabel *leftView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 222, controlH)];
    leftView.text = @" 设置下载最大并发数(上限5):";
    leftView.textColor = KWhiteColor;
    textField.leftView = leftView;
    textField.leftViewMode = UITextFieldViewModeAlways;
    textField.text = [NSString stringWithFormat:@"%ld", [[NSUserDefaults standardUserDefaults] integerForKey:HWDownloadMaxConcurrentCountKey]];
    textField.textColor = [UIColor yellowColor];
    textField.font = [UIFont boldSystemFontOfSize:18.f];
    textField.backgroundColor = [UIColor lightGrayColor];
    textField.textAlignment = NSTextAlignmentCenter;
    textField.returnKeyType = UIReturnKeyDone;
    textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    [textField addTarget:self action:@selector(textFieldEditingChanged:) forControlEvents:UIControlEventEditingChanged];
    [textField addTarget:self action:@selector(done) forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.view addSubview:textField];
    _textField = textField;
    
    // 是否允许蜂窝网络下载
    UILabel *accessLable = [[UILabel alloc] initWithFrame:CGRectMake(controlX, CGRectGetMaxY(textField.frame) + controlYPadding, controlW, controlH)];
    accessLable.text = @" 是否允许蜂窝网络下载";
    accessLable.textColor = KWhiteColor;
    accessLable.textAlignment = NSTextAlignmentLeft;
    accessLable.userInteractionEnabled = YES;
    accessLable.backgroundColor = [UIColor lightGrayColor];
    accessLable.layer.masksToBounds = YES;
    [self.view addSubview:accessLable];
    
    // 开关
    UISwitch *accessSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(accessLable.frameWidth - 60, 6.5, 0, 0)];
    accessSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:HWDownloadAllowsCellularAccessKey];
    [accessSwitch addTarget:self action:@selector(accessSwitchOnClick:) forControlEvents:UIControlEventValueChanged];
    [accessLable addSubview:accessSwitch];
    
    // 清空缓存
    UIButton *clearBtn = [[UIButton alloc] initWithFrame:CGRectMake(controlX, CGRectGetMaxY(accessLable.frame) + controlYPadding, controlW, controlH)];
    [clearBtn setTitle:@"清空缓存" forState:UIControlStateNormal];
    clearBtn.backgroundColor = [UIColor lightGrayColor];
    [clearBtn addTarget:self action:@selector(clearBtnOnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:clearBtn];
}

- (void)textFieldEditingChanged:(UITextField *)textField
{
    if (textField.text.length > 1) {
        textField.text = [textField.text substringToIndex:1];
        
    }else if (textField.text.length == 1) {
        NSCharacterSet *characterSet = [[NSCharacterSet characterSetWithCharactersInString:@"12345"] invertedSet];
        NSString *filtered = [[_textField.text componentsSeparatedByCharactersInSet:characterSet] componentsJoinedByString:@""];
        BOOL basicTest = [_textField.text isEqualToString:filtered];
        if (!basicTest) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请输入数字1~5" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];
            textField.text = @"";
        }
    }
}

- (void)done
{
    if ([_textField.text isEqualToString:@""]) _textField.text = @"1";
    
    // 原并发数
    NSInteger oldCount = [[NSUserDefaults standardUserDefaults] integerForKey:HWDownloadMaxConcurrentCountKey];
    // 新并发数
    NSInteger newCount = [_textField.text integerValue];
    
    if (oldCount != newCount) {
        // 保存
        [[NSUserDefaults standardUserDefaults] setInteger:newCount forKey:HWDownloadMaxConcurrentCountKey];
        
        // 通知
        [[NSNotificationCenter defaultCenter] postNotificationName:HWDownloadMaxConcurrentCountChangeNotification object:[NSNumber numberWithInteger:newCount]];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    
    [self done];
}

- (void)accessSwitchOnClick:(UISwitch *)accessSwitch
{
    // 保存
    [[NSUserDefaults standardUserDefaults] setBool:accessSwitch.isOn forKey:HWDownloadAllowsCellularAccessKey];

    // 通知
    [[NSNotificationCenter defaultCenter] postNotificationName:HWDownloadAllowsCellularAccessChangeNotification object:[NSNumber numberWithBool:accessSwitch.isOn]];
}

- (void)clearBtnOnClick
{
    [HWToolBox showAlertWithTitle:@"是否清空所有缓存？" sureMessage:@"确认" cancelMessage:@"取消" warningMessage:nil style:UIAlertControllerStyleAlert target:self sureHandler:^(UIAlertAction *action) {
        // 清空缓存
        [self clearLocalCache];
    } cancelHandler:nil warningHandler:nil];
}

- (void)clearLocalCache
{
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    dispatch_async(queue, ^{
        NSArray *array = [[HWDataBaseManager shareManager] getAllCacheData];
        for (HWDownloadModel *model in array) {
            [[HWDownloadManager shareManager] deleteTaskAndCache:model];
        }
    });
}

@end
