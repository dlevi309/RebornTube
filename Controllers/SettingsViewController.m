#import "SettingsViewController.h"
#import "BackgroundModeSettingsViewController.h"
#import "SponsorBlockSettingsViewController.h"
#import "../Headers/TheosLinuxFix.h"
#import "../Headers/iOS15Fix.h"

@interface SettingsViewController ()
@end

@implementation SettingsViewController

- (void)loadView {
	[super loadView];

	self.title = @"";
    self.view.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
	[self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
	self.navigationController.navigationBar.barStyle = UIBarStyleBlack;

	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
    self.navigationItem.leftBarButtonItem = doneButton;

    UIBarButtonItem *applyButton = [[UIBarButtonItem alloc] initWithTitle:@"Apply" style:UIBarButtonItemStylePlain target:self action:@selector(apply)];
    self.navigationItem.rightBarButtonItem = applyButton;

    if (@available(iOS 15.0, *)) {
    	[self.tableView setSectionHeaderTopPadding:0.0f];
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    if (section == 1) {
        return 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"SettingsTableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
        cell.textLabel.adjustsFontSizeToFitWidth = true;
        cell.textLabel.adjustsFontForContentSizeCategory = false;
        cell.backgroundColor = [UIColor colorWithRed:0.110 green:0.110 blue:0.118 alpha:1.0];
        cell.textLabel.textColor = [UIColor whiteColor];
        if (indexPath.section == 0) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            if (indexPath.row == 0) {
                cell.textLabel.text = @"Background Mode";
                if (![[NSUserDefaults standardUserDefaults] integerForKey:@"kBackgroundMode"]) {
                    cell.detailTextLabel.text = @"None";
                } else {
                    int selectedTab = [[NSUserDefaults standardUserDefaults] integerForKey:@"kBackgroundMode"];
                    if (selectedTab == 0) {
                        cell.detailTextLabel.text = @"None";
                    }
                    if (selectedTab == 1) {
                        cell.detailTextLabel.text = @"Background Playback";
                    }
                    if (selectedTab == 2) {
                        cell.detailTextLabel.text = @"Picture In Picture";
                    }
                }
            }
        }
        if (indexPath.section == 1) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            if (indexPath.row == 0) {
                cell.textLabel.text = @"SponsorBlock";
            }
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            BackgroundModeSettingsViewController *backgroundModeSettingsViewController = [[BackgroundModeSettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
            UINavigationController *backgroundModeSettingsViewControllerView = [[UINavigationController alloc] initWithRootViewController:backgroundModeSettingsViewController];
            backgroundModeSettingsViewControllerView.modalPresentationStyle = UIModalPresentationFullScreen;

            [self presentViewController:backgroundModeSettingsViewControllerView animated:YES completion:nil];
        }
    }
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            SponsorBlockSettingsViewController *sponsorBlockSettingsViewController = [[SponsorBlockSettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
            UINavigationController *sponsorBlockSettingsViewControllerView = [[UINavigationController alloc] initWithRootViewController:sponsorBlockSettingsViewController];
            sponsorBlockSettingsViewControllerView.modalPresentationStyle = UIModalPresentationFullScreen;

            [self presentViewController:sponsorBlockSettingsViewControllerView animated:YES completion:nil];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [self.tableView reloadData];
}

@end

@implementation SettingsViewController (Privates)

- (void)done {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)apply {
    exit(0); 
}

@end