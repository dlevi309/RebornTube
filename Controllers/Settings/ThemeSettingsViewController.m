// Main

#import "ThemeSettingsViewController.h"

// Classes

#import "../../Classes/AppColours.h"

// Interface

@interface ThemeSettingsViewController ()
{
    int selectedIndex;
}
@end

@implementation ThemeSettingsViewController

- (void)loadView {
	[super loadView];

	self.title = @"";
    self.view.backgroundColor = [AppColours mainBackgroundColour];

    if (@available(iOS 15.0, *)) {
    	[self.tableView setSectionHeaderTopPadding:0.0f];
	}

    if (![[NSUserDefaults standardUserDefaults] integerForKey:@"kAppTheme"]) {
        selectedIndex = 0;
    } else {
        selectedIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"kAppTheme"];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 4;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"ThemeSettingsTableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
        cell.backgroundColor = [AppColours viewBackgroundColour];
        cell.textLabel.textColor = [AppColours textColour];
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                cell.textLabel.text = @"Auto (Device)";
                if (selectedIndex == 0) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
            }
            if (indexPath.row == 1) {
                cell.textLabel.text = @"Light";
                if (selectedIndex == 1) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
            }
            if (indexPath.row == 2) {
                cell.textLabel.text = @"Dark";
                if (selectedIndex == 2) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
            }
            if (indexPath.row == 3) {
                cell.textLabel.text = @"Pure Dark";
                if (selectedIndex == 3) {
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
    [[NSUserDefaults standardUserDefaults] setInteger:selectedIndex forKey:@"kAppTheme"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.tableView reloadData];
}

@end