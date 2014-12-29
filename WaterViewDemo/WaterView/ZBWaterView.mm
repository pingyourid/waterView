//
//  PhoneWaterView.m
//  
//
//  Created by zhangbin on 14-6-12.
//  Copyright (c) 2014年 zhangbin. All rights reserved.
//

#import "ZBWaterView.h"
#import "UIScrollView+LoadingMore.h"
#include <vector>
using namespace std;

#define UI_SCREEN_HEIGHT            ([[UIScreen mainScreen] bounds].size.height)
#define UI_SCREEN_WIDTH             ([[UIScreen mainScreen] bounds].size.width)
#define BottomLineHeight            (self.contentOffset.y-self.waterInfo.topMargin+self.frame.size.height)
#define TopLineHeight               (self.contentOffset.y-self.waterInfo.topMargin)

@interface TopEntity : NSObject

@property (nonatomic, assign) CGPoint point;
@property (nonatomic, assign) NSInteger index;

@end

@implementation TopEntity

@end


@implementation CustomWaterInfo

@end

@interface ZBWaterView()<ZBFlowViewDelegate>
{
    UIView *_footView;                              //加载更多视图
    NSMutableArray *_visibleViews;                  //可见视图
    vector<CGPoint> _bottomDrawPointVector;         //底部绘制点
    vector<TopEntity *> _topEntityVector;           //上部绘制点
    vector<CGPoint *> _simulatePointVector;         //模拟绘制指针
	NSMutableDictionary *_reusedViews;              //可重用视图
    NSMutableDictionary *_resHeightDic;             //绘制视图高度
    NSRange _topRange;                              //上部范围
    NSRange _visibleRange;                          //可见范围
    CGFloat _resWidth;                              //视图宽度
}
@end

@implementation ZBWaterView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.delegate = self;
        self.backgroundColor = [UIColor whiteColor];
        self.isDataEnd = YES;
    }
    return self;
}

- (void)dealloc
{
    [self clearVector];
}

#pragma mark - Inside
- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier
{
    if (!identifier || identifier == 0 ) return nil;
    
    NSArray *cellsWithIndentifier = [NSArray arrayWithArray:[_reusedViews objectForKey:identifier]];
    if (cellsWithIndentifier &&  cellsWithIndentifier.count > 0)
    {
        ZBFlowView *flowView = [cellsWithIndentifier lastObject];
        [[_reusedViews objectForKey:identifier] removeLastObject];
        return flowView;
    }
    return nil;
}

/**
 *  放视图到重用队列
 *
 *  @param flowView 视图
 */
- (void)recycleFlowViewIntoReusableQueue:(ZBFlowView *)flowView
{
    if (!flowView.reuseIdentifier) {
        return;
    }
    if(!_reusedViews)
    {
        _reusedViews = [NSMutableDictionary dictionary];
        
        NSMutableArray *array = [NSMutableArray arrayWithObject:flowView];
        [_reusedViews setObject:array forKey:flowView.reuseIdentifier];
    }
    
    else
    {
        if (![_reusedViews objectForKey:flowView.reuseIdentifier])
        {
            NSMutableArray *array = [NSMutableArray arrayWithObject:flowView];
            [_reusedViews setObject:array forKey:flowView.reuseIdentifier];
        }
        else
        {
            [[_reusedViews objectForKey:flowView.reuseIdentifier] addObject:flowView];
        }
    }
}

/**
 *  视图移动
 *
 *  @param scrollView 视图
 */
- (void)waterScroll:(UIScrollView *)scrollView
{
    //顶部视图移出
    if (_visibleRange.length > 0) {
        CGPoint topOutPoint = (_bottomDrawPointVector[_visibleRange.location]);
        CGFloat topOutHeight = (topOutPoint).y+[[_resHeightDic objectForKey:[NSNumber numberWithUnsignedInteger:_visibleRange.location]] floatValue];
        if (topOutHeight < TopLineHeight) {
            ZBFlowView *flowView = [_visibleViews firstObject];
            [self recycleFlowViewIntoReusableQueue:flowView];
            [flowView removeFromSuperview];
            [_visibleViews removeObject:flowView];
            _visibleRange.location++;
            _visibleRange.length--;
            _topRange.length--;
            return;
        }
    }
    
    //顶部视图移入
    if (_visibleRange.location >= 1) {
        //当前应移入坐标
        TopEntity *topEntity = _topEntityVector[_topRange.location+_topRange.length];
        if (topEntity.point.y>TopLineHeight) {//循环添加到移入点
            while (_visibleRange.location>= topEntity.index+1) {//be caution location is a non-negtive
                CGPoint topInPoint = _bottomDrawPointVector[_visibleRange.location-1];
                UIView *view = [self drawView:topInPoint index:(int)_visibleRange.location-1];
                [_visibleViews insertObject:view atIndex:0];
                _visibleRange.location--;
                _visibleRange.length++;
                _topRange.length++;
            }
            return;
        }
    }
    
    //底部视图移入
    if ((int)(_visibleRange.location+_visibleRange.length) <= (int)_bottomDrawPointVector.size()-1) {
        CGPoint bottomInPoint = _bottomDrawPointVector[_visibleRange.location+_visibleRange.length];
        CGFloat bottomInHeight = (bottomInPoint).y;
        if (bottomInHeight<BottomLineHeight) {
            UIView *view = [self drawView:bottomInPoint index:(int)(_visibleRange.location+_visibleRange.length)];
            [_visibleViews addObject:view];
            _visibleRange.length++;
            return;
        }
    }
    //底部视图移出
    if ((_visibleRange.location+_visibleRange.length <= _bottomDrawPointVector.size())
        &&_visibleRange.length>=1) {
        CGPoint bottomOutPoint = _bottomDrawPointVector[_visibleRange.location+_visibleRange.length-1];
        CGFloat bottomOutHeight = (bottomOutPoint).y;
        if (bottomOutHeight>BottomLineHeight) {
            ZBFlowView *flowView = [_visibleViews lastObject];
            [self recycleFlowViewIntoReusableQueue:flowView];
            [flowView removeFromSuperview];
            [_visibleViews removeObject:flowView];
            _visibleRange.length--;
            return;
        }
    }
    
    //加载更多
    if (_isDataEnd) {
        return;
    }
    if ((!_footView)&&(self.contentOffset.y+self.frame.size.height >= self.contentSize.height-_waterInfo.bottomMargin)) {
        self.contentSize = CGSizeMake(self.contentSize.width, self.contentSize.height+50);
        _footView = [self loadingMoreWithFrame:CGRectMake(0, self.contentSize.height-_waterInfo.bottomMargin-40, UI_SCREEN_WIDTH, 40) target:self selector:@selector(loadMore)];
        [self addSubview:_footView];
    }
}

/**
 *  通知代理加载更多
 */
- (void)loadMore
{
    if ([self.waterDelegate respondsToSelector:@selector(needLoadMoreByWaterView:)]) {
        [_waterDelegate needLoadMoreByWaterView:self];
    }
}

/**
 *  绘制视图节点
 *
 *  @param resArr 视图数组
 */
- (UIView *)drawView:(CGPoint)drawPoint index:(int)index
{
    CGRect flowViewRect;
    flowViewRect.origin = drawPoint;
    flowViewRect.size = CGSizeMake(_resWidth, [[_resHeightDic objectForKey:[NSNumber numberWithInt:index]] floatValue]);
    ZBFlowView *view = [self.waterDataSource waterView:self flowViewAtIndex:index];
    view.flowViewDelegate = self;
    view.frame = flowViewRect;
    [_bodyView addSubview:view];
    return view;
}

/**
 *  初始化视图
 */
- (void)initView
{
    _bodyView = [[UIView alloc] initWithFrame:CGRectMake(self.frame.origin.x, self.waterInfo.topMargin, self.frame.size.width, self.contentSize.height-self.waterInfo.topMargin)];
    _bodyView.backgroundColor = [UIColor clearColor];
    [self addSubview:_bodyView];
    
    BOOL isFirst = YES;
    for (int i=0; i<_bottomDrawPointVector.size(); i++) {
        CGPoint point = _bottomDrawPointVector[i];
        CGFloat topInHeight = point.y+[[_resHeightDic objectForKey:[NSNumber numberWithInt:i]] floatValue];
        if (topInHeight<TopLineHeight) {
            continue;
        }
        if ((point).y>BottomLineHeight) {
            break;
        }
        if (isFirst) {
            _visibleRange.location = i;
            _topRange.length = _topEntityVector.size()-i;
            isFirst = NO;
        }
        UIView *view = [self drawView:point index:i];
        [_visibleViews addObject:view];
        _visibleRange.length++;
    }
}

#pragma mark - Action
/**
 *  重新加载
 */
- (void)reloadData
{
    for (UIView *resView in _visibleViews) {
        [resView removeFromSuperview];
    }
    [_bodyView removeFromSuperview];
    _bodyView = nil;
    
    [self clearVector];
    [self initialize];
}

/**
 *  初始化
 */
- (void)initialize
{
    NSAssert([self.waterDataSource respondsToSelector:@selector(infoOfWaterView:)]
             ,@"infoOfWaterView must be implement");
    _waterInfo = [self.waterDataSource infoOfWaterView:self];
    
    //检查外部系统配置
    [self checkWaterInfo];
    
    //初始化容器
    _visibleViews = [NSMutableArray array];
    _reusedViews = [NSMutableDictionary dictionary];
    _resHeightDic = [NSMutableDictionary dictionary];
    _visibleRange = NSMakeRange(0, 0);
    _topRange = NSMakeRange(0, 0);
    
    //计算节点宽度
    _resWidth = (UI_SCREEN_WIDTH - _waterInfo.leftMargin-_waterInfo.rightMargin-(_waterInfo.numOfColumn-1)*_waterInfo.horizonPadding)/(_waterInfo.numOfColumn);
    
    //配置模拟节点指针
    for (int i=0; i<_waterInfo.numOfColumn; i++) {
        CGPoint point = CGPointMake(_waterInfo.leftMargin+(_resWidth+_waterInfo.horizonPadding)*i, 0);
        CGPoint *drawPointer = (CGPoint *)malloc(sizeof(CGPoint));
        *drawPointer = point;
        _simulatePointVector.push_back(drawPointer);
    }
    
    //配置节点
    NSAssert([self.waterDataSource respondsToSelector:@selector(numberOfFlowViewInWaterView:)]
             ,@"numberOfFlowViewInWaterView must be implement");
    int numbers = (int)[self.waterDataSource numberOfFlowViewInWaterView:self];
    for (int i=0; i<numbers; i++) {
        NSAssert([self.waterDataSource respondsToSelector:@selector(waterView:heightOfFlowViewAtIndex:)]
                 ,@"waterView:heightOfFlowViewAtIndex: must be implement");
        CGFloat flowViewHeight = [self.waterDataSource waterView:self heightOfFlowViewAtIndex:i];
        //
        [_resHeightDic setObject:[NSNumber numberWithFloat:flowViewHeight] forKey:[NSNumber numberWithInt:i]];
        
        //
        [self recordDrawPointByHeight:flowViewHeight index:i];
    }

    //排序绘制点+绘制高度
    stable_sort(_topEntityVector.begin(), _topEntityVector.end(), less_second);
    
    
    //初始化视图
    self.contentSize = CGSizeMake(self.frame.size.width, _topEntityVector[0].point.y);
    [self initView];
}

//排序方法
bool less_second(const TopEntity *m1, const TopEntity *m2) {
    return m1.point.y > m2.point.y;
}

/**
 *  记录绘制点
 *
 *  @param height 高度
 *  @param index  序号
 */
- (void)recordDrawPointByHeight:(CGFloat)height index:(NSInteger)index
{
    CGPoint *drawPointer = _simulatePointVector[0];
    for (int i=1; i!=_simulatePointVector.size(); i++) {
        //
        CGPoint *nextDrawPointer = _simulatePointVector[i];
        if ((*nextDrawPointer).y<(*drawPointer).y) {
            drawPointer = nextDrawPointer;
        }
    }

    _bottomDrawPointVector.push_back(*drawPointer);
    (*drawPointer).y += height+_waterInfo.veticalPadding;
    
    TopEntity *entity = [[TopEntity alloc] init];
    entity.point = *drawPointer;
    entity.index = index;
    _topEntityVector.push_back(entity);
}

/**
 *  检查外部系统配置
 */
- (void)checkWaterInfo
{
    //to do
}

/**
 *  结束加载更多
 */
- (void)endLoadMore
{
    [_footView removeFromSuperview];
    _footView = nil;
}

/**
 *  清除非oc变量
 */
- (void)clearVector
{ 
    _bottomDrawPointVector.clear();
    _topEntityVector.clear();
    
    for (int i=0;i<_simulatePointVector.size();i++) {
        free(_simulatePointVector[i]);
    }
    _simulatePointVector.clear();
}

#pragma mark - ScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self waterScroll:scrollView];
    if ([_waterDelegate respondsToSelector:@selector(phoneWaterViewDidScroll:)]) {
        [_waterDelegate phoneWaterViewDidScroll:self];
    }
}

#pragma mark - ZBFlowViewDelegate
- (void)pressedAtFlowView:(ZBFlowView *)flowView
{
    if ([self.waterDelegate respondsToSelector:@selector(waterView:didSelectAtIndex:)]) {
        [self.waterDelegate waterView:self didSelectAtIndex:flowView.index];
    }
}

@end
