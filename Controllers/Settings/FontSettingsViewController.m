// Main

#import "FontSettingsViewController.h"

// Classes

#import "../../Classes/AppColours.h"

// Interface

@interface FontSettingsViewController ()
@end

@implementation FontSettingsViewController

- (void)loadView {
	[super loadView];

	self.title = @"Font";
    self.view.backgroundColor = [AppColours mainBackgroundColour];

    if (@available(iOS 15.0, *)) {
    	[self.tableView setSectionHeaderTopPadding:0.0f];
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 2;
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
                cell.textLabel.text = @"San Francisco";
            }
            if (indexPath.row == 1) {
                cell.textLabel.text = @"Tabitha";
            }
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.tableView reloadData];
}

@end