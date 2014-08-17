//
//  ViewController.m
//  WaterViewDemo
//
//  Created by zhangbin on 14-8-17.
//  Copyright (c) 2014年 Z&B. All rights reserved.
//

#import "ViewController.h"
#import "ZBFlowView.h"
#import "ZBWaterView.h"

@interface TestData : NSObject

@property (nonatomic,strong) UIColor *color;
@property (nonatomic,assign) CGFloat height;

@end

@implementation TestData

@end

@interface ViewController ()<ZBWaterViewDatasource,ZBWaterViewDelegate>
{
    NSMutableArray *_testDataArr;
    ZBWaterView *_waterView;
}
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    _waterView = [[ZBWaterView alloc]  initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
    _waterView.waterDataSource = self;
    _waterView.waterDelegate = self;
    _waterView.isDataEnd = NO;
    [self.view addSubview:_waterView];
    
    //config test data
    _testDataArr = [NSMutableArray array];
    for (int i=0; i<20; i++) {
        TestData *data = [[TestData alloc] init];
        data.color = [UIColor colorWithRed:arc4random()%255/255.0 green:arc4random()%255/255.0 blue:arc4random()%255/255.0 alpha:1.0];
        data.height = arc4random()%300;
        [_testDataArr addObject:data];
    }
    
    [_waterView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ZBWaterViewDatasource
- (NSInteger)numberOfFlowViewInWaterView:(ZBWaterView *)waterView
{
    return [_testDataArr count];
}

- (CustomWaterInfo *)infoOfWaterView:(ZBWaterView*)waterView
{
    CustomWaterInfo *info = [[CustomWaterInfo alloc] init];
    info.topMargin = 0;
    info.leftMargin = 10;
    info.bottomMargin = 0;
    info.rightMargin = 10;
    info.horizonPadding = 5;
    info.veticalPadding = 5;
    info.numOfColumn = 2;
    return info;
}

- (ZBFlowView *)waterView:(ZBWaterView *)waterView flowViewAtIndex:(NSInteger)index
{
    TestData *data = [_testDataArr objectAtIndex:index];
    ZBFlowView *flowView = [waterView dequeueReusableCellWithIdentifier:@"cell"];
    if (flowView == nil) {
        flowView = [[ZBFlowView alloc] initWithFrame:CGRectZero];
        flowView.reuseIdentifier = @"cell";
    }
    flowView.index = index;
    flowView.backgroundColor = data.color;
    
    return flowView;
}

- (CGFloat)waterView:(ZBWaterView *)waterView heightOfFlowViewAtIndex:(NSInteger)index
{
    TestData *data = [_testDataArr objectAtIndex:index];
    return data.height;
}


#pragma mark - ZBWaterViewDelegate
- (void)needLoadMoreByWaterView:(ZBWaterView *)waterView;
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [NSThread sleepForTimeInterval:2.0];
        for (int i=0; i<20; i++) {
            TestData *data = [[TestData alloc] init];
            data.color = [UIColor colorWithRed:arc4random()%255/255.0 green:arc4random()%255/255.0 blue:arc4random()%255/255.0 alpha:1.0];
            data.height = arc4random()%300;
            [_testDataArr addObject:data];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [_waterView endLoadMore];
            [_waterView reloadData];
        });
    });
}

- (void)phoneWaterViewDidScroll:(ZBWaterView *)waterView
{
    //do what you want to do
    return;
}

- (void)waterView:(ZBWaterView *)waterView didSelectAtIndex:(NSInteger)index
{
    NSLog(@"didSelectAtIndex%d",index);
}

@end
