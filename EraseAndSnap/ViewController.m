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
#import <Photos/Photos.h>
#import "Masonry.h"

@interface ViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,AVCaptureAudioDataOutputSampleBufferDelegate,UIDocumentInteractionControllerDelegate>

@property (strong,nonatomic) IBOutlet UIView *imageUIView;
@property (nonatomic,strong) UIView *topV;
@property (nonatomic,strong) UIView *botV;
@property (nonatomic,strong) UIView *snapView;
@property  (strong,nonatomic) drawView *dView;

@property (nonatomic,strong) UIImage *avCapturedImage;
@property (nonatomic,strong) UIImage *savedImage;
@property (nonatomic,strong) CALayer *subLayerCamera;




@property (assign) BOOL firstPicTaken;
@property (assign) BOOL secondPicTaken;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *cameraFlipButton;
@property (nonatomic,strong) NSArray *paths;
@property (nonatomic,strong) NSString *documentsDirectory;
@property (nonatomic,strong) NSString *savedImagePath;

@property (nonatomic,strong) UIDocumentInteractionController *documentInteractionController;

- (IBAction)cameraFlip:(id)sender;




@end

@implementation ViewController

@synthesize imageUIView,firstPicTaken,secondPicTaken,dView,captureManager;
;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    _documentsDirectory = [_paths objectAtIndex:0];
    _savedImagePath = [_documentsDirectory stringByAppendingPathComponent:@"savedImage.png"];
  
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
    
    _cameraFlipButton.enabled=NO;
    
    [self addTagsToViews];
    
   
    
    
}

-(IBAction)clear:(id)sender{
    [self stopReading];
    
    _cameraFlipButton.enabled=NO;
}


-(IBAction)takeSecondPic:(id)sender{
    
    if (!firstPicTaken && !secondPicTaken) {
                [self startCamera];
        }
    
    if (firstPicTaken && !secondPicTaken) {
       
        dispatch_async(dispatch_get_main_queue(), ^{
            [self startReading:NO];
            secondPicTaken=YES;
            [_bbitemStart setTitle:@"Snap!!!!"];
            
            dView.drawLock=YES;
            });
    }
    
    if (secondPicTaken) {
         [self takeScreenShot];
     }
    
}

-(void)startCamera{
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:picker animated:YES completion:NULL];
}

-(void)takeScreenShot{
    
       [[self captureManager] captureStillImage];
    
    [self showAlert];
    
}

-(void)showAlert{
    
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Image Saved in Album"
                                  message:@"What you would like to do now ?"
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"Continue editing"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [self stopReading];
                             
                             dView=[[drawView alloc]initWithFrame:imageUIView.frame];
                             dView.delegate=self;
                             [dView drawImage:_savedImage];
                             dView.drawLock=NO;
                             [imageUIView addSubview:dView];
                             
                             firstPicTaken=YES;
                             _bbitemStart.enabled=NO;
                             _bbitemStart.title=@"Take Another Pic";
                             _choosePic.enabled=NO;
                             
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             
                         }];
    UIAlertAction* share = [UIAlertAction
                             actionWithTitle:@"Share"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [self shareImage];
                                 
                                 
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
    
    [alert addAction:ok];
    [alert addAction:share];
    
    [self presentViewController:alert animated:YES completion:nil];

}

-(void)shareImage{
    
    UIButton *button = (UIButton *)nil;
    NSURL *URL = [NSURL fileURLWithPath:_savedImagePath];
    
    if (URL) {
        // Initialize Document Interaction Controller
        self.documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:URL];
        
        // Configure Document Interaction Controller
        [self.documentInteractionController setDelegate:self];
        
        // Present Open In Menu
        [self.documentInteractionController presentOpenInMenuFromRect:[button frame] inView:self.view animated:YES];
    }
    
}

-(void)enableDrawLock{
    
    dView.drawLock=YES;
    
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Trail Period Expired"
                                  message:@"Purchase the app to remove the erase lock"
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"Ok"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             
                         }];
    
    [alert addAction:ok];
    
    [self presentViewController:alert animated:YES completion:nil];
   
}

-(void)takeSnapShot{
    
    UIGraphicsBeginImageContext(self.imageUIView.frame.size);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    _savedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    //UIImageWriteToSavedPhotosAlbum(_savedImage, nil, nil, nil);
    
//    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
//        PHAssetChangeRequest *changeRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:_savedImage];
//        
//    } completionHandler:^(BOOL success, NSError *error) {
//        if (success) {
//            
//            
//            
//        }
//        else {
//            
//        }
//    }];
    
    [self saveImageAtPath];
    
    
    
    
}

-(void)saveImageAtPath{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    
    [fileManager removeItemAtPath:_savedImagePath error:&error];
    
    NSData *imageData = UIImagePNGRepresentation(_savedImage);
    [imageData writeToFile:_savedImagePath atomically:NO];

    
    
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
    dView.delegate=self;
    [dView drawImage:chosenImage];
    dView.drawLock=NO;
    [imageUIView addSubview:dView];
    
    firstPicTaken=YES;
    _bbitemStart.enabled=NO;
    _bbitemStart.title=@"Take Another Pic";
    _choosePic.enabled=NO;
    
    [self addViewsBasedOnScreenSize];
    
    [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(enableDrawLock) userInfo:nil repeats:NO];
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)addViewsBasedOnScreenSize{
    
    if ([[UIScreen mainScreen]bounds].size.height==568) {
        
        [self addTwoViewsForiPhone5];
    }
    
    if ([[UIScreen mainScreen]bounds].size.height==480) {
        
        [self addTwoViewsForiPhone4];
    }
    
    if ([[UIScreen mainScreen]bounds].size.height==667) {
        
        [self addTwoViewsForiPhone6];
    }
    
    if ([[UIScreen mainScreen]bounds].size.height==736) {
        
        [self addTwoViews];
    }
    if ([[UIScreen mainScreen]bounds].size.height==1024) {
        
        [self addTwoViewsForiPadRetina];
    }
    if ([[UIScreen mainScreen]bounds].size.height==1366) {
        
        [self addTwoViewsForiPadPro];
    }
}


#pragma mark - Private method implementation

- (BOOL)startReading :(BOOL) value{
    
    [self setCaptureManager:[[CaptureSessionManager alloc] init]];
    
    [[self captureManager] addVideoInputFrontCamera:value]; // set to YES for Front Camera, No for Back camera
    
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

-(void)addTwoViewsForiPadRetina{
    
    _topV=[[UIView alloc]initWithFrame:CGRectMake(0, 0, imageUIView.frame.size.width, 240)];
    _topV.backgroundColor=[UIColor blackColor];
    [self.view addSubview:_topV];
    
    _botV=[[UIView alloc]initWithFrame:CGRectMake(0, 740, imageUIView.frame.size.width, 240)];
    _botV.backgroundColor=[UIColor blackColor];
    [self.view addSubview:_botV];
    
    
}

-(void)addTwoViewsForiPadPro{
    
    _topV=[[UIView alloc]initWithFrame:CGRectMake(0, 0, imageUIView.frame.size.width, 330)];
    _topV.backgroundColor=[UIColor blackColor];
    [self.view addSubview:_topV];
    
    _botV=[[UIView alloc]initWithFrame:CGRectMake(0, 962, imageUIView.frame.size.width, 360)];
    _botV.backgroundColor=[UIColor blackColor];
    [self.view addSubview:_botV];
}

-(void)addTwoViewsForiPhone4{
    
    _topV=[[UIView alloc]initWithFrame:CGRectMake(0, 0, imageUIView.frame.size.width, 140)];
    _topV.backgroundColor=[UIColor blackColor];
    [self.view addSubview:_topV];
    
    _botV=[[UIView alloc]initWithFrame:CGRectMake(0, 320, imageUIView.frame.size.width, 150)];
    _botV.backgroundColor=[UIColor blackColor];
    [self.view addSubview:_botV];
}

-(void)addTwoViewsForiPhone5{
    
    _topV=[[UIView alloc]initWithFrame:CGRectMake(0, 0, imageUIView.frame.size.width, 160)];
    _topV.backgroundColor=[UIColor blackColor];
    [self.view addSubview:_topV];
    
    _botV=[[UIView alloc]initWithFrame:CGRectMake(0, 360, imageUIView.frame.size.width, 170)];
    _botV.backgroundColor=[UIColor blackColor];
    [self.view addSubview:_botV];
}

-(void)addTwoViewsForiPhone6{
    
    _topV=[[UIView alloc]initWithFrame:CGRectMake(0, 0, imageUIView.frame.size.width, 190)];
    _topV.backgroundColor=[UIColor blackColor];
    [self.view addSubview:_topV];
    
    _botV=[[UIView alloc]initWithFrame:CGRectMake(0, 430, imageUIView.frame.size.width, 200)];
    _botV.backgroundColor=[UIColor blackColor];
    [self.view addSubview:_botV];
}



- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error != NULL) {
            //show alert
    }
    
}

-(void)stopReading{
    
    firstPicTaken=NO;
    secondPicTaken=NO;
    _bbitemStart.title=@"Take Pic";
    _choosePic.enabled=YES;
    
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

- (IBAction)cameraFlip:(id)sender {
         
         [_subLayerCamera removeFromSuperlayer];
         
         [[NSNotificationCenter defaultCenter] removeObserver:self name:kImageCapturedSuccessfully object:nil];
         
         [[self captureManager]stop];
         
         [self startReading:YES];
}

#pragma drawView delegate methods

-(void)setDrawStarted:(BOOL)value{
    
    if (value) {
        _bbitemStart.enabled=YES;
        _cameraFlipButton.enabled=YES;
    }
    
}



-(BOOL)drawStarted{
    
    return YES;
}

@end
