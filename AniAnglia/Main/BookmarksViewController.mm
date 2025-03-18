//
//  BookmarksViewController.m
//  iOSAnixart
//
//  Created by Toilettrauma on 28.08.2024.
//

#import <Foundation/Foundation.h>
#import "BookmarksViewController.h"
#import "AppColor.h"

#import "TorrentAVAsset.h"
#import "PlayerViewController.h"
#import "StringCvt.h"

#import <torrentrepo/TorrentSession.hpp>

@interface BookmarksViewController ()

@end

@implementation BookmarksViewController

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
