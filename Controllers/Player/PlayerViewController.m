// Main

#import "PlayerViewController.h"

// Classes

#import "../../Classes/AppColours.h"
#import "../../Classes/PlayerHistory.h"
#import "../../Classes/YouTubeDownloader.h"

// Views

#import "../../Views/MainPopupView.h"

// Other

#import "../Playlists/AddToPlaylistsViewController.h"

// Interface

@interface PlayerViewController ()
{
	// Keys
	UIWindow *boundsWindow;
	BOOL deviceOrientation;
	BOOL playbackMode;
	BOOL overlayHidden;
	BOOL loopEnabled;
	float playbackRate;
	NSString *playerAssetsBundlePath;
	NSBundle *playerAssetsBundle;
	NSMutableDictionary *songInfo;

	// Player
	AVPlayerItem *playerItem;
	AVPlayer *player;
	AVPlayerLayer *playerLayer;
	AVPictureInPictureController *pictureInPictureController;
	UIImageView *videoImage;

	// Overlay Left
	UIView *overlayLeftView;
	UIView *overlayLeftViewShadow;
	UIImageView *collapseImage;
	UILabel *videoTimeLabel;

	// Overlay Middle
	UIView *overlayMiddleView;
	UIView *overlayMiddleViewShadow;
	UIImageView *playImage;
	UIImageView *pauseImage;
	UIImageView *restartImage;

	// Overlay Right
	UIView *overlayRightView;
	UIView *overlayRightViewShadow;
	UISwitch *playbackModeSwitch;

	// Overlay Other
	UILabel *videoOverlayTitleLabel;
	NSTimer *overlayTimer;

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
- (void)rotationMode:(int)mode;
@end

@implementation PlayerViewController

- (void)loadView {
	[super loadView];

	self.view.backgroundColor = [AppColours mainBackgroundColour];
	[self.navigationController setNavigationBarHidden:YES animated:NO];

	[self keysSetup];
	[self playerSetup];
	[self overlaySetup];
	[self sliderSetup];
	[self scrollSetup];
	
	if ([[NSUserDefaults standardUserDefaults] integerForKey:@"kBackgroundMode"] == 1 || [[NSUserDefaults standardUserDefaults] integerForKey:@"kBackgroundMode"] == 2) {
		[self mediaSetup];
	}
}

- (void)keysSetup {
	boundsWindow = [[[UIApplication sharedApplication] windows] firstObject];
	deviceOrientation = NO;
	playbackMode = NO;
	overlayHidden = NO;
	loopEnabled = NO;
	playbackRate = 1.0f;
	playerAssetsBundlePath = [[NSBundle mainBundle] pathForResource:@"PlayerAssets" ofType:@"bundle"];
	playerAssetsBundle = [NSBundle bundleWithPath:playerAssetsBundlePath];
	songInfo = [NSMutableDictionary new];
}

- (void)playerSetup {
	AVURLAsset *videoAsset = [[AVURLAsset alloc] initWithURL:self.videoURL options:nil];

	playerItem = [[AVPlayerItem alloc] initWithAsset:videoAsset];
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"kEnableCaptions"] != YES) {
		AVMediaSelectionGroup *subtitleSelectionGroup = [playerItem.asset mediaSelectionGroupForMediaCharacteristic:AVMediaCharacteristicLegible];
		[playerItem selectMediaOption:nil inMediaSelectionGroup:subtitleSelectionGroup];
	}

	player = [AVPlayer playerWithPlayerItem:playerItem];
	player.allowsExternalPlayback = YES;
	player.usesExternalPlaybackWhileExternalScreenIsActive = YES;
	[player addObserver:self forKeyPath:@"status" options:0 context:nil];
	[player addObserver:self forKeyPath:@"timeControlStatus" options:0 context:nil];
	__weak PlayerViewController *weakSelf = self;
	[player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1.0 / 60.0, NSEC_PER_SEC) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
		[weakSelf playerTimeChanged];
	}];

	videoImage = [[UIImageView alloc] init];
	videoImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:self.videoArtwork]];
	videoImage.frame = CGRectMake(0, boundsWindow.safeAreaInsets.top, self.view.bounds.size.width, self.view.bounds.size.width * 9 / 16);
	videoImage.hidden = YES;
	[self.view addSubview:videoImage];

	playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
	playerLayer.frame = CGRectMake(0, boundsWindow.safeAreaInsets.top, self.view.bounds.size.width, self.view.bounds.size.width * 9 / 16);
	[self.view.layer addSublayer:playerLayer];
}

- (void)overlaySetup {
	// Overlay Left
	overlayLeftView = [[UIView alloc] init];
	overlayLeftView.frame = CGRectMake(0, boundsWindow.safeAreaInsets.top, self.view.bounds.size.width / 3, self.view.bounds.size.width * 9 / 16);
	overlayLeftView.clipsToBounds = YES;
	overlayLeftView.userInteractionEnabled = YES;
	UITapGestureRecognizer *overlayLeftViewSingleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(overlayTap:)];
	overlayLeftViewSingleTap.numberOfTapsRequired = 1;
	[overlayLeftView addGestureRecognizer:overlayLeftViewSingleTap];
	UITapGestureRecognizer *overlayLeftViewDoubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rewindTap:)];
	overlayLeftViewDoubleTap.numberOfTapsRequired = 2;
	[overlayLeftView addGestureRecognizer:overlayLeftViewDoubleTap];

	overlayLeftViewShadow = [[UIView alloc] init];
	overlayLeftViewShadow.frame = CGRectMake(0, 0, overlayLeftView.bounds.size.width, overlayLeftView.bounds.size.height);
	overlayLeftViewShadow.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
	[overlayLeftView addSubview:overlayLeftViewShadow];

	collapseImage = [[UIImageView alloc] init];
	NSString *collapseImagePath = [playerAssetsBundle pathForResource:@"collapse" ofType:@"png"];
	collapseImage.image = [[UIImage imageWithContentsOfFile:collapseImagePath] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
	collapseImage.frame = CGRectMake(10, 10, 24, 24);
	collapseImage.tintColor = [UIColor whiteColor];
	collapseImage.userInteractionEnabled = YES;
	UITapGestureRecognizer *collapseViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(collapseTap:)];
	collapseViewTap.numberOfTapsRequired = 1;
	[collapseImage addGestureRecognizer:collapseViewTap];
	[overlayLeftView addSubview:collapseImage];

	videoTimeLabel = [[UILabel alloc] init];
	videoTimeLabel.frame = CGRectMake(10, overlayLeftView.bounds.size.height - 25, 80, 15);
	videoTimeLabel.textAlignment = NSTextAlignmentCenter;
	videoTimeLabel.textColor = [UIColor whiteColor];
	videoTimeLabel.numberOfLines = 1;
	[videoTimeLabel setFont:[UIFont boldSystemFontOfSize:videoTimeLabel.font.pointSize]];
	videoTimeLabel.adjustsFontSizeToFitWidth = YES;
	[overlayLeftView addSubview:videoTimeLabel];

	// Overlay Middle
	overlayMiddleView = [[UIView alloc] init];
	overlayMiddleView.frame = CGRectMake(self.view.bounds.size.width / 3, boundsWindow.safeAreaInsets.top, self.view.bounds.size.width / 3, self.view.bounds.size.width * 9 / 16);
	overlayMiddleView.clipsToBounds = YES;
	overlayMiddleView.userInteractionEnabled = YES;
	UITapGestureRecognizer *overlayMiddleViewSingleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(overlayTap:)];
	overlayMiddleViewSingleTap.numberOfTapsRequired = 1;
	[overlayMiddleView addGestureRecognizer:overlayMiddleViewSingleTap];

	overlayMiddleViewShadow = [[UIView alloc] init];
	overlayMiddleViewShadow.frame = CGRectMake(0, 0, overlayMiddleView.bounds.size.width, overlayMiddleView.bounds.size.height);
	overlayMiddleViewShadow.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
	[overlayMiddleView addSubview:overlayMiddleViewShadow];

	playImage = [[UIImageView alloc] init];
	NSString *playImagePath = [playerAssetsBundle pathForResource:@"play" ofType:@"png"];
	playImage.image = [[UIImage imageWithContentsOfFile:playImagePath] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
	playImage.frame = CGRectMake((overlayMiddleView.bounds.size.width / 2) - 24, (overlayMiddleView.bounds.size.height / 2) - 24, 48, 48);
	playImage.alpha = 0.0;
	playImage.tintColor = [UIColor whiteColor];
	playImage.userInteractionEnabled = YES;
	UITapGestureRecognizer *playViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playPauseTap:)];
	playViewTap.numberOfTapsRequired = 1;
	[playImage addGestureRecognizer:playViewTap];
	[overlayMiddleView addSubview:playImage];

	pauseImage = [[UIImageView alloc] init];
	NSString *pauseImagePath = [playerAssetsBundle pathForResource:@"pause" ofType:@"png"];
	pauseImage.image = [[UIImage imageWithContentsOfFile:pauseImagePath] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
	pauseImage.frame = CGRectMake((overlayMiddleView.bounds.size.width / 2) - 24, (overlayMiddleView.bounds.size.height / 2) - 24, 48, 48);
	pauseImage.alpha = 0.0;
	pauseImage.tintColor = [UIColor whiteColor];
	pauseImage.userInteractionEnabled = YES;
	UITapGestureRecognizer *pauseViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playPauseTap:)];
	pauseViewTap.numberOfTapsRequired = 1;
	[pauseImage addGestureRecognizer:pauseViewTap];
	[overlayMiddleView addSubview:pauseImage];

	restartImage = [[UIImageView alloc] init];
	NSString *restartImagePath = [playerAssetsBundle pathForResource:@"restart" ofType:@"png"];
	restartImage.image = [[UIImage imageWithContentsOfFile:restartImagePath] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
	restartImage.frame = CGRectMake((overlayMiddleView.bounds.size.width / 2) - 24, (overlayMiddleView.bounds.size.height / 2) - 24, 48, 48);
	restartImage.alpha = 0.0;
	restartImage.tintColor = [UIColor whiteColor];
	restartImage.userInteractionEnabled = YES;
	UITapGestureRecognizer *restartViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(restartTap:)];
	restartViewTap.numberOfTapsRequired = 1;
	[restartImage addGestureRecognizer:restartViewTap];
	[overlayMiddleView addSubview:restartImage];

	// Overlay Right
	overlayRightView = [[UIView alloc] init];
	overlayRightView.frame = CGRectMake((self.view.bounds.size.width / 3) * 2, boundsWindow.safeAreaInsets.top, self.view.bounds.size.width / 3, self.view.bounds.size.width * 9 / 16);
	overlayRightView.clipsToBounds = YES;
	overlayRightView.userInteractionEnabled = YES;
	UITapGestureRecognizer *overlayRightViewSingleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(overlayTap:)];
	overlayRightViewSingleTap.numberOfTapsRequired = 1;
	[overlayRightView addGestureRecognizer:overlayRightViewSingleTap];
	UITapGestureRecognizer *overlayRightViewDoubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(forwardTap:)];
	overlayRightViewDoubleTap.numberOfTapsRequired = 2;
	[overlayRightView addGestureRecognizer:overlayRightViewDoubleTap];

	overlayRightViewShadow = [[UIView alloc] init];
	overlayRightViewShadow.frame = CGRectMake(0, 0, overlayRightView.bounds.size.width, overlayRightView.bounds.size.height);
	overlayRightViewShadow.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
	[overlayRightView addSubview:overlayRightViewShadow];

	playbackModeSwitch = [[UISwitch alloc] init];
	playbackModeSwitch.frame = CGRectMake(overlayRightView.bounds.size.width - 61, 10, 0, 0);
	[playbackModeSwitch addTarget:self action:@selector(togglePlaybackMode:) forControlEvents:UIControlEventValueChanged];
	[overlayRightView addSubview:playbackModeSwitch];

	// Overlay Other
	videoOverlayTitleLabel = [[UILabel alloc] init];
	videoOverlayTitleLabel.text = self.videoTitle;
	videoOverlayTitleLabel.textColor = [AppColours textColour];
	videoOverlayTitleLabel.numberOfLines = 1;
	videoOverlayTitleLabel.alpha = 0.0;
	
	// Overlays
	overlayHidden = 1;
	[overlayLeftView.subviews setValue:@YES forKeyPath:@"hidden"];
	[overlayMiddleView.subviews setValue:@YES forKeyPath:@"hidden"];
	[overlayRightView.subviews setValue:@YES forKeyPath:@"hidden"];
	videoOverlayTitleLabel.hidden = YES;
	[self.view addSubview:overlayLeftView];
	[self.view addSubview:overlayMiddleView];
	[self.view addSubview:overlayRightView];
	[self.view addSubview:videoOverlayTitleLabel];
}

- (void)sliderSetup {
	progressSlider = [[UISlider alloc] init];
	progressSlider.frame = CGRectMake(0, boundsWindow.safeAreaInsets.top + (self.view.bounds.size.width * 9 / 16), self.view.bounds.size.width, 15);
	NSString *sliderThumbPath = [playerAssetsBundle pathForResource:@"sliderthumb" ofType:@"png"];
	[progressSlider setThumbImage:[UIImage imageWithContentsOfFile:sliderThumbPath] forState:UIControlStateNormal];
	[progressSlider setThumbImage:[UIImage imageWithContentsOfFile:sliderThumbPath] forState:UIControlStateHighlighted];
	progressSlider.minimumTrackTintColor = [UIColor redColor];
	progressSlider.minimumValue = 0.0f;
	progressSlider.maximumValue = [self.videoLength floatValue];
	[progressSlider addTarget:self action:@selector(progressSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
	[self.view addSubview:progressSlider];
}

- (void)scrollSetup {
	scrollView = [[UIScrollView alloc] init];
	scrollView.frame = CGRectMake(0, boundsWindow.safeAreaInsets.top + (self.view.bounds.size.width * 9 / 16) + progressSlider.frame.size.height, self.view.bounds.size.width, self.view.bounds.size.height - boundsWindow.safeAreaInsets.top - boundsWindow.safeAreaInsets.bottom - (self.view.bounds.size.width * 9 / 16) - progressSlider.frame.size.height);
	[scrollView setShowsHorizontalScrollIndicator:NO];
	[scrollView setShowsVerticalScrollIndicator:NO];

	UILabel *videoTitleLabel = [[UILabel alloc] init];
	videoTitleLabel.frame = CGRectMake(0, 0, self.view.bounds.size.width, 40);
	videoTitleLabel.text = self.videoTitle;
	videoTitleLabel.textColor = [AppColours textColour];
	videoTitleLabel.numberOfLines = 2;
	videoTitleLabel.adjustsFontSizeToFitWidth = YES;
	[scrollView addSubview:videoTitleLabel];

	UILabel *videoInfoLabel = [[UILabel alloc] init];
	videoInfoLabel.frame = CGRectMake(0, videoTitleLabel.frame.size.height + 5, self.view.bounds.size.width, 24);
	videoInfoLabel.text = [NSString stringWithFormat:@"%@ Views - %@\n%@ Likes - %@ Dislikes", self.videoViewCount, self.videoAuthor, self.videoLikes, self.videoDislikes];
	videoInfoLabel.textColor = [AppColours textColour];
	videoInfoLabel.numberOfLines = 2;
	videoInfoLabel.adjustsFontSizeToFitWidth = YES;
	[scrollView addSubview:videoInfoLabel];

	UIButton *loopButton = [[UIButton alloc] init];
	NSLayoutConstraint *loopButtonWidth = [NSLayoutConstraint constraintWithItem:loopButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0 constant:120];
	NSLayoutConstraint *loopButtonHeight = [NSLayoutConstraint constraintWithItem:loopButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0 constant:30];
	[loopButton addTarget:self action:@selector(loopButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
 	[loopButton setTitle:@"Loop" forState:UIControlStateNormal];
	[loopButton setTitleColor:[AppColours textColour] forState:UIControlStateNormal];
	loopButton.backgroundColor = [AppColours viewBackgroundColour];
	loopButton.layer.cornerRadius = 5;
	[loopButton addConstraints:@[loopButtonWidth, loopButtonHeight]];
	
	UIButton *shareButton = [[UIButton alloc] init];
	NSLayoutConstraint *shareButtonWidth = [NSLayoutConstraint constraintWithItem:shareButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0 constant:120];
	NSLayoutConstraint *shareButtonHeight = [NSLayoutConstraint constraintWithItem:shareButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0 constant:30];
	[shareButton addTarget:self action:@selector(shareButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
 	[shareButton setTitle:@"Share" forState:UIControlStateNormal];
	[shareButton setTitleColor:[AppColours textColour] forState:UIControlStateNormal];
	shareButton.backgroundColor = [AppColours viewBackgroundColour];
	shareButton.layer.cornerRadius = 5;
	[shareButton addConstraints:@[shareButtonWidth, shareButtonHeight]];

	UIButton *downloadButton = [[UIButton alloc] init];
	NSLayoutConstraint *downloadButtonWidth = [NSLayoutConstraint constraintWithItem:downloadButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0 constant:150];
	NSLayoutConstraint *downloadButtonHeight = [NSLayoutConstraint constraintWithItem:downloadButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0 constant:30];
	[downloadButton addTarget:self action:@selector(downloadButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
 	[downloadButton setTitle:@"Download" forState:UIControlStateNormal];
	[downloadButton setTitleColor:[AppColours textColour] forState:UIControlStateNormal];
	downloadButton.backgroundColor = [AppColours viewBackgroundColour];
	downloadButton.layer.cornerRadius = 5;
	[downloadButton addConstraints:@[downloadButtonWidth, downloadButtonHeight]];

	UIButton *addToPlaylistsButton = [[UIButton alloc] init];
	NSLayoutConstraint *addToPlaylistsButtonWidth = [NSLayoutConstraint constraintWithItem:addToPlaylistsButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0 constant:150];
	NSLayoutConstraint *addToPlaylistsButtonHeight = [NSLayoutConstraint constraintWithItem:addToPlaylistsButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0 constant:30];
	[addToPlaylistsButton addTarget:self action:@selector(addToPlaylistsButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
 	[addToPlaylistsButton setTitle:@"Add To Playlist" forState:UIControlStateNormal];
	[addToPlaylistsButton setTitleColor:[AppColours textColour] forState:UIControlStateNormal];
	addToPlaylistsButton.backgroundColor = [AppColours viewBackgroundColour];
	addToPlaylistsButton.layer.cornerRadius = 5;
	[addToPlaylistsButton addConstraints:@[addToPlaylistsButtonWidth, addToPlaylistsButtonHeight]];

	UIScrollView *stackScrollView = [[UIScrollView alloc] init];
	stackScrollView.frame = CGRectMake(10, videoTitleLabel.frame.size.height + videoInfoLabel.frame.size.height + 25, self.view.bounds.size.width - 20, 30);
	[stackScrollView setShowsHorizontalScrollIndicator:NO];
	[stackScrollView setShowsVerticalScrollIndicator:NO];
	
	UIStackView *stackView = [[UIStackView alloc] init];
    stackView.axis = UILayoutConstraintAxisHorizontal;
	stackView.alignment = UIStackViewAlignmentFill;
    stackView.spacing = 10;

    if (!self.videoLive) {
		[stackView addArrangedSubview:loopButton];
	}
    [stackView addArrangedSubview:shareButton];
	if (!self.videoLive) {
		[stackView addArrangedSubview:downloadButton];
	}
	[stackView addArrangedSubview:addToPlaylistsButton];

	stackView.translatesAutoresizingMaskIntoConstraints = NO;

	[stackScrollView addSubview:stackView];
	[stackView layoutIfNeeded];
	stackScrollView.contentSize = CGSizeMake(stackView.bounds.size.width, 30);
	[scrollView addSubview:stackScrollView];

	UIStepper *rateStepper = [[UIStepper alloc] init];
	rateStepper.frame = CGRectMake(10, videoTitleLabel.frame.size.height + videoInfoLabel.frame.size.height + 70, self.view.bounds.size.width - 10, 15);
	rateStepper.stepValue = 0.1f;
	rateStepper.minimumValue = 0.1f;
	rateStepper.maximumValue = 2.0f;
	rateStepper.value = 1.0f;
	[rateStepper addTarget:self action:@selector(rateStepperValueChanged:) forControlEvents:UIControlEventValueChanged];
	[scrollView addSubview:rateStepper];

	scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, 124);
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
		player.rate = playbackRate;
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    [commandCenter.pauseCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        [player pause];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
	[commandCenter.nextTrackCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        [player seekToTime:CMTimeMakeWithSeconds(CMTimeGetSeconds(player.currentTime) + 10.0f, NSEC_PER_SEC) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
	[commandCenter.previousTrackCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        [player seekToTime:CMTimeMakeWithSeconds(CMTimeGetSeconds(player.currentTime) - 10.0f, NSEC_PER_SEC) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
        return MPRemoteCommandHandlerStatusSuccess;
    }];

	UIImage *videoArt = [UIImage imageWithData:[NSData dataWithContentsOfURL:self.videoArtwork]];
	MPMediaItemArtwork *albumArt = [[MPMediaItemArtwork alloc] initWithBoundsSize:videoArt.size requestHandler:^(CGSize size) {
		return videoArt;
	}];
	[songInfo setObject:[NSString stringWithFormat:@"%@", self.videoTitle] forKey:MPMediaItemPropertyTitle];
	[songInfo setObject:[NSString stringWithFormat:@"%@", self.videoAuthor] forKey:MPMediaItemPropertyArtist];
	[songInfo setObject:albumArt forKey:MPMediaItemPropertyArtwork];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];

	UIInterfaceOrientation orientation = [[[[[UIApplication sharedApplication] windows] firstObject] windowScene] interfaceOrientation];
	switch (orientation) {
		case UIInterfaceOrientationPortrait:
		[self rotationMode:0];
		break;

		case UIInterfaceOrientationLandscapeLeft:
		[self rotationMode:1];
		break;

		case UIInterfaceOrientationLandscapeRight:
		[self rotationMode:1];
		break;

		case UIInterfaceOrientationPortraitUpsideDown:
		if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
			[self rotationMode:0];
		}
		break;

		case UIInterfaceOrientationUnknown:
		break;
	}
}

- (void)playerTimeChanged {
	progressSlider.value = (float)CMTimeGetSeconds(player.currentTime);
	videoTimeLabel.text = [NSString stringWithFormat:@"%d:%02d / %d:%02d", ((int)CMTimeGetSeconds(player.currentTime)) / 60, ((int)CMTimeGetSeconds(player.currentTime)) % 60, [self.videoLength intValue] / 60, [self.videoLength intValue] % 60];

	if ([[NSUserDefaults standardUserDefaults] integerForKey:@"kBackgroundMode"] == 1 || [[NSUserDefaults standardUserDefaults] integerForKey:@"kBackgroundMode"] == 2) {
		MPNowPlayingInfoCenter *playingInfoCenter = [MPNowPlayingInfoCenter defaultCenter];
		[songInfo setObject:[NSNumber numberWithDouble:CMTimeGetSeconds(player.currentTime)] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
		[songInfo setObject:[NSNumber numberWithDouble:CMTimeGetSeconds(playerItem.duration)] forKey:MPMediaItemPropertyPlaybackDuration];
		[playingInfoCenter setNowPlayingInfo:songInfo];
	}

	if ([NSJSONSerialization isValidJSONObject:self.sponsorBlockValues]) {
		for (NSMutableDictionary *jsonDictionary in self.sponsorBlockValues) {
            if ([[jsonDictionary objectForKey:@"category"] isEqual:@"sponsor"] && [[NSUserDefaults standardUserDefaults] integerForKey:@"kSponsorBlockSponsorSegmentedInt"] && CMTimeGetSeconds(player.currentTime) >= [[jsonDictionary objectForKey:@"segment"][0] floatValue] && CMTimeGetSeconds(player.currentTime) <= [[jsonDictionary objectForKey:@"segment"][1] floatValue]) {
				if ([[NSUserDefaults standardUserDefaults] integerForKey:@"kSponsorBlockSponsorSegmentedInt"] == 1) {
					[player seekToTime:CMTimeMakeWithSeconds([[jsonDictionary objectForKey:@"segment"][1] floatValue] + 1, NSEC_PER_SEC) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
				}
			} else if ([[jsonDictionary objectForKey:@"category"] isEqual:@"selfpromo"] && [[NSUserDefaults standardUserDefaults] integerForKey:@"kSponsorBlockSelfPromoSegmentedInt"] && CMTimeGetSeconds(player.currentTime) >= [[jsonDictionary objectForKey:@"segment"][0] floatValue] && CMTimeGetSeconds(player.currentTime) <= [[jsonDictionary objectForKey:@"segment"][1] floatValue]) {
				if ([[NSUserDefaults standardUserDefaults] integerForKey:@"kSponsorBlockSelfPromoSegmentedInt"] == 1) {
					[player seekToTime:CMTimeMakeWithSeconds([[jsonDictionary objectForKey:@"segment"][1] floatValue] + 1, NSEC_PER_SEC) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
				}
			} else if ([[jsonDictionary objectForKey:@"category"] isEqual:@"interaction"] && [[NSUserDefaults standardUserDefaults] integerForKey:@"kSponsorBlockInteractionSegmentedInt"] && CMTimeGetSeconds(player.currentTime) >= [[jsonDictionary objectForKey:@"segment"][0] floatValue] && CMTimeGetSeconds(player.currentTime) <= [[jsonDictionary objectForKey:@"segment"][1] floatValue]) {
				if ([[NSUserDefaults standardUserDefaults] integerForKey:@"kSponsorBlockInteractionSegmentedInt"] == 1) {
					[player seekToTime:CMTimeMakeWithSeconds([[jsonDictionary objectForKey:@"segment"][1] floatValue] + 1, NSEC_PER_SEC) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
				}
			} else if ([[jsonDictionary objectForKey:@"category"] isEqual:@"intro"] && [[NSUserDefaults standardUserDefaults] integerForKey:@"kSponsorBlockIntroSegmentedInt"] && CMTimeGetSeconds(player.currentTime) >= [[jsonDictionary objectForKey:@"segment"][0] floatValue] && CMTimeGetSeconds(player.currentTime) <= [[jsonDictionary objectForKey:@"segment"][1] floatValue]) {
				if ([[NSUserDefaults standardUserDefaults] integerForKey:@"kSponsorBlockIntroSegmentedInt"] == 1) {
					[player seekToTime:CMTimeMakeWithSeconds([[jsonDictionary objectForKey:@"segment"][1] floatValue] + 1, NSEC_PER_SEC) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
				}
			} else if ([[jsonDictionary objectForKey:@"category"] isEqual:@"outro"] && [[NSUserDefaults standardUserDefaults] integerForKey:@"kSponsorBlockOutroSegmentedInt"] && CMTimeGetSeconds(player.currentTime) >= [[jsonDictionary objectForKey:@"segment"][0] floatValue] && CMTimeGetSeconds(player.currentTime) <= [[jsonDictionary objectForKey:@"segment"][1] floatValue]) {
				if ([[NSUserDefaults standardUserDefaults] integerForKey:@"kSponsorBlockOutroSegmentedInt"] == 1) {
					[player seekToTime:CMTimeMakeWithSeconds([[jsonDictionary objectForKey:@"segment"][1] floatValue] + 1, NSEC_PER_SEC) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
				}
			} else if ([[jsonDictionary objectForKey:@"category"] isEqual:@"preview"] && [[NSUserDefaults standardUserDefaults] integerForKey:@"kSponsorBlockPreviewSegmentedInt"] && CMTimeGetSeconds(player.currentTime) >= [[jsonDictionary objectForKey:@"segment"][0] floatValue] && CMTimeGetSeconds(player.currentTime) <= [[jsonDictionary objectForKey:@"segment"][1] floatValue]) {
				if ([[NSUserDefaults standardUserDefaults] integerForKey:@"kSponsorBlockPreviewSegmentedInt"] == 1) {
					[player seekToTime:CMTimeMakeWithSeconds([[jsonDictionary objectForKey:@"segment"][1] floatValue] + 1, NSEC_PER_SEC) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
				}
			} else if ([[jsonDictionary objectForKey:@"category"] isEqual:@"music_offtopic"] && [[NSUserDefaults standardUserDefaults] integerForKey:@"kSponsorBlockMusicOffTopicSegmentedInt"] && CMTimeGetSeconds(player.currentTime) >= [[jsonDictionary objectForKey:@"segment"][0] floatValue] && CMTimeGetSeconds(player.currentTime) <= [[jsonDictionary objectForKey:@"segment"][1] floatValue]) {
				if ([[NSUserDefaults standardUserDefaults] integerForKey:@"kSponsorBlockMusicOffTopicSegmentedInt"] == 1) {
					[player seekToTime:CMTimeMakeWithSeconds([[jsonDictionary objectForKey:@"segment"][1] floatValue] + 1, NSEC_PER_SEC) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
				}
			}
		}
	}
}

- (void)rotationMode:(int)mode {
	if (mode == 0) {
		deviceOrientation = NO;

		// Main
		self.view.backgroundColor = [AppColours mainBackgroundColour];
		playerLayer.frame = CGRectMake(0, boundsWindow.safeAreaInsets.top, self.view.bounds.size.width, self.view.bounds.size.width * 9 / 16);
		videoImage.frame = CGRectMake(0, boundsWindow.safeAreaInsets.top, self.view.bounds.size.width, self.view.bounds.size.width * 9 / 16);

		// Overlay Left
		overlayLeftView.frame = CGRectMake(0, boundsWindow.safeAreaInsets.top, self.view.bounds.size.width / 3, self.view.bounds.size.width * 9 / 16);
		overlayLeftViewShadow.frame = CGRectMake(0, 0, overlayLeftView.bounds.size.width, overlayLeftView.bounds.size.height);
		collapseImage.alpha = 1.0;
		videoTimeLabel.frame = CGRectMake(10, overlayLeftView.bounds.size.height - 25, 80, 15);

		// Overlay Middle
		overlayMiddleView.frame = CGRectMake(self.view.bounds.size.width / 3, boundsWindow.safeAreaInsets.top, self.view.bounds.size.width / 3, self.view.bounds.size.width * 9 / 16);
		overlayMiddleViewShadow.frame = CGRectMake(0, 0, overlayMiddleView.bounds.size.width, overlayMiddleView.bounds.size.height);
		playImage.frame = CGRectMake((overlayMiddleView.bounds.size.width / 2) - 24, (overlayMiddleView.bounds.size.height / 2) - 24, 48, 48);
		pauseImage.frame = CGRectMake((overlayMiddleView.bounds.size.width / 2) - 24, (overlayMiddleView.bounds.size.height / 2) - 24, 48, 48);
		restartImage.frame = CGRectMake((overlayMiddleView.bounds.size.width / 2) - 24, (overlayMiddleView.bounds.size.height / 2) - 24, 48, 48);

		// Overlay Right
		overlayRightView.frame = CGRectMake((self.view.bounds.size.width / 3) * 2, boundsWindow.safeAreaInsets.top, self.view.bounds.size.width / 3, self.view.bounds.size.width * 9 / 16);
		overlayRightViewShadow.frame = CGRectMake(0, 0, overlayRightView.bounds.size.width, overlayRightView.bounds.size.height);
		playbackModeSwitch.frame = CGRectMake(overlayRightView.bounds.size.width - 61, 10, 0, 0);

		// Overlay Other
		videoOverlayTitleLabel.alpha = 0.0;

		// Info
		progressSlider.frame = CGRectMake(0, boundsWindow.safeAreaInsets.top + (self.view.bounds.size.width * 9 / 16), self.view.bounds.size.width, 15);
		progressSlider.hidden = NO;
		scrollView.hidden = NO;
	}
	if (mode == 1) {
		deviceOrientation = YES;

		// Main
		self.view.backgroundColor = [UIColor blackColor];
		playerLayer.frame = self.view.bounds;
		videoImage.frame = self.view.safeAreaLayoutGuide.layoutFrame;

		// Overlay Left
		overlayLeftView.frame = CGRectMake(0, 0, self.view.bounds.size.width / 3, self.view.bounds.size.height);
		overlayLeftViewShadow.frame = CGRectMake(0, 0, overlayLeftView.bounds.size.width, overlayLeftView.bounds.size.height);
		collapseImage.alpha = 0.0;
		videoTimeLabel.frame = CGRectMake(boundsWindow.safeAreaInsets.left + 10, (self.view.bounds.size.height / 2) + 75, 80, 15);
		
		// Overlay Middle
		overlayMiddleView.frame = CGRectMake(self.view.bounds.size.width / 3, 0, self.view.bounds.size.width / 3, self.view.bounds.size.height);
		overlayMiddleViewShadow.frame = CGRectMake(0, 0, overlayMiddleView.bounds.size.width, overlayMiddleView.bounds.size.height);
		playImage.frame = CGRectMake((overlayMiddleView.bounds.size.width / 2) - 24, (overlayMiddleView.bounds.size.height / 2) - 24, 48, 48);
		pauseImage.frame = CGRectMake((overlayMiddleView.bounds.size.width / 2) - 24, (overlayMiddleView.bounds.size.height / 2) - 24, 48, 48);
		restartImage.frame = CGRectMake((overlayMiddleView.bounds.size.width / 2) - 24, (overlayMiddleView.bounds.size.height / 2) - 24, 48, 48);
		
		// Overlay Right
		overlayRightView.frame = CGRectMake((self.view.bounds.size.width / 3) * 2, 0, self.view.bounds.size.width / 3, self.view.bounds.size.height);
		overlayRightViewShadow.frame = CGRectMake(0, 0, overlayRightView.bounds.size.width, overlayRightView.bounds.size.height);
		playbackModeSwitch.frame = CGRectMake(overlayRightView.bounds.size.width - boundsWindow.safeAreaInsets.right - 61, 10, 0, 0);

		// Overlay Other
		videoOverlayTitleLabel.frame = CGRectMake(boundsWindow.safeAreaInsets.left, 10, self.view.bounds.size.width - boundsWindow.safeAreaInsets.left - boundsWindow.safeAreaInsets.right - (self.view.bounds.size.width / 3), 31);
		videoOverlayTitleLabel.alpha = 1.0;

		// Info
		progressSlider.frame = CGRectMake(boundsWindow.safeAreaInsets.left, (self.view.bounds.size.height / 2) + 100, self.view.bounds.size.width - boundsWindow.safeAreaInsets.left - boundsWindow.safeAreaInsets.right, 15);
		if (overlayHidden) {
			progressSlider.hidden = YES;
		}
		scrollView.hidden = YES;
	}
}

@end

@implementation PlayerViewController (Privates)

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == player && [keyPath isEqualToString:@"status"]) {
        if (player.status == AVPlayerStatusReadyToPlay) {
			if ([[NSUserDefaults standardUserDefaults] integerForKey:@"kBackgroundMode"] == 1 || [[NSUserDefaults standardUserDefaults] integerForKey:@"kBackgroundMode"] == 2) {
				[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
				[[AVAudioSession sharedInstance] setActive:YES error:nil];
				[[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
		
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
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerReachedEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
            
			NSFileManager *fm = [[NSFileManager alloc] init];
			NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    		NSString *documentsDirectory = [paths objectAtIndex:0];
			NSString *playerPlistFilePath = [documentsDirectory stringByAppendingPathComponent:@"player.plist"];
			if ([fm fileExistsAtPath:playerPlistFilePath]) {
				NSMutableDictionary *playerDictionary = [NSMutableDictionary dictionaryWithContentsOfFile:playerPlistFilePath];
				if ([playerDictionary objectForKey:self.videoID]) {
					[player seekToTime:CMTimeMakeWithSeconds([[playerDictionary objectForKey:self.videoID] floatValue], NSEC_PER_SEC) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
						[player play];
						player.rate = playbackRate;
					}];
				} else {
					[player play];
					player.rate = playbackRate;
				}
			} else {
				[player play];
				player.rate = playbackRate;
			}
        }
    } else if (object == player && [keyPath isEqualToString:@"timeControlStatus"]) {
        if (player.timeControlStatus == AVPlayerTimeControlStatusPlaying) {
			playImage.alpha = 0.0;
			pauseImage.alpha = 1.0;
			restartImage.alpha = 0.0;
        } else if (player.timeControlStatus == AVPlayerTimeControlStatusPaused) {
			if ([[NSString stringWithFormat:@"%d:%02d", ((int)CMTimeGetSeconds(player.currentTime)) / 60, ((int)CMTimeGetSeconds(player.currentTime)) % 60] isEqual:[NSString stringWithFormat:@"%d:%02d", ((int)CMTimeGetSeconds(playerItem.duration)) / 60, ((int)CMTimeGetSeconds(playerItem.duration)) % 60]]) {
				playImage.alpha = 0.0;
				pauseImage.alpha = 0.0;
				restartImage.alpha = 1.0;
			} else {
				playImage.alpha = 1.0;
				pauseImage.alpha = 0.0;
				restartImage.alpha = 0.0;
			}
		}
		if ([[NSUserDefaults standardUserDefaults] integerForKey:@"kBackgroundMode"] == 1 || [[NSUserDefaults standardUserDefaults] integerForKey:@"kBackgroundMode"] == 2) {
			MPNowPlayingInfoCenter *playingInfoCenter = [MPNowPlayingInfoCenter defaultCenter];
			[songInfo setObject:[NSNumber numberWithDouble:CMTimeGetSeconds(player.currentTime)] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
			[songInfo setObject:[NSNumber numberWithDouble:CMTimeGetSeconds(playerItem.duration)] forKey:MPMediaItemPropertyPlaybackDuration];
			[playingInfoCenter setNowPlayingInfo:songInfo];
		}
    }
}

- (void)overlayTap:(UITapGestureRecognizer *)recognizer {
	if (overlayHidden) {
		overlayHidden = NO;
		overlayTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(overlayTimerCheck:) userInfo:nil repeats:NO];
		[overlayLeftView.subviews setValue:@NO forKeyPath:@"hidden"];
		[overlayMiddleView.subviews setValue:@NO forKeyPath:@"hidden"];
		[overlayRightView.subviews setValue:@NO forKeyPath:@"hidden"];
		videoOverlayTitleLabel.hidden = NO;
		progressSlider.hidden = NO;
	} else {
		overlayHidden = YES;
		if ([overlayTimer isValid]) {
			[overlayTimer invalidate];
		}
		overlayTimer = nil;
		[overlayLeftView.subviews setValue:@YES forKeyPath:@"hidden"];
		[overlayMiddleView.subviews setValue:@YES forKeyPath:@"hidden"];
		[overlayRightView.subviews setValue:@YES forKeyPath:@"hidden"];
		videoOverlayTitleLabel.hidden = YES;
		if (deviceOrientation) {
			progressSlider.hidden = YES;
		} else {
			progressSlider.hidden = NO;
		}
	}
}

- (void)overlayTimerCheck:(NSTimer *)timer {
	if (!overlayHidden) {
		overlayHidden = YES;
		if ([overlayTimer isValid]) {
			[overlayTimer invalidate];
		}
		overlayTimer = nil;
		[overlayLeftView.subviews setValue:@YES forKeyPath:@"hidden"];
		[overlayMiddleView.subviews setValue:@YES forKeyPath:@"hidden"];
		[overlayRightView.subviews setValue:@YES forKeyPath:@"hidden"];
		videoOverlayTitleLabel.hidden = YES;
		if (deviceOrientation) {
			progressSlider.hidden = YES;
		} else {
			progressSlider.hidden = NO;
		}
	} else {
		if ([overlayTimer isValid]) {
			[overlayTimer invalidate];
		}
		overlayTimer = nil;
	}
}

- (void)collapseTap:(UITapGestureRecognizer *)recognizer {
	if ([pictureInPictureController isPictureInPictureActive]) {
        [pictureInPictureController stopPictureInPicture];
    }
    [player pause];
	[PlayerHistory init:self.videoID:[NSString stringWithFormat:@"%f", CMTimeGetSeconds(player.currentTime)]];
	playerLayer.player = nil;
	player = nil;
    [playerLayer removeFromSuperlayer];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)rewindTap:(UITapGestureRecognizer *)recognizer {
	[player seekToTime:CMTimeMakeWithSeconds(CMTimeGetSeconds(player.currentTime) - 10.0f, NSEC_PER_SEC) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
		if (!overlayHidden) {
			overlayHidden = YES;
			if ([overlayTimer isValid]) {
				[overlayTimer invalidate];
			}
			overlayTimer = nil;
			[overlayLeftView.subviews setValue:@YES forKeyPath:@"hidden"];
			[overlayMiddleView.subviews setValue:@YES forKeyPath:@"hidden"];
			[overlayRightView.subviews setValue:@YES forKeyPath:@"hidden"];
			videoOverlayTitleLabel.hidden = YES;
			if (deviceOrientation) {
				progressSlider.hidden = YES;
			} else {
				progressSlider.hidden = NO;
			}
		} else {
			if ([overlayTimer isValid]) {
				[overlayTimer invalidate];
			}
			overlayTimer = nil;
		}
	}];
}

- (void)playPauseTap:(UITapGestureRecognizer *)recognizer {
	if (player.timeControlStatus == AVPlayerTimeControlStatusPlaying) {
		[player pause];
	} else {
		[player play];
		player.rate = playbackRate;
	}
}

- (void)restartTap:(UITapGestureRecognizer *)recognizer {
	[player seekToTime:CMTimeMakeWithSeconds(0, NSEC_PER_SEC) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
		[player play];
		player.rate = playbackRate;
	}];
}

- (void)forwardTap:(UITapGestureRecognizer *)recognizer {
	[player seekToTime:CMTimeMakeWithSeconds(CMTimeGetSeconds(player.currentTime) + 10.0f, NSEC_PER_SEC) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
		if (!overlayHidden) {
			overlayHidden = YES;
			if ([overlayTimer isValid]) {
				[overlayTimer invalidate];
			}
			overlayTimer = nil;
			[overlayLeftView.subviews setValue:@YES forKeyPath:@"hidden"];
			[overlayMiddleView.subviews setValue:@YES forKeyPath:@"hidden"];
			[overlayRightView.subviews setValue:@YES forKeyPath:@"hidden"];
			videoOverlayTitleLabel.hidden = YES;
			if (deviceOrientation) {
				progressSlider.hidden = YES;
			} else {
				progressSlider.hidden = NO;
			}
		} else {
			if ([overlayTimer isValid]) {
				[overlayTimer invalidate];
			}
			overlayTimer = nil;
		}
	}];
}

- (void)enteredBackground:(NSNotification *)notification {
	if (![pictureInPictureController isPictureInPictureActive]) {
		if (!playbackMode) {
			playerLayer.player = nil;
		}
	}

	MPNowPlayingInfoCenter *playingInfoCenter = [MPNowPlayingInfoCenter defaultCenter];
	[songInfo setObject:[NSNumber numberWithDouble:CMTimeGetSeconds(player.currentTime)] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
	[songInfo setObject:[NSNumber numberWithDouble:CMTimeGetSeconds(playerItem.duration)] forKey:MPMediaItemPropertyPlaybackDuration];
	[playingInfoCenter setNowPlayingInfo:songInfo];
}

- (void)enteredForeground:(NSNotification *)notification {
	if (![pictureInPictureController isPictureInPictureActive]) {
		if (!playbackMode) {
			playerLayer.player = player;
		}
	}
}

- (void)progressSliderValueChanged:(UISlider *)sender {
	[player seekToTime:CMTimeMakeWithSeconds(sender.value, NSEC_PER_SEC) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
		if (player.timeControlStatus == AVPlayerTimeControlStatusPlaying) {
			playImage.alpha = 0.0;
			pauseImage.alpha = 1.0;
			restartImage.alpha = 0.0;
        } else if (player.timeControlStatus == AVPlayerTimeControlStatusPaused) {
			if ([[NSString stringWithFormat:@"%d:%02d", ((int)CMTimeGetSeconds(player.currentTime)) / 60, ((int)CMTimeGetSeconds(player.currentTime)) % 60] isEqual:[NSString stringWithFormat:@"%d:%02d", ((int)CMTimeGetSeconds(playerItem.duration)) / 60, ((int)CMTimeGetSeconds(playerItem.duration)) % 60]]) {
				playImage.alpha = 0.0;
				pauseImage.alpha = 0.0;
				restartImage.alpha = 1.0;
			} else {
				playImage.alpha = 1.0;
				pauseImage.alpha = 0.0;
				restartImage.alpha = 0.0;
			}
		}
	}];
}

- (void)rateStepperValueChanged:(UIStepper *)sender {
	playbackRate = [[NSString stringWithFormat:@"%.01f", sender.value] floatValue];
	player.rate = playbackRate;
	MainPopupView *mainPopupView = [[MainPopupView alloc] initWithFrame:CGRectMake(20, self.view.bounds.size.height - boundsWindow.safeAreaInsets.bottom - 40, self.view.bounds.size.width - 40, 40):[NSString stringWithFormat:@"Speed: %.01f", playbackRate]:0];
	[self.view addSubview:mainPopupView];
	[NSTimer scheduledTimerWithTimeInterval:3.0 repeats:NO block:^(NSTimer *timer) {
		[mainPopupView removeFromSuperview];
	}];
}

- (MPRemoteCommandHandlerStatus)changedLockscreenPlaybackSlider:(MPChangePlaybackPositionCommandEvent *)event {
    [player seekToTime:CMTimeMakeWithSeconds(event.positionTime, NSEC_PER_SEC) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    return MPRemoteCommandHandlerStatusSuccess;
}

- (void)playerReachedEnd:(NSNotification *)notification {
	if (loopEnabled) {
		[player seekToTime:CMTimeMakeWithSeconds(0, NSEC_PER_SEC) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
			[player play];
			player.rate = playbackRate;
		}];
	}
}

- (void)loopButtonClicked:(UIButton *)sender {
	if (!loopEnabled) {
		loopEnabled = YES;
		MainPopupView *mainPopupView = [[MainPopupView alloc] initWithFrame:CGRectMake(20, self.view.bounds.size.height - boundsWindow.safeAreaInsets.bottom - 40, self.view.bounds.size.width - 40, 40):@"Loop Enabled":0];
		[self.view addSubview:mainPopupView];
		[NSTimer scheduledTimerWithTimeInterval:3.0 repeats:NO block:^(NSTimer *timer) {
			[mainPopupView removeFromSuperview];
		}];
	} else {
		loopEnabled = NO;
		MainPopupView *mainPopupView = [[MainPopupView alloc] initWithFrame:CGRectMake(20, self.view.bounds.size.height - boundsWindow.safeAreaInsets.bottom - 40, self.view.bounds.size.width - 40, 40):@"Loop Disabled":0];
		[self.view addSubview:mainPopupView];
		[NSTimer scheduledTimerWithTimeInterval:3.0 repeats:NO block:^(NSTimer *timer) {
			[mainPopupView removeFromSuperview];
		}];
	}
}

- (void)shareButtonClicked:(UIButton *)sender {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.youtube.com/watch?v=%@", self.videoID]];
	
    UIActivityViewController *shareSheet = [[UIActivityViewController alloc] initWithActivityItems:@[url] applicationActivities:nil];
	[shareSheet setModalPresentationStyle:UIModalPresentationPopover];
	UIPopoverPresentationController *popPresenter = [shareSheet popoverPresentationController];
	popPresenter.sourceView = self.view;
	popPresenter.sourceRect = self.view.bounds;
	popPresenter.permittedArrowDirections = 0;
	[self presentViewController:shareSheet animated:YES completion:nil];
}

- (void)downloadButtonClicked:(UIButton *)sender {
	if ([pictureInPictureController isPictureInPictureActive]) {
		[pictureInPictureController stopPictureInPicture];
	}
	[player pause];
	[YouTubeDownloader init:self.videoID];
}

- (void)addToPlaylistsButtonClicked:(UIButton *)sender {
	if ([pictureInPictureController isPictureInPictureActive]) {
        [pictureInPictureController stopPictureInPicture];
    }
	[player pause];

	AddToPlaylistsViewController *addToPlaylistsViewController = [[AddToPlaylistsViewController alloc] init];
	addToPlaylistsViewController.videoID = self.videoID;

    [self presentViewController:addToPlaylistsViewController animated:YES completion:nil];
}

- (void)togglePlaybackMode:(UISwitch *)sender {
    if ([sender isOn]) {
		playbackMode = YES;
		playerLayer.player = nil;
		playerLayer.hidden = YES;
		videoImage.hidden = NO;
    } else {
		playbackMode = NO;
		playerLayer.player = player;
		playerLayer.hidden = NO;
		videoImage.hidden = YES;
    }
}

@end