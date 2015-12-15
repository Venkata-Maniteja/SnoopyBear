//
//  ViewController.m
//  EraseAndSnap
//
//  Created by Venkata Maniteja on 2015-10-19.
//  Copyright © 2015 Venkata Maniteja. All rights reserved.
//

#import "ViewController.h"
#import "drawView.h"
#import "SnappingView.h"
#import <ImageIO/CGImageProperties.h>
#import <Photos/Photos.h>
#import "Masonry.h"
#import "EraserCollectionViewCell.h"

static const CGFloat kSlideMenuHeight = 95;
static const CGFloat kSlideMenuOvershoot = 20;
static const CGFloat kSlideCollectionViewHolderHeight = 200+kSlideMenuHeight;
static const CGFloat kSlideCollectionViewOvershoot = 40;


@interface ViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,AVCaptureAudioDataOutputSampleBufferDelegate,UIDocumentInteractionControllerDelegate,UIGestureRecognizerDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>{
    
    IBOutlet UICollectionView * eraserCollectionView;
    BOOL    menuOpen;
    BOOL    menuClose;
    BOOL    isEraserSelected;
    int     eraserSelected;
    
}

@property (strong,nonatomic)    IBOutlet UIView                 *   imageUIView;
@property (nonatomic,weak)      IBOutlet UIView                 *   slideMenu;
@property (nonatomic,weak)      IBOutlet NSLayoutConstraint     *   topConstraintForSlideMenu;
@property (nonatomic,weak)      IBOutlet NSLayoutConstraint     *   topConstraintForCollectionViewHolder;

@property (nonatomic,weak)      IBOutlet UIView                 *   collectionViewHolder;
@property (nonatomic,strong)             SnappingView           *   snapView;
@property  (strong,nonatomic)            drawView               *   dView;

@property (nonatomic,strong) UIImage *avCapturedImage;
@property (nonatomic,strong) UIImage *savedImage;
@property (nonatomic,strong) CALayer *subLayerCamera;

@property (nonatomic,weak) IBOutlet UIToolbar *toolBar;




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
    
    [self initialSetup];

}

-(void)initialSetup{
    
    _paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    _documentsDirectory = [_paths objectAtIndex:0];
    _savedImagePath = [_documentsDirectory stringByAppendingPathComponent:@"savedImage.png"];
    
    firstPicTaken=NO;
    secondPicTaken=NO;
    
    self.view.backgroundColor=[UIColor whiteColor];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    _slideMenu.alpha=0.0f;
    _collectionViewHolder.alpha=0.0f;
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(180, eraserCollectionView.frame.size.height-40)];
    [flowLayout setSectionInset:UIEdgeInsetsMake(10, 10, 10, 10)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    
    [self->eraserCollectionView setCollectionViewLayout:flowLayout];
}

-(void)addTagsToViews{
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
//        [self takeSnapShot];
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
//
    
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
                             dView.imgName=@"eraser.png";
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
                                     [self shareImage];
                                 });
                                 
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
    [alert addAction:ok];
    [alert addAction:share];
    
    [self presentViewController:alert animated:YES completion:nil];

}

-(void)shareImage{
    
    NSURL *URL = [NSURL fileURLWithPath:_savedImagePath];
    
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
    
    
    UIGraphicsBeginImageContext(self.imageUIView.frame.size);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()]; //changed layer
    _savedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImageWriteToSavedPhotosAlbum(_savedImage, nil, nil, nil);
    
    
    [self saveImageAtPath];
    
}

-(void)saveImageAtPath{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    
    [fileManager removeItemAtPath:_savedImagePath error:&error];
    
    NSData *imageData = UIImagePNGRepresentation(_savedImage);
    [imageData writeToFile:_savedImagePath atomically:NO];
    
    [self showAlert];
    
 
    
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
    
    dView=[[drawView alloc]initWithFrame:CGRectMake(0, 0, imageUIView.frame.size.width, imageUIView.frame.size.height)];
    dView.delegate=self;
    [dView drawImage:chosenImage];
    dView.drawLock=NO;
    [dView setErase:@"eraser.png"];
    [imageUIView addSubview:dView];
    [self animateImageUIView];
    
    firstPicTaken=YES;
    _bbitemStart.enabled=NO;
    _bbitemStart.title=@"Take Another Pic";
    _choosePic.enabled=NO;
    

    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
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
    
//    UIImageView *imageView = [[UIImageView alloc]init];//WithImage:imag];
    
//    NSNumber *x=[[NSUserDefaults standardUserDefaults]objectForKey:@"x"];
//    NSNumber *y=[[NSUserDefaults standardUserDefaults]objectForKey:@"y"];
//    NSNumber *width=[[NSUserDefaults standardUserDefaults]objectForKey:@"width"];
//    NSNumber *height=[[NSUserDefaults standardUserDefaults]objectForKey:@"height"];
//    
//    CGRect layerRect = CGRectMake([x floatValue], [y floatValue], [width floatValue], [height floatValue]);
    
    _snapView=[[SnappingView alloc]initWithFrame:imageUIView.frame]; //imageUIView frame
    
    
//    [imageView setFrame:layerRect];
//    [imageView setContentMode:UIViewContentModeScaleAspectFit];
   // imageView.image=_avCapturedImage;
    
//    imageView.frame=_snapView.frame;
    
    
    
    
    //[imageView setFrame:AVMakeRectWithAspectRatioInsideRect(imageView.image.size, _snapView.bounds)]; //frame
//    [imageView setFrame:CGRectMake(imageView.frame.origin.x, imageView.frame.origin.y, 340, 436)];
   // [_snapView addSubview:imageView];
    
//    _snapView.layer.contents=(id)_avCapturedImage.CGImage;
//    _snapView.layer.contentsScale=0.0f;
//    
//    _snapView.layer.contentsGravity=kCAGravityCenter;
//    CGAffineTransform rotateTransform = CGAffineTransformMakeRotation(M_PI / 2.0);
//    [_snapView.layer setAffineTransform:rotateTransform];
//
  
    [_snapView drawImage:_avCapturedImage];
    
    [_snapView addSubview:dView];
    [self.view addSubview:_snapView];
    
//    [imageUIView addSubview:_snapView];
//    [imageUIView.layer insertSublayer:_snapView.layer below:dView.layer];
    
   // [self addViewsBasedOnScreenSize];

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
    _bbitemStart.enabled=YES;
    
    [dView removeFromSuperview];
    [_snapView removeFromSuperview];
    [_subLayerCamera removeFromSuperlayer];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kImageCapturedSuccessfully object:nil];
   // [imageUIView removeFromSuperview];
   
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


#pragma eraser collectionview delegate methods
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return 3;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"EraserCollectionViewCell";
    
    EraserCollectionViewCell *cell = (EraserCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor whiteColor];
    cell.layer.borderColor=[[UIColor clearColor]CGColor];
    cell.layer.borderWidth=0.0;
    cell.imgView.contentMode=UIViewContentModeScaleAspectFit;
    cell.imgView.backgroundColor=[UIColor purpleColor];
    if (indexPath.row==0) {
        
        cell.imgView.image=[UIImage imageNamed:@"circleShape.png"];
        
    }
    if (indexPath.row==1) {
        cell.imgView.image=[UIImage imageNamed:@"heartShape.png"];
    }
    
    
       return cell;
    
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    EraserCollectionViewCell *cell = (EraserCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    cell.layer.borderColor=[[UIColor colorWithRed:13/255.0 green:79/255.0 blue:139/255.0 alpha:1]CGColor];
    cell.layer.borderWidth=3.0;
    eraserSelected=indexPath.row;
    isEraserSelected=YES;
    
    if (eraserSelected==0) {
        
            [dView setErase:@"eraser.png"];
    }
    if (eraserSelected==1) {
           [dView setErase:@"heart.png"];
    }
    
    [self hideCollectionView];
    
    // cell.backgroundColor = [UIColor magentaColor];
    
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
    
    _collectionViewHolder.alpha=1.0f;
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

-(void)hideCollectionView{
    
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
    }
    
}

-(void)openMenu{
    
    NSLog(@"swiped down");
    
    menuOpen=YES;
    
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
        
        _slideMenu.alpha=1.0f;;
    }];
    
    
    
}


@end
