//
//  FilterViewController.m
//  AniAnglia
//
//  Created by Toilettrauma on 13.12.2024.
//

#import <Foundation/Foundation.h>
#import "FilterViewController.h"

@interface FilterViewController ()

@end

@implementation FilterViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self setup];
}

-(void)setup {
    UILabel* label = [UILabel new];
    [self.view addSubview:label];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    [label.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [label.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    [label.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [label.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    label.text = @"HELLO";
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    
    [self setupLayout];
}
-(void)setupLayout {
    self.view.backgroundColor = [UIColor systemBlueColor];
}

@end
