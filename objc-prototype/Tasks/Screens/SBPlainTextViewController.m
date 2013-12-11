//
//  SBPlainTextViewController.m
//  Datastore Examples
//
//  Created by Vladimir Ignatev on 11.12.13.
//
//

#import "SBPlainTextViewController.h"

@interface SBPlainTextViewController ()

@end

@implementation SBPlainTextViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.textView.text = self.textToPresent;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
