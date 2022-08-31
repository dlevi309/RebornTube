// Main

#import "MainDisplayView.h"

// Classes

#import "../Classes/AppColours.h"

// Interface

@interface MainDisplayView ()
@end

@implementation MainDisplayView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        /* UIImageView *videoImage = [[UIImageView alloc] init];
        videoImage.frame = CGRectMake(0, 0, 80, 80);
        videoImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.image]]];
        [self addSubview:videoImage]; */

        UIView *view = [[UIView alloc] init];
        view.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        view.backgroundColor = [AppColours viewBackgroundColour];
        [self addSubview:view];
    }
    return self;
}

@end