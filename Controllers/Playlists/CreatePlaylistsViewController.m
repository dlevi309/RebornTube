// Main

#import "CreatePlaylistsViewController.h"

// Nav Bar

#import "../Search/SearchViewController.h"
#import "../Settings/SettingsViewController.h"

// Classes

#import "../../Classes/AppColours.h"

// Interface

@interface CreatePlaylistsViewController ()
{
    // Keys
	UIWindow *boundsWindow;

    // Other
	UITextField *playlistsTextField;
}
- (void)keysSetup;
- (void)navBarSetup;
@end

@implementation CreatePlaylistsViewController

- (void)loadView {
	[super loadView];

    self.title = @"";
    self.view.backgroundColor = [AppColours mainBackgroundColour];

    [self keysSetup];
    [self navBarSetup];
}

- (void)keysSetup {
	boundsWindow = [[[UIApplication sharedApplication] windows] lastObject];
}

- (void)navBarSetup {
	UIBarButtonItem *searchButton = [[UIBarButtonItem alloc] initWithTitle:@"Search" style:UIBarButtonItemStylePlain target:self action:@selector(search)];
    UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStylePlain target:self action:@selector(settings)];
    
    self.navigationItem.rightBarButtonItems = @[settingsButton, searchButton];
}

- (void)viewDidLoad {
    playlistsTextField = [[UITextField alloc] init];
	playlistsTextField.frame = CGRectMake(0, boundsWindow.safeAreaInsets.top + self.navigationController.navigationBar.frame.size.height, self.view.bounds.size.width, 60);
	playlistsTextField.backgroundColor = [AppColours viewBackgroundColour];
	playlistsTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Enter Playlist Name Here" attributes:@{NSForegroundColorAttributeName:[AppColours textColour]}];
	playlistsTextField.textColor = [AppColours textColour];
	[self.view addSubview:playlistsTextField];

    UITapGestureRecognizer *dismissKeyboardTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    dismissKeyboardTap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:dismissKeyboardTap];

    UIButton *createButton = [[UIButton alloc] init];
    createButton.frame = CGRectMake(0, boundsWindow.safeAreaInsets.top + self.navigationController.navigationBar.frame.size.height + playlistsTextField.bounds.size.height + 10, self.view.bounds.size.width, 40);
    [createButton addTarget:self action:@selector(createTap:) forControlEvents:UIControlEventTouchUpInside];
    [createButton setTitle:@"Create" forState:UIControlStateNormal];
	[createButton setTitleColor:[AppColours textColour] forState:UIControlStateNormal];
    createButton.backgroundColor = [AppColours viewBackgroundColour];
	createButton.layer.cornerRadius = 5;

    [self.view addSubview:createButton];
}

@end

@implementation CreatePlaylistsViewController (Privates)

// Nav Bar

- (void)search {
    SearchViewController *searchViewController = [[SearchViewController alloc] init];

	UINavigationController *searchViewControllerView = [[UINavigationController alloc] initWithRootViewController:searchViewController];
    searchViewControllerView.modalPresentationStyle = UIModalPresentationFullScreen;

    [self presentViewController:searchViewControllerView animated:YES completion:nil];
}

- (void)settings {
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