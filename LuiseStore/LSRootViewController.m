#import "LSRootViewController.h"
#import "LSAppTableViewController.h"
#import "LSVarCleanController.h"
#import "LSSettingsListController.h"
#import <LSPresentationDelegate.h>
#import <QuartzCore/QuartzCore.h>

@interface LSRootViewController ()
@property(nonatomic, retain) CAGradientLayer* backgroundGradient;
@end

@implementation LSRootViewController

- (void)loadView {
	[super loadView];

	LSAppTableViewController* appTableVC = [[LSAppTableViewController alloc] init];
	appTableVC.title = @"Apps";

	LSVarCleanController* varCleanVC = [LSVarCleanController sharedInstance];
	varCleanVC.title = @"varClean";

	LSSettingsListController* settingsListVC = [[LSSettingsListController alloc] init];
	settingsListVC.title = @"Settings";

	UINavigationController* appNavigationController = [[UINavigationController alloc] initWithRootViewController:appTableVC];
	UINavigationController* varCleanNavigationController = [[UINavigationController alloc] initWithRootViewController:varCleanVC];
	UINavigationController* settingsNavigationController = [[UINavigationController alloc] initWithRootViewController:settingsListVC];
	
	appNavigationController.tabBarItem.image = [UIImage systemImageNamed:@"square.stack.3d.up.fill"];
	varCleanNavigationController.tabBarItem.image = [UIImage systemImageNamed:@"trash"];
	settingsNavigationController.tabBarItem.image = [UIImage systemImageNamed:@"gear"];

	self.title = @"Root View Controller";
	self.viewControllers = @[appNavigationController, varCleanNavigationController, settingsNavigationController];
}

- (void)viewDidLoad
{
	[super viewDidLoad];

	LSPresentationDelegate.presentationViewController = self;

	// Liquid-Glass style backdrop: a soft indigo -> cyan gradient behind
	// translucent content, adapting to light/dark mode.
	UIColor* topColor = [UIColor colorWithDynamicProvider:^UIColor*(UITraitCollection* trait) {
		return trait.userInterfaceStyle == UIUserInterfaceStyleDark
			? [UIColor colorWithRed:0.18 green:0.15 blue:0.32 alpha:1.0]
			: [UIColor colorWithRed:0.93 green:0.90 blue:1.0 alpha:1.0];
	}];
	UIColor* bottomColor = [UIColor colorWithDynamicProvider:^UIColor*(UITraitCollection* trait) {
		return trait.userInterfaceStyle == UIUserInterfaceStyleDark
			? [UIColor colorWithRed:0.10 green:0.20 blue:0.32 alpha:1.0]
			: [UIColor colorWithRed:0.85 green:0.95 blue:1.0 alpha:1.0];
	}];

	self.backgroundGradient = [CAGradientLayer layer];
	self.backgroundGradient.colors = @[(id)topColor.CGColor, (id)bottomColor.CGColor];
	self.backgroundGradient.startPoint = CGPointMake(0.0, 0.0);
	self.backgroundGradient.endPoint = CGPointMake(1.0, 1.0);
	[self.view.layer insertSublayer:self.backgroundGradient atIndex:0];
	[self updateBackgroundGradientFrame];

	// Frosted glass bars: material blur with no tint so content shines through.
	UINavigationBarAppearance* navAppearance = [[UINavigationBarAppearance alloc] init];
	[navAppearance configureWithDefaultBackground];
	navAppearance.backgroundEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemMaterial];
	navAppearance.shadowColor = nil;
	navAppearance.titleTextAttributes = @{ NSFontAttributeName: [UIFont boldSystemFontOfSize:17] };
	[UINavigationBar appearance].standardAppearance = navAppearance;
	if(@available(iOS 15, *))
	{
		[UINavigationBar appearance].scrollEdgeAppearance = navAppearance;
	}

	UITabBarAppearance* tabAppearance = [[UITabBarAppearance alloc] init];
	[tabAppearance configureWithDefaultBackground];
	tabAppearance.backgroundEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemMaterial];
	tabAppearance.shadowColor = nil;
	[UITabBar appearance].standardAppearance = tabAppearance;
	if(@available(iOS 15, *))
	{
		[UITabBar appearance].scrollEdgeAppearance = tabAppearance;
	}

	[UITabBar appearance].tintColor = [UIColor systemIndigoColor];
	[UINavigationBar appearance].tintColor = [UIColor systemIndigoColor];

	// Translucent tables so the gradient shows through everywhere.
	[UITableView appearance].backgroundColor = [UIColor clearColor];
	[UITableViewCell appearance].backgroundColor = [UIColor clearColor];
}

- (void)viewDidLayoutSubviews
{
	[super viewDidLayoutSubviews];
	[self updateBackgroundGradientFrame];
}

- (void)updateBackgroundGradientFrame
{
	self.backgroundGradient.frame = self.view.bounds;
}

- (void)traitCollectionDidChange:(UITraitCollection*)previousTraitCollection
{
	[super traitCollectionDidChange:previousTraitCollection];
	// Dynamic colors resolve per-layer; recreate colors on mode switch.
	[CATransaction begin];
	[CATransaction setDisableActions:YES];
	UIColor* topColor = [UIColor colorWithDynamicProvider:^UIColor*(UITraitCollection* trait) {
		return trait.userInterfaceStyle == UIUserInterfaceStyleDark
			? [UIColor colorWithRed:0.18 green:0.15 blue:0.32 alpha:1.0]
			: [UIColor colorWithRed:0.93 green:0.90 blue:1.0 alpha:1.0];
	}];
	UIColor* bottomColor = [UIColor colorWithDynamicProvider:^UIColor*(UITraitCollection* trait) {
		return trait.userInterfaceStyle == UIUserInterfaceStyleDark
			? [UIColor colorWithRed:0.10 green:0.20 blue:0.32 alpha:1.0]
			: [UIColor colorWithRed:0.85 green:0.95 blue:1.0 alpha:1.0];
	}];
	self.backgroundGradient.colors = @[(id)topColor.CGColor, (id)bottomColor.CGColor];
	[CATransaction commit];
}

@end
