// Main

#import "MainDisplayView.h"

// Classes

#import "../Classes/AppColours.h"

// Interface

@interface MainDisplayView ()
@end

@implementation MainDisplayView

- (id)initWithFrame:(CGRect)frame infoDictionary:(NSDictionary *)dictionary infoDictionaryPosition:(int)position {
    self = [super initWithFrame:frame];
    if (self) {
        NSDictionary *infoDictionary = [dictionary valueForKey:[NSString stringWithFormat:@"%d", position]];
		
        UIView *mainView = [UIView new];
        mainView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        mainView.backgroundColor = [AppColours viewBackgroundColour];
        mainView.tag = position;
        mainView.userInteractionEnabled = YES;
        UITapGestureRecognizer *mainViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mainTap:)];
        mainViewTap.numberOfTapsRequired = 1;
        [mainView addGestureRecognizer:mainViewTap];

        UIImageView *imageView = [UIImageView new];
        imageView.frame = CGRectMake(0, 0, 80, 80);
        imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[infoDictionary valueForKey:@"artwork"]]]];
        [mainView addSubview:imageView];

        UILabel *timeLabel = [UILabel new];
        timeLabel.frame = CGRectMake(40, 65, 40, 15);
        timeLabel.text = [infoDictionary valueForKey:@"time"];
        timeLabel.textAlignment = NSTextAlignmentCenter;
        timeLabel.textColor = [UIColor whiteColor];
        timeLabel.numberOfLines = 1;
        timeLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
        timeLabel.layer.cornerRadius = 5;
        timeLabel.clipsToBounds = YES;
        timeLabel.adjustsFontSizeToFitWidth = YES;
        [mainView addSubview:timeLabel];

        UILabel *titleLabel = [UILabel new];
        titleLabel.frame = CGRectMake(85, 0, mainView.frame.size.width - 85, 80);
        titleLabel.text = [infoDictionary valueForKey:@"title"];
        titleLabel.textColor = [AppColours textColour];
        titleLabel.numberOfLines = 2;
        titleLabel.adjustsFontSizeToFitWidth = YES;
        [mainView addSubview:titleLabel];

        UILabel *infoLabel = [UILabel new];
        infoLabel.frame = CGRectMake(5, 80, mainView.frame.size.width - 45, 20);
        infoLabel.text = [NSString stringWithFormat:@"%@ - %@", [infoDictionary valueForKey:@"count"], [infoDictionary valueForKey:@"author"]];
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

        [self addSubview:mainView];
    }
    return self;
}

@end