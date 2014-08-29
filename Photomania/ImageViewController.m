//
//  ImageViewController.m
//  Imaginarium
//
//  Created by Neo on 8/20/14.
//  Copyright (c) 2014 Paradigm X. All rights reserved.
//

#import "ImageViewController.h"
#import "URLViewController.h"

@interface ImageViewController () <UIScrollViewDelegate, UISplitViewControllerDelegate>
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIImage *image;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) UIPopoverController *urlPopoverController;
@end

@implementation ImageViewController

- (void)setScrollView:(UIScrollView *)scrollView {
    _scrollView = scrollView;
    _scrollView.minimumZoomScale = 0.25;
    _scrollView.maximumZoomScale = 2;
    _scrollView.delegate = self;

    [self updateContentSize];
}

- (void)setImageURL:(NSURL *)imageURL {
    _imageURL = imageURL;

    if (self.urlPopoverController) [self.urlPopoverController dismissPopoverAnimated:YES];
    [self downloadImage];
}

- (UIImageView *)imageView {
    if (!_imageView) _imageView = [[UIImageView alloc] init];
    return _imageView;
}

- (UIImage *)image {
    return self.imageView.image;
}

- (void)setImage:(UIImage *)image {
    self.scrollView.zoomScale = 1.0;
    self.imageView.image = image;
    self.imageView.frame = CGRectMake(0.0, 0.0, image.size.width, image.size.height);
    [self updateContentSize];
    [self.spinner stopAnimating];
}

- (void)updateContentSize {
    self.scrollView.contentSize = self.image ? self.image.size : CGSizeZero;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.scrollView addSubview:self.imageView];
}

- (void)downloadImage {
    self.image = nil;

    if (self.imageURL) {
        [self.spinner startAnimating];

        NSURLRequest *request = [NSURLRequest requestWithURL:self.imageURL];
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
        // For ephemeral session configuration we can use completion handler, for background session we have to use delegate instead
        NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request
                                                        completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                                                            if (!error) {
                                                                if ([request.URL isEqual:self.imageURL]) {
                                                                    // NOTE: the location and the downloaded content only accessible inside the block!
                                                                    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:location]];
                                                                    dispatch_async(dispatch_get_main_queue(), ^{ self.image = image; });
                                                                    // [self performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:NO];
                                                                }
                                                            }
                                                        }];
        [task resume];
    }
}

#pragma mark - Scroll view controller delegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Show URL"]) {
        if ([segue isKindOfClass:[UIStoryboardPopoverSegue class]]) {
            self.urlPopoverController = ((UIStoryboardPopoverSegue *)segue).popoverController;
        }

        if ([segue.destinationViewController isKindOfClass:[URLViewController class]]) {
            URLViewController *urlViewController = (URLViewController *)segue.destinationViewController;
            urlViewController.url = self.imageURL;
        }
    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:@"Show URL"]) {
        return self.imageURL ? YES : NO;
    }
    else {
        return [super shouldPerformSegueWithIdentifier:identifier sender:sender];
    }
}

#pragma mark - Split view controller delegate

- (void)awakeFromNib {
    self.splitViewController.delegate = self;
}

- (BOOL)splitViewController:(UISplitViewController *)svc
   shouldHideViewController:(UIViewController *)vc
              inOrientation:(UIInterfaceOrientation)orientation {
    return UIInterfaceOrientationIsPortrait(orientation);
}

- (void)splitViewController:(UISplitViewController *)svc
     willHideViewController:(UIViewController *)aViewController
          withBarButtonItem:(UIBarButtonItem *)barButtonItem
       forPopoverController:(UIPopoverController *)pc {
    barButtonItem.title = aViewController.title;
    self.navigationItem.leftBarButtonItem = barButtonItem;
}

- (void)splitViewController:(UISplitViewController *)svc
     willShowViewController:(UIViewController *)aViewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    self.navigationItem.leftBarButtonItem = nil;
}

@end
