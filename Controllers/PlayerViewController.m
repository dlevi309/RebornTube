#import "PlayerViewController.h"

@interface PlayerViewController ()
@end

@implementation PlayerViewController

- (void)loadView {
	[super loadView];

	self.title = @"";

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

	[player play];
}

@end