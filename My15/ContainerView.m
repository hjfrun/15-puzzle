//
//  ContainerView.m
//  My15
//
//  Created by hjfrun on 15/11/20.
//  Copyright © 2015年 hjfrun. All rights reserved.
//

#import "ContainerView.h"
#import "UIView+Extension.h"

const static NSInteger Dimension = 4;

@implementation ContainerView


- (void)layoutSubviews
{
    CGFloat btnW = self.frame.size.width / Dimension;
    CGFloat btnH = btnW;
    
    for (NSUInteger i = 0; i < self.subviews.count; i++) {
        UIButton *button = self.subviews[i];
        
        button.origin = CGPointMake((i % 4) * btnW, (i / 4) * btnH);
        button.width = btnW;
        button.height = btnH;
    }
}

@end
