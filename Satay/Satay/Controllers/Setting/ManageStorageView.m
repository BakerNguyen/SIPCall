//
//  ManageStorageView.m
//  Satay
//
//  Created by Nghia (William) T. VO on 5/18/15.
//  Copyright (c) 2015 enclave. All rights reserved.
//

#import "ManageStorageView.h"

@interface ManageStorageView ()
{
    UIButton* btnSelectAll;
    NSMutableArray* chatBoxList;
    NSMutableArray* selectedchatBoxList;
    unsigned long long totalOfSelectFileSize;
    BOOL isSelectAll;
    NSByteCountFormatter *byteCountFormatter;
}
@end

@implementation ManageStorageView

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = TITLE_MANAGE_STORAGE;
    self.navigationItem.leftBarButtonItem=[UIBarButtonItem createLeftButtonTitle:_BACK
                                                                          Target:self
                                                                          Action:@selector(backToSetting)];
    
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem createRightButtonTitle:_SELECT_ALL Target:self Action:@selector(selectAll)];
    
    // Do any additional setup after loading the view from its nib.
    _tblStorage.delegate = self;
    _tblStorage.dataSource = self;
    
    byteCountFormatter = [[NSByteCountFormatter alloc] init];
    byteCountFormatter.countStyle = NSByteCountFormatterCountStyleFile;
    byteCountFormatter.adaptive = NO;
    
    selectedchatBoxList = [NSMutableArray new];
    [ChatFacade share].manageStorageDelegate = self;
    _tblStorage.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
}

-  (void)viewWillAppear:(BOOL)animated
{
    totalOfSelectFileSize = 0;
    isSelectAll = NO;
    
    [self loadDeleteButton];
    [self loadChatRoom];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Button Action
- (void) selectAll
{
    if (isSelectAll)
    {
        isSelectAll = NO;
        self.navigationItem.rightBarButtonItem = [UIBarButtonItem createRightButtonTitle:_SELECT_ALL Target:self Action:@selector(selectAll)];
        _btnDelete.hidden = YES;
        [selectedchatBoxList removeAllObjects];
        totalOfSelectFileSize = 0;
    }
    else
    {
        isSelectAll = YES;
        self.navigationItem.rightBarButtonItem = [UIBarButtonItem createRightButtonTitle:_UNSELECT_ALL Target:self Action:@selector(selectAll)];
        totalOfSelectFileSize = 0;
        for (ChatBox *chatBox in chatBoxList)
        {
            totalOfSelectFileSize += [[ChatFacade share] getAmountOfMediaFileSize:chatBox];
        }
        _btnDelete.hidden = NO;
        [_btnDelete setButtonTitle:[NSString stringWithFormat:_DELETE_RECLAIM, [byteCountFormatter stringFromByteCount:totalOfSelectFileSize]]];
        selectedchatBoxList = [chatBoxList mutableCopy];
    }
    [self fixTableViewWithBtnDelete:_btnDelete.hidden];
    [_tblStorage reloadData];
}

- (void) backToSetting
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) deleteSelectedMediaFile
{
    CAlertView *alert = [CAlertView new];
    NSMutableArray *buttonsName  = [NSMutableArray arrayWithObjects:ALERT_BUTTON_CANCEL, ALERT_BUTTON_DELETE, nil];
    [alert showInfo_2btn:_ALERT_DELETE_MEDIA ButtonsName:buttonsName];
    [alert setOnButtonTouchUpInside:^(CAlertView *alertView, int buttonIndex)
     {
         if(buttonIndex == 1) //delete
         {
             [[ChatFacade share] deleteStorage:selectedchatBoxList];
         }
     }];
}

#pragma mark - UITableView Datasource, Delegate
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return chatBoxList.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"ManageStorageCell";
    ManageStorageCell* cell = [_tblStorage dequeueReusableCellWithIdentifier:cellID];
    
    if (!cell)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellID owner:self options:nil];
        cell = (ManageStorageCell*)[nib objectAtIndex:0];
    }
    ChatBox *chatBox = chatBoxList[indexPath.row];
    if (chatBox.isGroup)
    {
        GroupObj *groupObj = [[AppFacade share] getGroupObj:chatBox.chatboxId];
        cell.lblChatRoomName.text = [[ChatFacade share] getGroupName:chatBox.chatboxId];
        cell.imageChatRoomAvatar.image = [[ChatFacade share] updateGroupLogo:groupObj.groupId];
    }
    else
    {
        Contact* contact = [[ContactFacade share] getContact:chatBox.chatboxId];
        cell.lblChatRoomName.text = [[ContactFacade share] getContactName:chatBox.chatboxId];
        cell.imageChatRoomAvatar.image = [[ContactFacade share] updateContactAvatar:contact.avatarURL];
    }
    cell.totalBypeSize = [[ChatFacade share] getAmountOfMediaFileSize:chatBox];
    cell.lblChatRoomSize.text = [byteCountFormatter stringFromByteCount:cell.totalBypeSize];
    
    if ([selectedchatBoxList containsObject:chatBox])
    {
        [cell.btnSelectedChatRoom setImage:[UIImage imageNamed:IMG_C_B_TICK] forState:UIControlStateNormal];
    }
    else
    {
        [cell.btnSelectedChatRoom setImage:[UIImage imageNamed:IMG_C_B_UNTICK] forState:UIControlStateNormal];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ManageStorageCell* cell =  (ManageStorageCell*)[tableView cellForRowAtIndexPath:indexPath];
    ChatBox *selectedChatBox = [chatBoxList objectAtIndex:indexPath.row];
    
    if ([selectedchatBoxList containsObject:selectedChatBox])
    { // Unselect case.
        [cell.btnSelectedChatRoom setImage:[UIImage imageNamed:IMG_C_B_UNTICK] forState:UIControlStateNormal];
        totalOfSelectFileSize = totalOfSelectFileSize - cell.totalBypeSize;
        [selectedchatBoxList removeObject:selectedChatBox];
    }
    else
    { //Select case.
        [cell.btnSelectedChatRoom setImage:[UIImage imageNamed:IMG_C_B_TICK] forState:UIControlStateNormal];
        totalOfSelectFileSize = totalOfSelectFileSize + cell.totalBypeSize;
        [selectedchatBoxList addObject:selectedChatBox];
    }
    [_btnDelete setButtonTitle:[NSString stringWithFormat:_DELETE_RECLAIM, [byteCountFormatter stringFromByteCount:totalOfSelectFileSize]]];
    // handle the select all case.
    if ([selectedchatBoxList count] == 0)
    {
        _btnDelete.hidden = YES;
        isSelectAll = NO;
        self.navigationItem.rightBarButtonItem = [UIBarButtonItem createRightButtonTitle:_SELECT_ALL Target:self Action:@selector(selectAll)];
    }
    else
    {
        _btnDelete.hidden = NO;
        
        if ([selectedchatBoxList count] == chatBoxList.count)
        {
            isSelectAll = YES;
            self.navigationItem.rightBarButtonItem = [UIBarButtonItem createRightButtonTitle:_UNSELECT_ALL Target:self Action:@selector(selectAll)];
        }
        else
        {
            isSelectAll = NO;
            self.navigationItem.rightBarButtonItem = [UIBarButtonItem createRightButtonTitle:_SELECT_ALL Target:self Action:@selector(selectAll)];
        }
    }
    [self fixTableViewWithBtnDelete:_btnDelete.hidden];
    cell.backgroundColor = [UIColor whiteColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
}
#pragma mark - Other Action
- (void) fixTableViewWithBtnDelete:(BOOL)isHidden
{
    if (!isHidden)
        [_tblStorage changeWidth:_tblStorage.width Height:[UIScreen mainScreen].bounds.size.height - _btnDelete.height];
    else
        [_tblStorage changeWidth:_tblStorage.width Height:[UIScreen mainScreen].bounds.size.height];
}
- (void) deleteStorageSuccees
{
    NSString *alertMessage = [NSString stringWithFormat:_ALERT_DELETE_STORAGE_SUCCESS, [byteCountFormatter stringFromByteCount:totalOfSelectFileSize]];
    [[CAlertView new] showInfo:alertMessage];
    totalOfSelectFileSize = 0;
    [selectedchatBoxList removeAllObjects];
    [self loadChatRoom];
    _btnDelete.hidden = YES;
    [self fixTableViewWithBtnDelete:_btnDelete.hidden];
}

- (void) loadChatRoom
{
    chatBoxList = [[ChatFacade share] getChatBoxHasMedia];
    if (chatBoxList.count > 0)
    {
        self.navigationItem.rightBarButtonItem = [UIBarButtonItem createRightButtonTitle:_SELECT_ALL Target:self Action:@selector(selectAll)];
        _lblStorageClear.hidden = YES;
    }
    else
    {
        [self.navigationItem setRightBarButtonItem:nil];
        _lblStorageClear.hidden = NO;
    }
    [_tblStorage reloadData];
}

- (void) loadDeleteButton
{
    _btnDelete.isAddButton = NO;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(deleteSelectedMediaFile)];
    tap.delegate = self;
    [_btnDelete addGestureRecognizer:tap];
    [_btnDelete.btnAddRequest addTarget:self
                                 action:@selector(deleteSelectedMediaFile)
                       forControlEvents:UIControlEventTouchUpInside];
    
    _btnDelete.btnAddRequest.layer.borderColor = COLOR_24317741.CGColor;
    
    _btnDelete.hidden = YES;
    [self.view addSubview:_btnDelete];
    [self.view bringSubviewToFront:_btnDelete];
    [self fixTableViewWithBtnDelete:_btnDelete.hidden];
    [_tblStorage reloadData];
}
@end
