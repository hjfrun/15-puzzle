//
//  ContainerView.m
//  My15
//
//  Created by hjfrun on 15/11/20.
//  Copyright © 2015年 hjfrun. All rights reserved.
//

#import "ContainerView.h"
#import "UIView+Extension.h"


@implementation ContainerView

//- (void)setDimension:(NSUInteger)dimension
//{
//    _dimension = dimension;
//    
//    [self setNeedsDisplay];
//}




- (void)layoutSubviews
{
    self.dimension = 5;
    CGFloat btnW = self.frame.size.width / self.dimension;
    CGFloat btnH = btnW;
    
    for (NSUInteger i = 0; i < self.subviews.count; i++) {
        UIButton *button = self.subviews[i];
        
        button.origin = CGPointMake((i % _dimension) * btnW, (i / _dimension) * btnH);
        button.width = btnW;
        button.height = btnH;
    }
}

@end
