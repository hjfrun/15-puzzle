//
//  ViewController.m
//  My15
//
//  Created by hjfrun on 15/11/20.
//  Copyright © 2015年 hjfrun. All rights reserved.
//

#import "ViewController.h"
#import "ContainerView.h"
#import "UIView+Extension.h"

const static NSInteger Dimension = 4;

@interface ViewController ()

@property (weak, nonatomic) IBOutlet ContainerView *containerView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.containerView.layer.borderColor = [UIColor colorWithRed:45 / 255.0 green:117 / 255.0 blue:111 / 255.0 alpha:1.0].CGColor;
    self.containerView.layer.borderWidth = 2;
    [self setupButtons];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self checkStatus];
}


- (void)setupButtons
{
    for (NSUInteger i = 1; i <= Dimension * Dimension; i++) {
        [self addButtonWithNumber:i];
    }
}

- (void)addButtonWithNumber:(NSUInteger)number
{
    UIButton *button = [[UIButton alloc] init];
    button.layer.borderColor = [UIColor colorWithRed:45 / 255.0 green:117 / 255.0 blue:111 / 255.0 alpha:1.0].CGColor;
    button.layer.borderWidth = 1;
    if (number < Dimension * Dimension) {
        button.titleLabel.font = [UIFont systemFontOfSize:30];
        [button setTitle:[NSString stringWithFormat:@"%lu", (unsigned long)number] forState:UIControlStateNormal];
        [button setTitle:[NSString stringWithFormat:@"%lu", (unsigned long)number] forState:UIControlStateHighlighted];
        button.backgroundColor = [UIColor colorWithRed:35 / 255.0 green:159 / 255.0 blue:134 / 255.0 alpha:1.0];
        [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    [self.containerView addSubview:button];
}

// 点击了数字，检查上下左右的按钮如果有空，则移动到对应的位置
- (void)buttonClicked:(UIButton *)button
{
    NSLog(@"buttonClicked: %@", button.currentTitle);
    // 当前按钮的origin
    CGPoint center = button.center;
    CGPoint blankCenter;
    UIButton *blankButton;
    for (UIButton *btn in self.containerView.subviews) {
        if (btn.currentTitle.length == 0) {
            blankCenter = btn.center;
            blankButton = btn;
            break;
        }
    }
    NSLog(@"button center: %@", NSStringFromCGPoint(center));
    NSLog(@"blank center: %@", NSStringFromCGPoint(blankCenter));
    
    CGFloat disWidth = ABS(center.x - blankCenter.x);
    CGFloat disHeight =  ABS(center.y - blankCenter.y);
    
    if (disHeight + disWidth <= button.width) {
        [UIView animateWithDuration:0.1 animations:^{
            CGPoint temp = blankCenter;
            blankButton.center = button.center;
            button.center = temp;
            [self checkStatus];
        }];
    }
    
    
}

- (void)checkStatus
{
    for (UIButton *button in self.containerView.subviews) {
        int row = button.origin.y / button.width;
        int col = button.origin.x / button.width;
        
        if ([button.currentTitle intValue] == row * Dimension + col + 1) {
            button.backgroundColor = [UIColor colorWithRed:69 / 255.0 green:196 / 255.0 blue:132 / 255.0 alpha:1.0];
        } else if (button.currentTitle.length == 0){
            button.backgroundColor = [UIColor clearColor];
        } else {
            button.backgroundColor = [UIColor colorWithRed:35 / 255.0 green:159 / 255.0 blue:134 / 255.0 alpha:1.0];
        }
    }
}




@end
