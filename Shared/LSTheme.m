#import "LSTheme.h"
#import <QuartzCore/QuartzCore.h>

@implementation LSTheme

+ (UIColor*)accentColor
{
	// Indigo accent — clean, modern.
	return [UIColor systemIndigoColor];
}

+ (UIColor*)accentColorDimmed
{
	return [[self accentColor] colorWithAlphaComponent:0.12];
}

+ (void)applyGlassToAlert:(UIViewController*)alertVC
{
	// Light glass for alerts: swap the alert's internal blur to a thin material
	// so the background subtly shows through, and add a soft border.
	__block UIVisualEffectView* glassContainer = nil;

	__block void (^__weak weakWalk)(UIView*, BOOL);
	__block void (^walk)(UIView*, BOOL);
	walk = ^(UIView* view, BOOL isRoot) {
		if([view isKindOfClass:UIVisualEffectView.class])
		{
			UIVisualEffectView* ev = (UIVisualEffectView*)view;
			UIBlurEffect* glass = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemThinMaterial];
			if(isRoot)
			{
				glass = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemMaterial];
				glassContainer = ev;
			}
			ev.effect = glass;
		}

		for(UIView* sub in view.subviews)
		{
			weakWalk(sub, NO);
		}
	};
	walk(alertVC.view, YES);

	if(glassContainer)
	{
		glassContainer.layer.cornerRadius = 20;
		glassContainer.layer.cornerCurve = kCACornerCurveContinuous;
		glassContainer.layer.borderWidth = 1.0 / [UIScreen mainScreen].scale;
		glassContainer.layer.borderColor = [UIColor.labelColor colorWithAlphaComponent:0.08].CGColor;
	}
}

+ (void)applyGlassToView:(UIView*)view cornerRadius:(CGFloat)radius
{
	view.layer.cornerRadius = radius;
	view.layer.cornerCurve = kCACornerCurveContinuous;
	view.layer.masksToBounds = YES;
}

+ (UIVisualEffectView*)glassCellBackgroundWithCornerRadius:(CGFloat)radius
{
	// Kept for compatibility; not used in the clean theme.
	UIVisualEffectView* glass = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemThinMaterial]];
	glass.layer.cornerRadius = radius;
	glass.layer.cornerCurve = kCACornerCurveContinuous;
	glass.layer.masksToBounds = YES;
	return glass;
}

// Clean card background: solid secondary system background with a soft shadow.
// No rounded corners — sharp edges, flat card style.
+ (UIView*)cleanCardBackgroundWithCornerRadius:(CGFloat)radius
{
	UIView* card = [[UIView alloc] init];
	card.backgroundColor = [UIColor secondarySystemGroupedBackgroundColor];
	card.layer.cornerRadius = 0;
	card.layer.cornerCurve = kCACornerCurveContinuous;
	card.layer.masksToBounds = NO;

	// Soft shadow for depth.
	card.layer.shadowColor = [UIColor.blackColor CGColor];
	card.layer.shadowOpacity = 0.06;
	card.layer.shadowRadius = 8;
	card.layer.shadowOffset = CGSizeMake(0, 2);
	card.layer.shouldRasterize = YES;
	card.layer.rasterizationScale = [UIScreen mainScreen].scale;

	return card;
}

@end
