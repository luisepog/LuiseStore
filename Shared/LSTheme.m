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
	// Intentionally a no-op. Swapping the alert's internal UIVisualEffectView
	// effect / layer styles here raced with dismissal transitions on iOS 15
	// (SIGSEGV in -[UIPresentationController transitionDidFinish:] while
	// enumerating the alert's subviews). Alerts keep the stock iOS look.
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
