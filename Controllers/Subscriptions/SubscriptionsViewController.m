// Main

#import "SubscriptionsViewController.h"

// Interface

@interface SubscriptionsViewController ()
{
    // Keys
	UIWindow *boundsWindow;
}
- (void)keysSetup;
@end

@implementation SubscriptionsViewController

- (void)loadView {
	[super loadView];
    [self keysSetup];
}

- (void)keysSetup {
	boundsWindow = [[UIApplication sharedApplication] keyWindow];
}

@end