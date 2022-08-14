// Main

#import "SearchViewController.h"

// Classes

#import "../Classes/YouTubeExtractor.h"
#import "../Classes/YouTubeLoader.h"
#import "../Classes/AppColours.h"

// Interface

@interface SearchViewController ()
{
	// View
	UITextField *searchTextField;

	// Keys
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
	searchTextField.backgroundColor = [AppColours viewBackgroundColour];
	searchTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Search Here" attributes:@{NSForegroundColorAttributeName:[AppColours textColour]}];
	searchTextField.textColor = [AppColours textColour];
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
	[scrollView removeFromSuperview];

    NSString *regexString = @"((?<=(v|V)/)|(?<=be/)|(?<=(\\?|\\&)v=)|(?<=embed/))([\\w-]++)";
    NSRegularExpression *regExp = [NSRegularExpression regularExpressionWithPattern:regexString options:NSRegularExpressionCaseInsensitive error:nil];
	NSArray *array = [regExp matchesInString:[searchTextField text] options:0 range:NSMakeRange(0, [searchTextField text].length)];
    if (array.count > 0) {
        @try {
			NSTextCheckingResult *result = array.firstObject;
			NSString *videoID = [[searchTextField text] substringWithRange:result.range];
			NSMutableDictionary *youtubeiOSPlayerRequest = [YouTubeExtractor youtubeiOSPlayerRequest:videoID];
			
			scrollView.frame = CGRectMake(0, boundsWindow.safeAreaInsets.top + self.navigationController.navigationBar.frame.size.height + searchTextField.frame.size.height, self.view.bounds.size.width, self.view.bounds.size.height - boundsWindow.safeAreaInsets.top - self.navigationController.navigationBar.frame.size.height - boundsWindow.safeAreaInsets.bottom - searchTextField.frame.size.height);

			UIView *searchView = [[UIView alloc] init];
			searchView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 100);
			searchView.backgroundColor = [AppColours viewBackgroundColour];
			searchView.tag = 1;
			UITapGestureRecognizer *searchViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(searchTap:)];
			searchViewTap.numberOfTapsRequired = 1;
			[searchView addGestureRecognizer:searchViewTap];

			UIImageView *videoImage = [[UIImageView alloc] init];
			videoImage.frame = CGRectMake(0, 0, 80, 80);
			NSArray *videoArtworkArray = youtubeiOSPlayerRequest[@"videoDetails"][@"thumbnail"][@"thumbnails"];
			NSURL *videoArtwork = [NSURL URLWithString:[NSString stringWithFormat:@"%@", videoArtworkArray[([videoArtworkArray count] - 1)][@"url"]]];
			videoImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:videoArtwork]];
			[searchView addSubview:videoImage];

			UILabel *videoTitleLabel = [[UILabel alloc] init];
			videoTitleLabel.frame = CGRectMake(85, 0, searchView.frame.size.width - 85, 80);
			videoTitleLabel.text = [NSString stringWithFormat:@"%@", youtubeiOSPlayerRequest[@"videoDetails"][@"title"]];
			videoTitleLabel.textColor = [AppColours textColour];
			videoTitleLabel.numberOfLines = 2;
			videoTitleLabel.adjustsFontSizeToFitWidth = true;
			videoTitleLabel.adjustsFontForContentSizeCategory = false;
			[searchView addSubview:videoTitleLabel];

			UILabel *videoAuthorLabel = [[UILabel alloc] init];
			videoAuthorLabel.frame = CGRectMake(5, 80, searchView.frame.size.width - 5, 20);
			videoAuthorLabel.text = [NSString stringWithFormat:@"%@", youtubeiOSPlayerRequest[@"videoDetails"][@"author"]];
			videoAuthorLabel.textColor = [AppColours textColour];
			videoAuthorLabel.numberOfLines = 1;
			[videoAuthorLabel setFont:[UIFont systemFontOfSize:12]];
			videoAuthorLabel.adjustsFontSizeToFitWidth = true;
			videoAuthorLabel.adjustsFontForContentSizeCategory = false;
			[searchView addSubview:videoAuthorLabel];
			
			[searchVideoIDDictionary setValue:videoID forKey:[NSString stringWithFormat:@"%d", 1]];

			[scrollView addSubview:searchView];

			scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, 100);
			[self.view addSubview:scrollView];
		}
		@catch (NSException *exception) {
		}
    } else {	
		NSMutableDictionary *youtubeWebSearchRequest = [YouTubeExtractor youtubeWebSearchRequest:[searchTextField text]];
		NSArray *searchContents = youtubeWebSearchRequest[@"contents"][@"twoColumnSearchResultsRenderer"][@"primaryContents"][@"sectionListRenderer"][@"contents"][0][@"itemSectionRenderer"][@"contents"];
		
		scrollView.frame = CGRectMake(0, boundsWindow.safeAreaInsets.top + self.navigationController.navigationBar.frame.size.height + searchTextField.frame.size.height, self.view.bounds.size.width, self.view.bounds.size.height - boundsWindow.safeAreaInsets.top - self.navigationController.navigationBar.frame.size.height - boundsWindow.safeAreaInsets.bottom - searchTextField.frame.size.height);
		
		int viewBounds = 0;
		for (int i = 0 ; i <= 50 ; i++) {
			@try {
				if (searchContents[i][@"videoRenderer"][@"videoId"]) {
					UIView *searchView = [[UIView alloc] init];
					searchView.frame = CGRectMake(0, viewBounds, self.view.bounds.size.width, 100);
					searchView.backgroundColor = [AppColours viewBackgroundColour];
					searchView.tag = i;
					UITapGestureRecognizer *searchViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(searchTap:)];
					searchViewTap.numberOfTapsRequired = 1;
					[searchView addGestureRecognizer:searchViewTap];

					UIImageView *videoImage = [[UIImageView alloc] init];
					videoImage.frame = CGRectMake(0, 0, 80, 80);
					NSArray *videoArtworkArray = searchContents[i][@"videoRenderer"][@"thumbnail"][@"thumbnails"];
					NSURL *videoArtwork = [NSURL URLWithString:[NSString stringWithFormat:@"%@", videoArtworkArray[([videoArtworkArray count] - 1)][@"url"]]];
					videoImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:videoArtwork]];
					[searchView addSubview:videoImage];

					UILabel *videoTimeLabel = [[UILabel alloc] init];
					videoTimeLabel.frame = CGRectMake(40, 65, 40, 15);
					videoTimeLabel.text = [NSString stringWithFormat:@"%@", searchContents[i][@"videoRenderer"][@"lengthText"][@"simpleText"]];
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
					videoTitleLabel.text = [NSString stringWithFormat:@"%@", searchContents[i][@"videoRenderer"][@"title"][@"runs"][0][@"text"]];
					videoTitleLabel.textColor = [AppColours textColour];
					videoTitleLabel.numberOfLines = 2;
					videoTitleLabel.adjustsFontSizeToFitWidth = true;
					videoTitleLabel.adjustsFontForContentSizeCategory = false;
					[searchView addSubview:videoTitleLabel];

					UILabel *videoCountAndAuthorLabel = [[UILabel alloc] init];
					videoCountAndAuthorLabel.frame = CGRectMake(5, 80, searchView.frame.size.width - 5, 20);
					videoCountAndAuthorLabel.text = [NSString stringWithFormat:@"%@ - %@", searchContents[i][@"videoRenderer"][@"viewCountText"][@"simpleText"], searchContents[i][@"videoRenderer"][@"longBylineText"][@"runs"][0][@"text"]];
					videoCountAndAuthorLabel.textColor = [AppColours textColour];
					videoCountAndAuthorLabel.numberOfLines = 1;
					[videoCountAndAuthorLabel setFont:[UIFont systemFontOfSize:12]];
					videoCountAndAuthorLabel.adjustsFontSizeToFitWidth = true;
					videoCountAndAuthorLabel.adjustsFontForContentSizeCategory = false;
					[searchView addSubview:videoCountAndAuthorLabel];
					
					[searchVideoIDDictionary setValue:[NSString stringWithFormat:@"%@", searchContents[i][@"videoRenderer"][@"videoId"]] forKey:[NSString stringWithFormat:@"%d", i]];
					viewBounds += 102;

					[scrollView addSubview:searchView];
				}
			}
			@catch (NSException *exception) {
			}
		}

		scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, viewBounds);
		[self.view addSubview:scrollView];
	}
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
    
    if (![historyArray containsObject:videoID]) {
		[historyArray addObject:videoID];
	}

    [historyDictionary setValue:historyArray forKey:date];

    [historyDictionary writeToFile:historyPlistFilePath atomically:YES];

    [YouTubeLoader init:videoID];
}

@end