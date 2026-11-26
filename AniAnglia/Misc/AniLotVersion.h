//
//  AniLotVersion.h
//  AniLot
//
//  Версия установленного релиза AniLot и проверка новых релизов на GitHub.
//
//  Номер релиза совпадает с номером релиза на GitHub: релиз «AniLot v9» (тег anilot-9) → 9.
//  При выпуске нового релиза достаточно поднять ANILOT_RELEASE_NUMBER (либо передать
//  -DANILOT_RELEASE_NUMBER=N при сборке).
//

#import <Foundation/Foundation.h>

#ifndef ANILOT_RELEASE_NUMBER
#define ANILOT_RELEASE_NUMBER 9
#endif

#define ANILOT_RELEASES_API_URL @"https://api.github.com/repos/vilefex/AniLot/releases/latest"
#define ANILOT_RELEASES_PAGE_URL @"https://github.com/vilefex/AniLot/releases/latest"

/* Номер установленного релиза (9) */
NSInteger AniLotReleaseNumber(void);
/* Название установленного релиза: «v9» */
NSString* AniLotReleaseName(void);
/* Служебная версия сборки из Info.plist: «0.10 (1)» */
NSString* AniLotBuildString(void);

@interface AniLotUpdateInfo : NSObject
@property(nonatomic, copy) NSString* tag;           // anilot-9
@property(nonatomic, copy) NSString* name;          // AniLot v9
@property(nonatomic, copy) NSString* notes;         // описание релиза
@property(nonatomic, copy) NSString* page_url;      // страница релиза
@property(nonatomic, copy) NSString* download_url;  // прямая ссылка на AniLot.ipa (если есть)
@property(nonatomic, strong) NSDate* published_at;
@property(nonatomic) NSInteger number;              // номер релиза, 0 — не удалось определить
@property(nonatomic) BOOL is_newer;                 // на GitHub версия новее установленной
@property(nonatomic) BOOL is_older;                 // установленная версия новее опубликованной (dev-сборка)

/* «v9» либо название релиза, если номер не удалось определить */
-(NSString*)displayName;
@end

@interface AniLotUpdateChecker : NSObject

/* Запрашивает последний релиз. completion вызывается в главном потоке:
   info != nil — релиз получен (смотрите is_newer), иначе error содержит причину. */
+(void)checkWithCompletion:(void(^)(AniLotUpdateInfo* info, NSString* error))completion;

/* Результат последней успешной проверки (хранится между запусками) */
+(AniLotUpdateInfo*)lastKnownInfo;
+(NSDate*)lastCheckDate;

/* Текст для строки в настройках: «Вчера, 12:30 · доступна v9» */
+(NSString*)statusSummary;

@end
