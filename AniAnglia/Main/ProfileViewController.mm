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

@end

@implementation ProfileViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
}

-(void)setupView {
    
    
    [self setupDarkLayout];
}

-(void)setupDarkLayout {
    self.view.backgroundColor = [AppColorProvider primaryColor];
}

@end
