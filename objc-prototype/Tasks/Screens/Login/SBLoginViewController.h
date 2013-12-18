//
// Created by Ринат Муртазин on 18.12.13.
//


#import <Foundation/Foundation.h>


@interface SBLoginViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@property (nonatomic) BOOL needShowNextScreen;

- (IBAction)loginButtonTapped:(UIButton *)sender;

@end