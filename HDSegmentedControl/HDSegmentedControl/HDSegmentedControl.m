//
//  HDSegmentedControl.m
//  HDSegmentedControl
//
//  Created by sldc_kdhu on 2018/2/24.
//  Copyright © 2018年 Popeye. All rights reserved.
//

#import "HDSegmentedControl.h"

NS_ASSUME_NONNULL_BEGIN

#define kAnimationDuration  0.3

@interface HDSegmentedControl()

@property (nonatomic, strong) UIView *sliderView;

@property (nonatomic, strong) NSMutableArray <UILabel *>*lowerSegments;
@property (nonatomic, strong) NSMutableArray <UILabel *>*upperSegments;

@property (nonatomic, strong) NSMutableDictionary <NSNumber *, NSNumber *>*segmentWidths;
@property (nonatomic, strong) NSMutableDictionary <NSNumber *, NSNumber *>*customSegmentWidths;

@property (nonatomic, assign) CGFloat sliderViewPanBeganLeft;

@end

@implementation HDSegmentedControl

- (instancetype)initWithItems:(nullable NSArray *)items
{
    self = [super init];
    if (self) {
        self.clipsToBounds = YES;
        
        self.tintColor = [UIColor redColor];
        self.normalTitleColor = [UIColor whiteColor];
        self.titleFont = [UIFont systemFontOfSize:15];
        
        self.selectedSegmentIndex = 0;
        
        self.sliderView = [[UIView alloc] init];
        self.sliderView.backgroundColor = self.normalTitleColor;
        self.sliderView.clipsToBounds = YES;
        [self addSubview:self.sliderView];
        
        [self buildSegments:items];
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(sliderViewDidDrage:)];
        [self addGestureRecognizer:panGesture];
    }
    return self;
}

- (void)layoutSubviews
{
    [self layoutLowerSegments];
    
    [self layoutSliderView];
}

- (void)layoutLowerSegments
{
    __block CGFloat left = 0;
    
    [self.lowerSegments enumerateObjectsUsingBlock:^(UILabel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat segmentWidth = [[self.segmentWidths objectForKey:@(idx)] floatValue];
        
        obj.frame = CGRectMake(left, 0, segmentWidth, self.frame.size.height);
        
        left += segmentWidth;
    }];
}

- (void)layoutSliderView
{
    self.sliderView.frame = CGRectMake([self sliderViewLeft], 
                                       0,
                                       [self selectedSegmentWith],
                                       self.frame.size.height);
    
    [self layoutUpperSegments];
}

- (void)layoutUpperSegments
{
    __block CGFloat left = -self.sliderView.frame.origin.x;
    [self.upperSegments enumerateObjectsUsingBlock:^(UILabel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat sliderViewTop = self.sliderView.frame.origin.y;
        CGFloat segmentWidth = [[self.segmentWidths objectForKey:@(idx)] floatValue];
        
        obj.frame = CGRectMake(left, -sliderViewTop, segmentWidth, self.frame.size.height);
        
        left += segmentWidth;
    }];
}

- (void)buildSegments:(NSArray *)segments
{
    if (segments.count <= 0) {return;}
    
    self.lowerSegments = [NSMutableArray arrayWithCapacity:segments.count];
    self.upperSegments = [NSMutableArray arrayWithCapacity:segments.count];
    
    [segments enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {        
        [self.lowerSegments insertObject:[self creatLowerSegmentWithTitle:obj animated:NO]
                                 atIndex:idx];
        [self.upperSegments insertObject:[self creatUpperSegmentWithTitle:obj]
                                 atIndex:idx];
    }];
}

#pragma mark - Auction

- (void)onDidTapSegment:(UITapGestureRecognizer *)gesture
{
    UILabel *segment = (UILabel *)gesture.view;
    if (!segment) {return;}
    
    NSInteger selectedIndex = [self.lowerSegments indexOfObject:segment];
    [self setSelectedSegmentIndex:selectedIndex animated:YES];
}

#pragma mark -

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    self.layer.cornerRadius = frame.size.height/2;
    self.layer.borderWidth = 1;
    
    [self buildSegmentWidths];
    
    self.sliderView.frame = CGRectMake([self sliderViewLeft], 0, [self selectedSegmentWith], self.frame.size.height);
    self.sliderView.layer.cornerRadius = frame.size.height/2;
}

- (void)setTintColor:(UIColor *)tintColor
{
    if (_tintColor != tintColor) {
        _tintColor = tintColor;
        
        self.backgroundColor = _tintColor;
        self.selectedTitleColor = _tintColor;
    }
}

- (void)setNormalTitleColor:(UIColor *)normalTitleColor
{
    if (_normalTitleColor != normalTitleColor) {
        _normalTitleColor = normalTitleColor;
        
        [self.lowerSegments enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            UILabel *segment = (UILabel *)obj;
            segment.textColor = _normalTitleColor;
        }];
        
        self.sliderView.backgroundColor = _normalTitleColor;
        self.layer.borderColor = self.normalTitleColor.CGColor;
    }
}

- (void)setSelectedTitleColor:(UIColor *)selectedTitleColor
{
    if (_selectedTitleColor != selectedTitleColor) {
        _selectedTitleColor = selectedTitleColor;
        
        [self.upperSegments enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            UILabel *segment = (UILabel *)obj;
            segment.textColor = _selectedTitleColor;
        }];
    }
}

- (void)setTitleFont:(UIFont *)titleFont
{
    if (_titleFont != titleFont) {
        _titleFont = titleFont;
        
        [self.lowerSegments enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            UILabel *segment = (UILabel *)obj;
            segment.font = _titleFont;
        }];
        
        [self.upperSegments enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            UILabel *segment = (UILabel *)obj;
            segment.font = _titleFont;
        }];
    }
}

- (void)setSelectedSegmentIndex:(NSUInteger)selectedSegmentIndex
{
    [self setSelectedSegmentIndex:selectedSegmentIndex animated:NO];
}

- (void)setSelectedSegmentIndex:(NSUInteger)selectedSegmentIndex animated:(BOOL)animated
{
    selectedSegmentIndex = MAX(selectedSegmentIndex, 0);
    selectedSegmentIndex = MIN(selectedSegmentIndex, self.lowerSegments.count-1);
    
    if (_selectedSegmentIndex != selectedSegmentIndex) {
        _selectedSegmentIndex = selectedSegmentIndex;
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
    
    if (animated) {
        [UIView animateWithDuration:kAnimationDuration animations:^{
            [self layoutSliderView];
        }];
    }
    else {
        [self layoutSliderView];
    }
}

- (NSInteger)segmentCount
{
    return self.lowerSegments.count;
}

#pragma mark - touches

- (void)sliderViewDidDrage:(UIPanGestureRecognizer *)panGesture
{
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            self.sliderViewPanBeganLeft = self.sliderView.frame.origin.x;
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGPoint translationPoint = [panGesture translationInView:self];
            
            CGFloat left = self.sliderViewPanBeganLeft + translationPoint.x;
            left = MAX(left, 0);
            left = MIN(left, self.frame.size.width-self.sliderView.frame.size.width);

            self.sliderView.frame = CGRectMake(left,
                                               self.sliderView.frame.origin.y,
                                               self.sliderView.frame.size.width,
                                               self.sliderView.frame.size.height);
            
        }
            break;
            
        case UIGestureRecognizerStateEnded:
        {
            __block NSInteger index = 0;
            [self.lowerSegments enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                UIView *lowerSegment = (UIView *)obj;
                if (CGRectContainsPoint(lowerSegment.frame, self.sliderView.center)) {
                    index = idx;
                }
            }];
            
            [self setSelectedSegmentIndex:index animated:YES];
        }
            break;
        case UIGestureRecognizerStateCancelled:
        default:
        {
            self.sliderView.frame = CGRectMake([self sliderViewLeft],
                                               self.sliderView.frame.origin.y,
                                               [self selectedSegmentWith],
                                               self.sliderView.frame.size.height);
            
            
        }
            break;
    }
    
    [self layoutUpperSegments];
}

#pragma mark - Private

- (UILabel *)creatUpperSegmentWithTitle:(NSString *)title
{
    UILabel *segment = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, self.frame.size.height)];
    segment.textAlignment = NSTextAlignmentCenter;
    segment.text = title;
    segment.textColor = self.selectedTitleColor;
    segment.font = self.titleFont;
    
    [self.sliderView addSubview:segment];
    
    return segment;
}

- (UILabel *)creatLowerSegmentWithTitle:(NSString *)title animated:(BOOL)animated
{
    UILabel *segment = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, self.frame.size.height)];
    segment.textAlignment = NSTextAlignmentCenter;
    segment.text = title;
    segment.textColor = self.normalTitleColor;
    segment.font = self.titleFont;
    segment.userInteractionEnabled = YES;
    
    if (animated) {
        [self animateWithBlock:^{
            [self addSubview:segment];
        }];
    }
    else {
        [self addSubview:segment];
    }
    
    [self bringSubviewToFront:self.sliderView];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onDidTapSegment:)];
    [segment addGestureRecognizer:tapGesture];
    
    return segment;
}

- (void)buildSegmentWidths
{
    if (self.lowerSegments.count <= 0) {
        [self.segmentWidths removeAllObjects];
        [self.customSegmentWidths removeAllObjects];
        return;
    }
    
    __block CGFloat othersWidth = self.frame.size.width;
    CGFloat segmentDefaultWidth = othersWidth / self.lowerSegments.count;
    
    [self.customSegmentWidths enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, NSNumber * _Nonnull obj, BOOL * _Nonnull stop) {
        othersWidth -= [obj doubleValue];
    }];
    segmentDefaultWidth = othersWidth / (self.lowerSegments.count - self.customSegmentWidths.allKeys.count);
    
    self.segmentWidths = [NSMutableDictionary dictionaryWithCapacity:self.lowerSegments.count];
    [self.lowerSegments enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.segmentWidths setObject:@(segmentDefaultWidth) forKey:@(idx)];
    }];
    
    if (self.customSegmentWidths.allKeys.count > 0) {
        [self.customSegmentWidths enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [self.segmentWidths setObject:obj forKey:key];
        }];
    }
}

- (CGFloat)selectedSegmentWith
{
    if (self.segmentWidths <= 0 || self.selectedSegmentIndex >= self.segmentWidths.count) {return 0;}
    
    return [[self.segmentWidths objectForKey:@(self.selectedSegmentIndex)] doubleValue];
}

- (CGFloat)sliderViewLeft
{
    __block CGFloat left = 0;
    
    NSArray *allKeys = [self.segmentWidths.allKeys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [@([obj1 integerValue]) compare:@([obj2 integerValue])];
    }];
    
    [allKeys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (idx >= self.selectedSegmentIndex) {
            *stop = YES;
        }
        else {
            left += [[self.segmentWidths objectForKey:obj] doubleValue];
        }
    }];
    
    left = MAX(left, 0);
    left = MIN(left, self.frame.size.width-[allKeys.lastObject doubleValue]);
    return left;
}

- (void)animateWithBlock:(void (^)(void))block
{
    [UIView transitionWithView:self
                      duration:kAnimationDuration
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:block
                    completion:nil];
    
}

#pragma mark - Public

- (void)insertSegmentWithTitle:(nullable NSString *)title atIndex:(NSUInteger)segment animated:(BOOL)animated
{
    if (!title || segment > self.lowerSegments.count) {return;}
    
    UILabel *beforeInsertingTheSelectedSegment = nil;
    if (self.lowerSegments.count > 0 && self.selectedSegmentIndex < self.lowerSegments.count) {
        beforeInsertingTheSelectedSegment = [self.lowerSegments objectAtIndex:self.selectedSegmentIndex];
    }
    
    [self.lowerSegments insertObject:[self creatLowerSegmentWithTitle:title animated:animated]
                             atIndex:segment];
    [self.upperSegments insertObject:[self creatUpperSegmentWithTitle:title]
                             atIndex:segment];
    
    if (beforeInsertingTheSelectedSegment && [self.lowerSegments containsObject:beforeInsertingTheSelectedSegment]) {
        [self setSelectedSegmentIndex:[self.lowerSegments indexOfObject:beforeInsertingTheSelectedSegment]
                             animated:animated];
    }
    else {
        [self setSelectedSegmentIndex:0 animated:animated];
    }
    
    [self buildSegmentWidths];
    
    [self setNeedsLayout];
}

- (void)removeSegmentAtIndex:(NSUInteger)segment animated:(BOOL)animated
{
    if (segment >= self.upperSegments.count) {return;}
    
    UILabel *beforeRemovingTheSelectedSegment = nil;
    if (self.lowerSegments.count > 0 && self.selectedSegmentIndex < self.lowerSegments.count) {
        beforeRemovingTheSelectedSegment = [self.lowerSegments objectAtIndex:self.selectedSegmentIndex];
    }
    
    UILabel *lowerSegment = [self.lowerSegments objectAtIndex:segment];
    UILabel *upperSegment = [self.upperSegments objectAtIndex:segment];
    
    if (animated) {
        [self animateWithBlock:^{
            [upperSegment removeFromSuperview];
            [lowerSegment removeFromSuperview];
        }];
    }
    else {
        [upperSegment removeFromSuperview];
        [lowerSegment removeFromSuperview];
    }
    
    [self.upperSegments removeObjectAtIndex:segment];
    [self.lowerSegments removeObjectAtIndex:segment];
    
    if (beforeRemovingTheSelectedSegment && [self.lowerSegments containsObject:beforeRemovingTheSelectedSegment]) {
        [self setSelectedSegmentIndex:[self.lowerSegments indexOfObject:beforeRemovingTheSelectedSegment]
                             animated:animated];
    }
    else {
        [self setSelectedSegmentIndex:0 animated:animated];
    }
    
    [self buildSegmentWidths];
    
    [self setNeedsLayout];
}

- (void)removeAllSegments
{
    [self.upperSegments enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    
    [self.lowerSegments enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    
    [self.upperSegments removeAllObjects];
    [self.lowerSegments removeAllObjects];
    [self.segmentWidths removeAllObjects];
    [self.customSegmentWidths removeAllObjects];
    
    self.selectedSegmentIndex = 0;
    
    [self buildSegmentWidths];
    
    [self setNeedsLayout];
}

- (void)setTitle:(nullable NSString *)title forSegmentAtIndex:(NSUInteger)segment
{
    if (!title || segment >= self.upperSegments.count) {return;}
    
    UILabel *upperSegment = [self.upperSegments objectAtIndex:segment];
    UILabel *lowerSegment = [self.lowerSegments objectAtIndex:segment];
    
    upperSegment.text = title;
    lowerSegment.text = title;
}

- (nullable NSString *)titleForSegmentAtIndex:(NSUInteger)segment
{
    if (segment >= self.upperSegments.count) {return nil;}
    
    UILabel *lowerSegment = [self.lowerSegments objectAtIndex:segment];
    return lowerSegment.text;
}

- (void)setWidth:(CGFloat)width forSegmentAtIndex:(NSUInteger)segment
{
    if (width < 0 || width > self.frame.size.width || segment > self.segmentWidths.count) {return;}
    
    if (!self.customSegmentWidths) {
        self.customSegmentWidths = [NSMutableDictionary dictionary];
    }
    [self.customSegmentWidths setObject:@(width) forKey:@(segment)];
    
    [self buildSegmentWidths];
    
    [self setNeedsLayout];
}

- (CGFloat)widthForSegmentAtIndex:(NSUInteger)segment
{
    if (segment >= self.segmentWidths.count) {return 0;}
    
    return [[self.segmentWidths objectForKey:@(segment)] doubleValue];
}

@end

NS_ASSUME_NONNULL_END
