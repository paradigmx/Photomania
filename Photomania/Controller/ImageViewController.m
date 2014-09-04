//
//  ImageViewController.m
//  Imaginarium
//
//  Created by Neo Lee on 8/23/14.
//  Copyright (c) 2014 Paradigm X. All rights reserved.
//

#import "ImageViewController.h"
#import "URLViewController.h"

@interface ImageViewController () <UIScrollViewDelegate, UISplitViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIImage *image;
@property (weak, atomic) UIPopoverController *urlPopoverController;
@end

@implementation ImageViewController

- (void)setScrollView:(UIScrollView *)scrollView {
    _scrollView = scrollView;
    
    _scrollView.minimumZoomScale = 0.25;
    _scrollView.maximumZoomScale = 2;
    _scrollView.delegate = self;
    
    [self updateContentSize];
}

- (void)updateContentSize {
    if (self.image) {
        _scrollView.contentSize = self.image.size;
        self.imageView.frame = CGRectMake(0, 0, self.image.size.width, self.image.size.height);
    }
    else {
        _scrollView.contentSize = CGSizeZero;
    }
}

- (void)setImageURL:(NSURL *)imageURL {
    _imageURL = imageURL;

    // Anytime a new url set, dismiss any exist popover
    if (self.urlPopoverController) { [self.urlPopoverController dismissPopoverAnimated:YES]; }
    
    [self downloadImage];
}

- (void)setImage:(UIImage *)image {
    self.scrollView.zoomScale = 1.0;
    self.imageView.image = image;
    [self updateContentSize];
    
    [self.spinner stopAnimating];
}

- (UIImage *)image {
    return self.imageView.image;
}

- (UIImageView *)imageView {
    if (!_imageView) _imageView = [[UIImageView alloc] init];
    return _imageView;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
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
        NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request
                                                        completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                                                            if (!error) {
                                                                if ([request.URL isEqual:self.imageURL]) {
                                                                    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:location]];
                                                                    dispatch_async(dispatch_get_main_queue(), ^{ self.image = image; });
                                                                }
                                                            }
                                                        }];
        [task resume];
    }
}

#pragma mark - Split view controller delegate

- (void)awakeFromNib {
    self.splitViewController.delegate = self;
}

- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation {
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

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue isKindOfClass:[UIStoryboardPopoverSegue class]]) {
        self.urlPopoverController = ((UIStoryboardPopoverSegue *)segue).popoverController;
    }
    
    if ([segue.identifier isEqualToString:@"Show URL"]) {
        if ([segue.destinationViewController isKindOfClass:[URLViewController class]]) {
            URLViewController *urlViewController = (URLViewController *)segue.destinationViewController;
            urlViewController.url = self.imageURL;
        }
    }
}

// Prevent popover if no image displayed
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:@"Show URL"]) {
        return self.imageURL ? YES : NO;
    }
    else {
        return [super shouldPerformSegueWithIdentifier:identifier sender:sender];
    }
}

@end
