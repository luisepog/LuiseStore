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
