//
//  MainViewController.m
//  iOSAnixart
//
//  Created by Toilettrauma on 28.08.2024.
//

#import <Foundation/Foundation.h>
#import "MainViewController.h"
#import "AppColor.h"

@interface MainViewController ()

@end

@implementation MainViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
}

-(void)setupView {
    
    
    [self setupDarkLayout];
}

-(void)setupDarkLayout {
    self.view.backgroundColor = [AppColorProvider backgroundColor];
}

@end
