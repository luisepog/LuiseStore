#import "LSFloatingTabBar.h"

@interface LSFloatingTabBar ()
@property (nonatomic, retain) UIVisualEffectView* blurView;
@end

@implementation LSFloatingTabBar

- (instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if(self)
	{
		self.backgroundColor = UIColor.clearColor;

		UIBlurEffect* blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemMaterial];
		self.blurView = [[UIVisualEffectView alloc] initWithEffect:blur];
		self.blurView.translatesAutoresizingMaskIntoConstraints = NO;
		self.blurView.layer.cornerRadius = 26;
		self.blurView.layer.cornerCurve = kCACornerCurveContinuous;
		self.blurView.layer.masksToBounds = YES;
		self.blurView.layer.borderWidth = 1.0 / [UIScreen mainScreen].scale;
		self.blurView.layer.borderColor = [UIColor.whiteColor colorWithAlphaComponent:0.22].CGColor;
		self.blurView.layer.shadowColor = [UIColor.blackColor CGColor];
		self.blurView.layer.shadowOpacity = 0.10;
		self.blurView.layer.shadowRadius = 12;
		self.blurView.layer.shadowOffset = CGSizeMake(0, 4);
		[self addSubview:self.blurView];

		[NSLayoutConstraint activateConstraints:@[
			[self.blurView.topAnchor constraintEqualToAnchor:self.topAnchor],
			[self.blurView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
			[self.blurView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
			[self.blurView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
		]];
	}
	return self;
}

- (void)configureWithItems:(NSArray<NSDictionary*>*)items
{
	// remove old buttons
	for(UIView* v in self.subviews)
	{
		if([v isKindOfClass:[UIButton class]]) [v removeFromSuperview];
	}

	NSUInteger count = items.count;
	CGFloat btnSize = 40;
	CGFloat spacing = (self.bounds.size.width - btnSize * count) / (count + 1);
	CGFloat barHeight = self.bounds.size.height;

	for(NSUInteger i = 0; i < count; i++)
	{
		UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
		btn.frame = CGRectMake(spacing + i * (btnSize + spacing), (barHeight - btnSize) / 2, btnSize, btnSize);
		btn.tag = i;
		UIImage* img = [UIImage systemImageNamed:items[i][@"image"]];
		[btn setImage:img forState:UIControlStateNormal];
		btn.tintColor = [UIColor systemGrayColor];
		btn.adjustsImageWhenHighlighted = NO;
		[btn addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:btn];
	}

	_selectedIndex = 0;
	[self updateSelection];
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	// Re-position buttons when the bar resizes.
	for(UIView* v in self.subviews)
	{
		if([v isKindOfClass:[UIButton class]])
		{
			UIButton* btn = (UIButton*)v;
			NSUInteger count = [self countButtons];
			CGFloat btnSize = 40;
			CGFloat spacing = (self.bounds.size.width - btnSize * count) / (count + 1);
			btn.frame = CGRectMake(spacing + btn.tag * (btnSize + spacing), (self.bounds.size.height - btnSize) / 2, btnSize, btnSize);
		}
	}
}

- (NSUInteger)countButtons
{
	NSUInteger count = 0;
	for(UIView* v in self.subviews)
	{
		if([v isKindOfClass:[UIButton class]]) count++;
	}
	return count;
}

- (void)buttonTapped:(UIButton*)btn
{
	self.selectedIndex = btn.tag;
	if(self.onSelect) self.onSelect(btn.tag);
}

- (void)updateSelection
{
	for(UIView* v in self.subviews)
	{
		if([v isKindOfClass:[UIButton class]])
		{
			UIButton* btn = (UIButton*)v;
			BOOL selected = (btn.tag == self.selectedIndex);
			btn.tintColor = selected ? [UIColor systemIndigoColor] : [UIColor systemGrayColor];
			[UIView animateWithDuration:0.15 animations:^{
				btn.transform = selected ? CGAffineTransformMakeScale(1.12, 1.12) : CGAffineTransformIdentity;
			}];
		}
	}
}

- (void)setSelectedIndex:(NSUInteger)idx
{
	_selectedIndex = idx;
	[self updateSelection];
}

@end
