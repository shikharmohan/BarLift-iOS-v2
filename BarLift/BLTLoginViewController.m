//
//  ViewController.m
//  BarLift
//
//  Created by Shikhar Mohan on 1/16/15.
//  Copyright (c) 2015 Shikhar Mohan. All rights reserved.
//

#import "BLTLoginViewController.h"
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "BLTUserDetailViewController.h"
#import "FLAnimatedImage.h"

@interface BLTLoginViewController ()

@end

@implementation BLTLoginViewController


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Check if user is cached and linked to Facebook, if so, bypass login
    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        [self performSegueWithIdentifier:@"toDetails" sender:self];
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    FLAnimatedImage *image = [FLAnimatedImage animatedImageWithGIFData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"https://31.media.tumblr.com/c48378e8ce8f0e29ea7d3198df4decef/tumblr_n7wk45d38O1tvkgeto1_500.gif"]]];
    FLAnimatedImageView *imageView = [[FLAnimatedImageView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    imageView.animatedImage = image;
    [self.view addSubview:imageView];
    
    UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"barliftlogo.png"]];
    logo.center = CGPointMake(self.view.center.x, 100);
    logo.alpha = 0.0;
    [self.view addSubview:logo];

    UIButton *login = [[UIButton alloc] initWithFrame:CGRectMake(self.view.center.x/4, self.view.center.y+125, self.view.center.x+75, self.view.center.y/4)];
    UIImage *background = [UIImage imageNamed:@"Facebook@2x.png"];
    [login setTitle:@"Login With Facebook" forState:UIControlStateNormal];
    [login setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    login.alpha = 0.0;
    
    [login setBackgroundImage:background forState:UIControlStateNormal];

    [self.view addSubview:login];
    
    [UIView animateWithDuration:2.0 animations:^{
        logo.alpha = 1.0;
    }];
    [UIView animateWithDuration:3.5 animations:^{
        login.alpha = 1.0;
    }];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
