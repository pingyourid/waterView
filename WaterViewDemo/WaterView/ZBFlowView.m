//
//  ZBFlowView.m
//  
//
//  Created by zhangbin on 14-7-28.
//  Copyright (c) 2014年 OneStore. All rights reserved.
//

#import "ZBFlowView.h"

@interface ZBFlowView()
{
    
}
@end

@implementation ZBFlowView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = self.tag;
        btn.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
        btn.autoresizingMask = UIViewAutoresizingFlexibleWidth
        |UIViewAutoresizingFlexibleHeight;
   
        [btn addTarget:self action:@selector(pressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        return self;
    }
    return self;
}

- (void)pressed:(id)sender
{
    if (self) {
        if ([_flowViewDelegate respondsToSelector:@selector(pressedAtFlowView:)]) {
            [_flowViewDelegate pressedAtFlowView:self];
        }
    }
}




@end
