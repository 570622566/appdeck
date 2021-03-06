//
//  BarCodeScannerViewController.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 04/09/2017.
//  Copyright © 2017 Mathieu De Kermadec. All rights reserved.
//

#import "BarCodeScannerViewController.h"

@interface BarCodeScannerViewController ()

@end

@implementation BarCodeScannerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //self.view.backgroundColor = [UIColor blackColor];
    [self startReading];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (BOOL)startReading {
    NSError *error;
    
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];

    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    
    if (!input) {
        NSLog(@"%@", [error localizedDescription]);
        return NO;
    }
    
    _captureSession = [[AVCaptureSession alloc] init];
    [_captureSession addInput:input];
    
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [_captureSession addOutput:captureMetadataOutput];
    
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create("myQueue", NULL);
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    [captureMetadataOutput setMetadataObjectTypes:@[AVMetadataObjectTypeUPCECode, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode39Mod43Code, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeCode128Code, AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeQRCode, AVMetadataObjectTypeAztecCode, AVMetadataObjectTypeInterleaved2of5Code, AVMetadataObjectTypeITF14Code, AVMetadataObjectTypeDataMatrixCode]];
 
    _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [_videoPreviewLayer setFrame:self.preview.layer.bounds];
    [self.preview.layer addSublayer:_videoPreviewLayer];
    
    [_captureSession startRunning];
    
    return YES;
}

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeUPCECode] ||
            [[metadataObj type] isEqualToString:AVMetadataObjectTypeCode39Code] ||
            [[metadataObj type] isEqualToString:AVMetadataObjectTypeCode39Mod43Code] ||
            [[metadataObj type] isEqualToString:AVMetadataObjectTypeEAN13Code] ||
            [[metadataObj type] isEqualToString:AVMetadataObjectTypeEAN8Code] ||
            [[metadataObj type] isEqualToString:AVMetadataObjectTypeCode93Code] ||
            [[metadataObj type] isEqualToString:AVMetadataObjectTypeCode128Code] ||
            [[metadataObj type] isEqualToString:AVMetadataObjectTypePDF417Code] ||
            [[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode] ||
            [[metadataObj type] isEqualToString:AVMetadataObjectTypeAztecCode] ||
            [[metadataObj type] isEqualToString:AVMetadataObjectTypeInterleaved2of5Code] ||
            [[metadataObj type] isEqualToString:AVMetadataObjectTypeITF14Code] ||
            [[metadataObj type] isEqualToString:AVMetadataObjectTypeDataMatrixCode]) {
            NSString *match = [metadataObj stringValue];
            if (![self.lastMatch isEqualToString:match])
            {
                NSLog(@"Read: %@", match);
                self.lastMatch = match;
                
                dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.origin sendRepeatingCallback:@[match]];
                    });
                });
                
            }
            
        }
    }
}

-(void)stopReading
{
    [_captureSession stopRunning];
    _captureSession = nil;
    
    [_videoPreviewLayer removeFromSuperlayer];
}

@end
