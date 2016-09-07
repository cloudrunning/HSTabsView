//
//  SFSelectionBar.m
//  ScanFloor
//
//  Created by caozhen@neusoft on 16/5/30.
//  Copyright © 2016年 neusoft. All rights reserved.
//

#import "HSTabsView.h"
@interface HSTabsView ()

@property (nonatomic,strong) UIScrollView *tabsBarScrollView;
@property (nonatomic,strong) UIView *tabsBarContentView;

@property (nonatomic,strong) UIScrollView *vcScrollView;
@property (nonatomic,strong) UIView *vcContentView;

@property (nonatomic,strong) UIView *bottomLine;

@property (nonatomic,strong) NSMutableArray *itemsWidths;
@property (nonatomic,strong) NSMutableArray *controllers;

@property (nonatomic,assign) NSInteger lastIndex; // 当前选中
@property (nonatomic,strong) NSMutableArray<UIButton *> *items;

@end
static const CGFloat halfSpacing = 15.0;
@implementation HSTabsView

- (NSMutableArray *)items {
    if (!_items) {
        _items = [[NSMutableArray alloc]init];
    }
    return _items;
}

- (NSMutableArray *)itemsWidths {
    if (!_itemsWidths) {
        _itemsWidths = [[NSMutableArray alloc]init];
    }
    return _itemsWidths;
}

- (NSMutableArray *)controllers {
    if (!_controllers) {
        _controllers = [[NSMutableArray alloc]init];
    }
    return _controllers;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.tabsBarHeight = 44;
        
        self.tabsBarScrollView = [[UIScrollView alloc]init];
        self.tabsBarScrollView .showsHorizontalScrollIndicator = NO;
        [self addSubview:self.tabsBarScrollView ];
        
        self.tabsBarContentView = [[UIView alloc]init];
        [self.tabsBarScrollView addSubview:self.tabsBarContentView];
        
        
        
        self.vcScrollView = [[UIScrollView alloc]init];
        self.vcScrollView .showsHorizontalScrollIndicator = NO;
        [self addSubview:self.vcScrollView ];
        self.vcScrollView.pagingEnabled = YES;
        
        self.vcContentView = [[UIView alloc]init];
        [self.vcScrollView addSubview:self.vcContentView];

    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat selfWidth = self.bounds.size.width;
    CGFloat selfHeight = self.bounds.size.height;
    
    self.tabsBarScrollView.frame = CGRectMake(0, 0, selfWidth, self.tabsBarHeight);
    self.tabsBarContentView.frame = CGRectMake(0, 0, selfWidth, self.tabsBarHeight);
    
    self.vcScrollView.frame = CGRectMake(0, self.tabsBarHeight, selfWidth, self.bounds.size.height - self.tabsBarHeight);
    self.vcContentView.frame = CGRectMake(0, 0, selfWidth * self.controllers.count, selfHeight - self.tabsBarHeight);
    
    
    UIButton *lastItem = nil;
    for (int i = 0; i < self.items.count; i++) {
        UIButton *item = self.items[i];
        CGFloat width = [self.itemsWidths[i] floatValue];
        
        CGFloat itemX = lastItem?CGRectGetMaxX(lastItem.frame):0;
        CGFloat itemW = width + 2 * halfSpacing;
        CGFloat itemH = self.tabsBarHeight;
        
        item.frame = CGRectMake(itemX, 0, itemW, itemH);
        lastItem = item;
    }
    
    for (int i = 0; i < self.controllers.count; i++) {
        UIViewController *vc = self.controllers[i];
        vc.view.frame = CGRectMake(i * selfWidth, 0, selfWidth, selfHeight - self.tabsBarHeight);
    }
    
    CGRect rect = self.tabsBarContentView.frame;
    rect.size.width = CGRectGetMaxX(lastItem.frame);
    self.tabsBarContentView.frame = rect;
    
    CGFloat firstItemWidth = [self.itemsWidths[0] floatValue];
    self.bottomLine.frame = CGRectMake(halfSpacing,self.tabsBarHeight - 3, firstItemWidth, 3);
    // 默认选中第一个
    [self itemClick:self.items[0]];
}


- (void)reloadData{
    
    // 清空旧数据和旧子控件
    [self.itemsWidths removeAllObjects];
    [self.items removeAllObjects];
    [self.controllers removeAllObjects];
    [self.tabsBarContentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];

    if (![self.dataSource respondsToSelector:@selector(numberOfItemsInTabsView:)]) {
        @throw [NSException exceptionWithName:@"HSError" reason:@"numberOfItemsInTabsView:没有实现" userInfo:nil];
        
    }
    
    if (![self.dataSource respondsToSelector:@selector(tabsView:itemTitleAtIndex:)]) {
        @throw [NSException exceptionWithName:@"HSError" reason:@"tabsView:itemTitleAtIndex:没有实现" userInfo:nil];
        
    }
    
    if (![self.dataSource respondsToSelector:@selector(tabsView:itemTitleAtIndex:)]) {
        @throw [NSException exceptionWithName:@"HSError" reason:@"tabsView:itemTitleAtIndex:没有实现" userInfo:nil];
        
    }
    
    if (![self.dataSource respondsToSelector:@selector(tabsView:childViewControllerAtIndex:)]) {
        @throw [NSException exceptionWithName:@"HSError" reason:@"tabsView:childViewControllerAtIndex:没有实现" userInfo:nil];
        
    }
    
    NSInteger itemsCnt = [self.dataSource numberOfItemsInTabsView:self];
    
    if (itemsCnt <= 0) return;

    
    // 添加新数据和子控件
    for (int i = 0; i < itemsCnt; i++) {
        NSString *title = [self.dataSource tabsView:self itemTitleAtIndex:i];
        
        CGFloat itemWidth = [self itemWidthWithTitle:title];
        [self.itemsWidths addObject:@(itemWidth)];
        
        UIButton *btnItem = [self createItemWithTitle:title];
        [self.tabsBarContentView addSubview:btnItem];
        [self.items addObject:btnItem];
        
        UIViewController *vc = [self.dataSource tabsView:self childViewControllerAtIndex:i];
        if (!vc) {
            @throw [NSException exceptionWithName:@"HSError" reason:@"tabsView:childViewControllerAtIndex:不能返回nil" userInfo:nil];
        }
        [self.vcContentView addSubview:vc.view];
        [self.controllers addObject:vc];
    }
    self.bottomLine = [UIView new];
    self.bottomLine.backgroundColor = self.lineColor;
    [self.tabsBarContentView addSubview:_bottomLine];
    
}

- (void)setLastIndex:(NSInteger)lastIndex {
    _lastIndex = lastIndex;
    UIButton *button = self.items[lastIndex];
    CGFloat scrollWidth = self.tabsBarScrollView.frame.size.width;
    CGFloat centerX     = button.center.x;
    
    if (centerX < scrollWidth * 0.5 ) {
        [self.tabsBarScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    }else if (centerX > self.tabsBarContentView.frame.size.width - scrollWidth * 0.5){
        [self.tabsBarScrollView setContentOffset:CGPointMake(self.tabsBarContentView.frame.size.width-scrollWidth, 0) animated:YES];
    }else{
        CGFloat offsetX = centerX - scrollWidth*0.5;
        [self.tabsBarScrollView setContentOffset:CGPointMake(offsetX, 0) animated:YES];

    }
    
    //下划线的偏移量
    [UIView animateWithDuration:0.1f animations:^{
        
        CGFloat lineViewX = button.frame.origin.x + halfSpacing;
        CGFloat lineViewW = [self.itemsWidths[lastIndex] floatValue];
        
        CGRect rect = self.bottomLine.frame;
        rect.origin.x = lineViewX;
        rect.size.width = lineViewW;
        self.bottomLine.frame = rect;
    }];
}

- (UIButton *)createItemWithTitle:(NSString *)title{
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:16];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateSelected];        [button addTarget:self action:@selector(itemClick:) forControlEvents:UIControlEventTouchUpInside];
    return button;
    
}

- (void)itemClick:(UIButton *)btn{
    
    if (!btn.selected) {
        
        btn.selected = YES;

        // 当前item字体变大,lastItem变小
        UIFont *font = btn.titleLabel.font;
        CGFloat fontSize = font.pointSize;
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            btn.titleLabel.font = [UIFont fontWithName:font.fontName size:fontSize+2];
        } completion:NULL];
        
        for (UIButton *item in self.items) {
            if (item == btn) continue;
            item.titleLabel.font = font;
            item.selected = NO;
        }
        
        self.lastIndex = [self.items indexOfObject:btn];
        
        [self.vcScrollView setContentOffset:CGPointMake(self.lastIndex * self.bounds.size.width, 0) animated:NO];
        
        if (self.dataSource) {
            [self.dataSource tabsView:self itemTitleAtIndex:self.lastIndex];
        }
    }
}
- (CGFloat)itemWidthWithTitle:(NSString *)title {
    
    CGSize size = [title boundingRectWithSize:CGSizeMake(MAXFLOAT, 0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]} context:NULL].size;
    
    return size.width;
}

@end
