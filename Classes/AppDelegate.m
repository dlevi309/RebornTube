// Main

#import "AppDelegate.h"

// Classes

#import "AppColours.h"
#import "AppFonts.h"
#import "AppHistory.h"
#import "YouTubeLoader.h"

// Controllers

#import "../Controllers/Home/HomeViewController.h"
#import "../Controllers/Subscriptions/SubscriptionsViewController.h"
#import "../Controllers/History/HistoryViewController.h"
#import "../Controllers/Playlists/PlaylistsViewController.h"
#import "../Controllers/Downloads/DownloadsViewController.h"
#import "../Controllers/Player/PlayerViewController.h"
#import "../Controllers/Player/VLCPlayerViewController.h"

// Views

#import "../Views/MainPopupView.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.tabBarController = [[UITabBarController alloc] init];

    HomeViewController *homeViewController = [[HomeViewController alloc] init];
    UINavigationController *homeNavViewController = [[UINavigationController alloc] initWithRootViewController:homeViewController];
    homeNavViewController.tabBarItem.title = @"Home";

    SubscriptionsViewController *subscriptionsViewController = [[SubscriptionsViewController alloc] init];
    UINavigationController *subscriptionsNavViewController = [[UINavigationController alloc] initWithRootViewController:subscriptionsViewController];
    subscriptionsNavViewController.tabBarItem.title = @"Subscriptions";

    HistoryViewController *historyViewController = [[HistoryViewController alloc] init];
    UINavigationController *historyNavViewController = [[UINavigationController alloc] initWithRootViewController:historyViewController];
    historyNavViewController.tabBarItem.title = @"History";

    PlaylistsViewController *playlistsViewController = [[PlaylistsViewController alloc] init];
    UINavigationController *playlistsNavViewController = [[UINavigationController alloc] initWithRootViewController:playlistsViewController];
    playlistsNavViewController.tabBarItem.title = @"Playlists";

    DownloadsViewController *downloadsViewController = [[DownloadsViewController alloc] init];
    UINavigationController *downloadsNavViewController = [[UINavigationController alloc] initWithRootViewController:downloadsViewController];
    downloadsNavViewController.tabBarItem.title = @"Downloads";

    self.tabBarController.viewControllers = [NSArray arrayWithObjects:homeNavViewController, subscriptionsNavViewController, historyNavViewController, playlistsNavViewController, downloadsNavViewController, nil];

	UINavigationBarAppearance *navBarAppearance = [[UINavigationBarAppearance alloc] init];
    [navBarAppearance configureWithOpaqueBackground];
    navBarAppearance.titleTextAttributes = @{NSForegroundColorAttributeName : [AppColours textColour]};
    navBarAppearance.backgroundColor = [AppColours mainBackgroundColour];
    [UINavigationBar appearance].standardAppearance = navBarAppearance;

    UITabBarItemAppearance *tabBarItemAppearance = [[UITabBarItemAppearance alloc] init];
    tabBarItemAppearance.normal.titleTextAttributes = @{NSFontAttributeName : [AppFonts mainFont:12]};
    tabBarItemAppearance.selected.titleTextAttributes = @{NSFontAttributeName : [AppFonts mainFont:12]};
    tabBarItemAppearance.disabled.titleTextAttributes = @{NSFontAttributeName : [AppFonts mainFont:12]};
    tabBarItemAppearance.focused.titleTextAttributes = @{NSFontAttributeName : [AppFonts mainFont:12]};
    
    UITabBarAppearance *tabBarAppearance = [[UITabBarAppearance alloc] init];
    [tabBarAppearance configureWithOpaqueBackground];
    tabBarAppearance.backgroundColor = [AppColours mainBackgroundColour];
    tabBarAppearance.stackedLayoutAppearance = tabBarItemAppearance;
    tabBarAppearance.inlineLayoutAppearance = tabBarItemAppearance;
    tabBarAppearance.compactInlineLayoutAppearance = tabBarItemAppearance;
    [UITabBar appearance].standardAppearance = tabBarAppearance;
    
    if (@available(iOS 15.0, *)){
        [UINavigationBar appearance].scrollEdgeAppearance = navBarAppearance;
        [UITabBar appearance].scrollEdgeAppearance = tabBarAppearance;
    }

    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
    NSString *returnURL = [NSString stringWithFormat:@"%@", url];
    NSString *regexString = @"((?<=(v|V)/)|(?<=be/)|(?<=(\\?|\\&)v=)|(?<=embed/))([\\w-]++)";
    NSRegularExpression *regExp = [NSRegularExpression regularExpressionWithPattern:regexString options:NSRegularExpressionCaseInsensitive error:nil];
	NSArray *array = [regExp matchesInString:returnURL options:0 range:NSMakeRange(0, returnURL.length)];
    if (array.count > 0) {
        NSTextCheckingResult *result = array.firstObject;
		NSString *videoID = [returnURL substringWithRange:result.range];

        [AppHistory init:videoID];
        NSDictionary *loaderDictionary = [YouTubeLoader init:videoID];

        if (loaderDictionary == nil) {
            (void)[[MainPopupView alloc] initWithFrame:CGRectZero:@"Video Unsupported":1];
        } else {
            UIViewController *topViewController = [[[[UIApplication sharedApplication] windows] firstObject] rootViewController];
            while (true) {
                if (topViewController.presentedViewController) {
                    topViewController = topViewController.presentedViewController;
                } else if ([topViewController isKindOfClass:[UINavigationController class]]) {
                    UINavigationController *nav = (UINavigationController *)topViewController;
                    topViewController = nav.topViewController;
                } else if ([topViewController isKindOfClass:[UITabBarController class]]) {
                    UITabBarController *tab = (UITabBarController *)topViewController;
                    topViewController = tab.selectedViewController;
                } else {
                    break;
                }
            }
            
            UIAlertController *alertPlayerOptions = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];

            [alertPlayerOptions addAction:[UIAlertAction actionWithTitle:@"AVPlayer" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                PlayerViewController *playerViewController = [[PlayerViewController alloc] init];
                playerViewController.videoID = loaderDictionary[@"videoID"];
                playerViewController.videoURL = loaderDictionary[@"streamURL"];
                playerViewController.videoLive = [loaderDictionary[@"videoLive"] boolValue];
                playerViewController.videoTitle = loaderDictionary[@"videoTitle"];
                playerViewController.videoAuthor = loaderDictionary[@"videoAuthor"];
                playerViewController.videoLength = loaderDictionary[@"videoLength"];
                playerViewController.videoArtwork = loaderDictionary[@"videoArtwork"];
                playerViewController.videoViewCount = loaderDictionary[@"videoViewCount"];
                playerViewController.videoLikes = loaderDictionary[@"videoLikes"];
                playerViewController.videoDislikes = loaderDictionary[@"videoDislikes"];
                playerViewController.sponsorBlockValues = loaderDictionary[@"sponsorBlockValues"];
                UINavigationController *playerViewControllerView = [[UINavigationController alloc] initWithRootViewController:playerViewController];
                playerViewControllerView.modalPresentationStyle = UIModalPresentationFullScreen;
                [topViewController presentViewController:playerViewControllerView animated:YES completion:nil];
            }]];

            [alertPlayerOptions addAction:[UIAlertAction actionWithTitle:@"VLC (Experimental)" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                VLCPlayerViewController *playerViewController = [[VLCPlayerViewController alloc] init];
                playerViewController.videoID = loaderDictionary[@"videoID"];
                playerViewController.videoURL = loaderDictionary[@"videoURL"];
                playerViewController.audioURL = loaderDictionary[@"audioURL"];
                playerViewController.streamURL = loaderDictionary[@"streamURL"];
                playerViewController.videoLive = [loaderDictionary[@"videoLive"] boolValue];
                playerViewController.videoTitle = loaderDictionary[@"videoTitle"];
                playerViewController.videoAuthor = loaderDictionary[@"videoAuthor"];
                playerViewController.videoLength = loaderDictionary[@"videoLength"];
                playerViewController.videoArtwork = loaderDictionary[@"videoArtwork"];
                playerViewController.videoViewCount = loaderDictionary[@"videoViewCount"];
                playerViewController.videoLikes = loaderDictionary[@"videoLikes"];
                playerViewController.videoDislikes = loaderDictionary[@"videoDislikes"];
                playerViewController.sponsorBlockValues = loaderDictionary[@"sponsorBlockValues"];
                UINavigationController *playerViewControllerView = [[UINavigationController alloc] initWithRootViewController:playerViewController];
                playerViewControllerView.modalPresentationStyle = UIModalPresentationFullScreen;
                [topViewController presentViewController:playerViewControllerView animated:YES completion:nil];
            }]];

            [alertPlayerOptions addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            }]];

            [alertPlayerOptions setModalPresentationStyle:UIModalPresentationPopover];
            UIPopoverPresentationController *popPresenter = [alertPlayerOptions popoverPresentationController];
            popPresenter.sourceView = topViewController.view;
            popPresenter.sourceRect = topViewController.view.bounds;
            popPresenter.permittedArrowDirections = 0;
            
            [topViewController presentViewController:alertPlayerOptions animated:YES completion:nil];
        }
    }
    return YES;
}

@end