// Main

#import "CreatePlaylistsViewController.h"

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
@end

@implementation CreatePlaylistsViewController

- (void)loadView {
	[super loadView];

	self.view.backgroundColor = [AppColours mainBackgroundColour];
    
    [self keysSetup];

	playlistsTextField = [[UITextField alloc] init];
	playlistsTextField.frame = CGRectMake(0, boundsWindow.safeAreaInsets.top + self.navigationController.navigationBar.frame.size.height, self.view.bounds.size.width, 60);
	playlistsTextField.backgroundColor = [AppColours viewBackgroundColour];
	playlistsTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Enter Playlist Name Here" attributes:@{NSForegroundColorAttributeName:[AppColours textColour]}];
	playlistsTextField.textColor = [AppColours textColour];
	[self.view addSubview:playlistsTextField];
}

- (void)viewDidLoad {
    if (@available(iOS 13.0, *)) {
        self.modalInPresentation = YES;
    }

    UIButton *cancelButton = [[UIButton alloc] init];
    cancelButton.frame = CGRectMake(0, boundsWindow.safeAreaInsets.top + self.navigationController.navigationBar.frame.size.height + playlistsTextField.bounds.size.height + 10, self.view.bounds.size.width, 40);
    [cancelButton addTarget:self action:@selector(cancelTap:) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
	[cancelButton setTitleColor:[AppColours textColour] forState:UIControlStateNormal];
    cancelButton.backgroundColor = [AppColours viewBackgroundColour];
	cancelButton.layer.cornerRadius = 5;

    [self.view addSubview:cancelButton];

    UIButton *createButton = [[UIButton alloc] init];
    createButton.frame = CGRectMake(0, boundsWindow.safeAreaInsets.top + self.navigationController.navigationBar.frame.size.height + playlistsTextField.bounds.size.height + cancelButton.bounds.size.height + 20, self.view.bounds.size.width, 40);
    [createButton addTarget:self action:@selector(createTap:) forControlEvents:UIControlEventTouchUpInside];
    [createButton setTitle:@"Create" forState:UIControlStateNormal];
	[createButton setTitleColor:[AppColours textColour] forState:UIControlStateNormal];
    createButton.backgroundColor = [AppColours viewBackgroundColour];
	createButton.layer.cornerRadius = 5;

    [self.view addSubview:createButton];
}

- (void)keysSetup {
	boundsWindow = [[UIApplication sharedApplication] keyWindow];
}

@end

@implementation CreatePlaylistsViewController (Privates)

- (void)cancelTap:(UIButton *)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)createTap:(UIButton *)sender {
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
    if ([playlistsDictionary objectForKey:[playlistsTextField text]]) {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    } else {
        playlistsArray = [[NSMutableArray alloc] init];
    
        [playlistsDictionary setValue:playlistsArray forKey:[playlistsTextField text]];

        [playlistsDictionary writeToFile:playlistsPlistFilePath atomically:YES];

        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

@end