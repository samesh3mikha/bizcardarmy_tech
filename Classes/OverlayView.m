//
//  OverlayView.m
//  SchoolCalendar
//
//  Created by Bala Bhadra Maharjan on 7/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "OverlayView.h"

@implementation OverlayView

@synthesize isActive;
@synthesize color, opacity, animDuration;

-(id)initWithFrame:(CGRect)frame{
	isActive = NO;
	return [self initWithFrame:frame opacity:0.5 color:[UIColor blackColor] animDuration:0.5];
}

-(id)initWithFrame:(CGRect)frame opacity:(CGFloat)anOpacity color:(UIColor *)aColor animDuration:(CGFloat)duration{
	if((self = [super initWithFrame:frame])){
		self.opaque = NO;
		self.color = aColor;
		self.backgroundColor = self.color;
		self.opacity = anOpacity;
		self.animDuration = duration;
		isActive = NO;
	}
	return self; 
}

-(void)showInView:(UIView *)parentView withActivityIndicator:(BOOL)indicator{
	[self retain];
	self.alpha = 0;
	[parentView addSubview:self];
	
	if(indicator && [[self subviews] count] == 0){
		UIActivityIndicatorView *indicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease];
		indicator.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
		indicator.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
		[self addSubview:indicator];
		[indicator startAnimating];
	}
	
	[UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animDuration];

	self.alpha = opacity;
	[UIView commitAnimations];
	isActive = YES;
}

-(void)hide{
	isActive = NO;
	[UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animDuration];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(finishedFadeOut:finished:context:)];
    self.alpha = 0.0;
    [UIView commitAnimations];
}

-(void)finishedFadeOut:(NSString*)animationID finished:(BOOL)finished context:(void*)context{
	[self removeFromSuperview];
	[self release];
}

-(void)setColor:(UIColor *)aColor{
	[aColor retain]; 
	[color release];
	color = aColor;
	self.backgroundColor = color;
}

-(void)setOpacity:(CGFloat)anOpacity{
	opacity = anOpacity;
	self.alpha = opacity;
}

-(void)dealloc{
	[color release];
	[super dealloc];
}

@end
