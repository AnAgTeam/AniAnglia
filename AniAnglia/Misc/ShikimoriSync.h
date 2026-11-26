//
//  ShikimoriSync.h
//  AniLot
//
//  Синхронизация списков и прогресса просмотра с Shikimori.
//
//  • Импорт Shikimori → Anixart: списки (смотрю / в планах / просмотрено / отложено / брошено)
//    и количество просмотренных серий. Для публичного списка вход не нужен — достаточно ника.
//  • Экспорт Anixart → Shikimori: те же списки и прогресс (нужен вход через OAuth2).
//
//  Идентификатор аниме в Shikimori совпадает с MAL ID. Соответствие релизов Anixart ↔ Shikimori
//  находится по названию/году/числу серий и запоминается.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

extern NSString* const AniLotShikimoriDidChangeNotification;

@interface ShikimoriSyncReport : NSObject
@property(nonatomic) NSInteger total;            // всего записей
@property(nonatomic) NSInteger synced;           // перенесено
@property(nonatomic) NSInteger progress_synced;  // у скольких перенесён прогресс просмотра
@property(nonatomic) NSInteger failed;           // не найдено соответствие / ошибка
@property(nonatomic) BOOL cancelled;
@property(nonatomic, copy) NSString* fatal_error;
@property(nonatomic, copy) NSArray<NSString*>* problems;  // названия, которые не удалось перенести

-(NSString*)summary;
@end

@interface ShikimoriSync : NSObject

+(instancetype)sharedInstance;

/* Данные приложения Shikimori (shikimori.one/oauth/applications) */
@property(nonatomic, copy) NSString* client_id;
@property(nonatomic, copy) NSString* client_secret;
/* Redirect URI, который нужно указать в приложении Shikimori */
@property(nonatomic, readonly) NSString* redirect_uri;

@property(nonatomic, readonly) NSString* nickname;       // подключённый аккаунт
@property(nonatomic, readonly) BOOL isAuthorized;
@property(nonatomic, readonly) BOOL isRunning;
/* переносить ли прогресс просмотра (по умолчанию YES) */
@property(nonatomic) BOOL sync_progress;
/* последний ник, из которого делали импорт */
@property(nonatomic, copy) NSString* last_import_nickname;
@property(nonatomic, readonly) NSString* last_sync_text;

/* Вход через OAuth2 (ASWebAuthenticationSession). completion — в главном потоке:
   nil — успех, пустая строка — пользователь отменил вход, иначе текст ошибки. */
-(void)authorizeFromViewController:(UIViewController*)controller completion:(void(^)(NSString* error))completion;
-(void)signOut;

/* progress и completion вызываются в главном потоке */
-(void)importListsForNickname:(NSString*)nickname progress:(void(^)(NSString* text, double fraction))progress completion:(void(^)(ShikimoriSyncReport* report))completion;
-(void)exportListsWithProgress:(void(^)(NSString* text, double fraction))progress completion:(void(^)(ShikimoriSyncReport* report))completion;
-(void)cancel;

@end
