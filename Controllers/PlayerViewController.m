#import "PlayerViewController.h"

@interface PlayerViewController ()
@end

@implementation PlayerViewController

- (void)loadView {
	[super loadView];

	self.title = @"";
	self.view.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
	[self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
	self.navigationController.navigationBar.barStyle = UIBarStyleBlack;

	AVURLAsset *audioAsset = [[AVURLAsset alloc] initWithURL:self.audioURL options:nil];
	AVURLAsset *videoAsset = [[AVURLAsset alloc] initWithURL:self.videoURL options:nil];

	AVMutableComposition *mixComposition = [AVMutableComposition composition];

	AVMutableCompositionTrack *compositionCommentaryTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
	[compositionCommentaryTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, audioAsset.duration) ofTrack:[[audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:kCMTimeZero error:nil];

	AVMutableCompositionTrack *compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
	[compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, audioAsset.duration) ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:kCMTimeZero error:nil];

	AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithAsset:mixComposition];

	AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];

	AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
	playerLayer.frame = CGRectMake(0, 0, 320, 480);
	[self.view.layer addSublayer:playerLayer];

	if ([AVPictureInPictureController isPictureInPictureSupported]) {
		AVPictureInPictureController *pictureInPictureController = [[AVPictureInPictureController alloc] initWithPlayerLayer:playerLayer];
		pictureInPictureController.delegate = self;
		if (@available(iOS 14.2, *)) {
			pictureInPictureController.canStartPictureInPictureAutomaticallyFromInline = YES;
		}
	}

	[player play];
}

@end