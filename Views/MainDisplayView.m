// Main

#import "MainDisplayView.h"

// Classes

#import "../Classes/AppColours.h"
#import "../Classes/AppHistory.h"
#import "../Classes/YouTubeLoader.h"

// Other

#import "../Controllers/Playlists/AddToPlaylistsViewController.h"

// Interface

@interface MainDisplayView ()
{
    NSString *videoID;
    BOOL saveToHistory;
}
- (id)_viewControllerForAncestor;
@end

@implementation MainDisplayView

- (id)initWithFrame:(CGRect)frame array:(NSArray *)array position:(int)position save:(BOOL)save {
    self = [super initWithFrame:frame];
    if (self) {
        UIView *mainView = [UIView new];
        mainView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        mainView.backgroundColor = [AppColours viewBackgroundColour];
        mainView.clipsToBounds = YES;
        mainView.tag = position;
        mainView.userInteractionEnabled = YES;
        UITapGestureRecognizer *mainViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mainTap:)];
        mainViewTap.numberOfTapsRequired = 1;
        [mainView addGestureRecognizer:mainViewTap];

        UIImageView *imageView = [UIImageView new];
        imageView.frame = CGRectMake(0, 0, 80, 80);
        imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", array[position][@"artwork"]]]]];
        [mainView addSubview:imageView];

        UILabel *timeLabel = [UILabel new];
        timeLabel.text = [NSString stringWithFormat:@"%@", array[position][@"time"]];
        timeLabel.textAlignment = NSTextAlignmentCenter;
        timeLabel.textColor = [UIColor whiteColor];
        timeLabel.numberOfLines = 1;
        timeLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
        timeLabel.clipsToBounds = YES;
        timeLabel.layer.cornerRadius = 5;
        timeLabel.adjustsFontSizeToFitWidth = YES;

        NSFileManager *fm = [NSFileManager new];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *playerPlistFilePath = [documentsDirectory stringByAppendingPathComponent:@"player.plist"];
        if ([fm fileExistsAtPath:playerPlistFilePath]) {
            NSMutableDictionary *playerDictionary = [NSMutableDictionary dictionaryWithContentsOfFile:playerPlistFilePath];
            if ([playerDictionary objectForKey:array[position][@"id"]] && [playerDictionary objectForKey:array[position][@"length"]]) {
                timeLabel.frame = CGRectMake(40, 55, 40, 15);
                [mainView addSubview:timeLabel];
                
                UISlider *progressView = [UISlider new];
                progressView.frame = CGRectMake(0, 75, 80, 0);
                [progressView setThumbImage:[UIImage new] forState:UIControlStateNormal];
                [progressView setThumbImage:[UIImage new] forState:UIControlStateHighlighted];
                progressView.enabled = NO;
                progressView.minimumTrackTintColor = [UIColor redColor];
	            progressView.minimumValue = 0.0f;
                progressView.maximumValue = [[playerDictionary objectForKey:array[position][@"length"]] floatValue];
                progressView.value = [[playerDictionary objectForKey:array[position][@"id"]] floatValue];
                [mainView addSubview:progressView];
            } else {
                timeLabel.frame = CGRectMake(40, 65, 40, 15);
                [mainView addSubview:timeLabel];
            }
        } else {
            timeLabel.frame = CGRectMake(40, 65, 40, 15);
            [mainView addSubview:timeLabel];
        }

        UILabel *titleLabel = [UILabel new];
        titleLabel.frame = CGRectMake(85, 0, mainView.frame.size.width - 85, 80);
        titleLabel.text = [NSString stringWithFormat:@"%@", array[position][@"title"]];
        titleLabel.textColor = [AppColours textColour];
        titleLabel.numberOfLines = 2;
        titleLabel.adjustsFontSizeToFitWidth = YES;
        [mainView addSubview:titleLabel];

        UILabel *infoLabel = [UILabel new];
        infoLabel.frame = CGRectMake(5, 80, mainView.frame.size.width - 45, 20);
        if (array[position][@"count"] && array[position][@"author"]) {
            infoLabel.text = [NSString stringWithFormat:@"%@ - %@", array[position][@"count"], array[position][@"author"]];
        } else if (!array[position][@"count"] && array[position][@"author"]) {
            infoLabel.text = [NSString stringWithFormat:@"%@", array[position][@"author"]];
        }
        infoLabel.textColor = [AppColours textColour];
        infoLabel.numberOfLines = 1;
        [infoLabel setFont:[UIFont systemFontOfSize:12]];
        infoLabel.adjustsFontSizeToFitWidth = YES;
        [mainView addSubview:infoLabel];

        UILabel *actionLabel = [UILabel new];
        actionLabel.frame = CGRectMake(mainView.frame.size.width - 30, 80, 20, 20);
        actionLabel.tag = position;
        actionLabel.text = @"•••";
        actionLabel.textAlignment = NSTextAlignmentCenter;
        actionLabel.textColor = [AppColours textColour];
        actionLabel.numberOfLines = 1;
        [actionLabel setFont:[UIFont systemFontOfSize:12]];
        actionLabel.adjustsFontSizeToFitWidth = YES;
        actionLabel.userInteractionEnabled = YES;
        UITapGestureRecognizer *actionLabelTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTap:)];
        actionLabelTap.numberOfTapsRequired = 1;
        [actionLabel addGestureRecognizer:actionLabelTap];
        [mainView addSubview:actionLabel];

        videoID = array[position][@"id"];
        saveToHistory = save;
        [self addSubview:mainView];
    }
    return self;
}

@end

@implementation MainDisplayView (Privates)

- (void)mainTap:(UITapGestureRecognizer *)recognizer {
    if (saveToHistory) {
        [AppHistory init:videoID];
    }
    [YouTubeLoader init:videoID];
}

- (void)actionTap:(UITapGestureRecognizer *)recognizer {
    UIViewController *mainViewController = [self _viewControllerForAncestor];

    UIAlertController *alertSelector = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];

	[alertSelector addAction:[UIAlertAction actionWithTitle:@"Share" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
		NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.youtube.com/watch?v=%@", videoID]];
	
		UIActivityViewController *shareSheet = [[UIActivityViewController alloc] initWithActivityItems:@[url] applicationActivities:nil];
        
        [mainViewController presentViewController:shareSheet animated:YES completion:nil];
    }]];

	[alertSelector addAction:[UIAlertAction actionWithTitle:@"Add To Playlist" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
		AddToPlaylistsViewController *addToPlaylistsViewController = [[AddToPlaylistsViewController alloc] init];
		addToPlaylistsViewController.videoID = videoID;

		[mainViewController presentViewController:addToPlaylistsViewController animated:YES completion:nil];
    }]];

	[alertSelector addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }]];

    [mainViewController presentViewController:alertSelector animated:YES completion:nil];
}

@end