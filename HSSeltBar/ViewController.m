//
//  ViewController.m
//  HSSeltBar
//
//  Created by caozhen@neusoft on 16/9/6.
//  Copyright © 2016年 Neusoft. All rights reserved.
//

#import "ViewController.h"
#import "HSTabsView.h"
#import "SecondViewController.h"

@interface ViewController () <HSTabsViewDataSouce>
@property (nonatomic,strong) NSArray *titles;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//
    HSTabsView *seltBar = [[HSTabsView alloc]initWithFrame:CGRectMake(0, 100, 414, 500)];
    seltBar.dataSource = self;
    seltBar.lineColor = [UIColor greenColor];
    [self.view addSubview:seltBar];
    seltBar.backgroundColor = [UIColor lightGrayColor];
    [seltBar reloadData];
    
}
- (NSArray *)titles {
    if (!_titles) {
        _titles = @[@"全部",@"新闻",@"社会",@"财经",@"NBA",@"娱乐",@"数码",@"游戏",@"八卦",@"猎奇"];
    }
    return _titles;
}
#pragma mark ---- HSTabsViewDataSouce
- (NSInteger)numberOfItemsInTabsView:(HSTabsView *)tabsView {
    return self.titles.count;

}

- (NSString *)tabsView:(HSTabsView *)tabsView itemTitleAtIndex:(NSInteger)index {
    return self.titles[index];
}


- (void)tabsView:(HSTabsView *)tabsView itemDidSelectedAtIndex:(NSInteger)index {
    NSLog(@"%ld",index);
}

// 每一列对应的子控制器
- (UIViewController *)tabsView:(HSTabsView *)tabsView childViewControllerAtIndex:(NSInteger)index {
    return [[SecondViewController alloc]init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)itemDidSelectedAtIndex:(NSInteger)index {
    NSLog(@"%ld",index);
}
@end
