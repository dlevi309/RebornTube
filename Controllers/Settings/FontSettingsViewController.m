// Main

#import "FontSettingsViewController.h"

// Classes

#import "../../Classes/AppColours.h"

// Interface

@interface FontSettingsViewController ()
{
    int selectedIndex;
}
@end

@implementation FontSettingsViewController

- (void)loadView {
	[super loadView];

	self.title = @"Font";
    self.view.backgroundColor = [AppColours mainBackgroundColour];

    if (@available(iOS 15.0, *)) {
    	[self.tableView setSectionHeaderTopPadding:0.0f];
	}

    if (![[NSUserDefaults standardUserDefaults] integerForKey:@"kFontOption"]) {
        selectedIndex = 0;
    } else {
        selectedIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"kFontOption"];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 6;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"FontSettingsTableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
        cell.backgroundColor = [AppColours viewBackgroundColour];
        cell.textLabel.textColor = [AppColours textColour];
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                cell.textLabel.text = @"San Francisco (iOS Default)";
                if (selectedIndex == 0) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
            }
            if (indexPath.row == 1) {
                cell.textLabel.text = @"Arial";
                if (selectedIndex == 1) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
            }
            if (indexPath.row == 2) {
                cell.textLabel.text = @"Helvetica";
                if (selectedIndex == 2) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
            }
            if (indexPath.row == 3) {
                cell.textLabel.text = @"Minecraft";
                if (selectedIndex == 3) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
            }
            if (indexPath.row == 4) {
                cell.textLabel.text = @"Tabitha";
                if (selectedIndex == 4) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
            }
            if (indexPath.row == 5) {
                cell.textLabel.text = @"Times New Roman";
                if (selectedIndex == 5) {
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
    [[NSUserDefaults standardUserDefaults] setInteger:selectedIndex forKey:@"kFontOption"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.tableView reloadData];
}

@end