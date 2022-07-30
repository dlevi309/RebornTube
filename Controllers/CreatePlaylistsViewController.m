#import "CreatePlaylistsViewController.h"
#import "SearchViewController.h"
#import "PlayerViewController.h"
#import "../Classes/YouTubeExtractor.h"

@interface CreatePlaylistsViewController ()
{
	UITextField *playlistsTextField;
}
@end

@implementation CreatePlaylistsViewController

- (void)loadView {
	[super loadView];

	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
    self.navigationItem.rightBarButtonItem = doneButton;

	UIWindow *boundsWindow = [[UIApplication sharedApplication] keyWindow];

	playlistsTextField = [[UITextField alloc] init];
	playlistsTextField.frame = CGRectMake(0, boundsWindow.safeAreaInsets.top + self.navigationController.navigationBar.frame.size.height, self.view.bounds.size.width, 60);
	playlistsTextField.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
	playlistsTextField.placeholder = @"Enter Playlist Name Here";
	[playlistsTextField addTarget:self action:@selector(playlistsRequest) forControlEvents:UIControlEventEditingDidEndOnExit];
	[self.view addSubview:playlistsTextField];
}

@end

@implementation CreatePlaylistsViewController (Privates)

- (void)playlistsRequest {
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