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
#import "RKCardView.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "ActionSheetStringPicker.h"
@interface BLTUserDetailViewController ()
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet RKCardView *cardView;
@property (weak, nonatomic) IBOutlet UIView *pushView;
@property (weak, nonatomic) IBOutlet UISwitch *pushSwitch;
@property (weak, nonatomic) IBOutlet UILabel *pushLabel;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UITextField *teamTextField;
@property (weak, nonatomic) IBOutlet UITextField *nightTextField;
@property BOOL notifOn;
@end

@implementation BLTUserDetailViewController
@synthesize profilePicture;
- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //profile card
    [self.cardView.profileImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", [PFUser currentUser][@"fb_id"]]]];
    self.cardView.profileImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.cardView.coverImageView.image = [UIImage imageNamed:@"BG1.png"];
    self.cardView.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.cardView.titleLabel.text = [NSString stringWithFormat:@"%@", [PFUser currentUser][@"profile"][@"name"]];
    self.cardView.layer.cornerRadius = 5;
    [self.cardView addShadow];
    [self.cardView addSubview:self.pushView];
    
    if([PFUser currentUser][@"dm_team"]){
        self.teamTextField.text = [PFUser currentUser][@"dm_team"];
    }
    if([PFUser currentUser][@"num_nights"]){
        self.nightTextField.text = [PFUser currentUser][@"num_nights"];
    }
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"notNew"] == nil){
        self.pushSwitch.on = YES;
    }
    else if([[NSUserDefaults standardUserDefaults] boolForKey:@"notifOn"] == NO){
        self.pushSwitch.on = NO;
    }
    else if([[NSUserDefaults standardUserDefaults] boolForKey:@"notifOn"]){
        self.pushSwitch.on = YES;
    }

    //viral switch
    
    
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


- (IBAction)saveButtonPressed:(id)sender {
    if(self.pushSwitch.on){
    //ask for push permissions
        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                        UIUserNotificationTypeBadge |
                                                        UIUserNotificationTypeSound);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                                 categories:nil];
        [[UIApplication sharedApplication]  registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication]  registerForRemoteNotifications];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"notifOn"];
    }
    else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Instructions to turn off notifications" message:@"In order to turn off push notifications, please go to Settings -> Notifications -> BarLift." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
            [alertView show];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"notifOn"];
    }
    [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"notNew"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSString *teamName = self.teamTextField.text;
    NSString *numberTimes = self.nightTextField.text;
    NSLog(@"%@", numberTimes);
    [[PFUser currentUser] setObject:teamName forKey:@"dm_team"];
    [[PFUser currentUser] setObject:numberTimes forKey:@"num_nights"];
    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(succeeded){
            [self performSegueWithIdentifier:@"profileToDeal" sender:self];
        }
        else{
            NSLog(@"%@", error);
        }
    }];
    
}

- (IBAction)teamNameEdit:(id)sender {
    NSArray *names = [NSArray arrayWithObjects:@"3rd floor hinman",
                      @"AAIV",
                      @"All Cultural Effect",
                      @"Allison Hall",
                      @"Alpha Chi Omega/Alpha Epsilon Pi",
                      @"Alpha Phi/Sigma Chi",
                      @"Ayers CCI",
                      @"Bobb",
                      @"Chapin/ CCS",
                      @"Sigma Phi Epsilon",
                      @"CRC",
                      @"Delta Delta Delta/Sigma Alpha Epsilon",
                      @"Delta Gamma/Zeta Beta Tau/Alpha Iota Omicron",
                      @"Delta Zeta/Delta Chi",
                      @"Elder",
                      @"Evans Scholars",
                      @"Gamma Phi/Phi Delta Theta",
                      @"Hinman Residential Hall",
                      @"Hobart",
                      @"ISA",
                      @"ISRC",
                      @"Jones",
                      @"Kappa Delta/Sigma Nu",
                      @"Kappa Kappa Gamma/Pi Kappa Alpha",
                      @"Lamda Chi/Chi O",
                      @"NU Marching Band",
                      @"PARC",
                      @"Phi Kappa Psi/ Kappa Alpha Theta",
                      @"Pi Beta Phi/Beta Theta Pi",
                      @"Project Wildcat",
                      @"Rugby",
                      @"Sargent",
                      @"Shepard",
                      @"Sherman Avenue",
                      @"Slivka",
                      @"Theatre/A Cappella",
                      @"Willard",
                      @"Zeta Tau Alpha/ Delt",
                      @"IPS Israel",
                      @"Substance Free",
                      @"The Seagulls",
                      @"May and O",
                      @"Sigma Psi Zeta",
                      @"Friends",
                      @"Phi Sigma Pi", nil];
    
    [ActionSheetStringPicker showPickerWithTitle:@"DM Team Name"
                                            rows:names
                                initialSelection:0
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                           [self.teamTextField setText:[NSString stringWithFormat:@"%@", selectedValue]];
                                           [self.teamTextField resignFirstResponder];
                                       }
                                     cancelBlock:^(ActionSheetStringPicker *picker) {
                                         NSLog(@"Block Picker Canceled");
                                         [self.teamTextField resignFirstResponder];

                                     }
                                          origin:sender];
}

- (IBAction)numberNightEdit:(id)sender {
    NSArray *nights = [NSArray arrayWithObjects:@"0", @"1", @"2", @"3", @"4", @"5",  @"6", @"7", nil];
    
    [ActionSheetStringPicker showPickerWithTitle:@"Number Of Nights"
                                            rows:nights
                                initialSelection:0
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                           [self.nightTextField setText:[NSString stringWithFormat:@"%@", selectedValue]];
                                           [self.nightTextField resignFirstResponder];
                                           
                                       }
                                     cancelBlock:^(ActionSheetStringPicker *picker) {
                                         NSLog(@"Block Picker Canceled");
                                         [self.nightTextField resignFirstResponder];

                                     }
                                          origin:sender];
    // You can also use self.view if you don't have a sender
}


@end
