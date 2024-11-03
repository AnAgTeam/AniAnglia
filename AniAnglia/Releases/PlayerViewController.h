//
//  PlayerViewController.h
//  iOSAnixart
//
//  Created by Toilettrauma on 07.10.2024.
//

#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>

@interface PlayerController : NSObject <AVPictureInPictureControllerDelegate>
@property(nonatomic, readonly, retain, getter = getPlayer) AVPlayerViewController* player;

-(instancetype)initWithReleaseID:(long long)release_id sourceID:(long long)source_id position:(long)position;

-(AVPlayerViewController*)getPlayer;

@end
