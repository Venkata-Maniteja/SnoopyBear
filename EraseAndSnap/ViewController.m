//
//  ViewController.m
//  EraseAndSnap
//
//  Created by Venkata Maniteja on 2015-10-19.
//  Copyright © 2015 Venkata Maniteja. All rights reserved.
//
//TODO: imgae shfts down , after tap on continue editing
//      fill the image after second snap

//TODO: tap on undo , hide the camera flip button

//TODO: add bar code/qr code scanning to the app(not necessary at this point)
//TODO: add drawing on the image
#import "ViewController.h"
#import "drawView.h"
#import "SnappingView.h"
#import <ImageIO/CGImageProperties.h>
#import <Photos/Photos.h>
#import "Masonry.h"
#import "EraserCollectionViewCell.h"
#import "CropView.h"
#import "circleView.h"
#import "BlurView.h"
#import "MyManager.h"
#import "TOCropViewController.h"
#import "AceDrawingView.h"

static const CGFloat kSlideMenuHeight                       = 95;
static const CGFloat kSlideMenuOvershoot                    = 20;
static const CGFloat kSlideCollectionViewHolderHeight       = 200+kSlideMenuHeight;
static const CGFloat kSlideCollectionViewOvershoot          = 40;

static NSString  * kSmallCircleErase        =@"eraser_small";
static NSString  * kMediumCircleErase       =@"eraser_medium";
static NSString  * kLargeCircleErase        =@"eraser_large";
static NSString  * kSmallHeartErase         =@"heart_small";
static NSString  * kMediumHeartErase        =@"heart_medium";
static NSString  * kLargeHeartErase         =@"heart_large";
static NSString  * kSmallMapleErase         =@"maple_small";
static NSString  * kMediumMapleErase        =@"maple_medium";
static NSString  * kLargeMapleErase         =@"maple_large";
static NSString  * kSmallAppleErase         =@"apple_small";
static NSString  * kMediumAppleErase        =@"apple_medium";
static NSString  * kLargeAppleErase         =@"apple_large";
static NSString  * kSmallSkeletonErase      =@"skeleton_small";
static NSString  * kMediumSkeletonErase     =@"skeleton_medium";
static NSString  * kLargeSkeletonErase      =@"skeleton_large";
static NSString  * kCircleShape             =@"circleShape";
static NSString  * kHeartShape              =@"heartShape";
static NSString  * kAppleShape              =@"appleShape";
static NSString  * kMapleShape              =@"mapleShape";
static NSString  * kSkeletonShape           =@"skeletonShape";


@interface ViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,AVCaptureAudioDataOutputSampleBufferDelegate,UIDocumentInteractionControllerDelegate,UIGestureRecognizerDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,TOCropViewControllerDelegate>{
    
    IBOutlet UICollectionView * eraserCollectionView;
    BOOL    menuOpen;
    BOOL    menuClose;
    BOOL    isEraserSelected;
    int     eraserSelected;
    BOOL    eraserSubMenuOpened;
    BOOL    smallImage;
    BOOL    mediumImage;
    BOOL    largeImage;
    BOOL    cropMode;
    BOOL    blurMode;
    BOOL    photoSelected;
    
}

@property (strong,nonatomic)    IBOutlet UIView                 *   imageUIView;
@property (nonatomic,weak)      IBOutlet UIView                 *   slideMenu;
@property (nonatomic,weak)      IBOutlet UISegmentedControl     *   eraserSegmentControl;
@property (nonatomic,weak)      IBOutlet NSLayoutConstraint     *   topConstraintForSlideMenu;
@property (nonatomic,weak)      IBOutlet NSLayoutConstraint     *   topConstraintForCollectionViewHolder;
@property (nonatomic,weak)      IBOutlet UIView                 *   collectionViewHolder;
@property (nonatomic,weak)      IBOutlet UIView                 *   blurSettingsView;
@property (nonatomic,weak)      IBOutlet UISlider               *   blurViewAlphaSlider;
@property (nonatomic,weak)      IBOutlet UISlider               *   seeThroughViewAlphaSlider;

@property (nonatomic,strong)             SnappingView           *   snapView;
@property (strong,nonatomic)             drawView               *   dView;
@property (nonatomic,strong)             circleView             *   circleBlurMaskView;
@property (strong,nonatomic)             BlurView               *   blurView;
@property (strong,nonatomic)             MyManager              *   myManager;
@property (strong,nonatomic)             ACEDrawingView         *   aceDrawView;
@property (strong,nonatomic)    IBOutlet CropView               *   cropView;

@property (nonatomic,strong)             UIImage                *   avCapturedImage;
@property (nonatomic,strong)             UIImage                *   savedImage;
@property (nonatomic,strong)             UIImage                *   savedCropImage;
@property (nonatomic,assign)             CGSize                     oldImageSize;

@property (nonatomic,strong)             CALayer                *   subLayerCamera;

@property (nonatomic,weak)      IBOutlet UIToolbar              *   toolBar;

@property (nonatomic,strong)             NSMutableArray         *   smallImageArray;
@property (nonatomic,strong)             NSMutableArray         *   mediumImageArray;
@property (nonatomic,strong)             NSMutableArray         *   largeImageArray;
@property (nonatomic,strong)             NSMutableArray         *   imageShapeArray;
@property (nonatomic,strong)             CAShapeLayer           *   shapeLayer;
@property (nonatomic,strong)             UIBezierPath           *   cropBezierPath;


@property (assign) BOOL firstPicTaken;
@property (assign) BOOL secondPicTaken;

@property (weak, nonatomic)  IBOutlet UIBarButtonItem *cameraFlipButton;
@property (weak, nonatomic)  IBOutlet UIBarButtonItem *undoButton;
@property (weak, nonatomic)  IBOutlet UIBarButtonItem *bbitemStart;
@property (nonatomic,strong) IBOutlet UIBarButtonItem *choosePic;
@property (nonatomic,strong) IBOutlet UIBarButtonItem *clear;

@property (nonatomic,strong) NSArray *paths;
@property (nonatomic,strong) NSString *documentsDirectory;
@property (nonatomic,strong) NSString *savedImagePath;
@property (nonatomic,strong) NSString *savedCropImagePath;

@property (nonatomic,strong) UIDocumentInteractionController *documentInteractionController;

- (IBAction)cameraFlip:(id)sender;




@end

@implementation ViewController

@synthesize imageUIView,firstPicTaken,secondPicTaken,dView,captureManager,drawStarted,lineInteresctedInCropView;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initialSetup];

}


-(void)testAvFoundation{
    
    _snapView=[[SnappingView alloc]initWithFrame:imageUIView.frame]; //imageUIView frame
    [_snapView drawImage:[UIImage imageNamed:@"savedImage_large.png"]];
    [_snapView addSubview:dView];
    [self.view addSubview:_snapView];
    
}

-(void)initialSetup{
    
    _paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    _documentsDirectory = [_paths objectAtIndex:0];
    _savedImagePath = [_documentsDirectory stringByAppendingPathComponent:@"savedImage.png"];
    _savedCropImagePath=[_documentsDirectory stringByAppendingPathComponent:@"savedCropImage.png"];
    firstPicTaken=NO;
    secondPicTaken=NO;
    
    self.view.backgroundColor=[UIColor whiteColor];
    // Do any additional setup after loading the view, typically from a nib.
    
    _myManager=[MyManager sharedInstance];
    
    _slideMenu.alpha=0.0f;
    _collectionViewHolder.alpha=0.0f;
    
    smallImage=YES;
    
    _undoButton.tintColor=[UIColor clearColor];
    _cameraFlipButton.tintColor=[UIColor clearColor];
    _clear.tintColor=[UIColor clearColor];
    _undoButton.enabled=NO;
    _cameraFlipButton.enabled=NO;
    _clear.enabled=NO;
    
    _cropView.hidden=YES;
    _blurSettingsView.hidden=YES;
    
    _smallImageArray=[[NSMutableArray alloc]init];
    _mediumImageArray=[[NSMutableArray alloc]init];
    _largeImageArray=[[NSMutableArray alloc]init];
    _imageShapeArray=[[NSMutableArray alloc]init];
    
    [self loadImagesIntoArray];
    
    [self addCollectionViewFlowLayout];
    
}

-(void)addCollectionViewFlowLayout{
 
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(180, eraserCollectionView.frame.size.height-40)];
    [flowLayout setSectionInset:UIEdgeInsetsMake(10, 10, 10, 10)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    
    [self->eraserCollectionView setCollectionViewLayout:flowLayout];
}

-(void)loadImagesIntoArray{
    
    [_smallImageArray addObject:[UIImage imageNamed:kSmallCircleErase]];
    [_smallImageArray addObject:[UIImage imageNamed:kSmallHeartErase]];
    [_smallImageArray addObject:[UIImage imageNamed:kSmallAppleErase]];
    [_smallImageArray addObject:[UIImage imageNamed:kSmallMapleErase]];
    [_smallImageArray addObject:[UIImage imageNamed:kSmallSkeletonErase]];
    
    [_mediumImageArray addObject:[UIImage imageNamed:kMediumCircleErase]];
    [_mediumImageArray addObject:[UIImage imageNamed:kMediumHeartErase]];
    [_mediumImageArray addObject:[UIImage imageNamed:kMediumAppleErase]];
    [_mediumImageArray addObject:[UIImage imageNamed:kMediumMapleErase]];
    [_mediumImageArray addObject:[UIImage imageNamed:kMediumSkeletonErase]];
    
    [_largeImageArray addObject:[UIImage imageNamed:kLargeCircleErase]];
    [_largeImageArray addObject:[UIImage imageNamed:kLargeHeartErase]];
    [_largeImageArray addObject:[UIImage imageNamed:kLargeAppleErase]];
    [_largeImageArray addObject:[UIImage imageNamed:kLargeMapleErase]];
    [_largeImageArray addObject:[UIImage imageNamed:kLargeSkeletonErase]];
    
    [_imageShapeArray addObject:[UIImage imageNamed:kCircleShape]];
    [_imageShapeArray addObject:[UIImage imageNamed:kHeartShape]];
    [_imageShapeArray addObject:[UIImage imageNamed:kAppleShape]];
    [_imageShapeArray addObject:[UIImage imageNamed:kMapleShape]];
    [_imageShapeArray addObject:[UIImage imageNamed:kSkeletonShape]];

    
}

-(void)addTagsToViews{
    _snapView.tag=2;
    imageUIView.tag=3;
    dView.tag=4;
    
}

-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
    _cameraFlipButton.enabled=NO;
    
    //need to take care of my singleton model
    
    [self addTagsToViews];
    
    
}


-(IBAction)clear:(id)sender{
    [self stopReading];
    
    _cameraFlipButton.tintColor=[UIColor clearColor];
    _undoButton.tintColor=[UIColor clearColor];
    _undoButton.enabled=NO;
    _cameraFlipButton.enabled=NO;
    photoSelected=NO;
    
    if (cropMode) {
        
        cropMode=NO;
        _cropView.hidden=YES;
       
    }
}


-(IBAction)takeSecondPic:(id)sender{
    
    cropMode=NO;
    _cameraFlipButton.enabled=YES; //enable flip camera only when back camera is started
    
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
//        [self takeSnapShot];
     }
    
}



-(void)startCamera{
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
//    [self presentViewController:picker animated:YES completion:NULL];
    [self.navigationController pushViewController:picker animated:YES];
}

-(void)takeScreenShot{
    
    [[self captureManager] captureStillImage];
    
}

-(void)showAlert{
    
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Image Saved in Album"
                                  message:@"What would you like to do?"
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"Continue editing"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [self stopReading];
                             
                             dView=[[drawView alloc]initWithFrame:CGRectMake(0, 0, imageUIView.frame.size.width, imageUIView.frame.size.height)];
                             dView.delegate=self;
                             [dView drawImage:_savedImage];
                             dView.drawLock=NO;
                             [dView setErase:[self getImageBasedOnSelection]];
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
                                 
                                 
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     [self shareImageWithPath:_savedImagePath];
                                 });
                                 
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
    [alert addAction:ok];
    [alert addAction:share];
    
    [self presentViewController:alert animated:YES completion:nil];

}

-(void)shareImageWithPath:(NSString *)path{
    
    NSURL *URL = [NSURL fileURLWithPath:path];
    
    if (URL) {
        // Initialize Document Interaction Controller
        self.documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:URL];
        
        // Configure Document Interaction Controller
        [self.documentInteractionController setDelegate:self];
        
        // Present Open In Menu
        [self.documentInteractionController presentOptionsMenuFromBarButtonItem:_choosePic animated:YES];
    }
    
}



- (void)documentInteractionControllerDidDismissOptionsMenu:(UIDocumentInteractionController *) controller
{
    
    NSLog(@"cancelled/dismissed");
    
    [self stopReading];
    
    _cameraFlipButton.enabled=NO;
    _undoButton.enabled=NO;
    _undoButton.tintColor=[UIColor clearColor];
    _cameraFlipButton.tintColor=[UIColor clearColor];
    
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Share View Dismissed"
                                  message:@"The view is cleared as the share view is dismissed. The image is still saved in the camera roll for future reference"
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"ok"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             
                         }];
    
    [alert addAction:ok];
    
    [self presentViewController:alert animated:YES completion:nil];
    
    
}

-(void)enableDrawLock{
    
    dView.drawLock=YES;
   
}

-(void)disableDrawLock{
    
     dView.drawLock=NO;
}

-(void)takeSnapShot{
    
    
    UIGraphicsBeginImageContext(self.imageUIView.bounds.size); //imageUIView
    [self.snapView.layer renderInContext:UIGraphicsGetCurrentContext()]; //changed layer
    _savedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //try to resize the image and save the aspect fit image
    
    UIImageWriteToSavedPhotosAlbum(_savedImage, nil, nil, nil);
    [self saveImageAtPath:_savedImagePath withImage:_savedImage];
    
}

-(void)saveImageAtPath:(NSString *)path withImage:(UIImage *)image{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    [fileManager removeItemAtPath:path error:&error];
    NSData *imageData = UIImagePNGRepresentation(image);
    [imageData writeToFile:path atomically:NO];
    if(!cropMode){
    [self showAlert];
    }
}

- (IBAction)selectPhoto:(UIButton *)sender {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:NULL];
    
}

#pragma marks picker delegate  methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    
    [self loadDrawViewWithSelectedImage:chosenImage];
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

-(void)loadDrawViewWithSelectedImage:(UIImage *)choosenImage{
    
    [_myManager showOverlay];
    
    dView=[[drawView alloc]initWithFrame:CGRectMake(0, 0, imageUIView.frame.size.width, imageUIView.frame.size.height)]; //0,0 to 0,64
    dView.delegate=self;
    [dView drawImage:choosenImage];
    dView.drawLock=NO;
    [dView setErase:[self getImageBasedOnSelection]];
    [imageUIView addSubview:dView];
    [self animateImageUIView];
    
    
    firstPicTaken=YES;
    _bbitemStart.enabled=NO;
    _bbitemStart.title=@"Take Another Pic";
    _choosePic.enabled=NO;
    
    photoSelected=YES;
    
    
    
}

#pragma Crop controller delegate methods
- (void)cropViewController:(TOCropViewController *)cropViewController didCropToImage:(UIImage *)image withRect:(CGRect)cropRect angle:(NSInteger)angle
{
    // 'image' is the newly cropped version of the original image
     [self loadDrawViewWithSelectedImage:image];
    
    [cropViewController dismissViewControllerAnimated:YES completion:nil];
}


- (void)presentCropViewControllerWithImage:(UIImage*)img
{
    UIImage *image = img; //Load an image
 
    //TODO: img should not be nil
    if (img) {

        TOCropViewController *cropViewController = [[TOCropViewController alloc] initWithImage:image];
        cropViewController.delegate = self;
        [self presentViewController:cropViewController animated:YES completion:nil];
    
    }else{
        
        //show alert to select an image
        UIAlertController *acon=[UIAlertController alertControllerWithTitle:@"No Image selected" message:@"Please select an image from gallery/cameraw" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancel=[UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action){
            [acon dismissViewControllerAnimated:YES completion:nil];
        }];
        UIAlertAction *chosePic=[UIAlertAction actionWithTitle:@"Choose pic" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
            [self selectPhoto:nil];
            [acon dismissViewControllerAnimated:YES completion:nil];
        }];
        UIAlertAction *takePic=[UIAlertAction actionWithTitle:@"Take pic" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
            [self startCamera];
            [acon dismissViewControllerAnimated:YES completion:nil];
        }];
        
        [acon addAction:cancel];
        [acon addAction:chosePic];
        [acon addAction:takePic];
        
        [self presentViewController:acon animated:YES completion:nil];
    }
}


-(void)animateImageUIView{
    
        imageUIView.alpha=1.0f;
    [UIView animateWithDuration:2.0f animations:^{
        imageUIView.alpha=0.0f;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:2.0f animations:^{
            
            [imageUIView setAlpha:1.0f];
            
        } completion:nil];
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
//    [[[self captureManager] previewLayer] setBounds:layerRect];
    
    [[[self captureManager] previewLayer] setBounds:dView.bounds];
    
    [[[self captureManager] previewLayer] setPosition:CGPointMake(CGRectGetMidX(layerRect),CGRectGetMidY(layerRect))];
  
    _subLayerCamera=[[self captureManager]previewLayer];
    
    
    if (cropMode) { //!cropmode for testing, else replace it with !cropmode
        
        CAShapeLayer *newLayer=[[CAShapeLayer alloc]init];
        newLayer.path=_cropBezierPath.CGPath;
        _subLayerCamera.mask=newLayer;
    }
   
    
    
 //i will also try masking the imageuiview
    [imageUIView.layer insertSublayer:_subLayerCamera below:dView.layer]; //imageUIView.layer
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveImageToPhotoAlbum) name:kImageCapturedSuccessfully object:nil];
    
    [[captureManager captureSession] startRunning];
    
    return YES;
}

- (void)saveImageToPhotoAlbum
{
    _avCapturedImage=[[self captureManager] stillImage];
    
    _avCapturedImage=[self imageWithImage:_avCapturedImage scaledToSize:CGSizeMake(imageUIView.frame.size.width, imageUIView.frame.size.height)];
    
    [self addViewsForSnapShot];
    [[self captureManager]stop];
    [self takeSnapShot];

}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

-(void)addViewsForSnapShot{
    
    _snapView=[[SnappingView alloc]initWithFrame:imageUIView.frame]; //imageUIView frame
    [_snapView drawImage:_avCapturedImage];
    [_snapView addSubview:dView]; //y do i comment this
    
    
    //try to mask the snappingview
    _snapView.layer.mask=_shapeLayer; //is this only when in crop mode ?
    
    [self.view addSubview:_snapView];
  
}



- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error != NULL) {
            //show alert
    }
    
}

-(void)stopReading{
    
    cropMode=NO;
    firstPicTaken=NO;
    secondPicTaken=NO;
    _bbitemStart.title=@"Take Pic";
    _choosePic.enabled=YES;
    _bbitemStart.enabled=YES;
    
    [dView removeFromSuperview];
    [_snapView removeFromSuperview];
    [_subLayerCamera removeFromSuperlayer];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kImageCapturedSuccessfully object:nil];
   
    dView=nil;
    _snapView=nil;
    
}

- (IBAction)cameraFlip:(id)sender {
    
        cropMode=NO;
         [_subLayerCamera removeFromSuperlayer];
         
         [[NSNotificationCenter defaultCenter] removeObserver:self name:kImageCapturedSuccessfully object:nil];
         
         [[self captureManager]stop];
         
         [self startReading:YES];
}

-(IBAction)undo:(id)sender{
    
    _undoButton.enabled=YES;
    _undoButton.tintColor=[UIColor whiteColor];
    
    
    [dView undoTheErasing];
    
    if (cropMode) {
        [_cropView erase];
         dView.layer.mask=nil;
    }
}

#pragma drawView delegate methods

-(void)setDrawStarted:(BOOL)value{
    
    if (value) {
        if (!cropMode) {
            _bbitemStart.enabled=YES;
            _cameraFlipButton.enabled=NO;
            _cameraFlipButton.tintColor=[UIColor clearColor];
        }
        _undoButton.enabled=YES;
        _undoButton.tintColor=[UIColor whiteColor];
    }
    
}

-(void)setLineInteresctedInCropView:(BOOL)value
{
    if (value) {
        
        NSLog(@"path interesected");
        
       
    }
}

-(void)sendBezierPath:(UIBezierPath *)path{
    
    _cropBezierPath=path;
    _shapeLayer=[[CAShapeLayer alloc]init];
    _shapeLayer.frame=imageUIView.bounds;
    _shapeLayer.path=path.CGPath;
 //   imageUIView.layer.mask=_shapeLayer; //this thing is to crop the bezier path image and remove rest
    
//    [dView.layer addSublayer:_shapeLayer];  //this is to remove the bezier path and keep the rest
    
    dView.layer.mask=_shapeLayer;
    
    NSLog(@"layer count after take pic is %lu",dView.layer.sublayers.count);
    
    
    _cropView.hidden=YES;
    [self saveCroppedPhoto];
    [self showAlertForCrop];
}

-(void)showAlertForCrop{
    
    UIAlertController *aCon=[UIAlertController alertControllerWithTitle:@"Image Cropped!" message:@"Do you want to share the image?" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *saveAction=[UIAlertAction actionWithTitle:@"Save" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
       
      //TODO save crop image here
        
        [aCon dismissViewControllerAnimated:YES completion:nil];
    }];
    
    UIAlertAction *shareAction=[UIAlertAction actionWithTitle:@"Share" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        //save the crop image in the sandbox/photoalbum
        [self shareCroppedPhoto];
        [aCon dismissViewControllerAnimated:YES completion:nil];
    }];
    
    UIAlertAction *clearAct=[UIAlertAction actionWithTitle:@"Clear Everything" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
       //do nothing
        //save the crop image in album and dismiss the view and everything
        [aCon dismissViewControllerAnimated:YES completion:nil];
    }];
    
    UIAlertAction *noAct=[UIAlertAction actionWithTitle:@"Do nothing" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        //do nothing
        //save the crop image in album and dismiss the view and everything
        [aCon dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [aCon addAction:saveAction];
    [aCon addAction:shareAction];
    [aCon addAction:clearAct];
    [aCon addAction:noAct];
    
    [self presentViewController:aCon animated:YES completion:nil];
}

-(void)shareCroppedPhoto{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self shareImageWithPath:_savedCropImagePath];
    });
    
}

-(void)saveCroppedPhoto{
    
    UIGraphicsBeginImageContextWithOptions(dView.bounds.size, NO, 0.0);
    [dView.layer renderInContext:UIGraphicsGetCurrentContext()];
    
   _savedCropImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    //TODO: save image to photo gallery or save to app sandbox ?
    [self saveImageAtPath:_savedCropImagePath withImage:_savedCropImage];
    
    
}

-(UIImage *)getImageFromDrawView{
    
    UIGraphicsBeginImageContextWithOptions(dView.bounds.size, NO, 0.0);
    [dView.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
    
}

#pragma eraser collectionview delegate methods
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return _smallImageArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"EraserCollectionViewCell";
    
    EraserCollectionViewCell *cell = (EraserCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor whiteColor];
    cell.layer.borderColor=[[UIColor clearColor]CGColor];
    cell.layer.borderWidth=0.0;
    cell.imgView.contentMode=UIViewContentModeScaleAspectFit;
    cell.imgView.backgroundColor=[UIColor purpleColor];
    cell.imgView.image=[_imageShapeArray objectAtIndex:indexPath.row];
    
       return cell;
    
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    EraserCollectionViewCell *cell = (EraserCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    cell.layer.borderColor=[[UIColor colorWithRed:13/255.0 green:79/255.0 blue:139/255.0 alpha:1]CGColor];
    cell.layer.borderWidth=3.0;
    eraserSelected=(int)indexPath.row;
    isEraserSelected=YES;
    [dView setErase:[self getImageBasedOnSelection]];
    
    [self closeMenu];
    [self hideCollectionView];
    
    
}

-(UIImage *)getImageBasedOnSelection{
    
    if (smallImage) {
        return [_smallImageArray objectAtIndex:eraserSelected];
    }
    if (mediumImage) {
        return [_mediumImageArray objectAtIndex:eraserSelected];
    }
    if (largeImage) {
        return [_largeImageArray objectAtIndex:eraserSelected];
    }
    
    return [UIImage imageNamed:@"noImage"];
    
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    EraserCollectionViewCell *cell = (EraserCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.layer.borderColor=[[UIColor clearColor]CGColor];
    cell.layer.borderWidth=0.0;
    cell.backgroundColor = [UIColor whiteColor];
    
    isEraserSelected=NO;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    return CGSizeMake(120.0f, 120.0f);
}

#pragma menu bar action methods

-(IBAction)clickOnErase:(id)sender{
    
    eraserSubMenuOpened=YES;
    _collectionViewHolder.alpha=1.0f;
    
    //load saved value on segment control
    [_eraserSegmentControl setSelectedSegmentIndex:0];
    
    //TODO: load the current selected value in singleton source/user defualts
    
    [imageUIView bringSubviewToFront:_collectionViewHolder];
    
    _topConstraintForCollectionViewHolder.constant = -kSlideCollectionViewHolderHeight - kSlideCollectionViewOvershoot;
    [self.view layoutIfNeeded];
    
    [UIView animateWithDuration:0.5 delay:0  options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        _topConstraintForCollectionViewHolder.constant = kSlideMenuHeight;
        [self.view layoutIfNeeded];
        
    } completion:^(BOOL finished) {}];
    
    [UIView animateWithDuration:0.5 delay:0.5  options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        _topConstraintForCollectionViewHolder.constant = kSlideCollectionViewOvershoot-40;
        [self.view layoutIfNeeded];
        
    } completion:^(BOOL finished) {}];
    
}

-(IBAction)crop:(id)sender{
    
    [self closeMenu];
    
    //show an alert with two options 1. freestyle crop, basic crop
    UIAlertController *aCon=[UIAlertController alertControllerWithTitle:@"Choose Crop mode" message:@"Which type of crop mode you want to use?" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *freeStyleCrop=[UIAlertAction actionWithTitle:@"Freestyle crop" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        //TODO: show overlay on how to crop the image, overlay with please draw a closed path to crop the image
        
        cropMode=YES;
        _cropView.hidden=NO;
        _cropView.delegate=self;
        _cropView.alpha=0.4;
        _cropView.backgroundColor=[UIColor blackColor];
        _cropView.lineColor=[UIColor whiteColor];
        _cropView.lineWidth=5.0;
        _cropView.path=[UIBezierPath bezierPath];
        
        [_cropView setNeedsDisplay];
        
        [aCon dismissViewControllerAnimated:YES completion:nil];
    }];
    
    UIAlertAction *basicCrop=[UIAlertAction actionWithTitle:@"Basic Crop" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self presentCropViewControllerWithImage:[self getImageFromDrawView]];
        [aCon dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [aCon addAction:freeStyleCrop];
    [aCon addAction:basicCrop];
    
    [self presentViewController:aCon animated:YES completion:nil];
    
    
    
}

-(IBAction)blur:(id)sender{
    
    blurMode=YES;
    
    [self closeMenu];
    
    // is picture selected.....YES/NO
    if (photoSelected) {
        
        _blurView=[[BlurView alloc]initWithFrame:imageUIView.bounds];
        _blurView.backgroundColor=[UIColor clearColor];
        _blurView.alpha=0.8;
        _blurView.opaque=NO;
        _blurView.maskAlpha=0.7;
       
        [imageUIView addSubview: _blurView];
        
        _circleBlurMaskView=[[circleView alloc]initWithFrame:CGRectMake(20, 20, 60, 60)];
        _circleBlurMaskView.backgroundColor=[UIColor clearColor];
        [_blurView addSubview:_circleBlurMaskView];
        
        [self applyMask];
        
    }else{
        
        //show alert to tell user to take or select a picture
    }
    
    
}

-(IBAction)draw:(id)sender{
      [self closeMenu];
      [self showAceDrawingViewWithCroppedImage:_savedImage];
}

-(void)applyMask{
    
  
    [_circleBlurMaskView setNeedsDisplay];
    [_blurView setSeeRect:_circleBlurMaskView.frame];    //set the transparency cut on transparency view
    [_blurView setNeedsDisplay];
    
}

-(void)moveCircleViewwithX:(float) x withY:(float) y{
    
    _circleBlurMaskView.frame=CGRectMake(x, y, _circleBlurMaskView.frame.size.width, _circleBlurMaskView.frame.size.height);
    [self applyMask];
}
-(void)hideCollectionView{
    
    eraserSubMenuOpened=NO;
    _collectionViewHolder.alpha=1.0f;
    
    [UIView animateWithDuration:0.5 delay:0  options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        _topConstraintForCollectionViewHolder.constant = 0;
        [self.view layoutIfNeeded];
        
    } completion:^(BOOL finished) {}];
    
    [UIView animateWithDuration:0.5 delay:0.5  options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        _topConstraintForCollectionViewHolder.constant = -kSlideMenuHeight-kSlideCollectionViewHolderHeight;
        [self.view layoutIfNeeded];
        
    } completion:^(BOOL finished) {
        
        _collectionViewHolder.alpha=1.0f;
        
        //also hide the menu if needed
    }];
    


    
    
}

-(IBAction)menuOpen:(id)sender{
    
    if (!menuOpen) {
        
        [self openMenu];
        
    }else{
            [self closeMenu];
        if (eraserSubMenuOpened) {
            [self hideCollectionView];
        }
    }
    
}

-(void)openMenu{
    
    NSLog(@"swiped down");
    
    menuOpen=YES;
    eraserSubMenuOpened=NO;
    _slideMenu.hidden=NO;
    
    [self enableDrawLock];
    
    [imageUIView bringSubviewToFront:_slideMenu];
    _slideMenu.alpha=1.0f;
    
    _topConstraintForSlideMenu.constant = -kSlideMenuHeight - kSlideMenuOvershoot;
    [self.view layoutIfNeeded];
    
    [UIView animateWithDuration:0.5 delay:0  options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        _topConstraintForSlideMenu.constant = 0;
        [self.view layoutIfNeeded];
        
    } completion:^(BOOL finished) {}];
    
    [UIView animateWithDuration:0.5 delay:0.5  options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        _topConstraintForSlideMenu.constant = -kSlideMenuOvershoot;
        [self.view layoutIfNeeded];
        
    } completion:^(BOOL finished) {}];

    
}

-(void)closeMenu{
    
    
    NSLog(@"swiped up");
    
    menuOpen=NO;
    
    [self disableDrawLock];
    
    [self.view layoutIfNeeded];
    
    [UIView animateWithDuration:0.5 delay:0  options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        _topConstraintForSlideMenu.constant = 0;
        [self.view layoutIfNeeded];
        
    } completion:^(BOOL finished) {}];
    
    [UIView animateWithDuration:0.5 delay:0.5  options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        _topConstraintForSlideMenu.constant = -kSlideMenuHeight;
        [self.view layoutIfNeeded];
        
    } completion:^(BOOL finished) {
        
        _slideMenu.alpha=1.0f;
        _slideMenu.hidden=YES;
    }];
    
    
    
}

-(IBAction)eraseSegmentControl:(UISegmentedControl *)sender{
    
    if (sender.selectedSegmentIndex==0) {
        
        NSLog(@"small eraser selected");
        smallImage=YES;mediumImage=NO;largeImage=NO;
        
    }
    if (sender.selectedSegmentIndex==1) {
        
        NSLog(@"medium eraser selected");
        smallImage=NO;mediumImage=YES;largeImage=NO;
        
    }
    if (sender.selectedSegmentIndex==2) {
        
        NSLog(@"large eraser selected");
        smallImage=NO;mediumImage=NO;largeImage=YES;
    }
    
}

#pragma touches delegate mehtods
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    UITouch *touch = [[event allTouches] anyObject];
   
    if ([touch tapCount] == 2 ) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
           //create a popup
            [self showBluerSettingspopUp];
        });
       
    
    }
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:_blurView];

    
    if (blurMode) {
        
        [self moveCircleViewwithX:touchLocation.x+30 withY:touchLocation.y-30];
        
    }
}

-(void)showBluerSettingspopUp{
    
    _blurSettingsView.hidden=NO;
    [imageUIView bringSubviewToFront:_blurSettingsView];
    
    _blurSettingsView.transform = CGAffineTransformMakeScale(0.01, 0.01);
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        // animate it to the identity transform (100% scale)
        _blurSettingsView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished){
        // if you want to do something once the animation finishes, put it here
    }];
    
    
   
}

-(IBAction)dismissBlurSettings:(id)sender{
    
   
    _blurSettingsView.transform = CGAffineTransformMakeScale(0.01, 0.01);
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        // animate it to the identity transform (100% scale)
        _blurSettingsView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished){
        // if you want to do something once the animation finishes, put it here
        
         _blurSettingsView.hidden=YES;
        
    }];
}

-(IBAction)blurViewAlphaValue:(id)sender{
    
    UISlider *slider=(UISlider *)sender;
    _blurView.alpha=slider.value;
    
}

-(IBAction)seeThroughViewAlphaValue:(id)sender{
    
    UISlider *slider=(UISlider *)sender;
    
    _blurView.maskAlpha=slider.value;
    [_blurView setNeedsDisplay];
    
    
}

#pragma marks Ace drawing view

-(void)showAceDrawingViewWithCroppedImage:(UIImage*)img{
    
    _aceDrawView=[[[NSBundle mainBundle] loadNibNamed:@"AceDrawingView" owner:self options:nil] objectAtIndex:0];
    _aceDrawView.frame=dView.bounds;
    [imageUIView addSubview:_aceDrawView];
    
    //TODO: add ace draw view as subview to dview and redraw the contents of dview into ace draw view
}



@end
