//
// Created by Ринат Муртазин on 09.12.13.
//


#import <Foundation/Foundation.h>


@interface SBImageViewController : UIViewController <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) NSString *imageName;

@property (nonatomic) BOOL imageFitMode;

- (IBAction)closeButtonPress:(id)sender;
- (IBAction)changeMode:(UISwitch *)sender;

@end