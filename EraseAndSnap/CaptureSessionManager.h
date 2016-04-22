#import <AVFoundation/AVFoundation.h>

#define kImageCapturedSuccessfully @"imageCapturedSuccessfully"

@class CaptureSessionManager;
@protocol CaptureSessionManagerDelegate <NSObject>

@optional
-(void)liveVideoOutput:(NSArray *)array;
-(void)liveVideoOutputWithCIIImage:(CIImage *)ciimage fromArray:(NSArray *)array ;

@end

@interface CaptureSessionManager : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate>{

    BOOL isUsingFrontFacingCamera;
}

@property (retain) AVCaptureVideoPreviewLayer *previewLayer;
@property (retain) AVCaptureSession *captureSession;
@property (retain) AVCaptureStillImageOutput *stillImageOutput;
@property (retain) AVCaptureConnection *captureConnection;
@property (nonatomic, retain) UIImage *stillImage;

- (void)addVideoPreviewLayer;
- (void)addStillImageOutput;
-(void)addVideoOutput;
- (void)captureStillImage;
- (void)addVideoInputFrontCamera:(BOOL)front;
-(void) stop;

@property (nonatomic, assign) id <CaptureSessionManagerDelegate> delegate;

@end
