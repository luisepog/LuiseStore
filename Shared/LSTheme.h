#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

// Central glassmorphism theme (Liquid-Glass style approximation for iOS 14+).
@interface LSTheme : NSObject

+ (UIColor*)accentColor;
+ (UIColor*)accentColorDimmed;

// Frosts an alert/action sheet after presentation: swaps the internal blur
// effect for a translucent material, adds a glass border and a specular
// highlight, and removes opaque fill colors.
+ (void)applyGlassToAlert:(UIViewController*)alertVC;

// Frosts a plain view (used for the activity panel).
+ (void)applyGlassToView:(UIView*)view cornerRadius:(CGFloat)radius;

// Convenience: creates a frosted glass view for use as a table cell background.
+ (UIVisualEffectView*)glassCellBackgroundWithCornerRadius:(CGFloat)radius;

@end

NS_ASSUME_NONNULL_END
