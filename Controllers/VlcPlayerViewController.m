#import "VlcPlayerViewController.h"

@interface VlcPlayerViewController ()
{
	// Keys
	UIWindow *boundsWindow;
	BOOL deviceOrientation;
	NSString *playerAssetsBundlePath;
	NSBundle *playerAssetsBundle;

	// VLC
	VLCMediaPlayer *mediaplayer;
}
- (void)keysSetup;
@end

@implementation VlcPlayerViewController

- (void)loadView {
	[super loadView];

	self.view.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
	[self.navigationController setNavigationBarHidden:YES animated:NO];

	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
    self.navigationItem.rightBarButtonItem = doneButton;

	[self keysSetup];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    mediaplayer = [[VLCMediaPlayer alloc] init];
    mediaplayer.delegate = self;
    mediaplayer.drawable = self.view;

    mediaplayer.media = [VLCMedia mediaWithURL:[NSURL URLWithString:@"http://streams.videolan.org/streams/mp4/Mr_MrsSmith-h264_aac.mp4"]];

	[mediaplayer play];
}

- (void)keysSetup {
	boundsWindow = [[UIApplication sharedApplication] keyWindow];
	deviceOrientation = 0;
	playerAssetsBundlePath = [[NSBundle mainBundle] pathForResource:@"PlayerAssets" ofType:@"bundle"];
	playerAssetsBundle = [NSBundle bundleWithPath:playerAssetsBundlePath];
}

- (BOOL)prefersHomeIndicatorAutoHidden {
	return YES;
}

@end