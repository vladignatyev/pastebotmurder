//
// Created by Ринат Муртазин on 18.12.13.
//


#import <Foundation/Foundation.h>


@interface SBLoginViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *loginButton;

- (IBAction)loginButtonTapped:(UIButton *)sender;

@end