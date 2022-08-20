#import "AppDelegate.h"
#import "AppColours.h"
#import "YouTubeLoader.h"
#import "../Controllers/Home/HomeViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	if (@available(iOS 15.0, *)){
        UINavigationBarAppearance *navBarAppearance = [[UINavigationBarAppearance alloc] init];
        [navBarAppearance configureWithOpaqueBackground];
        navBarAppearance.titleTextAttributes = @{NSForegroundColorAttributeName : [AppColours textColour]};
        navBarAppearance.backgroundColor = [AppColours mainBackgroundColour];
        [UINavigationBar appearance].standardAppearance = navBarAppearance;
        [UINavigationBar appearance].scrollEdgeAppearance = navBarAppearance;

		UITabBarAppearance *tabBarAppearance = [[UITabBarAppearance alloc] init];
		[tabBarAppearance configureWithOpaqueBackground];
        tabBarAppearance.backgroundColor = [AppColours mainBackgroundColour];
		[UITabBar appearance].standardAppearance = tabBarAppearance;
        [UITabBar appearance].scrollEdgeAppearance = tabBarAppearance;
    } else {
		UINavigationBarAppearance *navBarAppearance = [[UINavigationBarAppearance alloc] init];
        [navBarAppearance configureWithOpaqueBackground];
        navBarAppearance.titleTextAttributes = @{NSForegroundColorAttributeName : [AppColours textColour]};
        navBarAppearance.backgroundColor = [AppColours mainBackgroundColour];
        [UINavigationBar appearance].standardAppearance = navBarAppearance;

		UITabBarAppearance *tabBarAppearance = [[UITabBarAppearance alloc] init];
		[tabBarAppearance configureWithOpaqueBackground];
        tabBarAppearance.backgroundColor = [AppColours mainBackgroundColour];
		[UITabBar appearance].standardAppearance = tabBarAppearance;
	}
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[HomeViewController alloc] init]];
    self.window.rootViewController = self.rootViewController;
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

        NSFileManager *fm = [[NSFileManager alloc] init];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];

        NSString *historyPlistFilePath = [documentsDirectory stringByAppendingPathComponent:@"history.plist"];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSString *date = [dateFormatter stringFromDate:[NSDate date]];

        NSMutableDictionary *historyDictionary;
        if (![fm fileExistsAtPath:historyPlistFilePath]) {
            historyDictionary = [[NSMutableDictionary alloc] init];
        } else {
            historyDictionary = [NSMutableDictionary dictionaryWithContentsOfFile:historyPlistFilePath];
        }

        NSMutableArray *historyArray;
        if ([historyDictionary objectForKey:date]) {
            historyArray = [historyDictionary objectForKey:date];
        } else {
            historyArray = [[NSMutableArray alloc] init];
        }
        
        if (![historyArray containsObject:videoID]) {
            [historyArray addObject:videoID];
        }

        [historyDictionary setValue:historyArray forKey:date];

        [historyDictionary writeToFile:historyPlistFilePath atomically:YES];

        [YouTubeLoader init:videoID];
    }
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    if (self.allowRotation) {
        return UIInterfaceOrientationMaskAll;
    }
    return UIInterfaceOrientationMaskPortrait;
}

@end