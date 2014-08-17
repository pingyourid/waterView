//
//  UIScrollView+LoadingMore.h
//
//
//  Created by zhangbin on 14-6-13.
//  Copyright (c) 2014年 OneStore. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIScrollView (LoadingMore)

- (UIView *)loadingMoreWithFrame:(CGRect)frame target:(id)target selector:(SEL)selector;

@end
