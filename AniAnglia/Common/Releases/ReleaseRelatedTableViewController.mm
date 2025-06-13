//
//  ReleasesRelatedTableViewController.m
//  AniAnglia
//
//  Created by Toilettrauma on 13.06.2025.
//

#import <Foundation/Foundation.h>
#import "ReleaseRelatedTableViewController.h"
#import "LoadableView.h"
#import "StringCvt.h"
#import "AppColor.h"

@interface ReleaseRelatedTableViewCell ()
@property(nonatomic, retain) LoadableImageView* image_view;
@property(nonatomic, retain) UILabel* title_label;
@property(nonatomic, retain) UILabel* year_label;
@property(nonatomic, retain) UILabel* rating_label;
@property(nonatomic, retain) UILabel* category_label;

@end

@interface ReleaseRelatedTableViewController ()

@end

@implementation ReleaseRelatedTableViewCell

+(NSString*)getIdentifier {
    return @"ReleaseRelatedTableViewCell";
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuse_identifier {
    self = [super initWithStyle:style reuseIdentifier:reuse_identifier];
    
    [self setup];
    [self setupLayout];
    
    return self;
}

-(void)setup {
    _image_view = [LoadableImageView new];
    _image_view.clipsToBounds = YES;
    _image_view.layer.cornerRadius = 2;
    
    _title_label = [UILabel new];
    _title_label.numberOfLines = 2;
    
    _year_label = [UILabel new];
    _rating_label = [UILabel new];
    _category_label = [UILabel new];
    
    [self addSubview:_image_view];
    [self addSubview:_title_label];
    [self addSubview:_year_label];
    [self addSubview:_rating_label];
    [self addSubview:_category_label];
    
    _image_view.translatesAutoresizingMaskIntoConstraints = NO;
    _title_label.translatesAutoresizingMaskIntoConstraints = NO;
    _year_label.translatesAutoresizingMaskIntoConstraints = NO;
    _rating_label.translatesAutoresizingMaskIntoConstraints = NO;
    _category_label.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_image_view.topAnchor constraintEqualToAnchor:self.layoutMarginsGuide.topAnchor],
        [_image_view.leadingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.leadingAnchor],
        [_image_view.heightAnchor constraintEqualToAnchor:self.layoutMarginsGuide.heightAnchor],
        [_image_view.widthAnchor constraintEqualToAnchor:self.layoutMarginsGuide.heightAnchor multiplier:(10. / 16)],
        
        [_title_label.topAnchor constraintEqualToAnchor:self.layoutMarginsGuide.topAnchor],
        [_title_label.leadingAnchor constraintEqualToAnchor:_image_view.trailingAnchor constant:5],
        [_title_label.trailingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
        
        [_year_label.topAnchor constraintEqualToAnchor:_title_label.bottomAnchor],
        [_year_label.leadingAnchor constraintEqualToAnchor:_image_view.trailingAnchor constant:5],

        [_rating_label.topAnchor constraintEqualToAnchor:_title_label.bottomAnchor],
        [_rating_label.leadingAnchor constraintEqualToAnchor:_year_label.trailingAnchor constant:5],

        [_category_label.topAnchor constraintEqualToAnchor:_title_label.bottomAnchor],
        [_category_label.leadingAnchor constraintEqualToAnchor:_rating_label.trailingAnchor constant:5],
        [_category_label.trailingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.trailingAnchor]
    ]];
    
    [_title_label sizeToFit];
    [_year_label sizeToFit];
    [_rating_label sizeToFit];
    [_category_label sizeToFit];
}

-(void)setupLayout {
    _image_view.backgroundColor = [AppColorProvider foregroundColor1];
    _title_label.textColor = [AppColorProvider textColor];
    _year_label.textColor = [AppColorProvider textSecondaryColor];
    _rating_label.textColor = [AppColorProvider textSecondaryColor];
    _category_label.textColor = [AppColorProvider textSecondaryColor];
}

-(void)setImageUrl:(NSURL*)url {
    [_image_view tryLoadImageWithURL:url];
}
-(void)setTitle:(NSString*)title {
    _title_label.text = title;
}
-(void)setYear:(NSString*)year {
    _year_label.text = year;
}
-(void)setRating:(NSString*)rating {
    _rating_label.text = rating;
}
-(void)setCategory:(NSString*)category {
    _category_label.text = category;
}
@end

@implementation ReleaseRelatedTableViewController

-(void)tableViewDidLoad {
    [self.tableView registerClass:ReleaseRelatedTableViewCell.class forCellReuseIdentifier:[ReleaseRelatedTableViewCell getIdentifier]];
}

-(CGFloat)tableView:(UITableView*)table_view heightForRowAtIndexPath:(NSIndexPath*)index_path {
    return 100;
}

-(UITableViewCell*)tableView:(UITableView*)table_view cellForRowAtIndexPath:(NSIndexPath*)index_path withRelease:(anixart::Release::Ptr)release {
    ReleaseRelatedTableViewCell* cell = [table_view dequeueReusableCellWithIdentifier:[ReleaseRelatedTableViewCell getIdentifier] forIndexPath:index_path];
    NSURL* image_url = [NSURL URLWithString:TO_NSSTRING(release->image_url)];
    NSInteger rating = round(release->grade * 10) / 10;
    NSString* category = [ReleasesPageableDataProvider getCategoryNameFor:release->category];
    
    [cell setImageUrl:image_url];
    [cell setTitle:TO_NSSTRING(release->title_ru)];
    [cell setYear:TO_NSSTRING(release->year)];
    [cell setRating:[@(rating) stringValue]];
    [cell setCategory:category];
    
    return cell;
}

@end
