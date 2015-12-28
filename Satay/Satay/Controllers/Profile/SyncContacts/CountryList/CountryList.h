//
//  CountryList.h
//  KryptoChat
//
//  Created by ENCLAVEIT on 1/16/15.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CountryList : UIViewController<UITableViewDelegate, UITableViewDataSource>{
    NSIndexPath *checkedIndexPath;
}

@property (strong, nonatomic) IBOutlet UITableView *tblCountryList;
@property (nonatomic,retain) NSIndexPath *checkedIndexPath;


@property (nonatomic, retain) NSString* ISOCountryCode;
@property (nonatomic, retain) NSString* countryName;
@property (nonatomic, retain) NSString* countryCode;
@property (nonatomic, retain) NSString* dialCode;
@property (nonatomic, retain) NSArray* allCountries;


-(void) getCountries;

@end
