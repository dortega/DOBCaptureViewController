//
//  DOBCaptureConfigManager.h
//
//  Created by David Ortega on 07/03/14.
//

#import <Foundation/Foundation.h>

@interface DOBCaptureConfigManager : NSObject

@property (assign) BOOL flash;

+ (DOBCaptureConfigManager *)sharedInstance;

@end
