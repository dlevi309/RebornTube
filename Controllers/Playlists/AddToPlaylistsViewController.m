// Main

#import "AddToPlaylistsViewController.h"

// Classes

#import "../../Classes/AppColours.h"

// Interface

@interface AddToPlaylistsViewController ()
{
    // Keys
	UIWindow *boundsWindow;

    // Other
    NSMutableDictionary *playlistsIDDictionary;
    UIButton *closeButton;
}
- (void)keysSetup;
- (void)loadPlaylists;
@end

@implementation AddToPlaylistsViewController

- (void)loadView {
	[super loadView];

	self.view.backgroundColor = [AppColours mainBackgroundColour];
    
    [self keysSetup];
}

- (void)viewDidLoad {
    if (@available(iOS 13.0, *)) {
        self.modalInPresentation = YES;
    }

    closeButton = [[UIButton alloc] init];
    closeButton.frame = CGRectMake(0, boundsWindow.safeAreaInsets.top + self.navigationController.navigationBar.frame.size.height, self.view.bounds.size.width, 40);
    [closeButton addTarget:self action:@selector(closeTap:) forControlEvents:UIControlEventTouchUpInside];
    [closeButton setTitle:@"Close" forState:UIControlStateNormal];
	[closeButton setTitleColor:[AppColours textColour] forState:UIControlStateNormal];
    closeButton.backgroundColor = [AppColours viewBackgroundColour];
	closeButton.layer.cornerRadius = 5;

    [self.view addSubview:closeButton];

    [self loadPlaylists];
}

- (void)keysSetup {
	boundsWindow = [[UIApplication sharedApplication] keyWindow];
}

- (void)loadPlaylists {
    playlistsIDDictionary = [NSMutableDictionary new];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];

    NSString *playlistsPlistFilePath = [documentsDirectory stringByAppendingPathComponent:@"playlists.plist"];
    NSMutableDictionary *playlistsDictionary = [NSMutableDictionary dictionaryWithContentsOfFile:playlistsPlistFilePath];

    UIScrollView *scrollView = [[UIScrollView alloc] init];
	scrollView.frame = CGRectMake(0, boundsWindow.safeAreaInsets.top + self.navigationController.navigationBar.frame.size.height + closeButton.frame.size.height + 10, self.view.bounds.size.width, self.view.bounds.size.height - boundsWindow.safeAreaInsets.top - self.navigationController.navigationBar.frame.size.height - boundsWindow.safeAreaInsets.bottom - closeButton.frame.size.height - 10);
    
    int viewBounds = 0;
    int nameCount = 1;
    for (NSString *key in playlistsDictionary) {
        UIView *playlistsView = [[UIView alloc] init];
        playlistsView.frame = CGRectMake(0, viewBounds, self.view.bounds.size.width, 40);
        playlistsView.backgroundColor = [AppColours viewBackgroundColour];
        playlistsView.tag = nameCount;
        UITapGestureRecognizer *playlistsViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playlistsTap:)];
        playlistsViewTap.numberOfTapsRequired = 1;
        [playlistsView addGestureRecognizer:playlistsViewTap];

        UILabel *playlistsNameLabel = [[UILabel alloc] init];
        playlistsNameLabel.frame = CGRectMake(10, 0, playlistsView.frame.size.width - 10, playlistsView.frame.size.height);
        playlistsNameLabel.text = key;
        playlistsNameLabel.textColor = [AppColours textColour];
        playlistsNameLabel.numberOfLines = 1;
        playlistsNameLabel.adjustsFontSizeToFitWidth = true;
        playlistsNameLabel.adjustsFontForContentSizeCategory = false;
        [playlistsView addSubview:playlistsNameLabel];

        [playlistsIDDictionary setValue:key forKey:[NSString stringWithFormat:@"%d", nameCount]];
        viewBounds += 42;
        nameCount += 1;

        [scrollView addSubview:playlistsView];
    }

    scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, viewBounds);
	[self.view addSubview:scrollView];
}

@end

@implementation AddToPlaylistsViewController (Privates)

- (void)cancelTap:(UIButton *)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)playlistsTap:(UITapGestureRecognizer *)recognizer {
    NSString *playlistsViewTag = [NSString stringWithFormat:@"%d", recognizer.view.tag];
	NSString *playlistsViewID = [playlistsIDDictionary valueForKey:playlistsViewTag];

    NSFileManager *fm = [[NSFileManager alloc] init];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];

    NSString *playlistsPlistFilePath = [documentsDirectory stringByAppendingPathComponent:@"playlists.plist"];

    NSMutableDictionary *playlistsDictionary;
    if (![fm fileExistsAtPath:playlistsPlistFilePath]) {
        playlistsDictionary = [[NSMutableDictionary alloc] init];
    } else {
        playlistsDictionary = [NSMutableDictionary dictionaryWithContentsOfFile:playlistsPlistFilePath];
    }

    NSMutableArray *playlistsArray;
    if ([playlistsDictionary objectForKey:playlistsViewID]) {
        playlistsArray = [playlistsDictionary objectForKey:playlistsViewID];
    } else {
        playlistsArray = [[NSMutableArray alloc] init];
    }

    if (![playlistsArray containsObject:self.videoID]) {
		[playlistsArray addObject:self.videoID];
	}
    
    [playlistsDictionary setValue:playlistsArray forKey:playlistsViewID];

    [playlistsDictionary writeToFile:playlistsPlistFilePath atomically:YES];
}

@end