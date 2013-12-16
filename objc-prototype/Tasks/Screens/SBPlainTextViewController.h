//
//  SBPlainTextViewController.h
//  Datastore Examples
//
//  Created by Vladimir Ignatev on 11.12.13.
//
//

#import <UIKit/UIKit.h>

@interface SBPlainTextViewController : UIViewController <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *textView;

@property(strong, nonatomic) NSString *textToPresent;

@end
