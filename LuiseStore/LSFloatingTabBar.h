#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LSFloatingTabBar : UIView

@property (nonatomic, copy) void (^onSelect)(NSUInteger index);
@property (nonatomic, assign) NSUInteger selectedIndex;

- (void)configureWithItems:(NSArray<NSDictionary*>*)items;

@end

NS_ASSUME_NONNULL_END
