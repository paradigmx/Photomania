//
//  AddPhotoViewController.h
//  Photomania
//
//  Created by Neo on 9/11/14.
//  Copyright (c) 2014 Paradigm X. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Photographer+Create.h"

@interface AddPhotoViewController : UIViewController
@property (strong, nonatomic) Photographer *photographer;
@property (strong, readonly) Photo *photo;
@end
