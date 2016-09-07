//
//  SFSelectionBar.h
//  ScanFloor
//
//  Created by caozhen@neusoft on 16/5/30.
//  Copyright © 2016年 neusoft. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HSTabsView;
@protocol HSTabsViewDataSouce <NSObject>

- (NSInteger)numberOfItemsInTabsView:(HSTabsView *)tabsView;

- (NSString *)tabsView:(HSTabsView *)tabsView itemTitleAtIndex:(NSInteger)index;
- (void)tabsView:(HSTabsView *)tabsView itemDidSelectedAtIndex:(NSInteger)index;

// 每一列对应的子控制器
- (UIViewController *)tabsView:(HSTabsView *)tabsView childViewControllerAtIndex:(NSInteger)index;

@end

@interface HSTabsView : UIView

@property (nonatomic,weak)   id<HSTabsViewDataSouce> dataSource;

@property (nonatomic,strong) UIColor *lineColor;

@property (nonatomic,assign) CGFloat tabsBarHeight;


// 配置信息
- (void)reloadData;

@end
