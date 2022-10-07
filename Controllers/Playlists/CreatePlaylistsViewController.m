// Main

#import "CreatePlaylistsViewController.h"

// Nav Bar

#import "../Search/SearchViewController.h"
#import "../Settings/SettingsViewController.h"

// Classes

#import "../../Classes/AppColours.h"
#import "../../Classes/AppFonts.h"

// Interface

@interface CreatePlaylistsViewController ()
{
    // Keys
	UIWindow *boundsWindow;

    // Other
	UITextField *playlistsTextField;
    UIButton *createButton;
}
- (void)keysSetup;
- (void)navBarSetup;
- (void)mainViewSetup;
@end

@implementation CreatePlaylistsViewController

- (void)loadView {
	[super loadView];

    self.view.backgroundColor = [AppColours mainBackgroundColour];

    [self keysSetup];
    [self navBarSetup];
    [self mainViewSetup];
}

- (void)keysSetup {
	boundsWindow = [[[UIApplication sharedApplication] windows] firstObject];
    playlistsTextField = [[UITextField alloc] init];
    createButton = [[UIButton alloc] init];
}

- (void)navBarSetup {
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
	
	UILabel *searchLabel = [[UILabel alloc] init];
	searchLabel.text = @"Search";
	searchLabel.textColor = [UIColor systemBlueColor];
	searchLabel.numberOfLines = 1;
	[searchLabel setFont:[AppFonts mainFont:searchLabel.font.pointSize]];
	searchLabel.adjustsFontSizeToFitWidth = YES;
	searchLabel.userInteractionEnabled = YES;
	UITapGestureRecognizer *searchTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(search:)];
	searchTap.numberOfTapsRequired = 1;
	[searchLabel addGestureRecognizer:searchTap];
    UIBarButtonItem *searchButton = [[UIBarButtonItem alloc] initWithCustomView:searchLabel];

	UILabel *settingsLabel = [[UILabel alloc] init];
	settingsLabel.text = @"Settings";
	settingsLabel.textColor = [UIColor systemBlueColor];
	settingsLabel.numberOfLines = 1;
	[settingsLabel setFont:[AppFonts mainFont:settingsLabel.font.pointSize]];
	settingsLabel.adjustsFontSizeToFitWidth = YES;
	settingsLabel.userInteractionEnabled = YES;
	UITapGestureRecognizer *settingsTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(settings:)];
	settingsTap.numberOfTapsRequired = 1;
	[settingsLabel addGestureRecognizer:settingsTap];
    UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithCustomView:settingsLabel];

	self.navigationItem.rightBarButtonItems = @[settingsButton, searchButton];
}

- (void)mainViewSetup {
    [playlistsTextField removeFromSuperview];
    playlistsTextField.frame = CGRectMake(boundsWindow.safeAreaInsets.left, boundsWindow.safeAreaInsets.top + self.navigationController.navigationBar.frame.size.height, self.view.bounds.size.width - boundsWindow.safeAreaInsets.left - boundsWindow.safeAreaInsets.right, 60);
	playlistsTextField.backgroundColor = [AppColours viewBackgroundColour];
	playlistsTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Enter Playlist Name Here" attributes:@{NSForegroundColorAttributeName:[AppColours textColour]}];
	playlistsTextField.textColor = [AppColours textColour];
	[self.view addSubview:playlistsTextField];

    UITapGestureRecognizer *dismissKeyboardTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    dismissKeyboardTap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:dismissKeyboardTap];

    [createButton removeFromSuperview];
    createButton.frame = CGRectMake(boundsWindow.safeAreaInsets.left, boundsWindow.safeAreaInsets.top + self.navigationController.navigationBar.frame.size.height + playlistsTextField.bounds.size.height + 10, self.view.bounds.size.width - boundsWindow.safeAreaInsets.left - boundsWindow.safeAreaInsets.right, 40);
    [createButton addTarget:self action:@selector(createTap:) forControlEvents:UIControlEventTouchUpInside];
    [createButton setTitle:@"Create" forState:UIControlStateNormal];
	[createButton setTitleColor:[AppColours textColour] forState:UIControlStateNormal];
    createButton.backgroundColor = [AppColours viewBackgroundColour];
	createButton.layer.cornerRadius = 5;
    [self.view addSubview:createButton];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];

	UIInterfaceOrientation orientation = [[[[[UIApplication sharedApplication] windows] firstObject] windowScene] interfaceOrientation];
	switch (orientation) {
		case UIInterfaceOrientationPortrait:
		[self mainViewSetup];
		break;

		case UIInterfaceOrientationLandscapeLeft:
		[self mainViewSetup];
		break;

		case UIInterfaceOrientationLandscapeRight:
		[self mainViewSetup];
		break;

		case UIInterfaceOrientationPortraitUpsideDown:
		if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
			[self mainViewSetup];
		}
		break;

		case UIInterfaceOrientationUnknown:
		break;
	}
}

@end

@implementation CreatePlaylistsViewController (Privates)

// Nav Bar

- (void)search:(UITapGestureRecognizer *)recognizer {
    SearchViewController *searchViewController = [[SearchViewController alloc] init];
	[self.navigationController pushViewController:searchViewController animated:YES];
}

- (void)settings:(UITapGestureRecognizer *)recognizer {
    SettingsViewController *settingsViewController = [[SettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
	UINavigationController *settingsViewControllerView = [[UINavigationController alloc] initWithRootViewController:settingsViewController];
    settingsViewControllerView.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:settingsViewControllerView animated:YES completion:nil];
}

// Other

- (void)dismissKeyboard:(UITapGestureRecognizer *)recognizer {
    [playlistsTextField resignFirstResponder];
}

- (void)createTap:(UIButton *)sender {
    [playlistsTextField resignFirstResponder];
    
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
    if (![playlistsDictionary objectForKey:[playlistsTextField text]]) {
        playlistsArray = [[NSMutableArray alloc] init];
    
        [playlistsDictionary setValue:playlistsArray forKey:[playlistsTextField text]];

        [playlistsDictionary writeToFile:playlistsPlistFilePath atomically:YES];
    }

    playlistsTextField.text = @"";
}

@end