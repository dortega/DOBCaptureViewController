//
//  DOBCaptureConfigManager.m
//
//  Created by David Ortega on 07/03/14.
//

#import "DOBCaptureConfigManager.h"

@implementation DOBCaptureConfigManager

+ (DOBCaptureConfigManager *)sharedInstance
{
    static DOBCaptureConfigManager *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[DOBCaptureConfigManager alloc] init];
    });
    return _instance;
}

@end
