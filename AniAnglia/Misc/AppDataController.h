//
//  AppDataController.h
//  iOSAnixart
//
//  Created by Toilettrauma on 28.08.2024.
//

#import <Foundation/Foundation.h>

@interface AppDataReleaseTypeObject
@property(nonatomic, retain) NSString* name;
@property(nonatomic) NSInteger id;

+(instancetype)typeFromObject:(NSDictionary*)object;
-(instancetype)initFromObject:(NSDictionary*)object;
-(NSDictionary*)typeToObject;
@end

@interface AppDataController : NSObject {
    NSString* _token;
}

-(instancetype)init;

-(NSString*)getToken;
-(void)setToken:(NSString*)token;

-(NSArray<NSString*>*)getSearchHistory;
-(void)addSearchHistoryItem:(NSString*)item;
-(NSUInteger)getSearchHistoryLength;
-(NSString*)getSearchHistoryItemAtIndex:(NSUInteger)index;
-(NSArray<AppDataReleaseTypeObject*>*)getSavedReleaseTypes:(NSInteger)release_id;

+(instancetype)sharedInstance;
@end

