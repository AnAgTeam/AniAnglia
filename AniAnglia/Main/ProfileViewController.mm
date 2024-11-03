//
//  ProfileViewController.m
//  iOSAnixart
//
//  Created by Toilettrauma on 28.08.2024.
//

#import <Foundation/Foundation.h>
#import "ProfileViewController.h"
#import "AppColor.h"

@interface ProfileViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *ava;

@end


@implementation ProfileViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    self.ava.clipsToBounds = YES;
    self.ava.layer.masksToBounds = YES;
    self.ava.layer.cornerRadius = 64;
    [self setupView];
}

-(void)setupView {
    
    
}

@end



