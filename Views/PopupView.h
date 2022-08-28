#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, Alignment) {
    Top,
    Middle,
    Bottom
};

@interface PopupView : UIView

@property (nonatomic, assign) Alignment align;
@property (nonatomic, strong) NSString *text;

@end