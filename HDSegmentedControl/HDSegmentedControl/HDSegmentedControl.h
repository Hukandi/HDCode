//
//  HDSegmentedControl.h
//  HDSegmentedControl
//
//  Created by sldc_kdhu on 2018/2/24.
//  Copyright © 2018年 Popeye. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDSegmentedControl : UIControl

- (instancetype)initWithItems:(nullable NSArray *)items;

@property (nonatomic, strong) UIColor *tintColor;

@property (nonatomic, strong) UIColor *normalTitleColor;
@property (nonatomic, strong) UIColor *selectedTitleColor;

@property (nonatomic, strong) UIFont *titleFont;

@property (nonatomic, assign, readonly) NSInteger segmentCount;

@property (nonatomic, assign) NSUInteger selectedSegmentIndex;
- (void)setSelectedSegmentIndex:(NSUInteger)selectedSegmentIndex animated:(BOOL)animated;

- (void)insertSegmentWithTitle:(nullable NSString *)title atIndex:(NSUInteger)segment animated:(BOOL)animated;
- (void)removeSegmentAtIndex:(NSUInteger)segment animated:(BOOL)animated;
- (void)removeAllSegments;

- (void)setTitle:(nullable NSString *)title forSegmentAtIndex:(NSUInteger)segment;
- (nullable NSString *)titleForSegmentAtIndex:(NSUInteger)segment;

- (void)setWidth:(CGFloat)width forSegmentAtIndex:(NSUInteger)segment;
- (CGFloat)widthForSegmentAtIndex:(NSUInteger)segment;

@end

NS_ASSUME_NONNULL_END
