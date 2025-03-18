//
//  TorrentAVAsset.h
//  AniAnglia
//
//  Created by Toilettrauma on 06.02.2025.
//

#import <AVFoundation/AVFoundation.h>

@interface TorrentResourceLoaderURL : NSURL
@property(nonatomic) int file_index;
@end

@interface TorrentAVResourceLoaderDelegate : NSObject <AVAssetResourceLoaderDelegate>

@end
