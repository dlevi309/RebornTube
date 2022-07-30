#import "CreatePlaylistsViewController.h"
#import "../Headers/TheosLinuxFix.h"

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

	[self keysSetup];

	playlistsTextField = [[UITextField alloc] init];
	playlistsTextField.frame = CGRectMake(0, boundsWindow.safeAreaInsets.top + self.navigationController.navigationBar.frame.size.height, self.view.bounds.size.width, 60);
	playlistsTextField.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
	playlistsTextField.placeholder = @"Enter Playlist Name Here";
	[self.view addSubview:playlistsTextField];
}

- (void)viewDidLoad {
    if (@available(iOS 13.0, *)) {
        self.modalInPresentation = YES;
    }

    UILabel *cancelLabel = [[UILabel alloc] init];
    cancelLabel.frame = CGRectMake(0, boundsWindow.safeAreaInsets.top + self.navigationController.navigationBar.frame.size.height + playlistsTextField.bounds.size.height, self.view.bounds.size.width, 40);
    cancelLabel.backgroundColor = [UIColor colorWithRed:0.110 green:0.110 blue:0.118 alpha:1.0];
    cancelLabel.text = @"Cancel";
    cancelLabel.textColor = [UIColor whiteColor];
    cancelLabel.numberOfLines = 1;
    cancelLabel.adjustsFontSizeToFitWidth = true;
    cancelLabel.adjustsFontForContentSizeCategory = false;
    cancelLabel.userInteractionEnabled = true;
    UITapGestureRecognizer *cancelLabelTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelTap:)];
    cancelLabelTap.numberOfTapsRequired = 1;
    [cancelLabel addGestureRecognizer:cancelLabelTap];

    [self.view addSubview:cancelLabel];

    UILabel *createLabel = [[UILabel alloc] init];
    createLabel.frame = CGRectMake(0, boundsWindow.safeAreaInsets.top + self.navigationController.navigationBar.frame.size.height + playlistsTextField.bounds.size.height + cancelLabel.bounds.size.height, self.view.bounds.size.width, 40);
    createLabel.backgroundColor = [UIColor colorWithRed:0.110 green:0.110 blue:0.118 alpha:1.0];
    createLabel.text = @"Create";
    createLabel.textColor = [UIColor whiteColor];
    createLabel.numberOfLines = 1;
    createLabel.adjustsFontSizeToFitWidth = true;
    createLabel.adjustsFontForContentSizeCategory = false;
    createLabel.userInteractionEnabled = true;
    UITapGestureRecognizer *createLabelTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(createTap:)];
    createLabelTap.numberOfTapsRequired = 1;
    [createLabel addGestureRecognizer:createLabelTap];

    [self.view addSubview:createLabel];
}

- (void)keysSetup {
	boundsWindow = [[UIApplication sharedApplication] keyWindow];
}

@end

@implementation CreatePlaylistsViewController (Privates)

- (void)cancelTap:(UITapGestureRecognizer *)recognizer {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)createTap:(UITapGestureRecognizer *)recognizer {
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
        playlistsArray = [playlistsDictionary objectForKey:[playlistsTextField text]];
    } else {
        playlistsArray = [[NSMutableArray alloc] init];
    }
    
    [playlistsDictionary setValue:playlistsArray forKey:[playlistsTextField text]];

    [playlistsDictionary writeToFile:playlistsPlistFilePath atomically:YES];

    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end