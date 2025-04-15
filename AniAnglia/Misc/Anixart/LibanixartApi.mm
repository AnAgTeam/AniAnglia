//
//  LibanixartApi.m
//  iOSAnixart
//
//  Created by Toilettrauma on 24.08.2024.
//

#import <Foundation/Foundation.h>
#import "LibanixartApi.h"
#import "AppDataController.h"
#import "StringCvt.h"

@interface LibanixartApi ()
@property(nonatomic, strong) AppDataController* app_data_controller;
@end

@implementation LibanixartApi

-(instancetype)init {
    self = [super init];
    
    NSDictionary* info_dict = [[NSBundle mainBundle] infoDictionary];
    NSString* app_version = [NSString stringWithFormat:@"%@-%@", info_dict[@"CFBundleShortVersionString"], info_dict[@"CFBundleVersion"]];
    
    _app_data_controller = [AppDataController sharedInstance];
    _api = new anixart::Api("ru_RU", "AniAnglia", TO_STDSTRING(app_version));
    _api->set_verbose(false, false);
    _api->set_token(TO_STDSTRING([_app_data_controller getToken]));
    _api->get_session().switch_base_url([[_app_data_controller getSettingsController] getAlternativeConnection]);
    _parsers = new anixart::parsers::Parsers();
    
    return self;
}
-(void)dealloc {
    delete _api;
}

-(anixart::Api*)getApi {
    return _api;
}
-(anixart::parsers::Parsers*)getParsers {
    return _parsers;
}
-(void)performAsyncBlock:(BOOL(^)(anixart::Api* api))block withUICompletion:(void(^)())completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        try {
            BOOL should_call_completion = block(self->_api);
            if (should_call_completion) {
                dispatch_async(dispatch_get_main_queue(), completion);
            }
        }
        catch (anixart::ApiError& e) {
            NSLog(@"Uncatched libanixart api exception: %s", e.what());
        }
        catch (network::JsonError& e) {
            NSLog(@"Uncatched libanixart api json exception: %s", e.what());
        }
        catch (network::UrlSessionError& e) {
            NSLog(@"Uncatched libanixart::UrlSession exception: %s", e.what());
        }
        catch (std::runtime_error& e) {
            NSLog(@"Uncatched libanixart runtime error: %s)", e.what());
        }
    });
}

-(void)setIsAlternativeConnection:(BOOL)is_alternative_connection {
    _api->get_session().switch_base_url(is_alternative_connection);
}

-(NSArray<NSString*>*)getGenresArray {
    return @[
        @"безумие",
        @"боевик",
        @"боевые искусства",
        @"вампиры",
        @"военное",
        @"гарем",
        @"демоны",
        @"детектив",
        @"детское",
        @"дзёсей",
        @"драма",
        @"игры",
        @"исторический",
        @"история",
        @"комедия",
        @"космос",
        @"магия",
        @"машины",
        @"меха",
        @"мистика",
        @"музыка",
        @"музыкальный",
        @"научная фантастика",
        @"пародия",
        @"повседневность",
        @"полиция",
        @"приключения",
        @"психологическое",
        @"романтика",
        @"самураи",
        @"сверхъестественное",
        @"сейнен",
        @"спорт",
        @"супер сила",
        @"сёдзё",
        @"сёдзё-ай",
        @"сёнен",
        @"сёнен-ай",
        @"триллер",
        @"ужасы",
        @"фантастика",
        @"фэнтези",
        @"школа",
        @"экшен",
        @"этти"
    ];
}

-(NSArray<NSString*>*)getStudiosArray {
    return @[
        @"A-1 Pictures",
        @"A.C.G.T",
        @"ACTAS, Inc",
        @"ACiD FiLM",
        @"AIC A.S.T.A",
        @"AIC PLUS",
        @"AIC Spirits",
        @"AIC",
        @"Animac",
        @"ANIMATE",
        @"Aniplex",
        @"ARMS",
        @"Artland",
        @"ARTMIC Studios",
        @"Asahi Production",
        @"Asia-Do",
        @"ASHI",
        @"Asread",
        @"Asmik Ace",
        @"Aubeck",
        @"BM Entertainment",
        @"Bandai Visua",
        @"Barnum Studio",
        @"Bee Train",
        @"BeSTACK",
        @"Blender Foundation",
        @"Bones",
        @"Brains Base",
        @"Bridge",
        @"Cinema Citrus",
        @"Chaos Project",
        @"Cherry Lips",
        @"David Production",
        @"Daume",
        @"Doumu",
        @"Dax International",
        @"DLE INC",
        @"Digital Frontier",
        @"Digital Works",
        @"Diomedea",
        @"DIRECTIONS Inc",
        @"Dogakobo",
        @"Dofus",
        @"Encourage Films",
        @"Feel",
        @"Fifth Avenue",
        @"Five Ways",
        @"Fuji TV",
        @"Foursome",
        @"GRAM Studio",
        @"G&G Entertainment",
        @"Gainax",
        @"GANSIS",
        @"Gathering",
        @"Gonzino",
        @"Gonzo",
        @"GoHands",
        @"Green Bunny",
        @"Group TAC",
        @"Hal Film Maker",
        @"Hasbro Studios",
        @"h.m.p",
        @"Himajin",
        @"Hoods Entertainment",
        @"Idea Factory",
        @"J.C.Staff",
        @"KANSAI",
        @"Kaname Production",
        @"Kitty Films",
        @"Knack",
        @"Kokusai Eigasha",
        @"KSS (студия)",
        @"Kyoto Animation",
        @"Lemon Heart",
        @"LMD",
        @"Madhouse Studios",
        @"Magic Bus",
        @"Manglobe Inc.",
        @"Manpuku Jinja",
        @"MAPPA",
        @"Milky",
        @"Minamimachi Bugyosho",
        @"Media Blasters",
        @"Mook Animation",
        @"Moonrock",
        @"MOVIC",
        @"Mushi Productions",
        @"Natural High",
        @"Nippon Animation",
        @"Nomad",
        @"Lerche",
        @"OB Planning",
        @"Office AO",
        @"Ordet",
        @"Oriental Light and Magic",
        @"OLM Inc.",
        @"P.A. Works",
        @"Palm Studio",
        @"Pastel",
        @"Phoenix Entertainment",
        @"Picture Magic",
        @"Pink",
        @"Pink Pineapple",
        @"Planet",
        @"Plum",
        @"PPM",
        @"Primastea",
        @"Production I.G",
        @"Project No.9",
        @"Radix",
        @"Rikuentai",
        @"Robot",
        @"Satelight",
        @"Seven",
        @"Seven Arcs",
        @"Shaft",
        @"Silver Link",
        @"Shinei Animation",
        @"Shogakukan Music & Digital Entertainment",
        @"Soft on Demand",
        @"Starchild Records",
        @"Studio 9 Maiami",
        @"Studio Tulip",
        @"Studio 4°C",
        @"Studio e.go!",
        @"Studio A.P.P.P",
        @"Studio Barcelona",
        @"Studio Blanc",
        @"Studio Comet",
        @"Studio Deen",
        @"Studio Fantasia",
        @"Studio Flag",
        @"Studio Gallop",
        @"Studio Ghibli",
        @"Studio Guts",
        @"Studio Gokumi",
        @"Studio Rikka",
        @"Studio Hibari",
        @"Studio Junio",
        @"Studio Khara",
        @"Studio Live",
        @"Studio Matrix",
        @"Studio Pierrot",
        @"Studio Egg",
        @"Sunrise",
        @"Synergy SP",
        @"Synergy Japan",
        @"Tatsunoko Production",
        @"Tele-Cartoon Japan",
        @"Telecom Animation Film",
        @"Tezuka Productions",
        @"The Answer Studio",
        @"TMS",
        @"TNK",
        @"Toei Animation",
        @"Tokyo Kids",
        @"TYO Animations",
        @"Transarts",
        @"Triangle Staff",
        @"Trinet Entertainment",
        @"Ufotable",
        @"Vega Entertainment",
        @"Victor Entertainment",
        @"Viewworks",
        @"White Fox",
        @"Wonder Farm",
        @"XEBEC-M2",
        @"Xebec",
        @"Yumeta Company",
        @"Zexcs",
        @"Zuiyo Eizo",
        @"8bit"
    ];
}

+(instancetype)sharedInstance {
    static LibanixartApi* shared_instance = nil;
    static dispatch_once_t once_token;
    dispatch_once(&once_token, ^{
        shared_instance = [LibanixartApi new];
    });
    return shared_instance;
}

@end
