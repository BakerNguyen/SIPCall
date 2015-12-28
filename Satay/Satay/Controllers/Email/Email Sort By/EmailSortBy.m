//
//  EmailSortBy.m
//  Satay
//
//  Created by Arpana Sakpal on 3/18/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import "EmailSortBy.h"

@interface EmailSortBy ()

@property (strong, nonatomic) NSDictionary *optionsDict;
@property (strong, nonatomic) NSArray *sortingTypes;
@end

@implementation EmailSortBy

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.hidesBackButton = YES;
    
    self.view.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.7];
    
    self.tblSortByEmail.scrollEnabled = NO;
    self.tblSortByEmail.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self initSortingOptionData];
}

- (void)closeViewEmailKeeping
{
    
    self.view.hidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITableView
////////////////////////////////////////////////////////////////////////////////////

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //if (indexPath.row == 6)
    //return 268;
    return 60;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.self.tblSortByEmail deselectRowAtIndexPath:indexPath animated:YES];

    NSInteger n = indexPath.row;
    
    
    NSUInteger previousSelectedRow = [self.sortingTypes indexOfObject:@(self.sortingType)];
    
    if (previousSelectedRow != n)
    {
        // Uncheck the previous row
        UITableViewCell *previousCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:previousSelectedRow
                                                                                            inSection:0]];
        previousCell.accessoryType = UITableViewCellAccessoryNone;
        
        // Mark current cell checked
        UITableViewCell *currentCell = [tableView cellForRowAtIndexPath:indexPath];
        currentCell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        // Notify the delegate about the changing of sorting type value
        NSNumber *sortTypeNumber = [self.sortingTypes objectAtIndex:indexPath.row];
        self.sortingType = [sortTypeNumber intValue];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(sortingTypeDidChange:)])
        {
            [self.delegate sortingTypeDidChange:self.sortingType];
        }
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"CellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell.
    cell.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1];
    
    NSNumber *sortTypeNumber = [self.sortingTypes objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [self.optionsDict objectForKey:sortTypeNumber];
    
    // Check if the cell is the current selected cell
    EmailSortingType sortingType = (EmailSortingType)[[self.sortingTypes objectAtIndex:indexPath.row] integerValue];
    if (sortingType == self.sortingType) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}


#pragma mark - Initilize Sorting Options Data
- (void)initSortingOptionData
{
    self.optionsDict = @{
                         @(EmailSortingTypeDateASC) : POPUP_MOST_RECENT ,
                         @(EmailSortingTypeDateDESC) :  POPUP_OLDEST,
                         @(EmailSortingTypeSenderASC) :  POPUP_SENDER_A_TO_Z,
                         @(EmailSortingTypeSenderDESC) :  POPUP_SENDER_Z_TO_A,
                         @(EmailSortingTypeSubjectASC) :  POPUP_SUBJECT_A_TO_Z,
                         @(EmailSortingTypeSubjectDESC) : POPUP_SUBJECT_Z_TO_A
                         };
    
    self.sortingTypes = [[self.optionsDict allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2];
    }];
}

@end
