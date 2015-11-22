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
#import "NSArray+Extension.h"
#import "Const.h"

const static NSInteger Dimension = 4;

typedef NS_ENUM(NSUInteger, BlankMoveDirection) {
    BlankMoveDirectionUp,           // 空白按钮向上移动
    BlankMoveDirectionLeft,         // 空白按钮相左移动
    BlankMoveDirectionDown,         // 空白按钮向下移动
    BlankMoveDirectionRight,        // 空白按钮向右移动
};

@interface ViewController ()

@property (weak, nonatomic) ContainerView *containerView;
@property (nonatomic, assign) NSUInteger totalSeconds;      // 总共用的秒数
@property (nonatomic, strong) UILabel *timeLabel;           // 所用总时间
@property (nonatomic, strong) UILabel *countLabel;          // 总共使用步数
@property (nonatomic, strong) NSTimer *updateTimer;         // 每秒更新计时
@property (nonatomic, strong) UIButton *blankButton;        // 空白按钮
@property (nonatomic, strong) UIButton *upButton;           // 上面的按钮
@property (nonatomic, strong) UIButton *leftButton;         // 左边的按钮
@property (nonatomic, strong) UIButton *downButton;         // 下面的按钮
@property (nonatomic, strong) UIButton *rightButton;        // 右边的按钮

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // 添加上面的背景view
    UIView *upView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenW, ScreenH - ScreenW)];
    upView.backgroundColor = ColorUpView;
    upView.layer.borderColor = ColorBorder;
    upView.layer.borderWidth = 1;
    [self.view addSubview:upView];
    
    // 添加时间记录到上面左边部分
    UILabel *label = [[UILabel alloc] init];
    label.text = @"计时";
    [label setTextAlignment:NSTextAlignmentCenter];
    CGFloat labelW = ScreenW / 3.0;
    CGFloat labelH = 35;
    CGFloat labelX = 0;
    CGFloat labelY = 70;
    label.frame = CGRectMake(labelX, labelY, labelW, labelH);
    [upView addSubview:label];
    
    UILabel *timeLabel = [[UILabel alloc] init];
    timeLabel.text = @"00:00";
    [timeLabel setTextAlignment:NSTextAlignmentCenter];
    CGFloat timeLabelW = ScreenW / 3.0;
    CGFloat timeLabelH = 50;
    CGFloat timeLabelX = 0;
    CGFloat timeLabelY = CGRectGetMaxY(label.frame) + 10;
    timeLabel.frame = CGRectMake(timeLabelX, timeLabelY, timeLabelW, timeLabelH);
    self.timeLabel = timeLabel;
    [upView addSubview:timeLabel];
    
    // 添加刷新按钮到上面中间部分
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat btnW = ScreenW / 3.0;
    CGFloat btnH = ScreenH - ScreenW;
    CGFloat btnX = ScreenW / 3.0;
    CGFloat btnY = 0;
    button.frame = CGRectMake(btnX, btnY, btnW, btnH);
    
    [button setTitle:@"刷新" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    button.layer.borderColor = ColorBorder;
    button.layer.borderWidth = 2;
    
    [upView addSubview:button];
    [button addTarget:self action:@selector(refreshButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    // 添加步数记录部分到上面右边部分
    UILabel *moveLabel = [[UILabel alloc] init];
    moveLabel.text = @"计步";
    CGFloat moveLabelW = ScreenW / 3.0;
    CGFloat moveLabelH = labelH;
    CGFloat moveLabelX = ScreenW / 3.0 * 2;
    CGFloat moveLabelY = labelY;
    moveLabel.frame = CGRectMake(moveLabelX, moveLabelY, moveLabelW, moveLabelH);
    [moveLabel setTextAlignment:NSTextAlignmentCenter];
    [upView addSubview:moveLabel];
    
    UILabel *countLabel = [[UILabel alloc] init];
    countLabel.text = @"0";
    CGFloat countLabelW = ScreenW / 3.0;
    CGFloat countLabelH = timeLabelH;
    CGFloat countLabelX = moveLabelX;
    CGFloat countLabelY = timeLabelY;
    countLabel.frame = CGRectMake(countLabelX, countLabelY, countLabelW, countLabelH);
    [countLabel setTextAlignment:NSTextAlignmentCenter];
    [upView addSubview:countLabel];
    self.countLabel = countLabel;
    
    
    // 添加容器View
    ContainerView *containerView = [[ContainerView alloc] init];
    CGFloat containerViewW = ScreenW;
    CGFloat containerViewH = containerViewW;
    CGFloat containerViewX = 0;
    CGFloat containerViewY = ScreenH - containerViewH;
    containerView.frame = CGRectMake(containerViewX, containerViewY, containerViewW, containerViewH);
    containerView.backgroundColor = ColorEmpty;
    
    [self.view addSubview:containerView];
    
    self.containerView = containerView;
    
    self.containerView.layer.borderColor = ColorBorder;
    self.containerView.layer.borderWidth = 2;
    // 添加所有数字作为按钮
    [self setupButtons];
    // 打乱所有数字
    [self randomButtons];
}

/**
 *  在显示之前设置正确的颜色
 */
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self checkStatus];
}

/**
 *  创建所有按钮
 */
- (void)setupButtons
{
    for (NSUInteger i = 1; i <= Dimension * Dimension; i++) {
        [self addButtonWithNumber:i];
    }
}

/**
 *  打乱所有按钮
 */
- (void)randomButtons
{
    NSMutableArray *array = [NSMutableArray array];
    
    for (UIButton *button in self.containerView.subviews) {
        [array addObject:button];
        [button removeFromSuperview];
    }
    NSArray *newArray = [array shuffledArray];
    for (NSUInteger i = 0; i < newArray.count; i++) {
        [self.containerView addSubview:newArray[i]];
    }
}

#pragma mark - 获取空白按钮的上下左右四个方向的按钮
- (UIButton *)getButtonWithDirection:(BlankMoveDirection)moveDirection
{
    for (UIButton *button in self.containerView.subviews) {
        if (button.currentTitle.length == 0) continue;
        CGPoint buttonCenter = button.center;
        CGPoint blankCenter = self.blankButton.center;
        CGFloat disWidth = ABS(buttonCenter.x - blankCenter.x);
        CGFloat disHeight =  ABS(buttonCenter.y - blankCenter.y);
        
        if (disHeight + disWidth <= button.width) {
            if (buttonCenter.x < blankCenter.x) {
                self.leftButton = button;
            } else if (buttonCenter.x > blankCenter.x) {
                self.rightButton = button;
            } else if (buttonCenter.y < blankCenter.y) {
                self.upButton = button;
            } else if (buttonCenter.y > blankCenter.y) {
                self.downButton = button;
            }
        }
        
    }
    return nil;
}

/**
 *  点击按钮后相应操作，按照需要移动按钮位置
 */
- (void)refreshButtonClick
{
    [self randomButtons];
//    [self checkStatus];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self checkStatus];
//    });
    self.countLabel.text = @"0";
    self.timeLabel.text = @"00:00";
    self.totalSeconds = 0;
    [self.updateTimer invalidate];
    self.updateTimer = nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self checkStatus];
    });
}

/**
 *  添加具体数字的button
 *
 *  @param number 具体的数字
 */
- (void)addButtonWithNumber:(NSUInteger)number
{
    UIButton *button = [[UIButton alloc] init];
    button.layer.borderColor = ColorBorder;
    button.layer.borderWidth = 1;
    if (number < Dimension * Dimension) {
        button.titleLabel.font = [UIFont systemFontOfSize:30];
        [button setTitle:[NSString stringWithFormat:@"%lu", (unsigned long)number] forState:UIControlStateNormal];
        [button setTitle:[NSString stringWithFormat:@"%lu", (unsigned long)number] forState:UIControlStateHighlighted];
        button.backgroundColor = ColorNormal;
        [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        self.blankButton = button;
    }
    [self.containerView addSubview:button];
}

/**
 *  点击了数字，检查上下左右的按钮如果有空，则移动到对应的位置
 *
 *  @param button 所点击的按钮
 */
- (void)buttonClicked:(UIButton *)button
{
//    NSLog(@"buttonClicked: %@", button.currentTitle);
    // 当前按钮的origin
    CGPoint center = button.center;
    CGPoint blankCenter = self.blankButton.center;
//    UIButton *blankButton;
//    for (UIButton *btn in self.containerView.subviews) {
//        if (btn.currentTitle.length == 0) {
//            blankCenter = btn.center;
//            blankButton = btn;
//            break;
//        }
//    }
//    NSLog(@"button center: %@", NSStringFromCGPoint(center));
//    NSLog(@"blank center: %@", NSStringFromCGPoint(blankCenter));
    
    CGFloat disWidth = ABS(center.x - blankCenter.x);
    CGFloat disHeight =  ABS(center.y - blankCenter.y);
    
    if (disHeight + disWidth <= button.width) {
        if (self.updateTimer == nil) {
            self.updateTimer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(updateTimeLabel) userInfo:nil repeats:YES];
            [[NSRunLoop mainRunLoop] addTimer:self.updateTimer forMode:NSRunLoopCommonModes];
//            [self.updateTimer fire];
        }
        [UIView animateWithDuration:0.1 animations:^{
            CGPoint temp = blankCenter;
            self.blankButton.center = button.center;
            button.center = temp;
            self.countLabel.text = [NSString stringWithFormat:@"%d", self.countLabel.text.intValue + 1];
            [self checkStatus];
        }];
    }
}

- (void)updateTimeLabel
{
    self.totalSeconds++;
    NSUInteger minute = self.totalSeconds / 60;
    NSUInteger second = self.totalSeconds - minute * 60;
    self.timeLabel.text = [NSString stringWithFormat:@"%02lu:%02lu", (unsigned long)minute, (unsigned long)second];
}

/**
 *  检查当前的有效状态
 */
- (void)checkStatus
{
    NSUInteger rightCount = 0;
//    NSLog(@"%zd", self.containerView.subviews.count);
    for (UIButton *button in self.containerView.subviews) {
        int row = button.origin.y / button.width;
        int col = button.origin.x / button.width;
        
        if ([button.currentTitle intValue] == row * Dimension + col + 1) {  // 数字位置正确时
            button.backgroundColor = ColorRight;
            rightCount++;
            if (rightCount == Dimension * Dimension) {
                [self.updateTimer invalidate];
                self.updateTimer = nil;
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:[NSString stringWithFormat:@"用时: %zd秒\n总步数: %@", self.totalSeconds, self.countLabel.text] preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *again = [UIAlertAction actionWithTitle:@"再来一次" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [self randomButtons];
                    [self checkStatus];
                }];
                [alertController addAction:again];
                
                UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"算了" style:UIAlertActionStyleCancel handler:nil];
                [alertController addAction:cancel];
                [self presentViewController:alertController animated:YES completion:nil];
            }
        } else if (button.currentTitle.length == 0){                        // 空白按钮，没有数字时
            button.backgroundColor = ColorClear;
        } else {
            button.backgroundColor = ColorNormal;                           // 位置不正确时候
        }
    }
}




@end
