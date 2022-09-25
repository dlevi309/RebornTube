// Main

#import "MainMiniDisplayView.h"

// Classes

#import "../Classes/AppColours.h"
#import "../Classes/AppFonts.h"
#import "../Classes/YouTubeLoader.h"

// Controllers

#import "../Controllers/History/VideoHistoryViewController.h"
#import "../Controllers/Playlists/VideoPlaylistsViewController.h"

// Interface

@interface MainMiniDisplayView ()
{
    NSString *viewControllerID;
    int viewControllerInt;
}
- (id)_viewControllerForAncestor;
@end

@implementation MainMiniDisplayView

- (id)initWithFrame:(CGRect)frame array:(NSArray *)array position:(int)position viewcontroller:(int)viewcontroller {
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

        UILabel *mainLabel = [UILabel new];
        mainLabel.frame = CGRectMake(10, 0, mainView.frame.size.width - 10, mainView.frame.size.height);
        if (viewcontroller == 0) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            NSDate *date = [dateFormatter dateFromString:[NSString stringWithFormat:@"%@", array[position]]];
            [dateFormatter setDateFormat:@"MMMM dd, yyyy"];
            mainLabel.text = [dateFormatter stringFromDate:date];
        } else {
            mainLabel.text = [NSString stringWithFormat:@"%@", array[position]];
        }
        mainLabel.textColor = [AppColours textColour];
        mainLabel.numberOfLines = 1;
        [mainLabel setFont:[AppFonts mainFont:mainLabel.font.pointSize]];
        mainLabel.adjustsFontSizeToFitWidth = YES;
        [mainView addSubview:mainLabel];

        viewControllerID = array[position];
        viewControllerInt = viewcontroller;
        [self addSubview:mainView];
    }
    return self;
}

@end

@implementation MainMiniDisplayView (Privates)

- (void)mainTap:(UITapGestureRecognizer *)recognizer {
    UIViewController *mainViewController = [self _viewControllerForAncestor];
    if (viewControllerInt == 0) {
        VideoHistoryViewController *videoHistoryViewController = [[VideoHistoryViewController alloc] init];
        videoHistoryViewController.entryID = viewControllerID;

        [mainViewController.navigationController pushViewController:videoHistoryViewController animated:YES];
    }
    if (viewControllerInt == 1) {
        VideoPlaylistsViewController *playlistsVideosViewController = [[VideoPlaylistsViewController alloc] init];
        playlistsVideosViewController.entryID = viewControllerID;
        
        [mainViewController.navigationController pushViewController:playlistsVideosViewController animated:YES];
    }
}

@end