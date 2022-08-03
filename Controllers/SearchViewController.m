// Main

#import "SearchViewController.h"

// Classes

#import "../Classes/YouTubeExtractor.h"
#import "../Classes/YouTubeLoader.h"
#import "../Classes/AppColours.h"

// Interface

@interface SearchViewController ()
{
	UITextField *searchTextField;
	NSMutableDictionary *searchVideoIDDictionary;
    UIScrollView *scrollView;
}
- (void)keysSetup;
@end

@implementation SearchViewController

- (void)loadView {
	[super loadView];

	self.title = @"";
	self.view.backgroundColor = [AppColours mainBackgroundColour];

    [self keysSetup];

	UIWindow *boundsWindow = [[UIApplication sharedApplication] keyWindow];

	searchTextField = [[UITextField alloc] init];
	searchTextField.frame = CGRectMake(0, boundsWindow.safeAreaInsets.top + self.navigationController.navigationBar.frame.size.height, self.view.bounds.size.width, 60);
	searchTextField.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
	searchTextField.placeholder = @"Search Here";
	[searchTextField addTarget:self action:@selector(searchRequest) forControlEvents:UIControlEventEditingDidEndOnExit];
	[self.view addSubview:searchTextField];
}

- (void)keysSetup {
    scrollView = [[UIScrollView alloc] init];
}

@end

@implementation SearchViewController (Privates)

- (void)searchRequest {
	UIWindow *boundsWindow = [[UIApplication sharedApplication] keyWindow];
	searchVideoIDDictionary = [NSMutableDictionary new];

    NSMutableDictionary *youtubeiAndroidSearchRequest = [YouTubeExtractor youtubeiAndroidSearchRequest:[searchTextField text]];
    NSArray *searchContents = youtubeiAndroidSearchRequest[@"contents"][@"sectionListRenderer"][@"contents"][0][@"itemSectionRenderer"][@"contents"];
	
	[scrollView removeFromSuperview];
    scrollView.frame = CGRectMake(0, boundsWindow.safeAreaInsets.top + self.navigationController.navigationBar.frame.size.height + searchTextField.frame.size.height, self.view.bounds.size.width, self.view.bounds.size.height - boundsWindow.safeAreaInsets.top - self.navigationController.navigationBar.frame.size.height - boundsWindow.safeAreaInsets.bottom - searchTextField.frame.size.height);
	
	int viewBounds = 0;
	for (int i = 1 ; i <= 50 ; i++) {
		@try {
			UIView *searchView = [[UIView alloc] init];
			searchView.frame = CGRectMake(0, viewBounds, self.view.bounds.size.width, 100);
			searchView.backgroundColor = [UIColor colorWithRed:0.110 green:0.110 blue:0.118 alpha:1.0];
			searchView.tag = i;
			UITapGestureRecognizer *searchViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(searchTap:)];
			searchViewTap.numberOfTapsRequired = 1;
			[searchView addGestureRecognizer:searchViewTap];

			UIImageView *videoImage = [[UIImageView alloc] init];
			videoImage.frame = CGRectMake(0, 0, 80, 80);
            NSArray *videoArtworkArray = searchContents[i][@"compactVideoRenderer"][@"thumbnail"][@"thumbnails"];
            NSURL *videoArtwork = [NSURL URLWithString:[NSString stringWithFormat:@"%@", videoArtworkArray[([videoArtworkArray count] - 1)][@"url"]]];
			videoImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:videoArtwork]];
			[searchView addSubview:videoImage];

            UILabel *videoTimeLabel = [[UILabel alloc] init];
			videoTimeLabel.frame = CGRectMake(40, 65, 40, 15);
			videoTimeLabel.text = [NSString stringWithFormat:@"%@", searchContents[i][@"compactVideoRenderer"][@"lengthText"][@"runs"][0][@"text"]];
            videoTimeLabel.textAlignment = NSTextAlignmentCenter;
			videoTimeLabel.textColor = [UIColor whiteColor];
			videoTimeLabel.numberOfLines = 1;
            videoTimeLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
            videoTimeLabel.layer.cornerRadius = 5;
            videoTimeLabel.clipsToBounds = YES;
			videoTimeLabel.adjustsFontSizeToFitWidth = true;
			videoTimeLabel.adjustsFontForContentSizeCategory = false;
			[searchView addSubview:videoTimeLabel];

			UILabel *videoTitleLabel = [[UILabel alloc] init];
			videoTitleLabel.frame = CGRectMake(85, 0, searchView.frame.size.width - 85, 80);
			videoTitleLabel.text = [NSString stringWithFormat:@"%@", searchContents[i][@"compactVideoRenderer"][@"title"][@"runs"][0][@"text"]];
			videoTitleLabel.textColor = [UIColor whiteColor];
			videoTitleLabel.numberOfLines = 2;
			videoTitleLabel.adjustsFontSizeToFitWidth = true;
			videoTitleLabel.adjustsFontForContentSizeCategory = false;
			[searchView addSubview:videoTitleLabel];

            UILabel *videoCountAndAuthorLabel = [[UILabel alloc] init];
			videoCountAndAuthorLabel.frame = CGRectMake(5, 80, searchView.frame.size.width - 5, 20);
			videoCountAndAuthorLabel.text = [NSString stringWithFormat:@"%@ - %@", searchContents[i][@"compactVideoRenderer"][@"viewCountText"][@"runs"][0][@"text"], searchContents[i][@"compactVideoRenderer"][@"longBylineText"][@"runs"][0][@"text"]];
			videoCountAndAuthorLabel.textColor = [UIColor whiteColor];
			videoCountAndAuthorLabel.numberOfLines = 1;
            [videoCountAndAuthorLabel setFont:[UIFont systemFontOfSize:12]];
			videoCountAndAuthorLabel.adjustsFontSizeToFitWidth = true;
			videoCountAndAuthorLabel.adjustsFontForContentSizeCategory = false;
			[searchView addSubview:videoCountAndAuthorLabel];
			
			[searchVideoIDDictionary setValue:[NSString stringWithFormat:@"%@", searchContents[i][@"compactVideoRenderer"][@"videoId"]] forKey:[NSString stringWithFormat:@"%d", i]];
			viewBounds += 102;

			[scrollView addSubview:searchView];
		}
        @catch (NSException *exception) {
        }
	}

	scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, viewBounds);
	[self.view addSubview:scrollView];
}

- (void)searchTap:(UITapGestureRecognizer *)recognizer {
	NSString *searchViewTag = [NSString stringWithFormat:@"%d", recognizer.view.tag];
	NSString *videoID = [searchVideoIDDictionary valueForKey:searchViewTag];

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
    
    [historyArray addObject:videoID];

    [historyDictionary setValue:historyArray forKey:date];

    [historyDictionary writeToFile:historyPlistFilePath atomically:YES];

    [YouTubeLoader init:videoID];
}

@end