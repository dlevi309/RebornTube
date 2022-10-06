// Main

#import "OpenSourceLibrariesViewController.h"

// Classes

#import "../../Classes/AppColours.h"
#import "../../Classes/AppFonts.h"

// Interface

@interface OpenSourceLibrariesViewController ()
@end

@implementation OpenSourceLibrariesViewController

- (void)loadView {
	[super loadView];

	self.title = @"Open-Source Libraries";
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
        return 3;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"OpenSourceLibrariesTableViewCell";
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
                cell.textLabel.text = @"AFNetworking";
            }
            if (indexPath.row == 1) {
                cell.textLabel.text = @"FFmpegKit";
            }
            if (indexPath.row == 2) {
                cell.textLabel.text = @"MobileVLCKit";
            }
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/AFNetworking/AFNetworking"] options:@{} completionHandler:nil];
        }
        if (indexPath.row == 1) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/arthenica/ffmpeg-kit"] options:@{} completionHandler:nil];
        }
        if (indexPath.row == 2) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://code.videolan.org/videolan/VLCKit"] options:@{} completionHandler:nil];
        }
    }
}

@end