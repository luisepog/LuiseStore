#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LSFloatingNavBar : UIView

@property (nonatomic, copy) NSString* title;
@property (nonatomic, retain) UIColor* tintColor;

- (void)setLeftButtons:(NSArray<UIBarButtonItem*>*)buttons;
- (void)setRightButtons:(NSArray<UIBarButtonItem*>*)buttons;

@end

NS_ASSUME_NONNULL_END
