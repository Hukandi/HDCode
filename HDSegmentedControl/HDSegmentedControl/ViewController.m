//
//  ViewController.m
//  HDSegmentedControl
//
//  Created by sldc_kdhu on 2018/2/24.
//  Copyright © 2018年 Popeye. All rights reserved.
//

#import "ViewController.h"

#import "HDSegmentedControl.h"

@interface ViewController ()

@property (nonatomic, strong) HDSegmentedControl *sc;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor redColor];
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    
    self.sc = [[HDSegmentedControl alloc] initWithItems:@[@"动态", @"附近"]];
    self.sc.frame = CGRectMake(80, 70, screenSize.width-160, 40);
    [self.sc addTarget:self action:@selector(segmentedControlDidChangeSelectedIndex) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.sc];

    UIButton *insertSegment = [UIButton buttonWithType:UIButtonTypeCustom];
    insertSegment.backgroundColor = [UIColor blackColor];
    insertSegment.frame = CGRectMake(100, 130, 120, 40);
    [insertSegment setTitle:@"insert" forState:UIControlStateNormal];
    [insertSegment addTarget:self action:@selector(insert) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:insertSegment];
    
    UIButton *removeSegment = [UIButton buttonWithType:UIButtonTypeCustom];
    removeSegment.backgroundColor = [UIColor blackColor];
    removeSegment.frame = CGRectMake(100, 180, 120, 40);
    [removeSegment setTitle:@"remove" forState:UIControlStateNormal];
    [removeSegment addTarget:self action:@selector(remove) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:removeSegment];
    
    UIButton *removeAllSegment = [UIButton buttonWithType:UIButtonTypeCustom];
    removeAllSegment.backgroundColor = [UIColor blackColor];
    removeAllSegment.frame = CGRectMake(100, 230, 120, 40);
    [removeAllSegment setTitle:@"removeAll" forState:UIControlStateNormal];
    [removeAllSegment addTarget:self action:@selector(removeAll) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:removeAllSegment];
    
    UIButton *titleSegment = [UIButton buttonWithType:UIButtonTypeCustom];
    titleSegment.backgroundColor = [UIColor blackColor];
    titleSegment.frame = CGRectMake(100, 280, 120, 40);
    [titleSegment setTitle:@"changeTitle" forState:UIControlStateNormal];
    [titleSegment addTarget:self action:@selector(changeTitle) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:titleSegment];
    
    UIButton *widthSegment = [UIButton buttonWithType:UIButtonTypeCustom];
    widthSegment.backgroundColor = [UIColor blackColor];
    widthSegment.frame = CGRectMake(100, 330, 120, 40);
    [widthSegment setTitle:@"changeWidth" forState:UIControlStateNormal];
    [widthSegment addTarget:self action:@selector(changeWidth) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:widthSegment];
}

- (void)segmentedControlDidChangeSelectedIndex
{
    NSLog(@"selectedIndex : %@", @(self.sc.selectedSegmentIndex));
}

- (void)insert
{
    [self.sc insertSegmentWithTitle:@"单曲" atIndex:0 animated:YES];
}

- (void)remove
{
    [self.sc removeSegmentAtIndex:0 animated:YES];
}

- (void)removeAll
{
    [self.sc removeAllSegments];
}

- (void)changeTitle
{
    [self.sc setTitle:@"节目" forSegmentAtIndex:0];
    NSLog(@"title %@", [self.sc titleForSegmentAtIndex:self.sc.segmentCount-1]);
}

- (void)changeWidth
{
    [self.sc setWidth:120 forSegmentAtIndex:0];
    NSLog(@"width %@", @([self.sc widthForSegmentAtIndex:self.sc.segmentCount-1]));
}

@end
