#import "AddToPlaylistsViewController.h"
#import "../Classes/AppColours.h"

@interface AddToPlaylistsViewController ()
{
    // Keys
	UIWindow *boundsWindow;

    // Other
    NSMutableDictionary *playlistsIDDictionary;
}
- (void)keysSetup;
@end

@implementation AddToPlaylistsViewController

- (void)loadView {
	[super loadView];

	[self keysSetup];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)keysSetup {
	boundsWindow = [[UIApplication sharedApplication] keyWindow];
}

@end

@implementation AddToPlaylistsViewController (Privates)

@end