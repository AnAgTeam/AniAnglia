//
//  SettingsViewController.mm
//  AniAnglia
//
//  Переписанный экран настроек. Все подэкраны (уведомления, данные,
//  воспроизведение, помощь, о приложении) живут в этом файле, чтобы не
//  править project.pbxproj.
//

#import <Foundation/Foundation.h>
#include <chrono>
#import "SettingsViewController.h"
#import "AppColor.h"
#import "AppDataController.h"
#import "LoadableView.h"
#import "PlayerViewController.h"
#import "SettingsProfileViewController.h"
#import "SettingsAppearanceViewController.h"
#import "SettingsSecurityViewController.h"

#define L(key, def) NSLocalizedStringWithDefaultValue(key, nil, [NSBundle mainBundle], def, @"")

static NSString* const kTelegramURL = @"https://t.me/AnAgTeam";
static NSString* const kGithubURL = @"https://github.com/AnAgTeam/AniAnglia";
static NSString* const kGithubIssuesURL = @"https://github.com/AnAgTeam/AniAnglia/issues";

@class SettingsListViewController;
typedef void (^SettingsAction)(SettingsListViewController* from);

#pragma mark - Модель

@interface SettingsRow : NSObject
@property(nonatomic, copy) NSString* title;
@property(nonatomic, copy) NSString* (^valueProvider)(void);
@property(nonatomic, copy) BOOL (^isOn)(void);
@property(nonatomic, copy) void (^setOn)(BOOL on);
@property(nonatomic, copy) SettingsAction action;
@property(nonatomic, copy) NSString* icon;
@property(nonatomic, strong) UIColor* iconColor;
@property(nonatomic) BOOL destructive;
@property(nonatomic) BOOL showsDisclosure;
@end
@implementation SettingsRow
@end

@interface SettingsSection : NSObject
@property(nonatomic, copy) NSString* header;
@property(nonatomic, copy) NSString* footer;
@property(nonatomic, copy) NSArray<SettingsRow*>* rows;
@end
@implementation SettingsSection
@end

static SettingsSection* MakeSection(NSString* header, NSString* footer, NSArray<SettingsRow*>* rows) {
    SettingsSection* s = [SettingsSection new];
    s.header = header;
    s.footer = footer;
    s.rows = rows;
    return s;
}
static SettingsRow* NavRow(NSString* title, NSString* icon, UIColor* color, SettingsAction action) {
    SettingsRow* r = [SettingsRow new];
    r.title = title;
    r.icon = icon;
    r.iconColor = color;
    r.action = action;
    r.showsDisclosure = YES;
    return r;
}
static SettingsRow* ValueRow(NSString* title, NSString* (^value)(void), SettingsAction action) {
    SettingsRow* r = [SettingsRow new];
    r.title = title;
    r.valueProvider = value;
    r.action = action;
    return r;
}
static SettingsRow* SwitchRow(NSString* title, BOOL (^isOn)(void), void (^setOn)(BOOL)) {
    SettingsRow* r = [SettingsRow new];
    r.title = title;
    r.isOn = isOn;
    r.setOn = setOn;
    return r;
}
static SettingsRow* ButtonRow(NSString* title, BOOL destructive, SettingsAction action) {
    SettingsRow* r = [SettingsRow new];
    r.title = title;
    r.destructive = destructive;
    r.action = action;
    return r;
}

#pragma mark - Помощники

static void OpenURL(NSString* string) {
    NSURL* url = [NSURL URLWithString:string];
    if (url) {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    }
}

static NSString* FormatBytes(long long bytes) {
    return [NSByteCountFormatter stringFromByteCount:bytes countStyle:NSByteCountFormatterCountStyleFile];
}

static void PresentChoices(UIViewController* from, NSString* title, NSArray<NSString*>* names, NSInteger selected, void (^pick)(NSInteger index)) {
    UIAlertController* sheet = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    for (NSUInteger i = 0; i < names.count; i++) {
        NSString* name = (NSInteger)i == selected ? [@"✓ " stringByAppendingString:names[i]] : names[i];
        [sheet addAction:[UIAlertAction actionWithTitle:name style:UIAlertActionStyleDefault handler:^(UIAlertAction* action) {
            pick((NSInteger)i);
        }]];
    }
    [sheet addAction:[UIAlertAction actionWithTitle:L(@"app.common.cancel", @"Отмена") style:UIAlertActionStyleCancel handler:nil]];
    sheet.popoverPresentationController.sourceView = from.view;
    sheet.popoverPresentationController.sourceRect = CGRectMake(CGRectGetMidX(from.view.bounds), CGRectGetMidY(from.view.bounds), 1, 1);
    [from presentViewController:sheet animated:YES completion:nil];
}

static void PresentConfirm(UIViewController* from, NSString* title, NSString* message, NSString* button, void (^confirmed)(void)) {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:L(@"app.common.cancel", @"Отмена") style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:button style:UIAlertActionStyleDestructive handler:^(UIAlertAction* action) {
        confirmed();
    }]];
    [from presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Универсальный список настроек

@interface SettingsListViewController : UITableViewController
@property(nonatomic, copy) NSArray<SettingsSection*>* (^builder)(SettingsListViewController* controller);
@property(nonatomic, copy) NSArray<SettingsSection*>* sections;
@property(nonatomic, copy) NSString* reload_notification_name;
-(instancetype)initWithTitle:(NSString*)title builder:(NSArray<SettingsSection*>* (^)(SettingsListViewController* controller))builder;
-(void)reload;
@end

@interface SettingsListViewController () {
    id _reload_observer;
}
@end

@implementation SettingsListViewController

-(instancetype)initWithTitle:(NSString*)title builder:(NSArray<SettingsSection*>* (^)(SettingsListViewController* controller))builder {
    self = [super initWithStyle:UITableViewStyleInsetGrouped];
    self.title = title;
    _builder = [builder copy];
    _sections = @[];
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [AppColorProvider backgroundColor];
    self.tableView.backgroundColor = [AppColorProvider backgroundColor];
    [self reload];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reload];
    if (_reload_notification_name && !_reload_observer) {
        __weak SettingsListViewController* weak_self = self;
        _reload_observer = [[NSNotificationCenter defaultCenter] addObserverForName:_reload_notification_name object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification* note) {
            [weak_self reload];
        }];
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (_reload_observer) {
        [[NSNotificationCenter defaultCenter] removeObserver:_reload_observer];
        _reload_observer = nil;
    }
}

-(void)reload {
    _sections = _builder ? _builder(self) : @[];
    [self.tableView reloadData];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
    return _sections.count;
}
-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
    return _sections[section].rows.count;
}
-(NSString*)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section {
    return _sections[section].header;
}
-(NSString*)tableView:(UITableView*)tableView titleForFooterInSection:(NSInteger)section {
    return _sections[section].footer;
}

-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
    SettingsRow* row = _sections[indexPath.section].rows[indexPath.row];
    UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    cell.backgroundColor = [AppColorProvider foregroundColor1];
    cell.textLabel.text = row.title;
    cell.textLabel.textColor = row.destructive ? [AppColorProvider alertColor] : [AppColorProvider textColor];
    cell.detailTextLabel.textColor = [AppColorProvider textSecondaryColor];
    if (row.valueProvider) {
        cell.detailTextLabel.text = row.valueProvider();
    }
    if (row.icon) {
        cell.imageView.image = [UIImage systemImageNamed:row.icon];
        cell.imageView.tintColor = row.iconColor ?: [AppColorProvider primaryColor];
    }
    if (row.isOn) {
        UISwitch* toggle = [UISwitch new];
        toggle.on = row.isOn();
        toggle.onTintColor = [AppColorProvider primaryColor];
        void (^setter)(BOOL) = row.setOn;
        [toggle addAction:[UIAction actionWithHandler:^(__kindof UIAction* action) {
            UISwitch* sender = (UISwitch*)action.sender;
            if (setter) setter(sender.isOn);
        }] forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = toggle;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else if (row.showsDisclosure) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    if (!row.action && !row.isOn) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

-(void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SettingsRow* row = _sections[indexPath.section].rows[indexPath.row];
    if (row.action) {
        row.action(self);
    }
}

@end

#pragma mark - Подэкраны

static SettingsListViewController* MakeNotificationsPage(void) {
    return [[SettingsListViewController alloc] initWithTitle:L(@"app.settings.notifications.name", @"Уведомления") builder:^NSArray<SettingsSection*>*(SettingsListViewController* vc) {
        return @[
            MakeSection(nil, L(@"app.settings.notifications.footer", @"Разрешения на уведомления управляются в системных настройках iOS."), @[
                NavRow(L(@"app.settings.notifications.system", @"Системные настройки уведомлений"), @"bell.badge.fill", [UIColor systemPurpleColor], ^(SettingsListViewController* from) {
                    OpenURL(UIApplicationOpenSettingsURLString);
                })
            ])
        ];
    }];
}

static SettingsListViewController* MakeDataControlPage(void) {
    AppSettingsDataController* settings = [[AppDataController sharedInstance] getSettingsController];
    NSArray<NSNumber*>* limits = @[@(50), @(100), @(250), @(500), @(1024)]; // МБ
    return [[SettingsListViewController alloc] initWithTitle:L(@"app.settings.data_control.name", @"Управление данными") builder:^NSArray<SettingsSection*>*(SettingsListViewController* vc) {
        SettingsRow* size_row = ValueRow(L(@"app.settings.data_control.cache_size", @"Занято кэшем изображений"), ^NSString*{
            return FormatBytes((long long)[LoadableImageView imageCacheDiskUsage]);
        }, nil);
        SettingsRow* limit_row = ValueRow(L(@"app.settings.data_control.cache_limit", @"Лимит кэша"), ^NSString*{
            return FormatBytes([settings getMaxCacheSizeBytes]);
        }, ^(SettingsListViewController* from) {
            NSMutableArray<NSString*>* names = [NSMutableArray new];
            NSInteger selected = -1;
            for (NSUInteger i = 0; i < limits.count; i++) {
                long long bytes = limits[i].longLongValue * 1024 * 1024;
                [names addObject:FormatBytes(bytes)];
                if (bytes == [settings getMaxCacheSizeBytes]) selected = (NSInteger)i;
            }
            PresentChoices(from, L(@"app.settings.data_control.cache_limit", @"Лимит кэша"), names, selected, ^(NSInteger index) {
                NSInteger bytes = limits[index].integerValue * 1024 * 1024;
                [settings setMaxCacheSizeBytes:bytes];
                [LoadableImageView setImageCacheDiskLimit:(NSUInteger)bytes];
                [from reload];
            });
        });
        SettingsRow* clear_row = ButtonRow(L(@"app.settings.data_control.clear_cache", @"Очистить кэш изображений"), YES, ^(SettingsListViewController* from) {
            PresentConfirm(from, L(@"app.settings.data_control.clear_cache", @"Очистить кэш изображений"), L(@"app.settings.data_control.clear_cache.message", @"Обложки и картинки будут загружены заново."), L(@"app.settings.data_control.clear", @"Очистить"), ^{
                [LoadableImageView clearImageCache];
                [from reload];
            });
        });
        SettingsRow* history_row = ButtonRow(L(@"app.settings.data_control.clear_history", @"Очистить историю поиска"), YES, ^(SettingsListViewController* from) {
            PresentConfirm(from, L(@"app.settings.data_control.clear_history", @"Очистить историю поиска"), nil, L(@"app.settings.data_control.clear", @"Очистить"), ^{
                AppDataController* data = [AppDataController sharedInstance];
                while ([data getSearchHistoryLength] > 0) {
                    [data removeSearchHistoryItemAtIndex:0];
                }
                [from reload];
            });
        });
        return @[
            MakeSection(L(@"app.settings.data_control.images", @"Изображения"), nil, @[size_row, limit_row, clear_row]),
            MakeSection(L(@"app.settings.data_control.history", @"История"), nil, @[history_row])
        ];
    }];
}

static SettingsListViewController* MakePlaybackPage(void) {
    AppSettingsDataController* settings = [[AppDataController sharedInstance] getSettingsController];
    NSArray<NSString*>* qualities = @[@"360", @"480", @"720", @"1080"];
    NSArray<NSNumber*>* skips = @[@10, @30, @60, @85, @90, @120];
    return [[SettingsListViewController alloc] initWithTitle:L(@"app.settings.playback.name", @"Воспроизведение") builder:^NSArray<SettingsSection*>*(SettingsListViewController* vc) {
        SettingsRow* player_row = ValueRow(L(@"app.settings.playback.player", @"Плеер по умолчанию"), ^NSString*{
            return [settings getDefaultPlayer] == app_settings::Playback::DefaultPlayer::Internal
                ? L(@"app.settings.playback.player.internal", @"Встроенный")
                : L(@"app.settings.playback.player.ask", @"Спрашивать каждый раз");
        }, ^(SettingsListViewController* from) {
            NSArray<NSString*>* names = @[L(@"app.settings.playback.player.ask", @"Спрашивать каждый раз"), L(@"app.settings.playback.player.internal", @"Встроенный")];
            NSInteger selected = (NSInteger)[settings getDefaultPlayer];
            PresentChoices(from, L(@"app.settings.playback.player", @"Плеер по умолчанию"), names, selected, ^(NSInteger index) {
                [settings setDefaultPlayer:static_cast<app_settings::Playback::DefaultPlayer>(index)];
                [from reload];
            });
        });
        SettingsRow* quality_row = ValueRow(L(@"app.settings.playback.quality", @"Предпочитаемое качество"), ^NSString*{
            NSString* q = [settings getPrefferedQuality];
            return q.length ? [q stringByAppendingString:@"p"] : @"—";
        }, ^(SettingsListViewController* from) {
            NSMutableArray<NSString*>* names = [NSMutableArray new];
            for (NSString* q in qualities) [names addObject:[q stringByAppendingString:@"p"]];
            NSInteger selected = (NSInteger)[qualities indexOfObject:[settings getPrefferedQuality] ?: @""];
            if (selected == NSNotFound) selected = -1;
            PresentChoices(from, L(@"app.settings.playback.quality", @"Предпочитаемое качество"), names, selected, ^(NSInteger index) {
                [settings setPrefferedQuality:qualities[index]];
                [from reload];
            });
        });
        SettingsRow* skip_row = ValueRow(L(@"app.settings.playback.skip", @"Время перемотки"), ^NSString*{
            long long seconds = std::chrono::duration_cast<std::chrono::seconds>([settings getDefaultSkipTime]).count();
            return [NSString stringWithFormat:@"%lld %@", seconds, L(@"app.common.seconds_short", @"сек.")];
        }, ^(SettingsListViewController* from) {
            NSMutableArray<NSString*>* names = [NSMutableArray new];
            for (NSNumber* s in skips) [names addObject:[NSString stringWithFormat:@"%@ %@", s, L(@"app.common.seconds_short", @"сек.")]];
            long long current = std::chrono::duration_cast<std::chrono::seconds>([settings getDefaultSkipTime]).count();
            NSInteger selected = (NSInteger)[skips indexOfObject:@(current)];
            if (selected == NSNotFound) selected = -1;
            PresentChoices(from, L(@"app.settings.playback.skip", @"Время перемотки"), names, selected, ^(NSInteger index) {
                [settings setDefaultSkipTime:std::chrono::seconds(skips[index].longLongValue)];
                [from reload];
            });
        });
        SettingsRow* next_row = SwitchRow(L(@"app.settings.playback.auto_next", @"Автоматически следующая серия"), ^BOOL{
            return [settings getAutoNextVideo];
        }, ^(BOOL on) {
            [settings setAutoNextVideo:on];
        });
        SettingsRow* source_row = SwitchRow(L(@"app.settings.playback.remember_source", @"Запоминать источник"), ^BOOL{
            return [settings getRememberSource];
        }, ^(BOOL on) {
            [settings setRememberSource:on];
        });
        SettingsRow* external_row = ValueRow(L(@"app.settings.playback.external", @"Внешний плеер"), ^NSString*{
            return AniLotExternalPlayerName(AniLotExternalPlayerID());
        }, ^(SettingsListViewController* from) {
            NSArray<NSString*>* ids = AniLotExternalPlayerIDs();
            NSMutableArray<NSString*>* names = [NSMutableArray new];
            for (NSString* identifier in ids) {
                [names addObject:AniLotExternalPlayerName(identifier)];
            }
            NSInteger selected = (NSInteger)[ids indexOfObject:AniLotExternalPlayerID()];
            PresentChoices(from, L(@"app.settings.playback.external", @"Внешний плеер"), names, selected, ^(NSInteger index) {
                AniLotSetExternalPlayerID(ids[index]);
                [from reload];
            });
        });
        SettingsRow* resume_row = SwitchRow(L(@"app.settings.playback.resume", @"Запоминать позицию серии"), ^BOOL{
            return AniLotSettingBool(AniLotSettingResumeKey, YES);
        }, ^(BOOL on) {
            AniLotSetSettingBool(AniLotSettingResumeKey, on);
        });
        SettingsRow* skip_buttons_row = SwitchRow(L(@"app.settings.playback.skip_buttons", @"Кнопка пропуска опенинга/эндинга"), ^BOOL{
            return AniLotSettingBool(AniLotSettingSkipButtonsKey, YES);
        }, ^(BOOL on) {
            AniLotSetSettingBool(AniLotSettingSkipButtonsKey, on);
        });
        SettingsRow* auto_skip_row = SwitchRow(L(@"app.settings.playback.auto_skip", @"Автоматически пропускать опенинг/эндинг"), ^BOOL{
            return AniLotSettingBool(AniLotSettingAutoSkipKey, NO);
        }, ^(BOOL on) {
            AniLotSetSettingBool(AniLotSettingAutoSkipKey, on);
        });
        return @[
            MakeSection(nil, nil, @[player_row, quality_row, skip_row]),
            MakeSection(nil, nil, @[next_row, source_row, resume_row]),
            MakeSection(L(@"app.settings.playback.skip.header", @"Опенинги и эндинги"), L(@"app.settings.playback.skip.footer", @"Метки опенингов и эндингов приходят из источника Libria/Liberty. Если меток нет, кнопка перематывает на заданное время."), @[skip_buttons_row, auto_skip_row]),
            MakeSection(L(@"app.settings.playback.external.header", @"Внешний плеер"), L(@"app.settings.playback.external.footer", @"Серия откроется в выбранном приложении. Скачанные серии всегда играют во встроенном плеере."), @[external_row])
        ];
    }];
}

static NSString* DownloadStateText(DownloadItem* item) {
    switch (item.state) {
        case DownloadStateQueued:
            return L(@"app.downloads.state.queued", @"В очереди");
        case DownloadStateDownloading:
            return [NSString stringWithFormat:@"%d%%", (int)(item.progress * 100)];
        case DownloadStateCompleted:
            return L(@"app.downloads.state.done", @"Скачано");
        case DownloadStateFailed:
            return L(@"app.downloads.state.failed", @"Ошибка");
    }
    return @"";
}

static SettingsListViewController* MakeDownloadsPage(void) {
    SettingsListViewController* page = [[SettingsListViewController alloc] initWithTitle:L(@"app.downloads.title", @"Загрузки") builder:^NSArray<SettingsSection*>*(SettingsListViewController* vc) {
        NSArray<DownloadItem*>* items = [[DownloadManager sharedInstance] items];
        if (items.count == 0) {
            return @[MakeSection(nil, L(@"app.downloads.empty", @"Здесь пока пусто. В списке серий проведите по серии влево и нажмите кнопку загрузки."), @[])];
        }
        // группируем серии по аниме
        NSMutableArray<NSNumber*>* order = [NSMutableArray new];
        NSMutableDictionary<NSNumber*, NSMutableArray<DownloadItem*>*>* groups = [NSMutableDictionary new];
        for (DownloadItem* item in items) {
            NSNumber* key = @(item.release_id);
            if (!groups[key]) {
                groups[key] = [NSMutableArray new];
                [order addObject:key];
            }
            [groups[key] addObject:item];
        }
        NSMutableArray<SettingsSection*>* sections = [NSMutableArray new];
        for (NSNumber* key in order) {
            NSArray<DownloadItem*>* group = [groups[key] sortedArrayUsingComparator:^NSComparisonResult(DownloadItem* a, DownloadItem* b) {
                return [@(a.position) compare:@(b.position)];
            }];
            NSString* header = nil;
            for (DownloadItem* item in group) {
                if (item.release_title.length) {
                    header = item.release_title;
                    break;
                }
            }
            if (!header) {
                header = [NSString stringWithFormat:@"%@ #%lld", L(@"app.downloads.release", @"Аниме"), key.longLongValue];
            }
            NSMutableArray<SettingsRow*>* rows = [NSMutableArray new];
            for (DownloadItem* item in group) {
                NSString* title = item.title.length ? item.title : [NSString stringWithFormat:@"%@ %ld", L(@"app.downloads.episode", @"Серия"), item.position];
                [rows addObject:ValueRow(title, ^NSString*{
                    return DownloadStateText(item);
                }, ^(SettingsListViewController* from) {
                    NSArray<NSString*>* names;
                    switch (item.state) {
                        case DownloadStateCompleted:
                            names = @[L(@"app.downloads.watch", @"Смотреть"), L(@"app.downloads.delete", @"Удалить")];
                            break;
                        case DownloadStateFailed:
                            names = @[L(@"app.downloads.retry", @"Повторить"), L(@"app.downloads.delete", @"Удалить")];
                            break;
                        default:
                            names = @[L(@"app.downloads.cancel", @"Отменить загрузку")];
                            break;
                    }
                    NSString* sheet_title = (item.state == DownloadStateFailed && item.error_text.length) ? [NSString stringWithFormat:@"%@\n%@", title, item.error_text] : title;
                    PresentChoices(from, sheet_title, names, -1, ^(NSInteger index) {
                        DownloadManager* manager = [DownloadManager sharedInstance];
                        if (item.state == DownloadStateCompleted && index == 0) {
                            NSString* player_title = item.release_title.length ? [NSString stringWithFormat:@"%@ — %@", item.release_title, item.title ?: @""] : item.title;
                            [[PlayerController sharedInstance] playLocalURL:item.localURL title:player_title resumeKey:item.identifier];
                        } else if (item.state == DownloadStateFailed && index == 0) {
                            [manager downloadReleaseID:static_cast<anixart::ReleaseID>(item.release_id) sourceID:static_cast<anixart::EpisodeSourceID>(item.source_id) position:item.position title:item.title completion:nil];
                        } else {
                            [manager deleteItem:item];
                        }
                    });
                })];
            }
            [sections addObject:MakeSection(header, nil, rows)];
        }
        return sections;
    }];
    page.reload_notification_name = DownloadManagerDidUpdateNotification;
    return page;
}

static SettingsListViewController* MakeHelpPage(void) {
    return [[SettingsListViewController alloc] initWithTitle:L(@"app.settings.help.name", @"Помощь") builder:^NSArray<SettingsSection*>*(SettingsListViewController* vc) {
        return @[
            MakeSection(nil, L(@"app.settings.help.footer", @"При проблемах и идеях создайте issue и максимально подробно опишите вопрос."), @[
                NavRow(L(@"app.settings.help.telegram", @"Telegram-канал"), @"paperplane.fill", [UIColor systemBlueColor], ^(SettingsListViewController* from) {
                    OpenURL(kTelegramURL);
                }),
                NavRow(L(@"app.settings.help.issue", @"Сообщить о проблеме"), @"exclamationmark.bubble.fill", [UIColor systemOrangeColor], ^(SettingsListViewController* from) {
                    OpenURL(kGithubIssuesURL);
                })
            ])
        ];
    }];
}

static SettingsListViewController* MakeAboutPage(void) {
    return [[SettingsListViewController alloc] initWithTitle:L(@"app.settings.about.name", @"О приложении") builder:^NSArray<SettingsSection*>*(SettingsListViewController* vc) {
        NSDictionary* info = [NSBundle mainBundle].infoDictionary;
        NSString* version = [NSString stringWithFormat:@"%@ (%@)", info[@"CFBundleShortVersionString"] ?: @"?", info[@"CFBundleVersion"] ?: @"?"];
        return @[
            MakeSection(nil, L(@"app.settings.about.footer", @"AniLot — неофициальный клиент Anixart для iOS, форк проекта AniAnglia."), @[
                ValueRow(L(@"app.settings.about.version", @"Версия"), ^NSString*{ return version; }, nil),
                NavRow(L(@"app.settings.about.source", @"Исходный код оригинала (AniAnglia)"), @"chevron.left.forwardslash.chevron.right", [UIColor systemGrayColor], ^(SettingsListViewController* from) {
                    OpenURL(kGithubURL);
                })
            ])
        ];
    }];
}

#pragma mark - Главный экран настроек

@interface SettingsViewController ()
@property(nonatomic, strong) SettingsListViewController* list_controller;
@end

@implementation SettingsViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = L(@"app.settings.title", @"Настройки");
    self.view.backgroundColor = [AppColorProvider backgroundColor];

    AppSettingsDataController* settings = [[AppDataController sharedInstance] getSettingsController];

    _list_controller = [[SettingsListViewController alloc] initWithTitle:nil builder:^NSArray<SettingsSection*>*(SettingsListViewController* vc) {
        SettingsRow* alt_row = SwitchRow(L(@"app.settings.alternative_connection.name", @"Альтернативное соединение"), ^BOOL{
            return [settings getAlternativeConnection];
        }, ^(BOOL on) {
            [settings setAlternativeConnection:on];
        });
        return @[
            MakeSection(nil, nil, @[
                NavRow(L(@"app.settings.profile.name", @"Профиль"), @"person.fill", [UIColor systemRedColor], ^(SettingsListViewController* from) {
                    [from.navigationController pushViewController:[SettingsProfileViewController new] animated:YES];
                }),
                NavRow(L(@"app.settings.privacy_and_security.name", @"Приватность и безопасность"), @"lock.fill", [UIColor systemGrayColor], ^(SettingsListViewController* from) {
                    [from.navigationController pushViewController:[SettingsSecurityViewController new] animated:YES];
                })
            ]),
            MakeSection(nil, nil, @[
                NavRow(L(@"app.settings.appearance.name", @"Внешний вид"), @"eye.fill", [UIColor systemIndigoColor], ^(SettingsListViewController* from) {
                    [from.navigationController pushViewController:[SettingsAppearanceViewController new] animated:YES];
                }),
                NavRow(L(@"app.settings.notifications.name", @"Уведомления"), @"bell.fill", [UIColor systemPurpleColor], ^(SettingsListViewController* from) {
                    [from.navigationController pushViewController:MakeNotificationsPage() animated:YES];
                }),
                NavRow(L(@"app.settings.data_control.name", @"Управление данными"), @"externaldrive.fill", [UIColor systemGreenColor], ^(SettingsListViewController* from) {
                    [from.navigationController pushViewController:MakeDataControlPage() animated:YES];
                }),
                NavRow(L(@"app.settings.playback.name", @"Воспроизведение"), @"play.fill", [UIColor systemBlueColor], ^(SettingsListViewController* from) {
                    [from.navigationController pushViewController:MakePlaybackPage() animated:YES];
                }),
                NavRow(L(@"app.downloads.title", @"Загрузки"), @"arrow.down.circle.fill", [UIColor systemTealColor], ^(SettingsListViewController* from) {
                    [from.navigationController pushViewController:MakeDownloadsPage() animated:YES];
                })
            ]),
            MakeSection(nil, L(@"app.settings.alternative_connection.footer", @"Активируйте только если испытываете проблемы с работой приложения, связанные с блокировкой в вашей стране"), @[alt_row]),
            MakeSection(nil, nil, @[
                NavRow(L(@"app.settings.help.name", @"Помощь"), @"questionmark", [UIColor systemGrayColor], ^(SettingsListViewController* from) {
                    [from.navigationController pushViewController:MakeHelpPage() animated:YES];
                }),
                NavRow(L(@"app.settings.about.name", @"О приложении"), @"info.circle.fill", [UIColor systemPinkColor], ^(SettingsListViewController* from) {
                    [from.navigationController pushViewController:MakeAboutPage() animated:YES];
                })
            ])
        ];
    }];

    [self addChildViewController:_list_controller];
    _list_controller.view.frame = self.view.bounds;
    _list_controller.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_list_controller.view];
    [_list_controller didMoveToParentViewController:self];
}

@end
