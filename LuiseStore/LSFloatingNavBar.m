#import "LSFloatingNavBar.h"
#import <objc/runtime.h>
#import <objc/message.h>

@interface LSFloatingNavBar ()
@property (nonatomic, retain) UILabel* titleLabel;
@property (nonatomic, retain) UIStackView* leftStack;
@property (nonatomic, retain) UIStackView* rightStack;
@property (nonatomic, retain) UIStackView* mainStack;
@end

@implementation LSFloatingNavBar

- (instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if(self)
	{
		self.backgroundColor = UIColor.clearColor;

		self.titleLabel = [[UILabel alloc] init];
		self.titleLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightSemibold];
		self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;

		self.leftStack = [[UIStackView alloc] init];
		self.leftStack.axis = UILayoutConstraintAxisHorizontal;
		self.leftStack.spacing = 8;
		self.leftStack.translatesAutoresizingMaskIntoConstraints = NO;

		self.rightStack = [[UIStackView alloc] init];
		self.rightStack.axis = UILayoutConstraintAxisHorizontal;
		self.rightStack.spacing = 8;
		self.rightStack.translatesAutoresizingMaskIntoConstraints = NO;

		self.mainStack = [[UIStackView alloc] init];
		self.mainStack.axis = UILayoutConstraintAxisHorizontal;
		self.mainStack.alignment = UIStackViewAlignmentCenter;
		self.mainStack.spacing = 10;
		self.mainStack.translatesAutoresizingMaskIntoConstraints = NO;
		[self addSubview:self.mainStack];

		[self.mainStack addArrangedSubview:self.leftStack];
		[self.mainStack addArrangedSubview:self.titleLabel];
		[self.mainStack addArrangedSubview:self.rightStack];

		// Title sits on the app background (no pill), buttons keep their
		// circular glass look.
		[NSLayoutConstraint activateConstraints:@[
			[self.mainStack.topAnchor constraintEqualToAnchor:self.topAnchor],
			[self.mainStack.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
			[self.mainStack.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:4],
			[self.mainStack.trailingAnchor constraintLessThanOrEqualToAnchor:self.trailingAnchor],
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
		[btn.widthAnchor constraintEqualToConstant:32],
		[btn.heightAnchor constraintEqualToConstant:32],
	]];

	// Circular button.
	btn.layer.cornerRadius = 16;
	btn.layer.cornerCurve = kCACornerCurveContinuous;
	btn.layer.masksToBounds = YES;
	btn.backgroundColor = [UIColor.whiteColor colorWithAlphaComponent:0.14];
	btn.layer.borderWidth = 1.0 / [UIScreen mainScreen].scale;
	btn.layer.borderColor = [UIColor.whiteColor colorWithAlphaComponent:0.20].CGColor;

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
