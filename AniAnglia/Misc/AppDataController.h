//
//  AppDataController.h
//  iOSAnixart
//
//  Created by Toilettrauma on 28.08.2024.
//

#import <Foundation/Foundation.h>

@interface AppDataController : NSObject {
    NSString* _token;
}
@property(nonatomic, retain, setter=setToken:, getter=getToken) NSString* token;

-(instancetype)init;

-(NSString*)getToken;
-(void)setToken:(NSString*)token;
-(NSArray<NSString*>*)getSearchHistory;
-(void)addSearchHistoryItem:(NSString*)item;
-(NSUInteger)getSearchHistoryLength;
-(NSString*)getSearchHistoryItemAtIndex:(NSUInteger)index;

+(instancetype)sharedInstance;
@end

