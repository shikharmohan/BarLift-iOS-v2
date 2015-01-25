//
//  BLTUserDetailViewController.m
//  BarLift
//
//  Created by Shikhar Mohan on 1/18/15.
//  Copyright (c) 2015 Shikhar Mohan. All rights reserved.
//

#import "BLTUserDetailViewController.h"
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>

@interface BLTUserDetailViewController ()
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;

@end

@implementation BLTUserDetailViewController
@synthesize profilePicture;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.nameLabel.text = [NSString stringWithFormat:@"Hello, %@", [PFUser currentUser][@"profile"][@"name"]];
    dispatch_async(dispatch_get_global_queue(0,0), ^{
        NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: [PFUser currentUser][@"profile"][@"pictureURL"]]];
        if ( data == nil )
            return;
        dispatch_async(dispatch_get_main_queue(), ^{
            [profilePicture initWithImage:[UIImage imageWithData:data scale:1.0]];
            profilePicture.layer.cornerRadius = 120;
        });
    });
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
