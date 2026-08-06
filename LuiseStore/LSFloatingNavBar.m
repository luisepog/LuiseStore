#import "LSFloatingNavBar.h"
#import <objc/runtime.h>
#import <objc/message.h>

@interface LSFloatingNavBar ()
@property (nonatomic, retain) UIVisualEffectView* blurView;
@property (nonatomic, retain) UILabel* titleLabel;
@property (nonatomic, retain) UIStackView* leftStack;
@property (nonatomic, retain) UIStackView* rightStack;
@end

@implementation LSFloatingNavBar

- (instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if(self)
	{
		self.backgroundColor = UIColor.clearColor;

		UIBlurEffect* blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemMaterial];
		self.blurView = [[UIVisualEffectView alloc] initWithEffect:blur];
		self.blurView.translatesAutoresizingMaskIntoConstraints = NO;
		self.blurView.layer.cornerRadius = 24;
		self.blurView.layer.cornerCurve = kCACornerCurveContinuous;
		self.blurView.layer.masksToBounds = YES;
		self.blurView.layer.borderWidth = 1.0 / [UIScreen mainScreen].scale;
		self.blurView.layer.borderColor = [UIColor.whiteColor colorWithAlphaComponent:0.22].CGColor;
		self.blurView.layer.shadowColor = [UIColor.blackColor CGColor];
		self.blurView.layer.shadowOpacity = 0.10;
		self.blurView.layer.shadowRadius = 10;
		self.blurView.layer.shadowOffset = CGSizeMake(0, 4);
		[self addSubview:self.blurView];

		self.titleLabel = [[UILabel alloc] init];
		self.titleLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightBold];
		self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
		[self.blurView.contentView addSubview:self.titleLabel];

		self.leftStack = [[UIStackView alloc] init];
		self.leftStack.axis = UILayoutConstraintAxisHorizontal;
		self.leftStack.spacing = 8;
		self.leftStack.translatesAutoresizingMaskIntoConstraints = NO;
		[self.blurView.contentView addSubview:self.leftStack];

		self.rightStack = [[UIStackView alloc] init];
		self.rightStack.axis = UILayoutConstraintAxisHorizontal;
		self.rightStack.spacing = 8;
		self.rightStack.translatesAutoresizingMaskIntoConstraints = NO;
		[self.blurView.contentView addSubview:self.rightStack];

		[NSLayoutConstraint activateConstraints:@[
			[self.blurView.topAnchor constraintEqualToAnchor:self.topAnchor],
			[self.blurView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
			[self.blurView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
			[self.blurView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],

			// Title sits 3pt below the bar's vertical center -> "nổi" (lifted) look.
			[self.titleLabel.centerYAnchor constraintEqualToAnchor:self.blurView.contentView.centerYAnchor constant:3],
			[self.titleLabel.centerXAnchor constraintEqualToAnchor:self.blurView.contentView.centerXAnchor],
			[self.titleLabel.widthAnchor constraintLessThanOrEqualToAnchor:self.blurView.contentView.widthAnchor multiplier:0.6],

			[self.leftStack.centerYAnchor constraintEqualToAnchor:self.titleLabel.centerYAnchor],
			[self.leftStack.leadingAnchor constraintEqualToAnchor:self.blurView.contentView.leadingAnchor constant:8],

			[self.rightStack.centerYAnchor constraintEqualToAnchor:self.titleLabel.centerYAnchor],
			[self.rightStack.trailingAnchor constraintEqualToAnchor:self.blurView.contentView.trailingAnchor constant:-8],
		]];
	}
	return self;
}

- (void)setTitle:(NSString*)title
{
	_title = title;
	self.titleLabel.text = title;
}

- (void)setTintColor:(UIColor*)tintColor
{
	_tintColor = tintColor;
	self.titleLabel.textColor = tintColor;
}

- (void)setLeftButtons:(NSArray<UIBarButtonItem*>*)buttons
{
	for(UIView* v in self.leftStack.arrangedSubviews) [self.leftStack removeArrangedSubview:v];
	for(UIBarButtonItem* b in buttons)
	{
		[self.leftStack addArrangedSubview:[self makeButtonViewForBarButtonItem:b]];
	}
}

- (void)setRightButtons:(NSArray<UIBarButtonItem*>*)buttons
{
	for(UIView* v in self.rightStack.arrangedSubviews) [self.rightStack removeArrangedSubview:v];
	for(UIBarButtonItem* b in buttons)
	{
		[self.rightStack addArrangedSubview:[self makeButtonViewForBarButtonItem:b]];
	}
}

// Convert a UIBarButtonItem (image/menu) into a circular glass button.
- (UIView*)makeButtonViewForBarButtonItem:(UIBarButtonItem*)item
{
	UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];

	UIImage* img = item.image;
	if(img)
	{
		[btn setImage:img forState:UIControlStateNormal];
	}

	btn.tintColor = self.tintColor ?: [UIColor systemIndigoColor];
	btn.translatesAutoresizingMaskIntoConstraints = NO;
	[NSLayoutConstraint activateConstraints:@[
		[btn.widthAnchor constraintEqualToConstant:36],
		[btn.heightAnchor constraintEqualToConstant:36],
	]];

	// Circular button.
	btn.layer.cornerRadius = 18;
	btn.layer.cornerCurve = kCACornerCurveContinuous;
	btn.layer.masksToBounds = YES;
	btn.backgroundColor = [UIColor.whiteColor colorWithAlphaComponent:0.14];
	btn.layer.borderWidth = 1.0 / [UIScreen mainScreen].scale;
	btn.layer.borderColor = [UIColor.whiteColor colorWithAlphaComponent:0.20].CGColor;

	// Subtle highlight on press.
	if(@available(iOS 15, *))
	{
		btn.configuration = nil;
	}
	[btn setAdjustsImageWhenHighlighted:YES];

	if(item.menu)
	{
		btn.menu = item.menu;
		btn.showsMenuAsPrimaryAction = YES;
	}
	else
	{
		[btn addTarget:self action:@selector(forwardButtonAction:) forControlEvents:UIControlEventTouchUpInside];
		btn.accessibilityLabel = item.accessibilityLabel ?: img.accessibilityLabel;
	}

	objc_setAssociatedObject(btn, @selector(forwardButtonAction:), item, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

	return btn;
}

- (void)forwardButtonAction:(UIButton*)btn
{
	UIBarButtonItem* item = objc_getAssociatedObject(btn, @selector(forwardButtonAction:));
	if(item && item.target && item.action)
	{
		((void(*)(id, SEL, id, id))objc_msgSend)(item.target, item.action, item, item);
	}
}

@end
