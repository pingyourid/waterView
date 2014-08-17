//
//  ZBFlowView.h
//
//
//  Created by zhangbin on 14-7-28.
//  Copyright (c) 2014年 OneStore. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZBFlowView;

@protocol ZBFlowViewDelegate <NSObject>

- (void)pressedAtFlowView:(ZBFlowView *)flowView;

@end

@interface ZBFlowView : UIView

@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong) NSString *reuseIdentifier;
@property (nonatomic, assign) id <ZBFlowViewDelegate> flowViewDelegate;

@end
