// Main

#import "PlayerViewController.h"

// Other

#import "Playlists/AddToPlaylistsViewController.h"

// Classes

#import "../Classes/AppColours.h"
#import "../Classes/AppDelegate.h"

// Interface

@interface PlayerViewController ()
{
	// Keys
	UIWindow *boundsWindow;
	BOOL deviceOrientation;
	BOOL overlayHidden;
	NSString *playerAssetsBundlePath;
	NSBundle *playerAssetsBundle;

	// Player
	AVPlayerItem *playerItem;
	AVPlayer *player;
	AVPlayerLayer *playerLayer;
	AVPictureInPictureController *pictureInPictureController;
	UIImageView *videoImage;

	// Overlay
	UIView *overlayView;
	UIImageView *collapseImage;
	UIImageView *rewindImage;
	UIImageView *playImage;
	UIImageView *pauseImage;
	UIImageView *forwardImage;

	// Info
	UISlider *progressSlider;
	UIScrollView *scrollView;
}
- (void)keysSetup;
- (void)playerSetup;
- (void)overlaySetup;
- (void)sliderSetup;
- (void)scrollSetup;
- (void)mediaSetup;
- (void)playerTimeChanged;
@end

@implementation PlayerViewController

- (void)loadView {
	[super loadView];

	self.view.backgroundColor = [AppColours mainBackgroundColour];
	[self.navigationController setNavigationBarHidden:YES animated:NO];

	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
    self.navigationItem.rightBarButtonItem = doneButton;

	[self keysSetup];
	[self playerSetup];
	[self overlaySetup];
	[self sliderSetup];
	[self scrollSetup];
	
	if ([[NSUserDefaults standardUserDefaults] integerForKey:@"kBackgroundMode"] == 1 || [[NSUserDefaults standardUserDefaults] integerForKey:@"kBackgroundMode"] == 2) {
		[self mediaSetup];
	}

	if (self.playbackMode == 1) {
		AppDelegate *shared = [UIApplication sharedApplication].delegate;
		shared.allowRotation = YES;
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
	}
}

- (void)keysSetup {
	boundsWindow = [[UIApplication sharedApplication] keyWindow];
	deviceOrientation = 0;
	overlayHidden = 0;
	playerAssetsBundlePath = [[NSBundle mainBundle] pathForResource:@"PlayerAssets" ofType:@"bundle"];
	playerAssetsBundle = [NSBundle bundleWithPath:playerAssetsBundlePath];
}

- (void)playerSetup {
	if (self.playbackMode == 1) {
		AVURLAsset *streamAsset = [[AVURLAsset alloc] initWithURL:self.videoStream options:nil];

		playerItem = [[AVPlayerItem alloc] initWithAsset:streamAsset];
		if ([[NSUserDefaults standardUserDefaults] boolForKey:@"kEnableCaptions"] != YES) {
			AVMediaSelectionGroup *subtitleSelectionGroup = [playerItem.asset mediaSelectionGroupForMediaCharacteristic:AVMediaCharacteristicLegible];
			[playerItem selectMediaOption:nil inMediaSelectionGroup:subtitleSelectionGroup];
		}
		playerItem.audioTimePitchAlgorithm = AVAudioTimePitchAlgorithmLowQualityZeroLatency;

		player = [AVPlayer playerWithPlayerItem:playerItem];
		player.allowsExternalPlayback = YES;
		player.usesExternalPlaybackWhileExternalScreenIsActive = YES;
		[player addObserver:self forKeyPath:@"status" options:0 context:nil];
		[player addObserver:self forKeyPath:@"timeControlStatus" options:0 context:nil];
		[player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1.0 / 60.0, NSEC_PER_SEC) queue:nil usingBlock:^(CMTime time) {
			[self playerTimeChanged];
		}];

		playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
		playerLayer.frame = CGRectMake(0, boundsWindow.safeAreaInsets.top, self.view.bounds.size.width, self.view.bounds.size.width * 9 / 16);
		[self.view.layer addSublayer:playerLayer];
	} else if (self.playbackMode == 2) {
		AVURLAsset *videoAsset = [[AVURLAsset alloc] initWithURL:self.videoURL options:nil];

		playerItem = [[AVPlayerItem alloc] initWithAsset:videoAsset];
		if ([[NSUserDefaults standardUserDefaults] boolForKey:@"kEnableCaptions"] != YES) {
			AVMediaSelectionGroup *subtitleSelectionGroup = [playerItem.asset mediaSelectionGroupForMediaCharacteristic:AVMediaCharacteristicLegible];
			[playerItem selectMediaOption:nil inMediaSelectionGroup:subtitleSelectionGroup];
		}
		playerItem.audioTimePitchAlgorithm = AVAudioTimePitchAlgorithmLowQualityZeroLatency;

		player = [AVPlayer playerWithPlayerItem:playerItem];
		player.allowsExternalPlayback = YES;
		player.usesExternalPlaybackWhileExternalScreenIsActive = YES;
		[player addObserver:self forKeyPath:@"status" options:0 context:nil];
		[player addObserver:self forKeyPath:@"timeControlStatus" options:0 context:nil];
		[player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1.0 / 60.0, NSEC_PER_SEC) queue:nil usingBlock:^(CMTime time) {
			[self playerTimeChanged];
		}];

		playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
		playerLayer.frame = CGRectMake(0, boundsWindow.safeAreaInsets.top, self.view.bounds.size.width, self.view.bounds.size.width * 9 / 16);
		[self.view.layer addSublayer:playerLayer];
	} else if (self.playbackMode == 3) {
		AVURLAsset *audioAsset = [[AVURLAsset alloc] initWithURL:self.audioURL options:nil];

		CMTime length = CMTimeMakeWithSeconds([self.videoLength intValue], NSEC_PER_SEC);

		AVMutableComposition *mixComposition = [AVMutableComposition composition];

		AVMutableCompositionTrack *compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
		[compositionAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, length) ofTrack:[[audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:kCMTimeZero error:nil];

		playerItem = [[AVPlayerItem alloc] initWithAsset:mixComposition];
		if ([[NSUserDefaults standardUserDefaults] boolForKey:@"kEnableCaptions"] != YES) {
			AVMediaSelectionGroup *subtitleSelectionGroup = [playerItem.asset mediaSelectionGroupForMediaCharacteristic:AVMediaCharacteristicLegible];
			[playerItem selectMediaOption:nil inMediaSelectionGroup:subtitleSelectionGroup];
		}
		playerItem.audioTimePitchAlgorithm = AVAudioTimePitchAlgorithmLowQualityZeroLatency;

		player = [AVPlayer playerWithPlayerItem:playerItem];
		player.allowsExternalPlayback = YES;
		[player addObserver:self forKeyPath:@"status" options:0 context:nil];
		[player addObserver:self forKeyPath:@"timeControlStatus" options:0 context:nil];
		[player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1.0 / 60.0, NSEC_PER_SEC) queue:nil usingBlock:^(CMTime time) {
			[self playerTimeChanged];
		}];

		videoImage = [[UIImageView alloc] init];
		videoImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:self.videoArtwork]];
		videoImage.frame = CGRectMake(0, boundsWindow.safeAreaInsets.top, self.view.bounds.size.width, self.view.bounds.size.width * 9 / 16);
		[self.view addSubview:videoImage];
	}
}

- (void)overlaySetup {
	overlayView = [[UIView alloc] init];
	overlayView.frame = CGRectMake(0, boundsWindow.safeAreaInsets.top, self.view.bounds.size.width, self.view.bounds.size.width * 9 / 16);
	overlayView.userInteractionEnabled = YES;
	UITapGestureRecognizer *overlayViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(overlayTap:)];
	overlayViewTap.numberOfTapsRequired = 1;
	[overlayView addGestureRecognizer:overlayViewTap];
	
	collapseImage = [[UIImageView alloc] init];
	NSString *collapseImagePath = [playerAssetsBundle pathForResource:@"collapse" ofType:@"png"];
	collapseImage.image = [[UIImage imageWithContentsOfFile:collapseImagePath] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
	collapseImage.frame = CGRectMake(10, 10, 24, 24);
	collapseImage.tintColor = [UIColor whiteColor];
	collapseImage.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
	collapseImage.layer.cornerRadius = collapseImage.bounds.size.width / 2;
	collapseImage.clipsToBounds = YES;
	collapseImage.userInteractionEnabled = YES;
	UITapGestureRecognizer *collapseViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(collapseTap:)];
	collapseViewTap.numberOfTapsRequired = 1;
	[collapseImage addGestureRecognizer:collapseViewTap];
	[overlayView addSubview:collapseImage];
	
	rewindImage = [[UIImageView alloc] init];
	NSString *rewindImagePath = [playerAssetsBundle pathForResource:@"rewind" ofType:@"png"];
	rewindImage.image = [[UIImage imageWithContentsOfFile:rewindImagePath] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
	rewindImage.frame = CGRectMake((overlayView.bounds.size.width / 2) - 96, (overlayView.bounds.size.height / 2) - 24, 48, 48);
	rewindImage.tintColor = [UIColor whiteColor];
	rewindImage.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
	rewindImage.layer.cornerRadius = rewindImage.bounds.size.width / 2;
	rewindImage.clipsToBounds = YES;
	rewindImage.userInteractionEnabled = YES;
	UITapGestureRecognizer *rewindViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rewindTap:)];
	rewindViewTap.numberOfTapsRequired = 1;
	[rewindImage addGestureRecognizer:rewindViewTap];
	[overlayView addSubview:rewindImage];

	playImage = [[UIImageView alloc] init];
	NSString *playImagePath = [playerAssetsBundle pathForResource:@"play" ofType:@"png"];
	playImage.image = [[UIImage imageWithContentsOfFile:playImagePath] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
	playImage.frame = CGRectMake((overlayView.bounds.size.width / 2) - 24, (overlayView.bounds.size.height / 2) - 24, 48, 48);
	playImage.tintColor = [UIColor whiteColor];
	playImage.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
	playImage.layer.cornerRadius = playImage.bounds.size.width / 2;
	playImage.clipsToBounds = YES;
	playImage.userInteractionEnabled = YES;
	UITapGestureRecognizer *playViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playPauseTap:)];
	playViewTap.numberOfTapsRequired = 1;
	[playImage addGestureRecognizer:playViewTap];
	[overlayView addSubview:playImage];

	pauseImage = [[UIImageView alloc] init];
	NSString *pauseImagePath = [playerAssetsBundle pathForResource:@"pause" ofType:@"png"];
	pauseImage.image = [[UIImage imageWithContentsOfFile:pauseImagePath] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
	pauseImage.frame = CGRectMake((overlayView.bounds.size.width / 2) - 24, (overlayView.bounds.size.height / 2) - 24, 48, 48);
	pauseImage.tintColor = [UIColor whiteColor];
	pauseImage.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
	pauseImage.layer.cornerRadius = pauseImage.bounds.size.width / 2;
	pauseImage.clipsToBounds = YES;
	pauseImage.userInteractionEnabled = YES;
	UITapGestureRecognizer *pauseViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playPauseTap:)];
	pauseViewTap.numberOfTapsRequired = 1;
	[pauseImage addGestureRecognizer:pauseViewTap];
	[overlayView addSubview:pauseImage];

	forwardImage = [[UIImageView alloc] init];
	NSString *forwardImagePath = [playerAssetsBundle pathForResource:@"forward" ofType:@"png"];
	forwardImage.image = [[UIImage imageWithContentsOfFile:forwardImagePath] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
	forwardImage.frame = CGRectMake((overlayView.bounds.size.width / 2) + 48, (overlayView.bounds.size.height / 2) - 24, 48, 48);
	forwardImage.tintColor = [UIColor whiteColor];
	forwardImage.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
	forwardImage.layer.cornerRadius = forwardImage.bounds.size.width / 2;
	forwardImage.clipsToBounds = YES;
	forwardImage.userInteractionEnabled = YES;
	UITapGestureRecognizer *forwardViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(forwardTap:)];
	forwardViewTap.numberOfTapsRequired = 1;
	[forwardImage addGestureRecognizer:forwardViewTap];
	[overlayView addSubview:forwardImage];

	overlayHidden = 1;
	[overlayView.subviews setValue:@YES forKeyPath:@"hidden"];
	[self.view addSubview:overlayView];
}

- (void)sliderSetup {
	progressSlider = [[UISlider alloc] init];
	progressSlider.frame = CGRectMake(0, boundsWindow.safeAreaInsets.top + overlayView.frame.size.height, self.view.bounds.size.width, 15);
	NSString *sliderThumbPath = [playerAssetsBundle pathForResource:@"sliderthumb" ofType:@"png"];
	[progressSlider setThumbImage:[UIImage imageWithContentsOfFile:sliderThumbPath] forState:UIControlStateNormal];
	[progressSlider setThumbImage:[UIImage imageWithContentsOfFile:sliderThumbPath] forState:UIControlStateHighlighted];
	progressSlider.minimumTrackTintColor = [UIColor redColor];
	progressSlider.minimumValue = 0.0f;
	progressSlider.maximumValue = [self.videoLength floatValue];
	[progressSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
	[self.view addSubview:progressSlider];
}

- (void)scrollSetup {
	scrollView = [[UIScrollView alloc] init];
	scrollView.frame = CGRectMake(0, boundsWindow.safeAreaInsets.top + overlayView.frame.size.height + progressSlider.frame.size.height, self.view.bounds.size.width, self.view.bounds.size.height - boundsWindow.safeAreaInsets.top - boundsWindow.safeAreaInsets.bottom - overlayView.frame.size.height - progressSlider.frame.size.height);
	
	UILabel *videoTitleLabel = [[UILabel alloc] init];
	videoTitleLabel.frame = CGRectMake(0, 0, self.view.bounds.size.width, 40);
	videoTitleLabel.text = self.videoTitle;
	videoTitleLabel.textColor = [AppColours textColour];
	videoTitleLabel.numberOfLines = 2;
	videoTitleLabel.adjustsFontSizeToFitWidth = true;
	videoTitleLabel.adjustsFontForContentSizeCategory = false;
	[scrollView addSubview:videoTitleLabel];

	scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, 40);
	[self.view addSubview:scrollView];
}

- (void)mediaSetup {
	MPRemoteCommandCenter *commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
    [commandCenter.togglePlayPauseCommand setEnabled:YES];
    [commandCenter.playCommand setEnabled:YES];
    [commandCenter.pauseCommand setEnabled:YES];
    [commandCenter.nextTrackCommand setEnabled:YES];
    [commandCenter.previousTrackCommand setEnabled:YES];
	[commandCenter.changePlaybackPositionCommand setEnabled:YES];
    [commandCenter.changePlaybackPositionCommand addTarget:self action:@selector(changedLockscreenPlaybackSlider:)];

	[commandCenter.playCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        [player play];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    [commandCenter.pauseCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        [player pause];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
	[commandCenter.nextTrackCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        NSTimeInterval newTime = CMTimeGetSeconds(player.currentTime) + 10.0f;
		CMTime time = CMTimeMakeWithSeconds(newTime, NSEC_PER_SEC);
		[player seekToTime:time];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
	[commandCenter.previousTrackCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        NSTimeInterval newTime = CMTimeGetSeconds(player.currentTime) - 10.0f;
		CMTime time = CMTimeMakeWithSeconds(newTime, NSEC_PER_SEC);
		[player seekToTime:time];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
}

- (BOOL)prefersHomeIndicatorAutoHidden {
	return YES;
}

- (void)playerTimeChanged {
	progressSlider.value = (float)CMTimeGetSeconds(player.currentTime);

	if ([[NSUserDefaults standardUserDefaults] integerForKey:@"kBackgroundMode"] == 1 || [[NSUserDefaults standardUserDefaults] integerForKey:@"kBackgroundMode"] == 2) {
		MPNowPlayingInfoCenter *playingInfoCenter = [MPNowPlayingInfoCenter defaultCenter];	
		NSMutableDictionary *songInfo = [[NSMutableDictionary alloc] init];
		MPMediaItemArtwork *albumArt = [[MPMediaItemArtwork alloc] initWithImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:self.videoArtwork]]];
		[songInfo setObject:[NSString stringWithFormat:@"%@", self.videoTitle] forKey:MPMediaItemPropertyTitle];
		[songInfo setObject:[NSString stringWithFormat:@"%@", self.videoAuthor] forKey:MPMediaItemPropertyArtist];
		[songInfo setObject:[NSNumber numberWithDouble:CMTimeGetSeconds(player.currentTime)] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
		[songInfo setObject:[NSNumber numberWithDouble:CMTimeGetSeconds(playerItem.duration)] forKey:MPMediaItemPropertyPlaybackDuration];
		[songInfo setObject:albumArt forKey:MPMediaItemPropertyArtwork];
		[playingInfoCenter setNowPlayingInfo:songInfo];
	}

	if ([NSJSONSerialization isValidJSONObject:self.sponsorBlockValues]) {
		for (NSMutableDictionary *jsonDictionary in self.sponsorBlockValues) {
            if ([[jsonDictionary objectForKey:@"category"] isEqual:@"sponsor"]) {
				if ([[NSUserDefaults standardUserDefaults] integerForKey:@"kSponsorBlockSponsorSegmentedInt"] && [[NSUserDefaults standardUserDefaults] integerForKey:@"kSponsorBlockSponsorSegmentedInt"] == 1) {
					if (CMTimeGetSeconds(player.currentTime) >= [[jsonDictionary objectForKey:@"segment"][0] floatValue] && CMTimeGetSeconds(player.currentTime) <= [[jsonDictionary objectForKey:@"segment"][1] floatValue]) {
						[player seekToTime:CMTimeMakeWithSeconds([[jsonDictionary objectForKey:@"segment"][1] floatValue] + 1, NSEC_PER_SEC)];
					}
				}
			}
			if ([[jsonDictionary objectForKey:@"category"] isEqual:@"selfpromo"]) {
				if ([[NSUserDefaults standardUserDefaults] integerForKey:@"kSponsorBlockSelfPromoSegmentedInt"] && [[NSUserDefaults standardUserDefaults] integerForKey:@"kSponsorBlockSelfPromoSegmentedInt"] == 1) {
					if (CMTimeGetSeconds(player.currentTime) >= [[jsonDictionary objectForKey:@"segment"][0] floatValue] && CMTimeGetSeconds(player.currentTime) <= [[jsonDictionary objectForKey:@"segment"][1] floatValue]) {
						[player seekToTime:CMTimeMakeWithSeconds([[jsonDictionary objectForKey:@"segment"][1] floatValue] + 1, NSEC_PER_SEC)];
					}
				}
			}
			if ([[jsonDictionary objectForKey:@"category"] isEqual:@"interaction"]) {
				if ([[NSUserDefaults standardUserDefaults] integerForKey:@"kSponsorBlockInteractionSegmentedInt"] && [[NSUserDefaults standardUserDefaults] integerForKey:@"kSponsorBlockInteractionSegmentedInt"] == 1) {
					if (CMTimeGetSeconds(player.currentTime) >= [[jsonDictionary objectForKey:@"segment"][0] floatValue] && CMTimeGetSeconds(player.currentTime) <= [[jsonDictionary objectForKey:@"segment"][1] floatValue]) {
						[player seekToTime:CMTimeMakeWithSeconds([[jsonDictionary objectForKey:@"segment"][1] floatValue] + 1, NSEC_PER_SEC)];
					}
				}
			}
			if ([[jsonDictionary objectForKey:@"category"] isEqual:@"intro"]) {
				if ([[NSUserDefaults standardUserDefaults] integerForKey:@"kSponsorBlockIntroSegmentedInt"] && [[NSUserDefaults standardUserDefaults] integerForKey:@"kSponsorBlockIntroSegmentedInt"] == 1) {
					if (CMTimeGetSeconds(player.currentTime) >= [[jsonDictionary objectForKey:@"segment"][0] floatValue] && CMTimeGetSeconds(player.currentTime) <= [[jsonDictionary objectForKey:@"segment"][1] floatValue]) {
						[player seekToTime:CMTimeMakeWithSeconds([[jsonDictionary objectForKey:@"segment"][1] floatValue] + 1, NSEC_PER_SEC)];
					}
				}
			}
			if ([[jsonDictionary objectForKey:@"category"] isEqual:@"outro"]) {
				if ([[NSUserDefaults standardUserDefaults] integerForKey:@"kSponsorBlockOutroSegmentedInt"] && [[NSUserDefaults standardUserDefaults] integerForKey:@"kSponsorBlockOutroSegmentedInt"] == 1) {
					if (CMTimeGetSeconds(player.currentTime) >= [[jsonDictionary objectForKey:@"segment"][0] floatValue] && CMTimeGetSeconds(player.currentTime) <= [[jsonDictionary objectForKey:@"segment"][1] floatValue]) {
						[player seekToTime:CMTimeMakeWithSeconds([[jsonDictionary objectForKey:@"segment"][1] floatValue] + 1, NSEC_PER_SEC)];
					}
				}
			}
			if ([[jsonDictionary objectForKey:@"category"] isEqual:@"preview"]) {
				if ([[NSUserDefaults standardUserDefaults] integerForKey:@"kSponsorBlockPreviewSegmentedInt"] && [[NSUserDefaults standardUserDefaults] integerForKey:@"kSponsorBlockPreviewSegmentedInt"] == 1) {
					if (CMTimeGetSeconds(player.currentTime) >= [[jsonDictionary objectForKey:@"segment"][0] floatValue] && CMTimeGetSeconds(player.currentTime) <= [[jsonDictionary objectForKey:@"segment"][1] floatValue]) {
						[player seekToTime:CMTimeMakeWithSeconds([[jsonDictionary objectForKey:@"segment"][1] floatValue] + 1, NSEC_PER_SEC)];
					}
				}
			}
			if ([[jsonDictionary objectForKey:@"category"] isEqual:@"music_offtopic"]) {
				if ([[NSUserDefaults standardUserDefaults] integerForKey:@"kSponsorBlockMusicOffTopicSegmentedInt"] && [[NSUserDefaults standardUserDefaults] integerForKey:@"kSponsorBlockMusicOffTopicSegmentedInt"] == 1) {
					if (CMTimeGetSeconds(player.currentTime) >= [[jsonDictionary objectForKey:@"segment"][0] floatValue] && CMTimeGetSeconds(player.currentTime) <= [[jsonDictionary objectForKey:@"segment"][1] floatValue]) {
						[player seekToTime:CMTimeMakeWithSeconds([[jsonDictionary objectForKey:@"segment"][1] floatValue] + 1, NSEC_PER_SEC)];
					}
				}
			}
		}
	}
}

@end

@implementation PlayerViewController (Privates)

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
    } else if (object == player && [keyPath isEqualToString:@"timeControlStatus"]) {
        if (player.timeControlStatus == AVPlayerTimeControlStatusPlaying) {
			playImage.alpha = 0.0;
			pauseImage.alpha = 1.0;
        } else {
			playImage.alpha = 1.0;
			pauseImage.alpha = 0.0;
		}
    }
}

- (void)overlayTap:(UITapGestureRecognizer *)recognizer {
	if (overlayHidden == 1) {
		overlayHidden = 0;
		[overlayView.subviews setValue:@NO forKeyPath:@"hidden"];
		progressSlider.hidden = NO;
	} else {
		overlayHidden = 1;
		[overlayView.subviews setValue:@YES forKeyPath:@"hidden"];
		if (deviceOrientation == 1) {
			progressSlider.hidden = YES;
		} else {
			progressSlider.hidden = NO;
		}
	}
}

- (void)collapseTap:(UITapGestureRecognizer *)recognizer {
	AppDelegate *shared = [UIApplication sharedApplication].delegate;
	shared.allowRotation = NO;
	if ([pictureInPictureController isPictureInPictureActive]) {
        [pictureInPictureController stopPictureInPicture];
    }
    [player pause];
	playerLayer.player = nil;
	player = nil;
    [playerLayer removeFromSuperlayer];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)rewindTap:(UITapGestureRecognizer *)recognizer {
	NSTimeInterval newTime = CMTimeGetSeconds(player.currentTime) - 10.0f;
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
	NSTimeInterval newTime = CMTimeGetSeconds(player.currentTime) + 10.0f;
	CMTime time = CMTimeMakeWithSeconds(newTime, NSEC_PER_SEC);
	[player seekToTime:time];
}

- (void)enteredBackground:(NSNotification *)notification {
	if (![pictureInPictureController isPictureInPictureActive]) {
		playerLayer.player = nil;
	}
	overlayHidden = 1;
	[overlayView.subviews setValue:@YES forKeyPath:@"hidden"];
	if (deviceOrientation == 1) {
		progressSlider.hidden = YES;
	} else {
		progressSlider.hidden = NO;
	}

	MPNowPlayingInfoCenter *playingInfoCenter = [MPNowPlayingInfoCenter defaultCenter];	
	NSMutableDictionary *songInfo = [[NSMutableDictionary alloc] init];
	MPMediaItemArtwork *albumArt = [[MPMediaItemArtwork alloc] initWithImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:self.videoArtwork]]];
	[songInfo setObject:[NSString stringWithFormat:@"%@", self.videoTitle] forKey:MPMediaItemPropertyTitle];
	[songInfo setObject:[NSString stringWithFormat:@"%@", self.videoAuthor] forKey:MPMediaItemPropertyArtist];
	[songInfo setObject:[NSNumber numberWithDouble:CMTimeGetSeconds(player.currentTime)] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
	[songInfo setObject:[NSNumber numberWithDouble:CMTimeGetSeconds(playerItem.duration)] forKey:MPMediaItemPropertyPlaybackDuration];
	[songInfo setObject:albumArt forKey:MPMediaItemPropertyArtwork];
	[playingInfoCenter setNowPlayingInfo:songInfo];
}

- (void)enteredForeground:(NSNotification *)notification {
	if (![pictureInPictureController isPictureInPictureActive]) {
		playerLayer.player = player;
	}
}

- (void)orientationChanged:(NSNotification *)notification {
	UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
	switch (orientation) {
		case UIInterfaceOrientationPortrait:
		deviceOrientation = 0;
		self.view.backgroundColor = [AppColours mainBackgroundColour];
		playerLayer.frame = CGRectMake(0, boundsWindow.safeAreaInsets.top, self.view.bounds.size.width, self.view.bounds.size.width * 9 / 16);
		overlayView.frame = CGRectMake(0, boundsWindow.safeAreaInsets.top, self.view.bounds.size.width, self.view.bounds.size.width * 9 / 16);
		collapseImage.alpha = 1.0;
		rewindImage.frame = CGRectMake((overlayView.bounds.size.width / 2) - 96, (overlayView.bounds.size.height / 2) - 24, 48, 48);
		playImage.frame = CGRectMake((overlayView.bounds.size.width / 2) - 24, (overlayView.bounds.size.height / 2) - 24, 48, 48);
		pauseImage.frame = CGRectMake((overlayView.bounds.size.width / 2) - 24, (overlayView.bounds.size.height / 2) - 24, 48, 48);
		forwardImage.frame = CGRectMake((overlayView.bounds.size.width / 2) + 48, (overlayView.bounds.size.height / 2) - 24, 48, 48);
		progressSlider.frame = CGRectMake(0, boundsWindow.safeAreaInsets.top + overlayView.frame.size.height, self.view.bounds.size.width, 15);
		progressSlider.hidden = NO;
		scrollView.hidden = NO;
		break;

		case UIInterfaceOrientationLandscapeLeft:
		deviceOrientation = 1;
		self.view.backgroundColor = [UIColor blackColor];
		playerLayer.frame = self.view.bounds;
		overlayView.frame = self.view.bounds;
		collapseImage.alpha = 0.0;
		rewindImage.frame = CGRectMake((overlayView.bounds.size.width / 2) - 96, (overlayView.bounds.size.height / 2) - 24, 48, 48);
		playImage.frame = CGRectMake((overlayView.bounds.size.width / 2) - 24, (overlayView.bounds.size.height / 2) - 24, 48, 48);
		pauseImage.frame = CGRectMake((overlayView.bounds.size.width / 2) - 24, (overlayView.bounds.size.height / 2) - 24, 48, 48);
		forwardImage.frame = CGRectMake((overlayView.bounds.size.width / 2) + 48, (overlayView.bounds.size.height / 2) - 24, 48, 48);
		progressSlider.frame = CGRectMake(60, (overlayView.bounds.size.height / 2) + 60, self.view.bounds.size.width - 120, 15);
		if (overlayHidden == 1) {
			progressSlider.hidden = YES;
		}
		scrollView.hidden = YES;
		break;

		case UIInterfaceOrientationLandscapeRight:
		deviceOrientation = 1;
		self.view.backgroundColor = [UIColor blackColor];
		playerLayer.frame = self.view.bounds;
		overlayView.frame = self.view.bounds;
		collapseImage.alpha = 0.0;
		rewindImage.frame = CGRectMake((overlayView.bounds.size.width / 2) - 96, (overlayView.bounds.size.height / 2) - 24, 48, 48);
		playImage.frame = CGRectMake((overlayView.bounds.size.width / 2) - 24, (overlayView.bounds.size.height / 2) - 24, 48, 48);
		pauseImage.frame = CGRectMake((overlayView.bounds.size.width / 2) - 24, (overlayView.bounds.size.height / 2) - 24, 48, 48);
		forwardImage.frame = CGRectMake((overlayView.bounds.size.width / 2) + 48, (overlayView.bounds.size.height / 2) - 24, 48, 48);
		progressSlider.frame = CGRectMake(60, (overlayView.bounds.size.height / 2) + 60, self.view.bounds.size.width - 120, 15);
		if (overlayHidden == 1) {
			progressSlider.hidden = YES;
		}
		scrollView.hidden = YES;
		break;
	}
}

- (void)sliderValueChanged:(UISlider *)sender {
	[player seekToTime:CMTimeMakeWithSeconds(sender.value, NSEC_PER_SEC)];
}

- (MPRemoteCommandHandlerStatus)changedLockscreenPlaybackSlider:(MPChangePlaybackPositionCommandEvent *)event {
    [player seekToTime:CMTimeMakeWithSeconds(event.positionTime, NSEC_PER_SEC)];
    return MPRemoteCommandHandlerStatusSuccess;
}

@end