//
//  Drawing.h
//  KudanCV
//
//  Copyright © 2016 Kudan. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

@interface Quadrilateral : NSObject


- (void)initialise:(UIView *)view;

- (void)draw:(UIView *)view p0:(CGPoint)p0 p1:(CGPoint)p1 p2:(CGPoint)p2 p3:(CGPoint)p3 colour:(UIColor *)colour;

- (void)hide;


@end

@interface Grid : NSObject


- (void)initialise:(UIView *)view;

- (void)draw:(UIView *)view p0:(CGPoint)p0 p1:(CGPoint)p1 p2:(CGPoint)p2 p3:(CGPoint)p3 colour:(UIColor *)colour;

- (void)hide;


@end
