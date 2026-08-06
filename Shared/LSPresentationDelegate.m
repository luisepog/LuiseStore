#import "LSPresentationDelegate.h"
#import "LSTheme.h"

@implementation LSPresentationDelegate

static UIViewController* g_presentationViewController;
static UIAlertController* g_activityController;

+ (UIViewController*)presentationViewController
{
	return g_presentationViewController;
}

+ (void)setPresentationViewController:(UIViewController*)vc
{
	g_presentationViewController = vc;
}

+ (UIAlertController*)activityController
{
	return g_activityController;
}

+ (void)setActivityController:(UIAlertController*)ac
{
	g_activityController = ac;
}

+ (void)startActivity:(NSString*)activity withCancelHandler:(void (^)(void))cancelHandler
{
	if(self.activityController)
	{
		if(self.activityController.view.window)
		{
			// Already on screen: just update the title.
			self.activityController.title = activity;
		}
		else
		{
			// Still presenting or dismissing; wait for it to settle.
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
			{
				[self startActivity:activity withCancelHandler:cancelHandler];
			});
		}
		return;
	}

	self.activityController = [UIAlertController alertControllerWithTitle:activity message:@"" preferredStyle:UIAlertControllerStyleAlert];
		UIActivityIndicatorView* activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(5,5,50,50)];
		activityIndicator.hidesWhenStopped = YES;
		activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleMedium;
		[activityIndicator startAnimating];
		[self.activityController.view addSubview:activityIndicator];

		if(cancelHandler)
		{
			UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction* action)
			{
				self.activityController = nil;
				cancelHandler();
			}];
			[self.activityController addAction:cancelAction];
		}

		[self presentViewController:self.activityController animated:YES completion:nil];
}

+ (void)startActivity:(NSString*)activity
{
	[self startActivity:activity withCancelHandler:nil];
}

+ (void)stopActivityWithCompletion:(void (^)(void))completionBlock
{
	UIAlertController* ac = self.activityController;
	if(!ac)
	{
		if(completionBlock) completionBlock();
		return;
	}

	// Only dismiss if the activity alert is actually on screen. If it is still
	// mid-presentation (e.g. a download finished before the alert finished
	// presenting), wait for the presentation to finish first — dismissing a
	// controller that is still presenting crashes the transition machinery.
	UIViewController* presenter = ac.presentingViewController;
	if(!presenter)
	{
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
		{
			[self stopActivityWithCompletion:completionBlock];
		});
		return;
	}

	[ac dismissViewControllerAnimated:YES completion:^
	{
		self.activityController = nil;
		if(completionBlock) completionBlock();
	}];
}

+ (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completionBlock
{
	if([viewControllerToPresent isKindOfClass:UIAlertController.class])
	{
		UIViewController* target = self.presentationViewController;
		if(!target) return;

		[target presentViewController:viewControllerToPresent animated:flag completion:completionBlock];
	}
	else
	{
		[self.presentationViewController presentViewController:viewControllerToPresent animated:flag completion:completionBlock];
	}
}

@end