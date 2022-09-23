#import "PlayerNavigationController.h"
#import "PlayerViewController.h"

@interface PlayerNavigationController ()
@end

@implementation PlayerNavigationController

- (id)initWithRootViewController:(UIViewController *)rootViewController {
	self = [super initWithRootViewController:rootViewController];
    if (self) {
		self.modalPresentationStyle = UIModalPresentationFullScreen;
	}
    return self;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (UIInterfaceOrientationMask)navigationControllerSupportedInterfaceOrientations:(UINavigationController *)navigationController {
    return [navigationController.topViewController supportedInterfaceOrientations];
}

- (BOOL)prefersHomeIndicatorAutoHidden {
	return YES;
}

- (UIViewController *)childViewControllerForHomeIndicatorAutoHidden {
    return [PlayerViewController new];
}

@end