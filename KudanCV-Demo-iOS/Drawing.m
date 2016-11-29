//
//  Drawing.m
//  KudanCV
//
//  Copyright © 2016 Kudan. All rights reserved.
//

#import "Drawing.h"

/**
 This is a fairly terrible way of drawing a quadrilateral.
 Involves repreatedly creating and replacing CAShapeLayers on the UIView, and drawing lines on them with Bezier paths
 */

@implementation Quadrilateral
{
    UIBezierPath *path0;
    UIBezierPath *path1;
    UIBezierPath *path2;
    UIBezierPath *path3;
    
    CAShapeLayer *lastShapeLayer0 ;
    CAShapeLayer *lastShapeLayer1 ;
    CAShapeLayer *lastShapeLayer2 ;
    CAShapeLayer *lastShapeLayer3 ;
}


- (void)initialise:(UIView *)view
{
    path0 = [UIBezierPath bezierPath];
    path1 = [UIBezierPath bezierPath];
    path2 = [UIBezierPath bezierPath];
    path3 = [UIBezierPath bezierPath];
    
    lastShapeLayer0 =[CAShapeLayer layer];
    lastShapeLayer1 =[CAShapeLayer layer];
    lastShapeLayer2 =[CAShapeLayer layer];
    lastShapeLayer3 =[CAShapeLayer layer];
    
    [view.layer addSublayer:lastShapeLayer0];
    [view.layer addSublayer:lastShapeLayer1];
    [view.layer addSublayer:lastShapeLayer2];
    [view.layer addSublayer:lastShapeLayer3];
}

- (void)addToView:(UIView *)view colour:(UIColor *)colour
{
    CAShapeLayer *shapeLayer0 = [CAShapeLayer layer];
    CAShapeLayer *shapeLayer1 = [CAShapeLayer layer];
    CAShapeLayer *shapeLayer2 = [CAShapeLayer layer];
    CAShapeLayer *shapeLayer3 = [CAShapeLayer layer];
    
    shapeLayer0.path = [path0 CGPath];
    shapeLayer0.strokeColor = [colour CGColor];
    shapeLayer0.lineWidth = 3.0;
    shapeLayer0.fillColor = [[UIColor clearColor] CGColor];
    
    
    shapeLayer1.path = [path1 CGPath];
    shapeLayer1.strokeColor = [colour CGColor];
    shapeLayer1.lineWidth = 3.0;
    shapeLayer1.fillColor = [[UIColor clearColor] CGColor];
    
    
    shapeLayer2.path = [path2 CGPath];
    shapeLayer2.strokeColor = [colour CGColor];
    shapeLayer2.lineWidth = 3.0;
    shapeLayer2.fillColor = [[UIColor clearColor] CGColor];
    
    
    shapeLayer3.path = [path3 CGPath];
    shapeLayer3.strokeColor = [colour CGColor];
    shapeLayer3.lineWidth = 3.0;
    shapeLayer3.fillColor = [[UIColor clearColor] CGColor];
    
    [view.layer replaceSublayer:lastShapeLayer0 with:shapeLayer0];
    [view.layer replaceSublayer:lastShapeLayer1 with:shapeLayer1];
    [view.layer replaceSublayer:lastShapeLayer2 with:shapeLayer2];
    [view.layer replaceSublayer:lastShapeLayer3 with:shapeLayer3];
    
    lastShapeLayer0 = shapeLayer0;
    lastShapeLayer1 = shapeLayer1;
    lastShapeLayer2 = shapeLayer2;
    lastShapeLayer3 = shapeLayer3;
}

- (void)draw:(UIView *)view p0:(CGPoint)p0 p1:(CGPoint)p1 p2:(CGPoint)p2 p3:(CGPoint)p3 colour:(UIColor *)colour
{
    [path0 removeAllPoints];
    [path1 removeAllPoints];
    [path2 removeAllPoints];
    [path3 removeAllPoints];
    
    [path0 moveToPoint:CGPointMake(p0.x, p0.y)];
    [path0 addLineToPoint:CGPointMake(p1.x, p1.y)];
    
    [path1 moveToPoint:CGPointMake(p1.x, p1.y)];
    [path1 addLineToPoint:CGPointMake(p2.x, p2.y)];
    
    [path2 moveToPoint:CGPointMake(p2.x, p2.y)];
    [path2 addLineToPoint:CGPointMake(p3.x, p3.y)];
    
    [path3 moveToPoint:CGPointMake(p3.x, p3.y)];
    [path3 addLineToPoint:CGPointMake(p0.x, p0.y)];
    
    [self addToView:view colour:colour];
}


- (void)hide
{
    lastShapeLayer0.hidden = TRUE;
    lastShapeLayer1.hidden = TRUE;
    lastShapeLayer2.hidden = TRUE;
    lastShapeLayer3.hidden = TRUE;
}

@end



@implementation Grid
{
    UIBezierPath *path0;
    UIBezierPath *path1;
    UIBezierPath *path2;
    UIBezierPath *path3;
    UIBezierPath *path4;
    UIBezierPath *path5;
    
    CAShapeLayer *lastShapeLayer0 ;
    CAShapeLayer *lastShapeLayer1 ;
    CAShapeLayer *lastShapeLayer2 ;
    CAShapeLayer *lastShapeLayer3 ;
    CAShapeLayer *lastShapeLayer4 ;
    CAShapeLayer *lastShapeLayer5 ;
}


- (void)initialise:(UIView *)view
{
    path0 = [UIBezierPath bezierPath];
    path1 = [UIBezierPath bezierPath];
    path2 = [UIBezierPath bezierPath];
    path3 = [UIBezierPath bezierPath];
    path4 = [UIBezierPath bezierPath];
    path5 = [UIBezierPath bezierPath];
    
    lastShapeLayer0 = [CAShapeLayer layer];
    lastShapeLayer1 = [CAShapeLayer layer];
    lastShapeLayer2 = [CAShapeLayer layer];
    lastShapeLayer3 = [CAShapeLayer layer];
    lastShapeLayer4 = [CAShapeLayer layer];
    lastShapeLayer5 = [CAShapeLayer layer];
    
    [view.layer addSublayer:lastShapeLayer0];
    [view.layer addSublayer:lastShapeLayer1];
    [view.layer addSublayer:lastShapeLayer2];
    [view.layer addSublayer:lastShapeLayer3];
    [view.layer addSublayer:lastShapeLayer4];
    [view.layer addSublayer:lastShapeLayer5];
}

- (void)addToView:(UIView *)view colour:(UIColor *)colour
{
    CAShapeLayer *shapeLayer0 = [CAShapeLayer layer];
    CAShapeLayer *shapeLayer1 = [CAShapeLayer layer];
    CAShapeLayer *shapeLayer2 = [CAShapeLayer layer];
    CAShapeLayer *shapeLayer3 = [CAShapeLayer layer];
    CAShapeLayer *shapeLayer4 = [CAShapeLayer layer];
    CAShapeLayer *shapeLayer5 = [CAShapeLayer layer];
    
    shapeLayer0.path = [path0 CGPath];
    shapeLayer0.strokeColor = [colour CGColor];
    shapeLayer0.lineWidth = 3.0;
    shapeLayer0.fillColor = [[UIColor clearColor] CGColor];
    
    
    shapeLayer1.path = [path1 CGPath];
    shapeLayer1.strokeColor = [colour CGColor];
    shapeLayer1.lineWidth = 3.0;
    shapeLayer1.fillColor = [[UIColor clearColor] CGColor];
    
    
    shapeLayer2.path = [path2 CGPath];
    shapeLayer2.strokeColor = [colour CGColor];
    shapeLayer2.lineWidth = 3.0;
    shapeLayer2.fillColor = [[UIColor clearColor] CGColor];
    
    
    shapeLayer3.path = [path3 CGPath];
    shapeLayer3.strokeColor = [colour CGColor];
    shapeLayer3.lineWidth = 3.0;
    shapeLayer3.fillColor = [[UIColor clearColor] CGColor];
    
    
    shapeLayer4.path = [path4 CGPath];
    shapeLayer4.strokeColor = [colour CGColor];
    shapeLayer4.lineWidth = 3.0;
    shapeLayer4.fillColor = [[UIColor clearColor] CGColor];
    
    
    shapeLayer5.path = [path5 CGPath];
    shapeLayer5.strokeColor = [colour CGColor];
    shapeLayer5.lineWidth = 3.0;
    shapeLayer5.fillColor = [[UIColor clearColor] CGColor];
    
    
    [view.layer replaceSublayer:lastShapeLayer0 with:shapeLayer0];
    [view.layer replaceSublayer:lastShapeLayer1 with:shapeLayer1];
    [view.layer replaceSublayer:lastShapeLayer2 with:shapeLayer2];
    [view.layer replaceSublayer:lastShapeLayer3 with:shapeLayer3];
    [view.layer replaceSublayer:lastShapeLayer4 with:shapeLayer4];
    [view.layer replaceSublayer:lastShapeLayer5 with:shapeLayer5];
    
    lastShapeLayer0 = shapeLayer0;
    lastShapeLayer1 = shapeLayer1;
    lastShapeLayer2 = shapeLayer2;
    lastShapeLayer3 = shapeLayer3;
    lastShapeLayer4 = shapeLayer4;
    lastShapeLayer5 = shapeLayer5;
}

- (void)draw:(UIView *)view p0:(CGPoint)p0 p1:(CGPoint)p1 p2:(CGPoint)p2 p3:(CGPoint)p3 colour:(UIColor *)colour
{
    [path0 removeAllPoints];
    [path1 removeAllPoints];
    [path2 removeAllPoints];
    [path3 removeAllPoints];
    [path4 removeAllPoints];
    [path5 removeAllPoints];
    
    [path0 moveToPoint:CGPointMake(p0.x, p0.y)];
    [path0 addLineToPoint:CGPointMake(p1.x, p1.y)];
    
    [path1 moveToPoint:CGPointMake(p1.x, p1.y)];
    [path1 addLineToPoint:CGPointMake(p2.x, p2.y)];
    
    [path2 moveToPoint:CGPointMake(p2.x, p2.y)];
    [path2 addLineToPoint:CGPointMake(p3.x, p3.y)];
    
    [path3 moveToPoint:CGPointMake(p3.x, p3.y)];
    [path3 addLineToPoint:CGPointMake(p0.x, p0.y)];
    
    [path4 moveToPoint:CGPointMake((p0.x + p1.x)*0.5, (p0.y + p1.y)*0.5)];
    [path4 addLineToPoint:CGPointMake((p2.x + p3.x)*0.5, (p2.y + p3.y)*0.5)];
    
    [path5 moveToPoint:CGPointMake((p1.x + p2.x)*0.5, (p1.y + p2.y)*0.5)];
    [path5 addLineToPoint:CGPointMake((p3.x + p0.x)*0.5, (p3.y + p0.y)*0.5)];
    
    [self addToView:view colour:colour];
}

- (void)hide
{
    lastShapeLayer0.hidden = TRUE;
    lastShapeLayer1.hidden = TRUE;
    lastShapeLayer2.hidden = TRUE;
    lastShapeLayer3.hidden = TRUE;
    lastShapeLayer4.hidden = TRUE;
    lastShapeLayer5.hidden = TRUE;
}

@end
