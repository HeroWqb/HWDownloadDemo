//
//  UINavigationItem+Swizzling.m
//  SXEducation
//
//  Created by sxmaps on 2017/10/19.
//  Copyright © 2017年 sxmaps. All rights reserved.
//

#import "UINavigationItem+Swizzling.h"
#import "SwizzlingDefine.h"

#define KTitleLabelFont [UIFont boldSystemFontOfSize:18.f]
#define KTitleLabelTextColor [UIColor colorWithHexString:@"#ffffff"]

@implementation UINavigationItem (Swizzling)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        swizzling_exchangeMethod([UINavigationItem class], @selector(setTitle:), @selector(swizzling_setTitle:));
        swizzling_exchangeMethod([UINavigationItem class], @selector(title), @selector(swizzling_title));
    });
}

- (void)swizzling_setTitle:(NSString *)title
{
    UILabel *titleLabel = (UILabel *)self.titleView;
    if (!titleLabel) {
        titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.titleView = titleLabel;
    }
    
    if ([titleLabel isKindOfClass:[UILabel class]]) {
        titleLabel.font = KTitleLabelFont;
        titleLabel.textColor = KTitleLabelTextColor;
        titleLabel.text = title;
    }
    
    [titleLabel.superview layoutSubviews];
}

- (NSString *)swizzling_title
{
    if ([self swizzling_title].length ) {
        return [self swizzling_title];
    }
    
    UILabel *titleLabel = (UILabel *)self.titleView;
    if ([titleLabel isKindOfClass:[UILabel class]]) {
        titleLabel.font = KTitleLabelFont;
        titleLabel.textColor = KTitleLabelTextColor;
        
        return titleLabel.text;
    }
    
    return nil;
}

@end
