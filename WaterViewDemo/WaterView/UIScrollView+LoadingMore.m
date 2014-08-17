//
//  UIScrollView+LoadingMore.m
//  
//
//  Created by zhangbin on 14-6-13.
//  Copyright (c) 2014年 OneStore. All rights reserved.
//

#import "UIScrollView+LoadingMore.h"

@implementation UIScrollView (LoadingMore)

- (UIView *)loadingMoreWithFrame:(CGRect)frame target:(id)target selector:(SEL)selector
{
    CGFloat width = frame.size.width;
    CGFloat height = frame.size.height;
    
    UIView *footerView = [[UIView alloc] initWithFrame:frame];
    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(width/2-60, 10, height-20, height-20)];
    [indicatorView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    [indicatorView startAnimating];
    [footerView addSubview:indicatorView];
    
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setText:@"正在加载"];
    [label setTextColor:[UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0]];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setFont:[UIFont systemFontOfSize:15.0]];
    [footerView addSubview:label];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    
    if ([target respondsToSelector:selector]) {
        [target performSelector:selector withObject:nil];
    }
    return footerView;
}

#pragma clang diagnostic pop

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
