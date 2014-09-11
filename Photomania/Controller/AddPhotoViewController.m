//
//  AddPhotoViewController.m
//  Photomania
//
//  Created by Neo on 9/11/14.
//  Copyright (c) 2014 Paradigm X. All rights reserved.
//

#import "AddPhotoViewController.h"

@interface AddPhotoViewController ()
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextField *subtitleTextField;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) UIImage *image;
@end

@implementation AddPhotoViewController

- (UIImage *)image {
    return self.imageView.image;
}

- (void)setImage:(UIImage *)image {
    self.imageView.image = image;
}

- (IBAction)cancel {

}

- (IBAction)takePhoto {

}

@end
