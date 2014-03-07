//
//  DOBCaptureViewController.m
//
//  Created by David Ortega on 19/02/14.
//

#import "DOBCaptureViewController.h"
#import "DOBCaptureConfigManager.h"
@import AVFoundation;
@import QuartzCore;

@interface DOBCaptureViewController ()<AVCaptureMetadataOutputObjectsDelegate>
@property (nonatomic) AVCaptureSession *captureSession;
@property (nonatomic) AVCaptureDeviceInput *captureDeviceInput;
@property (nonatomic) AVCaptureVideoPreviewLayer *capturePreviewLayer;
@property (nonatomic) AVCaptureVideoDataOutput *captureVideoDataOutput;
@property (nonatomic) AVCaptureDevice* captureDevice;
@end

@implementation DOBCaptureViewController


- (void)viewDidLoad {
    [super viewDidLoad];
        
    _buttonFlash = [UIButton buttonWithType:UIButtonTypeCustom];
    [_buttonFlash setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_buttonFlash setImage:[UIImage imageNamed:@"flash_off.png"] forState:UIControlStateNormal];
    [_buttonFlash setImage:[UIImage imageNamed:@"flash_on.png"] forState:UIControlStateSelected];
    [_buttonFlash addTarget:self action:@selector(switchFlash:) forControlEvents:UIControlEventTouchUpInside];
    
    NSLayoutConstraint *topConstraint =
    [NSLayoutConstraint constraintWithItem:_buttonFlash attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:15];
    NSLayoutConstraint *leadingConstraint =
    [NSLayoutConstraint constraintWithItem:_buttonFlash attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1 constant:15];
    NSLayoutConstraint *widthConstraint =
    [NSLayoutConstraint constraintWithItem:_buttonFlash attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:30];
    
    NSLayoutConstraint *heightConstraint =
    [NSLayoutConstraint constraintWithItem:_buttonFlash attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:30];
    
    
    [self.view addSubview: self.buttonFlash];
    
    [self.view addConstraints:@[topConstraint, leadingConstraint]];
    [self.buttonFlash addConstraints:@[widthConstraint, heightConstraint]];
    
    [self setupCameraSession];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_buttonFlash setSelected:[DOBCaptureConfigManager sharedInstance].flash];
    [self setFlashState:[DOBCaptureConfigManager sharedInstance].flash];
    [self.captureSession startRunning];
}

-(void) viewWillDisappear:(BOOL)animated {
    if ([_buttonFlash isSelected])
        [self setFlashState:NO];
        
    [self.captureSession stopRunning];
    [super viewWillDisappear:animated];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (AVCaptureDevice *) captureDeviceWithPosition:(AVCaptureDevicePosition)position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if (device.position == position) {
            return device;
        }
    }
    return [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
}

#pragma mark - Camera configuration
- (void)setupCameraSession {
    // Creates a capture session
    if (self.captureSession == nil) {
        self.captureSession = [[AVCaptureSession alloc] init];
    }
    
    // Begins the capture session configuration
    [self.captureSession beginConfiguration];
    
    _captureDevice = [self captureDeviceWithPosition:AVCaptureDevicePositionBack];
    
    // Locks the configuration
    BOOL success = [_captureDevice lockForConfiguration:nil];
    if (success) {
        if ([_captureDevice isAutoFocusRangeRestrictionSupported]) {
            // Restricts the autofocus to near range (new in iOS 7)
            [_captureDevice setAutoFocusRangeRestriction:AVCaptureAutoFocusRangeRestrictionNear];
        }
    }
    // unlocks the configuration
    [_captureDevice unlockForConfiguration];
    
    NSError *error;
    // Adds the device input to capture session
    self.captureDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:_captureDevice error:&error];
    if ( [self.captureSession canAddInput:self.captureDeviceInput] )
        [self.captureSession addInput:self.captureDeviceInput];
    
    // Prepares the preview layer
    self.capturePreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    CGRect frame = [[UIScreen mainScreen] bounds];
    [self.capturePreviewLayer setFrame:frame];
    [self.capturePreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    // Adds the preview layer to the main view layer
    [self.view.layer insertSublayer:self.capturePreviewLayer atIndex:0];
    
    // Creates and adds the metadata output to the capture session
    AVCaptureMetadataOutput *metadataOutput = [[AVCaptureMetadataOutput alloc] init];
    if ([self.captureSession canAddOutput:metadataOutput]) {
        [self.captureSession addOutput:metadataOutput];
    }
    
    // Creates a GCD queue to dispatch the metadata
    dispatch_queue_t metadataQueue = dispatch_queue_create("com.davidberdun.metadataqueue", DISPATCH_QUEUE_SERIAL);
    [metadataOutput setMetadataObjectsDelegate:self queue:metadataQueue];
    
    // Sets the metadata object types. Essentially, here you can choose the barcode type.
    NSArray *metadataTypes = @[ AVMetadataObjectTypeQRCode,
                                AVMetadataObjectTypeEAN13Code,
                                AVMetadataObjectTypeEAN8Code ];
    [metadataOutput setMetadataObjectTypes:metadataTypes];
    
    // Commits the camera configuration
    [self.captureSession commitConfiguration];
}



- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputMetadataObjects:(NSArray *)metadataObjects
       fromConnection:(AVCaptureConnection *)connection
{
    if ([metadataObjects count] < 1) {
        return;
    }
    for (id item in metadataObjects) {
        if ([item isKindOfClass:[AVMetadataMachineReadableCodeObject class]]) {
            if (item) {
                NSLog(@"%@", [item stringValue]);
                
                
                [self.captureSession stopRunning];
                
                if (_closeAfterRead) {
                    [self dismissViewControllerAnimated:YES completion:^{
                        [self.delegate codeCaptured:[item stringValue]];
                    }];
                } else {
                    [self.delegate codeCaptured:[item stringValue]];
                }
                
            }
        }
    }
}


- (IBAction)switchFlash:(id)sender {
    
    BOOL state = ! [_buttonFlash isSelected];
    
    [self setFlashState:state];
    
    [_buttonFlash setSelected:state];
    [DOBCaptureConfigManager sharedInstance].flash = state;
    
}


- (void) setFlashState: (BOOL) state {
    NSError* error;
    
    if ([_captureDevice hasTorch]) {
        [_captureDevice lockForConfiguration:&error];
        (state)?[_captureDevice setTorchMode:AVCaptureTorchModeOn]:[_captureDevice setTorchMode:AVCaptureTorchModeOff];
        [_captureDevice unlockForConfiguration];
    }
    
    if (error)
        NSLog(@"Error switching on flash: %@", error);
}

- (void) reStartRunningReader {
    BOOL state = [DOBCaptureConfigManager sharedInstance].flash;
    
    [self setFlashState:state];
    
    [self.captureSession startRunning];
}


@end
