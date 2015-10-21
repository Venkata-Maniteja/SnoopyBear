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

@property  (strong,nonatomic) drawView *dView;

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

-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
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
    
    
    [self setCaptureManager:[[CaptureSessionManager alloc] init] ];
    
    [[self captureManager] addVideoInputFrontCamera:YES]; // set to YES for Front Camera, No for Back camera
    
    [[self captureManager] addStillImageOutput];
    
    [[self captureManager] addVideoPreviewLayer];
    
    
    NSNumber *x=[[NSUserDefaults standardUserDefaults]objectForKey:@"x"];
    NSNumber *y=[[NSUserDefaults standardUserDefaults]objectForKey:@"y"];
    NSNumber *width=[[NSUserDefaults standardUserDefaults]objectForKey:@"width"];
    NSNumber *height=[[NSUserDefaults standardUserDefaults]objectForKey:@"height"];
    
    
    
    CGRect layerRect = CGRectMake([x floatValue], [y floatValue], [width floatValue], [height floatValue]);//[[[self view] layer] bounds];
    [[[self captureManager] previewLayer] setBounds:layerRect];
    [[[self captureManager] previewLayer] setPosition:CGPointMake(CGRectGetMidX(layerRect),CGRectGetMidY(layerRect))];
    [imageUIView.layer insertSublayer:[[self captureManager]previewLayer] below:dView.layer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveImageToPhotoAlbum) name:kImageCapturedSuccessfully object:nil];
    
    [[captureManager captureSession] startRunning];
    
    return YES;
}

- (void)saveImageToPhotoAlbum
{
    UIImageWriteToSavedPhotosAlbum([[self captureManager] stillImage], self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    
    UIImage *imag=[[self captureManager] stillImage];
    
    
    UIView *snapView=[[UIView alloc]initWithFrame:imageUIView.frame];
    UIImageView *imageView = [[UIImageView alloc]initWithImage:imag];
    
    
    
    NSNumber *x=[[NSUserDefaults standardUserDefaults]objectForKey:@"x"];
    NSNumber *y=[[NSUserDefaults standardUserDefaults]objectForKey:@"y"];
    NSNumber *width=[[NSUserDefaults standardUserDefaults]objectForKey:@"width"];
    NSNumber *height=[[NSUserDefaults standardUserDefaults]objectForKey:@"height"];
    
    
    
    CGRect layerRect = CGRectMake([x floatValue], [y floatValue], [width floatValue], [height floatValue]);
    
    [imageView setContentMode:UIViewContentModeScaleAspectFill];
    [imageView setFrame:layerRect];
    [snapView addSubview:imageView];
    [snapView addSubview:dView];
   // [snapView bringSubviewToFront:dView];
    
  //  [self setConstraints:imageView];
    
    [self.view addSubview:snapView];
    
    [[self captureManager]stop];

    
    [self takeSnapShot];

}

-(void)setConstraints:(UIView *)view{
    
    [view setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.width.lessThanOrEqualTo(self);
        make.height.lessThanOrEqualTo(self);
        
    }];
   
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
    
}








@end
