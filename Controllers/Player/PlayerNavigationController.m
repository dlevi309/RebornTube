#import "PlayerNavigationController.h"

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

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        return UIInterfaceOrientationMaskAll;
    }
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (UIInterfaceOrientationMask)navigationControllerSupportedInterfaceOrientations:(UINavigationController *)navigationController {
    return [navigationController.topViewController supportedInterfaceOrientations];
}

@end