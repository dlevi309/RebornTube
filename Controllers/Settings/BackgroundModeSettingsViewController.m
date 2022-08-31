// Main

#import "BackgroundModeSettingsViewController.h"

// Classes

#import "../../Classes/AppColours.h"

// Definitions

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

// Interface

@interface BackgroundModeSettingsViewController ()
{
    int selectedIndex;
}
@end

@implementation BackgroundModeSettingsViewController

- (void)loadView {
	[super loadView];

	self.title = @"Background Mode";
    self.view.backgroundColor = [AppColours mainBackgroundColour];

    if (@available(iOS 15.0, *)) {
    	[self.tableView setSectionHeaderTopPadding:0.0f];
	}

    if (![[NSUserDefaults standardUserDefaults] integerForKey:@"kBackgroundMode"]) {
        selectedIndex = 0;
    } else {
        selectedIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"kBackgroundMode"];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"14.0")) {
            return 3;
        } else {
            return 2;
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"BackgroundModeSettingsTableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
        cell.backgroundColor = [AppColours viewBackgroundColour];
        cell.textLabel.textColor = [AppColours textColour];
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                cell.textLabel.text = @"None";
                if (selectedIndex == 0) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
            }
            if (indexPath.row == 1) {
                cell.textLabel.text = @"Background Playback";
                if (selectedIndex == 1) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
            }
            if (indexPath.row == 2) {
                cell.textLabel.text = @"Picture In Picture";
                if (selectedIndex == 2) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
            }
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    selectedIndex = indexPath.row;
    [[NSUserDefaults standardUserDefaults] setInteger:selectedIndex forKey:@"kBackgroundMode"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.tableView reloadData];
}

@end