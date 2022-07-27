#import "PlayerViewController.h"

@interface PlayerViewController ()
{
	AVPlayerItem *playerItem;
	AVPlayer *player;
	AVPlayerLayer *playerLayer;
	AVPictureInPictureController *pictureInPictureController;

	UIView *rewindView;
	UIView *playPauseView;
	UIView *forwardView;

	UIProgressView *progressView;
	UILabel *videoTitleLabel;
	UILabel *videoInfoLabel;
}
- (void)updateProgressView;
@end

@implementation PlayerViewController

- (void)loadView {
	[super loadView];

	self.title = @"";
	self.view.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
	[self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
	self.navigationController.navigationBar.barStyle = UIBarStyleBlack;

	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
    self.navigationItem.rightBarButtonItem = doneButton;

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
	
	UIWindow *boundsWindow = [[UIApplication sharedApplication] keyWindow];

	rewindView = [[UIView alloc] init];
	rewindView.frame = CGRectMake(0, boundsWindow.safeAreaInsets.top + self.navigationController.navigationBar.frame.size.height, self.view.bounds.size.width / 3, self.view.bounds.size.width * 9 / 16);
	UITapGestureRecognizer *rewindViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rewindTap:)];
	rewindViewTap.numberOfTapsRequired = 2;
	[rewindView addGestureRecognizer:rewindViewTap];
	[self.view addSubview:rewindView];
	
	playPauseView = [[UIView alloc] init];
	playPauseView.frame = CGRectMake(self.view.bounds.size.width / 3, boundsWindow.safeAreaInsets.top + self.navigationController.navigationBar.frame.size.height, self.view.bounds.size.width / 3, self.view.bounds.size.width * 9 / 16);
	UITapGestureRecognizer *playPauseViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playPauseTap:)];
	playPauseViewTap.numberOfTapsRequired = 2;
	[playPauseView addGestureRecognizer:playPauseViewTap];
	[self.view addSubview:playPauseView];

	forwardView = [[UIView alloc] init];
	forwardView.frame = CGRectMake((self.view.bounds.size.width / 3) * 2, boundsWindow.safeAreaInsets.top + self.navigationController.navigationBar.frame.size.height, self.view.bounds.size.width / 3, self.view.bounds.size.width * 9 / 16);
	UITapGestureRecognizer *forwardViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(forwardTap:)];
	forwardViewTap.numberOfTapsRequired = 2;
	[forwardView addGestureRecognizer:forwardViewTap];
	[self.view addSubview:forwardView];

	progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
	progressView.frame = CGRectMake(0, boundsWindow.safeAreaInsets.top + self.navigationController.navigationBar.frame.size.height + playPauseView.frame.size.height, self.view.bounds.size.width, 50);
	progressView.progressTintColor = [UIColor redColor];
	[self.view addSubview:progressView];

	videoTitleLabel = [[UILabel alloc] init];
	videoTitleLabel.frame = CGRectMake(0, boundsWindow.safeAreaInsets.top + self.navigationController.navigationBar.frame.size.height + playPauseView.frame.size.height + progressView.frame.size.height, self.view.bounds.size.width, 40);
	videoTitleLabel.text = self.videoTitle;
	videoTitleLabel.textColor = [UIColor whiteColor];
	videoTitleLabel.numberOfLines = 2;
	videoTitleLabel.adjustsFontSizeToFitWidth = true;
	videoTitleLabel.adjustsFontForContentSizeCategory = false;
	[self.view addSubview:videoTitleLabel];

	videoInfoLabel = [[UILabel alloc] init];
	videoInfoLabel.frame = CGRectMake(0, boundsWindow.safeAreaInsets.top + self.navigationController.navigationBar.frame.size.height + playPauseView.frame.size.height + progressView.frame.size.height + videoTitleLabel.frame.size.height, self.view.bounds.size.width, 60);
	videoInfoLabel.text = [NSString stringWithFormat:@"View Count: %@\nLikes: %@\nDislikes: %@", self.videoViewCount, self.videoLikes, self.videoDislikes];
	videoInfoLabel.textColor = [UIColor whiteColor];
	videoInfoLabel.numberOfLines = 3;
	videoInfoLabel.adjustsFontSizeToFitWidth = true;
	videoInfoLabel.adjustsFontForContentSizeCategory = false;
	[self.view addSubview:videoInfoLabel];
}

- (void)viewDidLoad {
	[super viewDidLoad];

	UIWindow *boundsWindow = [[UIApplication sharedApplication] keyWindow];

	AVURLAsset *audioAsset = [[AVURLAsset alloc] initWithURL:self.audioURL options:nil];
	AVURLAsset *videoAsset = [[AVURLAsset alloc] initWithURL:self.videoURL options:nil];

	CMTime length = CMTimeMake([self.videoLength intValue], 1);

	AVMutableComposition *mixComposition = [AVMutableComposition composition];

	AVMutableCompositionTrack *compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
	[compositionAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, length) ofTrack:[[audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:kCMTimeZero error:nil];

	AVMutableCompositionTrack *compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
	[compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, length) ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:kCMTimeZero error:nil];

	playerItem = [[AVPlayerItem alloc] initWithAsset:mixComposition];

	player = [AVPlayer playerWithPlayerItem:playerItem];
	player.allowsExternalPlayback = YES;
	[player addObserver:self forKeyPath:@"status" options:0 context:nil];
	[player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1.0 / 60.0, NSEC_PER_SEC) queue:nil usingBlock:^(CMTime time) {
		[self updateProgressView];
	}];

	playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
	playerLayer.frame = CGRectMake(0, boundsWindow.safeAreaInsets.top + self.navigationController.navigationBar.frame.size.height, self.view.bounds.size.width, self.view.bounds.size.width * 9 / 16);
	[self.view.layer addSublayer:playerLayer];
}

- (BOOL)prefersHomeIndicatorAutoHidden {
	return YES;
}

@end

@implementation PlayerViewController (Privates)

- (void)done {
	if ([pictureInPictureController isPictureInPictureActive]) {
        [pictureInPictureController stopPictureInPicture];
    }
    [player pause];
    [playerLayer removeFromSuperlayer];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == player && [keyPath isEqualToString:@"status"]) {
        if (player.status == AVPlayerStatusReadyToPlay) {
			if ([[NSUserDefaults standardUserDefaults] integerForKey:@"kBackgroundMode"] == 1 || [[NSUserDefaults standardUserDefaults] integerForKey:@"kBackgroundMode"] == 2) {
				[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enteredBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
				[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enteredForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];

				if ([[NSUserDefaults standardUserDefaults] integerForKey:@"kBackgroundMode"] == 2) {
					if ([AVPictureInPictureController isPictureInPictureSupported]) {
						pictureInPictureController = [[AVPictureInPictureController alloc] initWithPlayerLayer:playerLayer];
						pictureInPictureController.delegate = self;
						if (@available(iOS 14.2, *)) {
							pictureInPictureController.canStartPictureInPictureAutomaticallyFromInline = YES;
						}
					}
				}
			}
            [player play];
        }
    }
}

- (void)rewindTap:(UITapGestureRecognizer *)recognizer {
	NSTimeInterval currentTime = CMTimeGetSeconds(player.currentTime);
	NSTimeInterval newTime = currentTime - 15.0f;
	CMTime time = CMTimeMakeWithSeconds(newTime, NSEC_PER_SEC);
	[player seekToTime:time];
}

- (void)playPauseTap:(UITapGestureRecognizer *)recognizer {
	if (player.timeControlStatus == AVPlayerTimeControlStatusPlaying) {
		[player pause];
	} else {
		[player play];
	}
}

- (void)forwardTap:(UITapGestureRecognizer *)recognizer {
	NSTimeInterval currentTime = CMTimeGetSeconds(player.currentTime);
	NSTimeInterval newTime = currentTime + 15.0f;
	CMTime time = CMTimeMakeWithSeconds(newTime, NSEC_PER_SEC);
	[player seekToTime:time];
}

- (void)enteredBackground:(NSNotification *)notification {
	if (![pictureInPictureController isPictureInPictureActive]) {
		playerLayer.player = nil;
	}
	MPRemoteCommandCenter *commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
    [commandCenter.togglePlayPauseCommand setEnabled:YES];
    [commandCenter.playCommand setEnabled:YES];
    [commandCenter.pauseCommand setEnabled:YES];
    [commandCenter.nextTrackCommand setEnabled:NO];
    [commandCenter.previousTrackCommand setEnabled:NO];
	[commandCenter.playCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        [player play];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    [commandCenter.pauseCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        [player pause];
        return MPRemoteCommandHandlerStatusSuccess;
    }];

	MPNowPlayingInfoCenter *playingInfoCenter = [MPNowPlayingInfoCenter defaultCenter];
	
	NSMutableDictionary *songInfo = [[NSMutableDictionary alloc] init];
	[songInfo setObject:[NSString stringWithFormat:@"%@", self.videoTitle] forKey:MPMediaItemPropertyTitle];

	[playingInfoCenter setNowPlayingInfo:songInfo];
}

- (void)enteredForeground:(NSNotification *)notification {
	if (![pictureInPictureController isPictureInPictureActive]) {
		playerLayer.player = player;
	}
}

- (void)orientationChanged:(NSNotification *)notification {
	UIWindow *boundsWindow = [[UIApplication sharedApplication] keyWindow];
	UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
	switch (orientation) {
		case UIInterfaceOrientationPortrait:
		[self.navigationController setNavigationBarHidden:NO animated:NO];
		playerLayer.frame = CGRectMake(0, boundsWindow.safeAreaInsets.top + self.navigationController.navigationBar.frame.size.height, self.view.bounds.size.width, self.view.bounds.size.width * 9 / 16);
		rewindView.frame = CGRectMake(0, boundsWindow.safeAreaInsets.top + self.navigationController.navigationBar.frame.size.height, self.view.bounds.size.width / 3, self.view.bounds.size.width * 9 / 16);
		playPauseView.frame = CGRectMake(self.view.bounds.size.width / 3, boundsWindow.safeAreaInsets.top + self.navigationController.navigationBar.frame.size.height, self.view.bounds.size.width / 3, self.view.bounds.size.width * 9 / 16);
		forwardView.frame = CGRectMake((self.view.bounds.size.width / 3) * 2, boundsWindow.safeAreaInsets.top + self.navigationController.navigationBar.frame.size.height, self.view.bounds.size.width / 3, self.view.bounds.size.width * 9 / 16);
		progressView.hidden = NO;
		videoTitleLabel.hidden = NO;
		videoInfoLabel.hidden = NO;
		break;

		case UIInterfaceOrientationLandscapeLeft:
		[self.navigationController setNavigationBarHidden:YES animated:NO];
		playerLayer.frame = self.view.bounds;
		rewindView.frame = CGRectMake(0, 0, self.view.bounds.size.width / 3, self.view.bounds.size.height);
		playPauseView.frame = CGRectMake(self.view.bounds.size.width / 3, 0, self.view.bounds.size.width / 3, self.view.bounds.size.height);
		forwardView.frame = CGRectMake((self.view.bounds.size.width / 3) * 2, 0, self.view.bounds.size.width / 3, self.view.bounds.size.height);
		progressView.hidden = YES;
		videoTitleLabel.hidden = YES;
		videoInfoLabel.hidden = YES;
		break;

		case UIInterfaceOrientationLandscapeRight:
		[self.navigationController setNavigationBarHidden:YES animated:NO];
		playerLayer.frame = self.view.bounds;
		rewindView.frame = CGRectMake(0, 0, self.view.bounds.size.width / 3, self.view.bounds.size.height);
		playPauseView.frame = CGRectMake(self.view.bounds.size.width / 3, 0, self.view.bounds.size.width / 3, self.view.bounds.size.height);
		forwardView.frame = CGRectMake((self.view.bounds.size.width / 3) * 2, 0, self.view.bounds.size.width / 3, self.view.bounds.size.height);
		progressView.hidden = YES;
		videoTitleLabel.hidden = YES;
		videoInfoLabel.hidden = YES;
		break;
	}
}

- (void)updateProgressView {
	progressView.progress = CMTimeGetSeconds(player.currentTime) / CMTimeGetSeconds(playerItem.duration);
}

@end