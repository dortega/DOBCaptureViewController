//
//  DOBCaptureViewController.h
//
//  Created by David Ortega on 19/02/14.
//

#import <UIKit/UIKit.h>
#import "DOBCaptureDelegate.h"


@interface DOBCaptureViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIButton *buttonFlash;
@property (assign, nonatomic) BOOL closeAfterRead;

@property (weak, nonatomic) id<DOBCaptureDelegate> delegate;

- (IBAction)switchFlash:(id)sender;
- (void) reStartRunningReader;
@end
