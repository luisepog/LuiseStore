#import "LSTheme.h"
#import <QuartzCore/QuartzCore.h>

@implementation LSTheme

+ (UIColor*)accentColor
{
	// Indigo, matching the background gradient.
	return [UIColor colorWithRed:0.42 green:0.38 blue:0.95 alpha:1.0];
}

+ (UIColor*)accentColorDimmed
{
	return [[self accentColor] colorWithAlphaComponent:0.15];
}

static void LSApplyGlassAppearance(UIView* view, CGFloat cornerRadius)
{
	view.layer.cornerRadius = cornerRadius;
	view.layer.cornerCurve = kCACornerCurveContinuous;
	view.layer.masksToBounds = YES;
	view.layer.borderWidth = 1.0 / [UIScreen mainScreen].scale;
	view.layer.borderColor = [UIColor.whiteColor colorWithAlphaComponent:0.22].CGColor;
}

+ (void)applyGlassToAlert:(UIViewController*)alertVC
{
	// Traverse the alert's internal hierarchy and swap every UIVisualEffectView
	// (dimming backdrop, title vibrancy, button vibrancy) to a translucent
	// material so the gradient shows through. Remove opaque fills as well.
	__block UIVisualEffectView* glassContainer = nil;

	__block void (^__weak weakWalk)(UIView*, BOOL);
	__block void (^walk)(UIView*, BOOL);
	walk = ^(UIView* view, BOOL isRoot) {
		if([view isKindOfClass:UIVisualEffectView.class])
		{
			UIVisualEffectView* ev = (UIVisualEffectView*)view;
			UIBlurEffect* glass = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemMaterial];
			if(isRoot)
			{
				// Root container: keep a slightly stronger material.
				glass = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemThickMaterial];
				glassContainer = ev;
			}
			ev.effect = glass;
		}
		else
		{
			// Remove opaque background fills (white/gray box behind buttons).
			UIColor* bg = view.backgroundColor;
			if(bg && !(CGColorGetAlpha(bg.CGColor) > 0.0) && !CGColorEqualToColor(bg.CGColor, UIColor.clearColor.CGColor))
			{
				if([bg isEqual:UIColor.whiteColor] || [bg isEqual:UIColor.secondarySystemBackgroundColor] || [bg isEqual:UIColor.systemBackgroundColor])
				{
					view.backgroundColor = UIColor.clearColor;
				}
			}
		}

		for(UIView* sub in view.subviews)
		{
			weakWalk(sub, NO);
		}
	};
	walk(alertVC.view, YES);

	if(glassContainer)
	{
		// Glass border + specular highlight on the container.
		glassContainer.layer.cornerRadius = 22;
		glassContainer.layer.cornerCurve = kCACornerCurveContinuous;
		glassContainer.layer.borderWidth = 1.0 / [UIScreen mainScreen].scale;
		glassContainer.layer.borderColor = [UIColor.whiteColor colorWithAlphaComponent:0.25].CGColor;
	}
}

+ (void)applyGlassToView:(UIView*)view cornerRadius:(CGFloat)radius
{
	LSApplyGlassAppearance(view, radius);
}

+ (UIVisualEffectView*)glassCellBackgroundWithCornerRadius:(CGFloat)radius
{
	UIVisualEffectView* glass = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemMaterial]];
	LSApplyGlassAppearance(glass, radius);
	return glass;
}

@end
