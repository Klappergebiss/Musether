//
//  TEMasterTableViewController.m
//  Musether
//
//  Created by Tim Engel on 02.03.16.
//  Copyright © 2016 Tim Engel. All rights reserved.
//

#import "TEMasterTableViewController.h"
#import "TDMultipeerGuestViewController.h"
#import "TDMultipeerHostViewController.h"

@interface TEMasterTableViewController ()

@property (strong, nonatomic) NSString *username;

@end

@implementation TEMasterTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)viewDidAppear:(BOOL)animated {
    if (!self.username) [self showWelcomeAlert];
}

-(void)showWelcomeAlert {
    UIAlertController *welcomeAlert = [UIAlertController alertControllerWithTitle:@"Welcome" message:@"Welcome to Musether" preferredStyle:UIAlertControllerStyleAlert];
    [welcomeAlert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"enter username";
    }];
    
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"No, thanks" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        self.username = @"";
    }];
    UIAlertAction *doneAction = [UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.username = [welcomeAlert textFields][0].text;
    }];
    
    [welcomeAlert addAction:noAction];
    [welcomeAlert addAction:doneAction];
    
    [self presentViewController:welcomeAlert animated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {    
    if ([segue.destinationViewController isKindOfClass:[TDMultipeerGuestViewController class]]) {
        if ([self.username isEqualToString:@""] || [self.username isEqualToString:@"Host"]) self.username = @"Guest";
        TDMultipeerGuestViewController *guestVC = segue.destinationViewController;
        guestVC.username = self.username;
    } else if ([segue.destinationViewController isKindOfClass:[TDMultipeerHostViewController class]]) {
        if ([self.username isEqualToString:@""] || [self.username isEqualToString:@"Guest"]) self.username = @"Host";
        TDMultipeerHostViewController *hostVC = segue.destinationViewController;
        hostVC.username = self.username;
    }
}


@end
