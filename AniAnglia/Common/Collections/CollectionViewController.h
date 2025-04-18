//
//  CollectionViewController.h
//  AniAnglia
//
//  Created by Toilettrauma on 18.04.2025.
//

#ifndef CollectionViewController_h
#define CollectionViewController_h

#import <UIKit/UIKit.h>
#import "LibanixartApi.h"

@interface CollectionViewController : UIViewController

-(instancetype)initWithCollectionID:(anixart::CollectionID)collection_id;
@end


#endif /* CollectionViewController_h */
