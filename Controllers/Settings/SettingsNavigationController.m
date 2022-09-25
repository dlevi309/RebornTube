#import "SettingsNavigationController.h"

@interface SettingsNavigationController ()
@end

@implementation SettingsNavigationController

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
    /* if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        return UIInterfaceOrientationMaskAll;
    }
    return UIInterfaceOrientationMaskAllButUpsideDown; */
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientationMask)navigationControllerSupportedInterfaceOrientations:(UINavigationController *)navigationController {
    return [navigationController.topViewController supportedInterfaceOrientations];
}

@end