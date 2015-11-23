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
#import "Const.h"


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

@property (nonatomic, assign) NSUInteger dimension;         // 方阵的行数
@property (nonatomic, assign, readonly) CGFloat side;                 // 边长

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self setDimension:5];
    
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
//    [self randomButtons];
}

- (void)setDimension:(NSUInteger)dimension
{
    _dimension = dimension;
    
    _side = ScreenW / dimension;
    
    self.containerView.dimension = dimension;
}

/**
 *  在显示之前设置正确的颜色
 */
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self randomButtons];
    [self checkStatus];
}

/**
 *  创建所有按钮
 */
- (void)setupButtons
{
    for (NSUInteger i = 1; i <= self.dimension * self.dimension; i++) {
        [self addButtonWithNumber:i];
    }
}

/**
 *  打乱所有按钮
 */
- (void)randomButtons
{
    // 空白按钮随机四个方向走100步，数值可以变动
    for (int i = 0; i < 100; i++) {
        BlankMoveDirection direction = arc4random_uniform(4);
        UIButton *button = [self getButtonWithDirection:direction];
        if (button == nil) continue;
        
        CGPoint temp = self.blankButton.center;
        self.blankButton.center = button.center;
        button.center = temp;

        [self checkStatus];
    }
    
}

#pragma mark - 获取空白按钮的上下左右四个方向的按钮
- (UIButton *)getButtonWithDirection:(BlankMoveDirection)moveDirection
{
    CGPoint blankCenter = self.blankButton.center;
    CGPoint upCenter = CGPointMake(blankCenter.x, blankCenter.y - self.side);
    CGPoint leftCenter = CGPointMake(blankCenter.x - self.side, blankCenter.y);
    CGPoint downCenter = CGPointMake(blankCenter.x, blankCenter.y + self.side);
    CGPoint rightCenter = CGPointMake(blankCenter.x + self.side, blankCenter.y);
    
    switch (moveDirection) {
        case BlankMoveDirectionUp:
        {
            for (UIButton *button in self.containerView.subviews) {
                if (CGRectContainsPoint(button.frame, upCenter)) {
                    return button;
                }
            }
        }
            break;
        case BlankMoveDirectionLeft:
        {
            for (UIButton *button in self.containerView.subviews) {
                if (CGRectContainsPoint(button.frame, leftCenter)) {
                    return button;
                }
            }
        }
            break;
        case BlankMoveDirectionDown:
        {
            for (UIButton *button in self.containerView.subviews) {
                if (CGRectContainsPoint(button.frame, downCenter)) {
                    return button;
                }
            }
        }
            break;
        case BlankMoveDirectionRight:
        {
            for (UIButton *button in self.containerView.subviews) {
                if (CGRectContainsPoint(button.frame, rightCenter)) {
                    return button;
                }
            }
        }
            break;
            
        default:
            break;
    }
    
    return nil;
}

/**
 *  点击按钮后相应操作，按照需要移动按钮位置
 */
- (void)refreshButtonClick
{
    [self randomButtons];
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
    if (number < self.dimension * self.dimension) {
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
    CGPoint center = button.center;
    CGPoint blankCenter = self.blankButton.center;
    
    CGFloat disWidth = ABS(center.x - blankCenter.x);
    CGFloat disHeight =  ABS(center.y - blankCenter.y);
    
    if (disHeight + disWidth <= self.side + 4) {
        if (self.updateTimer == nil) {
            self.updateTimer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(updateTimeLabel) userInfo:nil repeats:YES];
            [[NSRunLoop mainRunLoop] addTimer:self.updateTimer forMode:NSRunLoopCommonModes];
        }
        [UIView animateWithDuration:0.1 animations:^{
            CGPoint temp = blankCenter;
            self.blankButton.center = button.center;
            button.center = temp;
        }];
        self.countLabel.text = [NSString stringWithFormat:@"%d", self.countLabel.text.intValue + 1];
        [self checkStatus];
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

    for (UIButton *button in self.containerView.subviews) {
        int row = button.origin.y / self.side;
        int col = button.origin.x / self.side;
        
        if ([button.currentTitle intValue] == row * self.dimension + col + 1) {  // 数字位置正确时
            button.backgroundColor = ColorRight;
            rightCount++;
            if (rightCount == self.dimension * self.dimension - 1) {
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
                [self presentViewController:alertController animated:YES completion:^{
                    self.timeLabel.text = @"00:00";
                    self.countLabel.text = @"0";
                }];
            }
        } else if (button.currentTitle.length == 0){                        // 空白按钮，没有数字时
            button.backgroundColor = ColorClear;
        } else {
            button.backgroundColor = ColorNormal;                           // 位置不正确时候
        }
    }
}




@end
