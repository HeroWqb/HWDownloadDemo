//
//  HWNavigationController.m
//  HWProject
//
//  Created by wangqibin on 2018/4/10.
//  Copyright © 2018年 wangqibin. All rights reserved.
//

#import "HWNavigationController.h"
#import "HWTabBarController.h"

@interface HWNavigationController ()

@end

@implementation HWNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImage *navBackImage = [UIImage imageWithColor:[UIColor colorWithHexString:@"#009ACD"]];
    UINavigationBar *navBar = [UINavigationBar appearance];
    [navBar setShadowImage:[[UIImage alloc] init]];
    [navBar setBackgroundImage:navBackImage forBarMetrics:UIBarMetricsDefault];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (self.childViewControllers.count) {
        HWTabBarController *tabBarController = (HWTabBarController *)self.tabBarController;
        [tabBarController setTabBarHiddenWithAnimaition:YES];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage imageNamed:@"nav_back"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"nav_back"] forState:UIControlStateHighlighted];
        [button sizeToFit];
        [button addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
        viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    }
    
    if (![[super topViewController] isKindOfClass:[viewController class]]) {
        [super pushViewController:viewController animated:animated];
    }
}

- (void)back
{
    if ([self.topViewController respondsToSelector:@selector(back)]) {
        [self.topViewController back];
        
    } else {
        [self popViewControllerAnimated:YES];
    }
}

@end
