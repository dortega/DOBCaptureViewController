//
//  DOBCaptureDelegate.h
//
//  Created by David Ortega on 05/03/14.
//

#import <Foundation/Foundation.h>

@protocol DOBCaptureDelegate <NSObject>

- (void) codeCaptured: (NSString*) code;

@end

