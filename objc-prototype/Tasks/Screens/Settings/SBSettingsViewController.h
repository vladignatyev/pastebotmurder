//
// Created by Ринат Муртазин on 19.12.13.
//

#import <Foundation/Foundation.h>


@interface SBSettingsViewController : UIViewController <UIAlertViewDelegate>

@property(nonatomic, strong) DBDatastore *store;

@property (weak, nonatomic) IBOutlet UILabel *accountLabel;

- (IBAction)didPressUnlink:(id)sender;
- (IBAction)didTapClearDataButton:(id)sender;

@end