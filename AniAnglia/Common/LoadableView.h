//
//  LoadableView.h
//  AniAnglia
//
//  Created by Toilettrauma on 11.11.2024.
//

#import <UIKit/UIKit.h>

@interface LoadableView : UIView
-(void)startLoading;
-(void)endLoading;
@end

@interface LoadableImageView : UIImageView

-(void)tryLoadImageWithURL:(NSURL*)url;
@end
