#import "VlcPlayerViewController.h"

@interface VlcPlayerViewController ()
{
	// Keys
	UIWindow *boundsWindow;
	BOOL deviceOrientation;
	NSString *playerAssetsBundlePath;
	NSBundle *playerAssetsBundle;

	// VLC
	UIView *vlcView;
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

	vlcView = [[UIView alloc] init];
	vlcView.frame = CGRectMake(0, boundsWindow.safeAreaInsets.top, self.view.bounds.size.width, self.view.bounds.size.width * 9 / 16);
	[self.view addSubview:vlcView];

    mediaplayer = [[VLCMediaPlayer alloc] init];
    mediaplayer.delegate = self;
    mediaplayer.drawable = vlcView;

    mediaplayer.media = [VLCMedia mediaWithURL:self.videoURL];
	[mediaplayer addPlaybackSlave:self.audioURL type:VLCMediaPlaybackSlaveTypeAudio enforce:YES];

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