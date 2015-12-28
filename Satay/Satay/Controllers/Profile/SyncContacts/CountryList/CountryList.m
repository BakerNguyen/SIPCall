//
//  CountryList.m
//  KryptoChat
//
//  Created by ENCLAVEIT on 1/16/15.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import "CountryList.h"


@implementation CountryList{
    
 NSArray *tableData;

}

@synthesize tblCountryList;
@synthesize checkedIndexPath;
@synthesize ISOCountryCode, countryCode, countryName, dialCode, allCountries;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self getCountries];
    
    tblCountryList.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
    [tblCountryList setDelegate:self];
    [tblCountryList setDataSource:self];
    [tblCountryList setBackgroundColor:COLOR_247247247];
    [tblCountryList setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    self.navigationItem.title = TITLE_COUNTRY_LIST;
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem createLeftButtonTitle:_BACK Target:self Action:@selector(backAction)];
    
    [tblCountryList reloadData];
    
}

- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)getCountries{

    allCountries  = [[ContactFacade share] getAllCountries];
    
}


////////////////////////////////////////////////////////////////////////////////////
#pragma mark UITableView
////////////////////////////////////////////////////////////////////////////////////

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
	return 1;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // Checked the selected row
    if (self.checkedIndexPath) {
        UITableViewCell *uncheckCell = [tableView cellForRowAtIndexPath:self.checkedIndexPath];
        uncheckCell.accessoryType = UITableViewCellAccessoryNone;
    }
    if ([self.checkedIndexPath isEqual:indexPath]) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else{
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        self.checkedIndexPath = indexPath;
        // Return country name and country code
        countryName = cell.textLabel.text;
        
        NSArray *countriesWithCountryCodesDialCodes = [[ContactFacade share] getAllCountriesWithCountryCodesAndDialCodes];
        
        for (NSDictionary *country in countriesWithCountryCodesDialCodes) {
            if ([[country objectForKey:kCOUNTRY_NAME] isEqualToString:countryName]) {
                dialCode = [country objectForKey:kDIAL_CODE];
                countryCode = [country objectForKey:kCOUNTRY_CODE];
            }
        }
        

    }
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex{
    return [allCountries count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView
                             dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell.
    cell.textLabel.text = [allCountries
                           objectAtIndex:[indexPath row]];
    
    if ([cell.textLabel.text isEqualToString:countryName]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        self.checkedIndexPath = indexPath;
    }
    else{
       cell.accessoryType = UITableViewCellAccessoryNone;
    }

    
    return cell;
    
    
}


@end
