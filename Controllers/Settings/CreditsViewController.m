// Main

#import "CreditsViewController.h"

// Classes

#import "../../Classes/AppColours.h"
#import "../../Classes/AppFonts.h"

// Interface

@interface CreditsViewController ()
@end

@implementation CreditsViewController

- (void)loadView {
	[super loadView];

	self.title = @"Credits";
    self.view.backgroundColor = [AppColours mainBackgroundColour];

    if (@available(iOS 15.0, *)) {
    	[self.tableView setSectionHeaderTopPadding:0.0f];
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    if (section == 1) {
        return 19;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CreditsTableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
        cell.backgroundColor = [AppColours viewBackgroundColour];
        cell.textLabel.textColor = [AppColours textColour];
        cell.detailTextLabel.textColor = [AppColours textColour];
        [cell.textLabel setFont:[AppFonts mainFont:cell.textLabel.font.pointSize]];
        [cell.detailTextLabel setFont:[AppFonts mainFont:cell.detailTextLabel.font.pointSize]];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                cell.textLabel.text = @"Lillie";
                cell.detailTextLabel.text = @"Developer";
            }
        }
        if (indexPath.section == 1) {
            if (indexPath.row == 0) {
                cell.textLabel.text = @"Alpha_Stream";
                cell.detailTextLabel.text = @"Icon Designer, Alpha Tester";
            }
            if (indexPath.row == 1) {
                cell.textLabel.text = @"Arsenal";
                cell.detailTextLabel.text = @"Alpha Tester";
            }
            if (indexPath.row == 2) {
                cell.textLabel.text = @"Cameren";
                cell.detailTextLabel.text = @"Alpha Tester";
            }
            if (indexPath.row == 3) {
                cell.textLabel.text = @"Clarity";
                cell.detailTextLabel.text = @"Alpha Tester";
            }
            if (indexPath.row == 4) {
                cell.textLabel.text = @"Cling Clang Bleep";
                cell.detailTextLabel.text = @"Alpha Tester";
            }
            if (indexPath.row == 5) {
                cell.textLabel.text = @"Emma";
                cell.detailTextLabel.text = @"Alpha Tester";
            }
            if (indexPath.row == 6) {
                cell.textLabel.text = @"fiore";
                cell.detailTextLabel.text = @"Alpha Tester";
            }
            if (indexPath.row == 7) {
                cell.textLabel.text = @"Hayden";
                cell.detailTextLabel.text = @"Alpha Tester";
            }
            if (indexPath.row == 8) {
                cell.textLabel.text = @"jazzy";
                cell.detailTextLabel.text = @"Alpha Tester";
            }
            if (indexPath.row == 9) {
                cell.textLabel.text = @"kirb";
                cell.detailTextLabel.text = @"Development Support, Alpha Tester";
            }
            if (indexPath.row == 10) {
                cell.textLabel.text = @"llsc12";
                cell.detailTextLabel.text = @"Development Support, Alpha Tester";
            }
            if (indexPath.row == 11) {
                cell.textLabel.text = @"maxasix";
                cell.detailTextLabel.text = @"Alpha Tester";
            }
            if (indexPath.row == 12) {
                cell.textLabel.text = @"Natalie";
                cell.detailTextLabel.text = @"Alpha Tester";
            }
            if (indexPath.row == 13) {
                cell.textLabel.text = @"nebula";
                cell.detailTextLabel.text = @"Alpha Tester";
            }
            if (indexPath.row == 14) {
                cell.textLabel.text = @"Needleroozer";
                cell.detailTextLabel.text = @"Alpha Tester";
            }
            if (indexPath.row == 15) {
                cell.textLabel.text = @"nyuszika7h";
                cell.detailTextLabel.text = @"Alpha Tester";
            }
            if (indexPath.row == 16) {
                cell.textLabel.text = @"oneinanull";
                cell.detailTextLabel.text = @"Alpha Tester";
            }
            if (indexPath.row == 17) {
                cell.textLabel.text = @"Sarah";
                cell.detailTextLabel.text = @"Alpha Tester";
            }
            if (indexPath.row == 18) {
                cell.textLabel.text = @"The_Lucifer";
                cell.detailTextLabel.text = @"Alpha Tester";
            }
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/LillieH001"] options:@{} completionHandler:nil];
        }
    }
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/Kutarin_"] options:@{} completionHandler:nil];
        }
    }
}

@end