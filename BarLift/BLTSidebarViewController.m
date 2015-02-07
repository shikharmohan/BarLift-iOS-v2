//
//  BLTSidebarViewController.m
//  BarLift
//
//  Created by Shikhar Mohan on 2/4/15.
//  Copyright (c) 2015 Shikhar Mohan. All rights reserved.
//

#import "BLTSidebarViewController.h"
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>


@interface BLTSidebarViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *profPic;
@property (weak, nonatomic) IBOutlet UILabel *name;

@end

@implementation BLTSidebarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.name.text = [NSString stringWithFormat:@"%@", [PFUser currentUser][@"profile"][@"name"]];

    dispatch_async(dispatch_get_global_queue(0,0), ^{
        NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: [PFUser currentUser][@"profile"][@"pictureURL"]]];
        if ( data == nil )
            return;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.profPic initWithImage:[UIImage imageWithData:data scale:1.0]];
            self.profPic.layer.cornerRadius = self.profPic.frame.size.width / 2;
            self.profPic.clipsToBounds = YES;
        });
    });

    // Do any additional setup after loading the view.
}

- (IBAction)logoutButtonPressed:(UIButton *)sender {
    if ([PFUser currentUser]) {
        [[PFFacebookUtils session] closeAndClearTokenInformation];
        [PFUser logOut];
    } else {
        NSLog(@"currentUser: %@", [PFUser currentUser]);
    }
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    
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