#import "LSRootViewController.h"
#import "LSAppTableViewController.h"
#import "LSVarCleanController.h"
#import "LSSettingsListController.h"
#import <LSPresentationDelegate.h>
#import "LSTheme.h"
#import "LSFloatingTabBar.h"

@interface LSRootViewController ()
@property (nonatomic, retain) LSFloatingTabBar* floatingBar;
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

	UIColor* accent = LSTheme.accentColor;
	[UINavigationBar appearance].tintColor = accent;

	[UITableView appearance].backgroundColor = [UIColor systemGroupedBackgroundColor];
	[UITableViewCell appearance].backgroundColor = [UIColor clearColor];

	// Hide the system tab bar; we replace it with a floating glass bar.
	self.tabBar.hidden = YES;
	// Reserve space at the bottom so content doesn't slide under the floating bar.
	self.additionalSafeAreaInsets = UIEdgeInsetsMake(0, 0, 76, 0);

	[self setupFloatingTabBar];
}

- (void)setupFloatingTabBar
{
	self.floatingBar = [[LSFloatingTabBar alloc] initWithFrame:CGRectZero];
	self.floatingBar.translatesAutoresizingMaskIntoConstraints = NO;
	[self.view addSubview:self.floatingBar];

	// Lift the bar 3pt above the bottom safe area -> "nổi" (floating) look.
	[NSLayoutConstraint activateConstraints:@[
		[self.floatingBar.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor constant:12],
		[self.floatingBar.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor constant:-12],
		[self.floatingBar.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:-10],
		[self.floatingBar.heightAnchor constraintEqualToConstant:56],
	]];

	[self.floatingBar configureWithItems:@[
		@{@"image": @"square.stack.3d.up.fill"},
		@{@"image": @"trash"},
		@{@"image": @"gear"},
	]];

	__weak typeof(self) weakSelf = self;
	self.floatingBar.onSelect = ^(NSUInteger idx) {
		weakSelf.selectedIndex = idx;
	};
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex
{
	[super setSelectedIndex:selectedIndex];
	self.floatingBar.selectedIndex = selectedIndex;
}

@end
