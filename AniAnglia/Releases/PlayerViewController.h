//
//  PlayerViewController.h
//  iOSAnixart
//
//  Created by Toilettrauma on 07.10.2024.
//

#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>

@interface PlayerController : NSObject <AVPictureInPictureControllerDelegate, AVPlayerViewControllerDelegate>
@property(nonatomic, readonly, retain, getter = getPlayer) AVPlayerViewController* player;

-(instancetype)init;

-(void)playWithReleaseID:(long long)release_id sourceID:(long long)source_id position:(long)position autoShow:(BOOL)auto_show completion:(void(^)(BOOL errored))completion_handler;

-(AVPlayerViewController*)getPlayer;

+(instancetype)sharedInstance;

@end
