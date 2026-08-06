#import "LSRootViewController.h"
#import "LSAppTableViewController.h"
#import "LSVarCleanController.h"
#import "LSSettingsListController.h"
#import <LSPresentationDelegate.h>

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

	// Global appearance: pick up the system accent but keep the default
	// label colors so dark mode stays intact.
	UIColor* tintColor = [UIColor systemBlueColor];

	UINavigationBarAppearance* navAppearance = [[UINavigationBarAppearance alloc] init];
	[navAppearance configureWithDefaultBackground];
	navAppearance.titleTextAttributes = @{ NSFontAttributeName: [UIFont boldSystemFontOfSize:17] };
	[UINavigationBar appearance].standardAppearance = navAppearance;
	if(@available(iOS 15, *))
	{
		[UINavigationBar appearance].scrollEdgeAppearance = navAppearance;
	}

	UITabBarAppearance* tabAppearance = [[UITabBarAppearance alloc] init];
	[tabAppearance configureWithDefaultBackground];
	[UITabBar appearance].standardAppearance = tabAppearance;
	if(@available(iOS 15, *))
	{
		[UITabBar appearance].scrollEdgeAppearance = tabAppearance;
	}

	[UITabBar appearance].tintColor = tintColor;
	[UINavigationBar appearance].tintColor = tintColor;
	[UIView appearance].tintColor = tintColor;
}

@end
