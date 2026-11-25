//
//  LoadableView.h
//  AniAnglia
//
//  Created by Toilettrauma on 11.11.2024.
//

#import <UIKit/UIKit.h>

@class LoadableView;

@protocol LoadableViewDelegate <NSObject>

-(void)didReloadForLoadableView:(LoadableView*)loadableView;

@end

@interface LoadableView : UIView
@property(nonatomic, weak) id<LoadableViewDelegate> delegate;

-(void)startLoading;
-(void)endLoading;
-(void)endLoadingWithErrored:(BOOL)errored;
-(void)setErrored:(BOOL)errored;

@end

/* Запрос на загрузку изображения. cancel — отменить (completion после этого не вызывается). */
@interface LoadableImageRequest : NSObject
-(void)cancel;
@end

@interface LoadableImageView : UIImageView

-(void)tryLoadImageWithURL:(NSURL*)url;

/* Общий загрузчик: https-апгрейд, прямой запрос + прокси-fallback и «альтернативное соединение».
   completion вызывается на главной очереди; image == nil означает ошибку после всех попыток.
   full_size = YES — оригинальное разрешение (для галереи), NO — превью. */
+(LoadableImageRequest*)loadImageWithURL:(NSURL*)url fullSize:(BOOL)full_size completion:(void(^)(UIImage* image))completion;
+(NSURL*)secureURLForURL:(NSURL*)url;

+(NSUInteger)imageCacheDiskUsage;
+(void)setImageCacheDiskLimit:(NSUInteger)bytes;
+(void)clearImageCache;
@end
