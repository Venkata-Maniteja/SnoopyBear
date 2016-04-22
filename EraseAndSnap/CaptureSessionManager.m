#import "CaptureSessionManager.h"
#import <ImageIO/ImageIO.h>
#import <UIKit/UIKit.h>

@implementation CaptureSessionManager

@synthesize captureSession;
@synthesize previewLayer;
@synthesize stillImageOutput;
@synthesize stillImage;

#pragma mark Capture Session Configuration

- (id)init {
	if ((self = [super init])) {
		[self setCaptureSession:[[AVCaptureSession alloc] init]];
	}
	return self;
}

- (void)addVideoPreviewLayer {
	[self setPreviewLayer:[[AVCaptureVideoPreviewLayer alloc] initWithSession:[self captureSession]]];
	[[self previewLayer] setVideoGravity:AVLayerVideoGravityResizeAspectFill];
  
}

- (void)addVideoInputFrontCamera:(BOOL)front {
    NSArray *devices = [AVCaptureDevice devices];
    AVCaptureDevice *frontCamera;
    AVCaptureDevice *backCamera;
    
    for (AVCaptureDevice *device in devices) {
        
        NSLog(@"Device name: %@", [device localizedName]);
        
        if ([device hasMediaType:AVMediaTypeVideo]) {
            
            if ([device position] == AVCaptureDevicePositionBack) {
                NSLog(@"Device position : back");
                backCamera = device;
            }
            else {
                NSLog(@"Device position : front");
                frontCamera = device;
            }
        }
    }
    
    NSError *error = nil;
    
    if (front) {
        isUsingFrontFacingCamera=YES;
        AVCaptureDeviceInput *frontFacingCameraDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:frontCamera error:&error];
        if (!error) {
            if ([[self captureSession] canAddInput:frontFacingCameraDeviceInput]) {
                [[self captureSession] addInput:frontFacingCameraDeviceInput];
            } else {
                NSLog(@"Couldn't add front facing video input");
            }
        }
    } else {
        AVCaptureDeviceInput *backFacingCameraDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:backCamera error:&error];
        if (!error) {
            if ([[self captureSession] canAddInput:backFacingCameraDeviceInput]) {
                [[self captureSession] addInput:backFacingCameraDeviceInput];
            } else {
                NSLog(@"Couldn't add back facing video input");
            }
        }
    }
}

- (void)addStillImageOutput 
{
  [self setStillImageOutput:[[AVCaptureStillImageOutput alloc] init] ];
  NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey,nil];
  [[self stillImageOutput] setOutputSettings:outputSettings];
  
  AVCaptureConnection *videoConnection = nil;
  for (AVCaptureConnection *connection in [[self stillImageOutput] connections]) {
    for (AVCaptureInputPort *port in [connection inputPorts]) {
      if ([[port mediaType] isEqual:AVMediaTypeVideo] ) {
        videoConnection = connection;
        break;
      }
    }
    if (videoConnection) { 
      break; 
    }
  }
  
  [[self captureSession] addOutput:[self stillImageOutput]];
}

-(void)addVideoOutput{
    
    AVCaptureVideoDataOutput *output2 = [[AVCaptureVideoDataOutput alloc] init];
    [[self captureSession] addOutput:output2];
    output2.videoSettings = @{(NSString*)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA)};
    output2.alwaysDiscardsLateVideoFrames = YES;
    dispatch_queue_t queue = dispatch_queue_create("com.myapp.faceDetectionQueueSerial", DISPATCH_QUEUE_SERIAL);
    [output2 setSampleBufferDelegate:self queue:queue];
}

- (void)captureStillImage
{  
	
	for (AVCaptureConnection *connection in [[self stillImageOutput] connections]) {
		for (AVCaptureInputPort *port in [connection inputPorts]) {
			if ([[port mediaType] isEqual:AVMediaTypeVideo]) {
				_captureConnection = connection;
				break;
			}
		}
		if (_captureConnection) {
            
      break; 
    }
	}
  
	NSLog(@"about to request a capture from: %@", [self stillImageOutput]);
	[[self stillImageOutput] captureStillImageAsynchronouslyFromConnection:_captureConnection
                                                       completionHandler:^(CMSampleBufferRef imageSampleBuffer, NSError *error) { 
                                                         CFDictionaryRef exifAttachments = CMGetAttachment(imageSampleBuffer, kCGImagePropertyExifDictionary, NULL);
                                                         if (exifAttachments) {
                                                           NSLog(@"attachements: %@", exifAttachments);
                                                         } else { 
                                                           NSLog(@"no attachments");
                                                         }
                                                         NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];    
                                                         UIImage *image = [[UIImage alloc]initWithData:imageData];
                                                           
                                                      
                                                         [self setStillImage:image];
                                                           
                                                         [[NSNotificationCenter defaultCenter] postNotificationName:kImageCapturedSuccessfully object:nil];
                                                       }];
}

- (void)stop {

	[[self captureSession] stopRunning];

     previewLayer = nil;
	 captureSession = nil;
  stillImageOutput = nil;
  stillImage = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    

	
}

//- (void) captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
//    
//    CIImage *ciimage = [CIImage imageWithCVPixelBuffer:CMSampleBufferGetImageBuffer(sampleBuffer)];
//    NSDictionary *opts = @{ CIDetectorAccuracy : CIDetectorAccuracyLow };
//    
//    CIDetector *faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:[CIContext contextWithOptions:nil] options:opts];
//    
//    UIDeviceOrientation curDeviceOrientation = [[UIDevice currentDevice] orientation];
//    int exifOrientation;
//    
//    enum {
//        PHOTOS_EXIF_0ROW_TOP_0COL_LEFT          = 1, //   1  =  0th row is at the top, and 0th column is on the left (THE DEFAULT).
//        PHOTOS_EXIF_0ROW_TOP_0COL_RIGHT         = 2, //   2  =  0th row is at the top, and 0th column is on the right.
//        PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT      = 3, //   3  =  0th row is at the bottom, and 0th column is on the right.
//        PHOTOS_EXIF_0ROW_BOTTOM_0COL_LEFT       = 4, //   4  =  0th row is at the bottom, and 0th column is on the left.
//        PHOTOS_EXIF_0ROW_LEFT_0COL_TOP          = 5, //   5  =  0th row is on the left, and 0th column is the top.
//        PHOTOS_EXIF_0ROW_RIGHT_0COL_TOP         = 6, //   6  =  0th row is on the right, and 0th column is the top.
//        PHOTOS_EXIF_0ROW_RIGHT_0COL_BOTTOM      = 7, //   7  =  0th row is on the right, and 0th column is the bottom.
//        PHOTOS_EXIF_0ROW_LEFT_0COL_BOTTOM       = 8  //   8  =  0th row is on the left, and 0th column is the bottom.
//    };
//
//    switch (curDeviceOrientation) {
//        case UIDeviceOrientationPortraitUpsideDown:  // Device oriented vertically, home button on the top
//            exifOrientation = PHOTOS_EXIF_0ROW_LEFT_0COL_BOTTOM;
//            break;
//        case UIDeviceOrientationLandscapeLeft:       // Device oriented horizontally, home button on the right
//            if (isUsingFrontFacingCamera)
//                exifOrientation = PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT;
//            else
//                exifOrientation = PHOTOS_EXIF_0ROW_TOP_0COL_LEFT;
//            break;
//        case UIDeviceOrientationLandscapeRight:      // Device oriented horizontally, home button on the left
//            if (isUsingFrontFacingCamera)
//                exifOrientation = PHOTOS_EXIF_0ROW_TOP_0COL_LEFT;
//            else
//                exifOrientation = PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT;
//            break;
//        case UIDeviceOrientationPortrait:            // Device oriented vertically, home button on the bottom
//        default:
//            exifOrientation = PHOTOS_EXIF_0ROW_RIGHT_0COL_TOP;
//            break;
//    }
//    NSString *prop =@"1";//[[ciimage properties] valueForKey:(__bridge NSString *)kCGImagePropertyOrientation];
//    
//    opts = @{ CIDetectorImageOrientation :prop
//                  };
//    
//    
//    NSArray *features = [faceDetector featuresInImage:ciimage options:opts];
//    
//    //send this arry to uiview and update the uiview accordingly
//    [_delegate liveVideoOutputWithCIIImage:ciimage fromArray:features];
// 
//    
//}

@end
