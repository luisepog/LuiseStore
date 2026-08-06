#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

// Shared theme helpers (accent color + card backgrounds).
@interface LSTheme : NSObject

+ (UIColor*)accentColor;
+ (UIColor*)accentColorDimmed;

// Clean card background: solid fill + soft shadow + rounded corners.
+ (UIView*)cleanCardBackgroundWithCornerRadius:(CGFloat)radius;

@end

NS_ASSUME_NONNULL_END
