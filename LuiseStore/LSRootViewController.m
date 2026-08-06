#import "LSRootViewController.h"
#import "LSAppTableViewController.h"
#import "LSVarCleanController.h"
#import "LSSettingsListController.h"
#import <LSPresentationDelegate.h>
#import "LSTheme.h"

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

	// Clean bars: system default appearance, just set tint.
	[UITabBar appearance].tintColor = accent;
	[UINavigationBar appearance].tintColor = accent;

	// Grouped table background — clean, modern, auto dark mode.
	[UITableView appearance].backgroundColor = [UIColor systemGroupedBackgroundColor];
	[UITableViewCell appearance].backgroundColor = [UIColor clearColor];
}

@end
