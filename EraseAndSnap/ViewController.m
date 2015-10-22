//
//  ViewController.m
//  EraseAndSnap
//
//  Created by Venkata Maniteja on 2015-10-19.
//  Copyright © 2015 Venkata Maniteja. All rights reserved.
//

#import "ViewController.h"
#import "drawView.h"
#import <ImageIO/CGImageProperties.h>
#import "Masonry.h"

@interface ViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,AVCaptureAudioDataOutputSampleBufferDelegate>

@property (strong,nonatomic) IBOutlet UIView *imageUIView;
@property (nonatomic,strong) UIView *topV;
@property (nonatomic,strong) UIView *botV;
@property (nonatomic,strong) UIView *snapView;
@property  (strong,nonatomic) drawView *dView;

@property (nonatomic,strong) UIImage *avCapturedImage;
@property (nonatomic,strong) CALayer *subLayerCamera;


@property (assign) BOOL firstPicTaken;
@property (assign) BOOL secondPicTaken;






@end

@implementation ViewController

@synthesize imageUIView,firstPicTaken,secondPicTaken,dView,captureManager;
;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    firstPicTaken=NO;
    secondPicTaken=NO;
    // Do any additional setup after loading the view, typically from a nib.
    
    
}

-(void)addTagsToViews{
    
    _topV.tag=0;
    _botV.tag=1;
    _snapView.tag=2;
    imageUIView.tag=3;
    dView.tag=4;
    
    
}

-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
    [self addTagsToViews];
    
}

-(IBAction)clear:(id)sender{
    [self stopReading];
}

-(IBAction)takeSecondPic:(id)sender{
    
    if (!firstPicTaken && !secondPicTaken) {
        
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        [self presentViewController:picker animated:YES completion:NULL];
        
    }
    
    if (firstPicTaken && !secondPicTaken) {
       
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self startReading];
            
            secondPicTaken=YES;
            
            [_bbitemStart setTitle:@"Snap!!!!"];
            
            
        });
    }
    
    if (secondPicTaken) {
       
         [self takeScreenShot];
        
    }
    
}

-(void)takeScreenShot{
    
       [[self captureManager] captureStillImage];
    
    //[self stopReading];
    
}


-(void)takeSnapShot{
    
    UIGraphicsBeginImageContext(self.view.frame.size);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImageWriteToSavedPhotosAlbum(viewImage, nil, nil, nil);
    
}


- (IBAction)selectPhoto:(UIButton *)sender {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
    
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    
    dView=[[drawView alloc]initWithFrame:imageUIView.frame];
    [dView drawImage:chosenImage];
    
    [imageUIView addSubview:dView];
    
    firstPicTaken=YES;
    
    _bbitemStart.title=@"Take Another Pic";
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}



- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Private method implementation

- (BOOL)startReading {
    
    
    [self setCaptureManager:[[CaptureSessionManager alloc] init]];
    
    [[self captureManager] addVideoInputFrontCamera:NO]; // set to YES for Front Camera, No for Back camera
    
    [[self captureManager] addStillImageOutput];
    
    [[self captureManager] addVideoPreviewLayer];
    
    
    NSNumber *x=[[NSUserDefaults standardUserDefaults]objectForKey:@"x"];
    NSNumber *y=[[NSUserDefaults standardUserDefaults]objectForKey:@"y"];
    NSNumber *width=[[NSUserDefaults standardUserDefaults]objectForKey:@"width"];
    NSNumber *height=[[NSUserDefaults standardUserDefaults]objectForKey:@"height"];
    
    
    
    CGRect layerRect = CGRectMake([x floatValue], [y floatValue], [width floatValue], [height floatValue]);//[[[self view] layer] bounds];
    [[[self captureManager] previewLayer] setBounds:layerRect];
    [[[self captureManager] previewLayer] setPosition:CGPointMake(CGRectGetMidX(layerRect),CGRectGetMidY(layerRect))];
    _subLayerCamera=[[self captureManager]previewLayer];
    
    [imageUIView.layer insertSublayer:_subLayerCamera below:dView.layer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveImageToPhotoAlbum) name:kImageCapturedSuccessfully object:nil];
    
    [[captureManager captureSession] startRunning];
    
    return YES;
}

- (void)saveImageToPhotoAlbum
{
//    UIImageWriteToSavedPhotosAlbum([[self captureManager] stillImage], self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    
    _avCapturedImage=[[self captureManager] stillImage];
    
    [self addViewsForSnapShot];
    
    [[self captureManager]stop];

    
    [self takeSnapShot];

}

-(void)addViewsForSnapShot{
    
    _snapView=[[UIView alloc]initWithFrame:imageUIView.frame];
    UIImageView *imageView = [[UIImageView alloc]init];//WithImage:imag];
    
    
    
    NSNumber *x=[[NSUserDefaults standardUserDefaults]objectForKey:@"x"];
    NSNumber *y=[[NSUserDefaults standardUserDefaults]objectForKey:@"y"];
    NSNumber *width=[[NSUserDefaults standardUserDefaults]objectForKey:@"width"];
    NSNumber *height=[[NSUserDefaults standardUserDefaults]objectForKey:@"height"];
    
    
    
    CGRect layerRect = CGRectMake([x floatValue], [y floatValue], [width floatValue], [height floatValue]);
    
    [imageView setFrame:layerRect];
    
    [imageView setContentMode:UIViewContentModeScaleAspectFill];
    imageView.image=_avCapturedImage;
    [imageView setFrame:AVMakeRectWithAspectRatioInsideRect(imageView.image.size, _snapView.frame)];
    [_snapView addSubview:imageView];
    [_snapView addSubview:dView];
    
    
    [self.view addSubview:_snapView];
    
    [self addTwoViews];

}

-(void)addTwoViews{
    
    _topV=[[UIView alloc]initWithFrame:CGRectMake(0, 0, imageUIView.frame.size.width, 140)];
    _topV.backgroundColor=[UIColor blackColor];
    [self.view addSubview:_topV];
    
    _botV=[[UIView alloc]initWithFrame:CGRectMake(0, 550, imageUIView.frame.size.width, 150)];
    _botV.backgroundColor=[UIColor blackColor];
    [self.view addSubview:_botV];
}



- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error != NULL) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Image couldn't be saved" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        
    }
    
}

-(void)stopReading{
    
    firstPicTaken=NO;
    secondPicTaken=NO;
    _bbitemStart.title=@"Take Pic";
    
    [_topV removeFromSuperview];
    [_botV removeFromSuperview];
    [dView removeFromSuperview];
    [_snapView removeFromSuperview];
    [_subLayerCamera removeFromSuperlayer];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kImageCapturedSuccessfully object:nil];
   // [imageUIView removeFromSuperview];
   
    _topV=nil;
    _botV=nil;
    dView=nil;
  //  imageUIView=nil;
    _snapView=nil;
    
}








@end
