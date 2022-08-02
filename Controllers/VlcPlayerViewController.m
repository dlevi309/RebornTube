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
	VLCMediaPlayer *mediaPlayer;

	// Overlay
	UIView *overlayView;
	UIImageView *collapseImage;
	UIImageView *rewindImage;
	UIImageView *playImage;
	UIImageView *pauseImage;
	UIImageView *forwardImage;

	// Info
	UISlider *progressSlider;
	UILabel *videoTitleLabel;
	UILabel *videoInfoLabel;
	UIButton *shareButton;

	// Developer
	UILabel *developerInfoLabel;
}
- (void)keysSetup;
- (void)playerSetup;
- (void)overlaySetup;
- (void)infoSetup;
@end

@implementation VlcPlayerViewController

- (void)loadView {
	[super loadView];

	self.view.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
	[self.navigationController setNavigationBarHidden:YES animated:NO];

	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
    self.navigationItem.rightBarButtonItem = doneButton;

	[self keysSetup];
	[self playerSetup];
	[self overlaySetup];
	[self infoSetup];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (void)keysSetup {
	boundsWindow = [[UIApplication sharedApplication] keyWindow];
	deviceOrientation = 0;
	playerAssetsBundlePath = [[NSBundle mainBundle] pathForResource:@"PlayerAssets" ofType:@"bundle"];
	playerAssetsBundle = [NSBundle bundleWithPath:playerAssetsBundlePath];
}

- (void)playerSetup {
	vlcView = [[UIView alloc] init];
	vlcView.frame = CGRectMake(0, boundsWindow.safeAreaInsets.top, self.view.bounds.size.width, self.view.bounds.size.width * 9 / 16);
	[self.view addSubview:vlcView];

    mediaPlayer = [[VLCMediaPlayer alloc] init];
    mediaPlayer.delegate = self;
    mediaPlayer.drawable = vlcView;

    [mediaPlayer addObserver:self forKeyPath:@"time" options:0 context:nil];
    [mediaPlayer addObserver:self forKeyPath:@"remainingTime" options:0 context:nil];
	mediaPlayer.media = [VLCMedia mediaWithURL:self.videoURL];
	[mediaPlayer addPlaybackSlave:self.audioURL type:VLCMediaPlaybackSlaveTypeAudio enforce:YES];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enteredBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
	[mediaPlayer play];
}

- (void)overlaySetup {
	overlayView = [[UIView alloc] init];
	overlayView.frame = CGRectMake(0, boundsWindow.safeAreaInsets.top, self.view.bounds.size.width, self.view.bounds.size.width * 9 / 16);
	overlayView.userInteractionEnabled = YES;
	UITapGestureRecognizer *overlayViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(overlayTap:)];
	overlayViewTap.numberOfTapsRequired = 1;
	[overlayView addGestureRecognizer:overlayViewTap];
	[self.view addSubview:overlayView];
	
	collapseImage = [[UIImageView alloc] init];
	NSString *collapseImagePath = [playerAssetsBundle pathForResource:@"collapse" ofType:@"png"];
	collapseImage.image = [[UIImage imageWithContentsOfFile:collapseImagePath] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
	collapseImage.frame = CGRectMake(10, boundsWindow.safeAreaInsets.top + 10, 24, 24);
	collapseImage.tintColor = [UIColor whiteColor];
	collapseImage.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
	collapseImage.layer.cornerRadius = collapseImage.bounds.size.width / 2;
	collapseImage.clipsToBounds = YES;
	collapseImage.hidden = YES;
	collapseImage.userInteractionEnabled = YES;
	UITapGestureRecognizer *collapseViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(collapseTap:)];
	collapseViewTap.numberOfTapsRequired = 1;
	[collapseImage addGestureRecognizer:collapseViewTap];
	[self.view addSubview:collapseImage];
	
	rewindImage = [[UIImageView alloc] init];
	NSString *rewindImagePath = [playerAssetsBundle pathForResource:@"rewind" ofType:@"png"];
	rewindImage.image = [[UIImage imageWithContentsOfFile:rewindImagePath] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
	rewindImage.frame = CGRectMake((overlayView.bounds.size.width / 2) - 96, boundsWindow.safeAreaInsets.top + (overlayView.bounds.size.height / 2) - 24, 48, 48);
	rewindImage.tintColor = [UIColor whiteColor];
	rewindImage.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
	rewindImage.layer.cornerRadius = rewindImage.bounds.size.width / 2;
	rewindImage.clipsToBounds = YES;
	rewindImage.hidden = YES;
	rewindImage.userInteractionEnabled = YES;
	UITapGestureRecognizer *rewindViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rewindTap:)];
	rewindViewTap.numberOfTapsRequired = 1;
	[rewindImage addGestureRecognizer:rewindViewTap];
	[self.view addSubview:rewindImage];

	playImage = [[UIImageView alloc] init];
	NSString *playImagePath = [playerAssetsBundle pathForResource:@"play" ofType:@"png"];
	playImage.image = [[UIImage imageWithContentsOfFile:playImagePath] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
	playImage.frame = CGRectMake((overlayView.bounds.size.width / 2) - 24, boundsWindow.safeAreaInsets.top + (overlayView.bounds.size.height / 2) - 24, 48, 48);
	playImage.tintColor = [UIColor whiteColor];
	playImage.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
	playImage.layer.cornerRadius = playImage.bounds.size.width / 2;
	playImage.clipsToBounds = YES;
	playImage.hidden = YES;
	playImage.userInteractionEnabled = YES;
	UITapGestureRecognizer *playViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playPauseTap:)];
	playViewTap.numberOfTapsRequired = 1;
	[playImage addGestureRecognizer:playViewTap];
	[self.view addSubview:playImage];

	pauseImage = [[UIImageView alloc] init];
	NSString *pauseImagePath = [playerAssetsBundle pathForResource:@"pause" ofType:@"png"];
	pauseImage.image = [[UIImage imageWithContentsOfFile:pauseImagePath] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
	pauseImage.frame = CGRectMake((overlayView.bounds.size.width / 2) - 24, boundsWindow.safeAreaInsets.top + (overlayView.bounds.size.height / 2) - 24, 48, 48);
	pauseImage.tintColor = [UIColor whiteColor];
	pauseImage.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
	pauseImage.layer.cornerRadius = pauseImage.bounds.size.width / 2;
	pauseImage.clipsToBounds = YES;
	pauseImage.hidden = YES;
	pauseImage.userInteractionEnabled = YES;
	UITapGestureRecognizer *pauseViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playPauseTap:)];
	pauseViewTap.numberOfTapsRequired = 1;
	[pauseImage addGestureRecognizer:pauseViewTap];
	[self.view addSubview:pauseImage];

	forwardImage = [[UIImageView alloc] init];
	NSString *forwardImagePath = [playerAssetsBundle pathForResource:@"forward" ofType:@"png"];
	forwardImage.image = [[UIImage imageWithContentsOfFile:forwardImagePath] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
	forwardImage.frame = CGRectMake((overlayView.bounds.size.width / 2) + 48, boundsWindow.safeAreaInsets.top + (overlayView.bounds.size.height / 2) - 24, 48, 48);
	forwardImage.tintColor = [UIColor whiteColor];
	forwardImage.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
	forwardImage.layer.cornerRadius = forwardImage.bounds.size.width / 2;
	forwardImage.clipsToBounds = YES;
	forwardImage.hidden = YES;
	forwardImage.userInteractionEnabled = YES;
	UITapGestureRecognizer *forwardViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(forwardTap:)];
	forwardViewTap.numberOfTapsRequired = 1;
	[forwardImage addGestureRecognizer:forwardViewTap];
	[self.view addSubview:forwardImage];
}

- (void)infoSetup {
	progressSlider = [[UISlider alloc] init];
	progressSlider.frame = CGRectMake(0, boundsWindow.safeAreaInsets.top + overlayView.frame.size.height, self.view.bounds.size.width, 10);
	NSString *sliderThumbPath = [playerAssetsBundle pathForResource:@"sliderthumb" ofType:@"png"];
	[progressSlider setThumbImage:[UIImage imageWithContentsOfFile:sliderThumbPath] forState:UIControlStateNormal];
	[progressSlider setThumbImage:[UIImage imageWithContentsOfFile:sliderThumbPath] forState:UIControlStateHighlighted];
	progressSlider.minimumTrackTintColor = [UIColor redColor];
	progressSlider.minimumValue = 0.0f;
	[progressSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
	[self.view addSubview:progressSlider];

	videoTitleLabel = [[UILabel alloc] init];
	videoTitleLabel.frame = CGRectMake(0, boundsWindow.safeAreaInsets.top + overlayView.frame.size.height + progressSlider.frame.size.height + 15, self.view.bounds.size.width, 40);
	videoTitleLabel.text = self.videoTitle;
	videoTitleLabel.textColor = [UIColor whiteColor];
	videoTitleLabel.numberOfLines = 2;
	videoTitleLabel.adjustsFontSizeToFitWidth = true;
	videoTitleLabel.adjustsFontForContentSizeCategory = false;
	[self.view addSubview:videoTitleLabel];

	videoInfoLabel = [[UILabel alloc] init];
	videoInfoLabel.frame = CGRectMake(0, boundsWindow.safeAreaInsets.top + overlayView.frame.size.height + progressSlider.frame.size.height + 20 + videoTitleLabel.frame.size.height, self.view.bounds.size.width, 60);
	videoInfoLabel.text = [NSString stringWithFormat:@"View Count: %@\nLikes: %@\nDislikes: %@", self.videoViewCount, self.videoLikes, self.videoDislikes];
	videoInfoLabel.textColor = [UIColor whiteColor];
	videoInfoLabel.numberOfLines = 3;
	videoInfoLabel.adjustsFontSizeToFitWidth = true;
	videoInfoLabel.adjustsFontForContentSizeCategory = false;
	[self.view addSubview:videoInfoLabel];

	shareButton = [[UIButton alloc] init];
	shareButton.frame = CGRectMake(20, boundsWindow.safeAreaInsets.top + overlayView.frame.size.height + progressSlider.frame.size.height + 25 + videoTitleLabel.frame.size.height + videoInfoLabel.frame.size.height, self.view.bounds.size.width - 40, 60);
	[shareButton addTarget:self action:@selector(shareButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
 	[shareButton setTitle:@"Share" forState:UIControlStateNormal];
	shareButton.backgroundColor = [UIColor colorWithRed:0.110 green:0.110 blue:0.118 alpha:1.0];
	shareButton.tintColor = [UIColor whiteColor];
	shareButton.layer.cornerRadius = 5;
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"kEnableDeveloperOptions"] == NO) {
		[self.view addSubview:shareButton];
	}

	developerInfoLabel = [[UILabel alloc] init];
	developerInfoLabel.frame = CGRectMake(0, boundsWindow.safeAreaInsets.top + overlayView.frame.size.height + progressSlider.frame.size.height + 25 + videoTitleLabel.frame.size.height + videoInfoLabel.frame.size.height, self.view.bounds.size.width, 80);
	developerInfoLabel.text = @"";
	developerInfoLabel.textColor = [UIColor whiteColor];
	developerInfoLabel.numberOfLines = 4;
	developerInfoLabel.adjustsFontSizeToFitWidth = true;
	developerInfoLabel.adjustsFontForContentSizeCategory = false;
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"kEnableDeveloperOptions"] == YES) {
		[self.view addSubview:developerInfoLabel];
	}
}

- (BOOL)prefersHomeIndicatorAutoHidden {
	return YES;
}

@end

@implementation VlcPlayerViewController (Privates)

- (void)overlayTap:(UITapGestureRecognizer *)recognizer {
	if (collapseImage.hidden == YES && rewindImage.hidden == YES && playImage.hidden == YES && pauseImage.hidden == YES && forwardImage.hidden == YES) {
		collapseImage.hidden = NO;
		rewindImage.hidden = NO;
		if (mediaPlayer.isPlaying) {
			pauseImage.hidden = NO;
		} else {
			playImage.hidden = NO;
		}
		forwardImage.hidden = NO;
		progressSlider.hidden = NO;
	} else {
		collapseImage.hidden = YES;
		rewindImage.hidden = YES;
		playImage.hidden = YES;
		pauseImage.hidden = YES;
		forwardImage.hidden = YES;
		if (deviceOrientation == 1) {
			progressSlider.hidden = YES;
		} else {
			progressSlider.hidden = NO;
		}
	}
}

- (void)collapseTap:(UITapGestureRecognizer *)recognizer {
	[mediaPlayer stop];
	mediaPlayer = nil;
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)rewindTap:(UITapGestureRecognizer *)recognizer {
}

- (void)playPauseTap:(UITapGestureRecognizer *)recognizer {
	if (mediaPlayer.isPlaying) {
		[mediaPlayer pause];
		playImage.hidden = NO;
		pauseImage.hidden = YES;
	} else {
		[mediaPlayer play];
		playImage.hidden = YES;
		pauseImage.hidden = NO;
	}
}

- (void)forwardTap:(UITapGestureRecognizer *)recognizer {
}

- (void)enteredBackground:(NSNotification *)notification {
	MPRemoteCommandCenter *commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
    [commandCenter.togglePlayPauseCommand setEnabled:YES];
    [commandCenter.playCommand setEnabled:YES];
    [commandCenter.pauseCommand setEnabled:YES];
    [commandCenter.nextTrackCommand setEnabled:NO];
    [commandCenter.previousTrackCommand setEnabled:NO];
	[commandCenter.playCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        [mediaPlayer play];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    [commandCenter.pauseCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        [mediaPlayer pause];
        return MPRemoteCommandHandlerStatusSuccess;
    }];

	MPNowPlayingInfoCenter *playingInfoCenter = [MPNowPlayingInfoCenter defaultCenter];
	
	NSMutableDictionary *songInfo = [[NSMutableDictionary alloc] init];

	MPMediaItemArtwork *albumArt = [[MPMediaItemArtwork alloc] initWithImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:self.videoArtwork]]];
	[songInfo setObject:[NSString stringWithFormat:@"%@", self.videoTitle] forKey:MPMediaItemPropertyTitle];
	[songInfo setObject:albumArt forKey:MPMediaItemPropertyArtwork];

	[playingInfoCenter setNowPlayingInfo:songInfo];
}

- (void)orientationChanged:(NSNotification *)notification {
	UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
	switch (orientation) {
		case UIInterfaceOrientationPortrait:
		deviceOrientation = 0;
		vlcView.frame = CGRectMake(0, boundsWindow.safeAreaInsets.top, self.view.bounds.size.width, self.view.bounds.size.width * 9 / 16);
		overlayView.frame = CGRectMake(0, boundsWindow.safeAreaInsets.top, self.view.bounds.size.width, self.view.bounds.size.width * 9 / 16);
		collapseImage.alpha = 1.0;
		rewindImage.frame = CGRectMake((overlayView.bounds.size.width / 2) - 96, boundsWindow.safeAreaInsets.top + (overlayView.bounds.size.height / 2) - 24, 48, 48);
		playImage.frame = CGRectMake((overlayView.bounds.size.width / 2) - 24, boundsWindow.safeAreaInsets.top + (overlayView.bounds.size.height / 2) - 24, 48, 48);
		pauseImage.frame = CGRectMake((overlayView.bounds.size.width / 2) - 24, boundsWindow.safeAreaInsets.top + (overlayView.bounds.size.height / 2) - 24, 48, 48);
		forwardImage.frame = CGRectMake((overlayView.bounds.size.width / 2) + 48, boundsWindow.safeAreaInsets.top + (overlayView.bounds.size.height / 2) - 24, 48, 48);
		progressSlider.frame = CGRectMake(0, boundsWindow.safeAreaInsets.top + overlayView.frame.size.height, self.view.bounds.size.width, 10);
		progressSlider.hidden = NO;
		videoTitleLabel.hidden = NO;
		videoInfoLabel.hidden = NO;
		shareButton.hidden = NO;
		developerInfoLabel.hidden = NO;
		break;

		case UIInterfaceOrientationLandscapeLeft:
		deviceOrientation = 1;
		vlcView.frame = self.view.bounds;
		overlayView.frame = self.view.bounds;
		collapseImage.alpha = 0.0;
		rewindImage.frame = CGRectMake((overlayView.bounds.size.width / 2) - 96, boundsWindow.safeAreaInsets.top + (overlayView.bounds.size.height / 2) - 24, 48, 48);
		playImage.frame = CGRectMake((overlayView.bounds.size.width / 2) - 24, boundsWindow.safeAreaInsets.top + (overlayView.bounds.size.height / 2) - 24, 48, 48);
		pauseImage.frame = CGRectMake((overlayView.bounds.size.width / 2) - 24, boundsWindow.safeAreaInsets.top + (overlayView.bounds.size.height / 2) - 24, 48, 48);
		forwardImage.frame = CGRectMake((overlayView.bounds.size.width / 2) + 48, boundsWindow.safeAreaInsets.top + (overlayView.bounds.size.height / 2) - 24, 48, 48);
		progressSlider.frame = CGRectMake(60, boundsWindow.safeAreaInsets.top + overlayView.frame.size.height - boundsWindow.safeAreaInsets.bottom - 60, self.view.bounds.size.width - 120, 10);
		if (collapseImage.hidden == YES && rewindImage.hidden == YES && playImage.hidden == YES && pauseImage.hidden == YES && forwardImage.hidden == YES) {
			progressSlider.hidden = YES;
		}
		videoTitleLabel.hidden = YES;
		videoInfoLabel.hidden = YES;
		shareButton.hidden = YES;
		developerInfoLabel.hidden = YES;
		break;

		case UIInterfaceOrientationLandscapeRight:
		deviceOrientation = 1;
		vlcView.frame = self.view.bounds;
		overlayView.frame = self.view.bounds;
		collapseImage.alpha = 0.0;
		rewindImage.frame = CGRectMake((overlayView.bounds.size.width / 2) - 96, boundsWindow.safeAreaInsets.top + (overlayView.bounds.size.height / 2) - 24, 48, 48);
		playImage.frame = CGRectMake((overlayView.bounds.size.width / 2) - 24, boundsWindow.safeAreaInsets.top + (overlayView.bounds.size.height / 2) - 24, 48, 48);
		pauseImage.frame = CGRectMake((overlayView.bounds.size.width / 2) - 24, boundsWindow.safeAreaInsets.top + (overlayView.bounds.size.height / 2) - 24, 48, 48);
		forwardImage.frame = CGRectMake((overlayView.bounds.size.width / 2) + 48, boundsWindow.safeAreaInsets.top + (overlayView.bounds.size.height / 2) - 24, 48, 48);
		progressSlider.frame = CGRectMake(60, boundsWindow.safeAreaInsets.top + overlayView.frame.size.height - boundsWindow.safeAreaInsets.bottom - 60, self.view.bounds.size.width - 120, 10);
		if (collapseImage.hidden == YES && rewindImage.hidden == YES && playImage.hidden == YES && pauseImage.hidden == YES && forwardImage.hidden == YES) {
			progressSlider.hidden = YES;
		}
		videoTitleLabel.hidden = YES;
		videoInfoLabel.hidden = YES;
		shareButton.hidden = YES;
		developerInfoLabel.hidden = YES;
		break;
	}
}

- (void)sliderValueChanged:(UISlider *)sender {
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	progressSlider.maximumValue = [mediaPlayer.media.length intValue];
	progressSlider.value = [mediaPlayer.time intValue];
	// Developer
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"kEnableDeveloperOptions"] == YES) {
		developerInfoLabel.text = [NSString stringWithFormat:@"Current Time: %f\nLength: %@\nRemaining Time: %@\nTime: %@", mediaPlayer.position * 200, [mediaPlayer.media.length stringValue], [mediaPlayer.remainingTime stringValue], [mediaPlayer.time stringValue]];
	}
}

- (void)shareButtonClicked:(UIButton *)sender {
	UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
	pasteBoard.string = [NSString stringWithFormat:@"https://www.youtube.com/watch?v=%@", self.videoID];
}

@end