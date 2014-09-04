//
//  URLViewController.m
//  Photomania
//
//  Created by Neo Lee on 9/3/14.
//  Copyright (c) 2014 Paradigm X. All rights reserved.
//

#import "URLViewController.h"

@interface URLViewController ()
@property (weak, nonatomic) IBOutlet UITextView *urlTextView;
@end

@implementation URLViewController

- (void)setUrl:(NSURL *)url {
    _url = url;
    [self updateUI];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self updateUI];
}

- (void)updateUI {
    self.urlTextView.text = self.url.absoluteString;
}

@end
