//
//  UINavigationBar+Swizzling.m
//  SXEducation
//
//  Created by sxmaps on 2017/10/19.
//  Copyright © 2017年 sxmaps. All rights reserved.
//

#import "UINavigationBar+Swizzling.h"
#import "SwizzlingDefine.h"

@implementation UINavigationBar (Swizzling)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        swizzling_exchangeMethod([UINavigationBar class], @selector(layoutSubviews), @selector(swizzling_layoutSubViews));
    });
}

- (void)swizzling_layoutSubViews
{
    UINavigationItem *navgationItem = [self topItem];
    
    if ([navgationItem.titleView isKindOfClass:[UILabel class]]) {
        UILabel *label = (UILabel *)navgationItem.titleView;
        UIFont *font = self.titleTextAttributes[NSFontAttributeName];
        if (font) {
            label.font = font;
        }
        
        UIColor *color = self.titleTextAttributes[NSForegroundColorAttributeName];
        if (color) {
            label.textColor = color;
        }
        
        [label sizeToFit];
    }

    if (!ISIOS11) {
        [self layoutLabel];
    }
    [self swizzling_layoutSubViews];
}

- (void)layoutLabel
{
    UINavigationItem *navigationItem = [self topItem];
    UIView *view = navigationItem.titleView;
    view.centerX = self.frameWidth  * .5f;
    view.centerY = self.frameHeight * .5f;
}

@end
