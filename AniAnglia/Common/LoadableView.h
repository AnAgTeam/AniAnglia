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
-(void)endLoadingWithErrored:(BOOL)errored;
-(void)setErrored:(BOOL)errored;
@end

@interface LoadableImageView : UIImageView

-(void)tryLoadImageWithURL:(NSURL*)url;
@end
