//
//  AniLotSubtitles.h
//  AniLot
//
//  Субтитры для собственного плеера: парсеры WebVTT / SRT / ASS и поиск ссылок на субтитры
//  в страницах источников (iframe-плееры отдают их через <track>, playerjs "subtitle" и т.п.).
//  Субтитры, встроенные в HLS (EXT-X-MEDIA TYPE=SUBTITLES), плеер получает через AVFoundation.
//

#import <Foundation/Foundation.h>

@interface AniLotSubtitleCue : NSObject
@property(nonatomic) double start;
@property(nonatomic) double end;
@property(nonatomic, copy) NSString* text;
@end

@interface AniLotSubtitleTrack : NSObject
@property(nonatomic, copy) NSString* label;
@property(nonatomic, strong) NSURL* url;
/* заголовки для запроса файла (Referer/User-Agent источника) */
@property(nonatomic, copy) NSDictionary<NSString*, NSString*>* headers;
/* nil — ещё не загружено */
@property(nonatomic, strong) NSArray<AniLotSubtitleCue*>* cues;

/* Текст, который нужно показывать в момент time (секунды); nil — ничего */
-(NSString*)textAtTime:(double)time;
/* Скачивает и разбирает файл. completion — в главном потоке. */
-(void)loadWithCompletion:(void(^)(BOOL ok))completion;
@end

/* Определяет формат (WebVTT, SRT или ASS/SSA) и возвращает реплики по возрастанию времени начала */
NSArray<AniLotSubtitleCue*>* AniLotParseSubtitleText(NSString* text);

/* Ищет в тексте страницы/JSON ссылки на файлы субтитров (.vtt/.srt/.ass).
   base_url нужен для относительных ссылок и заголовка Referer. */
NSArray<AniLotSubtitleTrack*>* AniLotFindSubtitleTracks(NSString* text, NSURL* base_url);
