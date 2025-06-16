//
//  PlayerViewController.h
//  iOSAnixart
//
//  Created by Toilettrauma on 07.10.2024.
//

#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>
#import "LibanixartApi.h"

@interface PlayerController : NSObject <AVPictureInPictureControllerDelegate, AVPlayerViewControllerDelegate>
@property(nonatomic, readonly, retain, getter = getPlayer) AVPlayerViewController* player;

-(instancetype)init;

-(void)playWithReleaseID:(anixart::ReleaseID)release_id sourceID:(anixart::EpisodeSourceID)source_id position:(long)position autoShow:(BOOL)auto_show completion:(void(^)(BOOL errored))completion_handler;
-(void)playWithURL:(NSURL*)url;

-(AVPlayerViewController*)getPlayer;

+(instancetype)sharedInstance;

@end
