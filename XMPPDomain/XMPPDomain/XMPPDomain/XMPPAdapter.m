//
//  XMPPAdapter.m
//  XMPPDomain
//
//  Created by Daniel Nguyen on 12/30/14.
//  Copyright (c) 2014 mTouche. All rights reserved.
//

#import "XMPPAdapter.h"
#import "XMPPDomainFields.h"
#import "Base64.h"
#import "NSData+XMPP.h"
#import "NSString+Utils.h"
#import "XMPPManager.h"
#import "MUCManager.h"
#import "DDLog_XMPP.h"
#import "DDASLLogger_XMPP.h"
#import "DDTTYLogger_XMPP.h"
#import "XMPPvCardTemp.h"
#import "XMPPvCardTemp+ContactDisplayName.h"
#import "JSONHelper_XMPP.h"

// Definitions for Error Handling
#define kXMPP_ERROR_DOMAIN                      @"XMPPDomainError"
#define kXMPP_ERROR_CODE_HOST_NOT_FOUND         1404
#define kXMPP_ERROR_CODE_GENERAL                1401
#define kXMPP_STREAM_ERROR_DOMAIN               @"XMPPStreamError"
#define kXMPP_STREAM_CODE_NOTAUTHENTICATE       1401
#define kXMPP_STREAM_CODE_INVALID_PARAMETERS    1001
#define kXMPP_MUC_ERROR_DOMAIN                  @"XMPPMUCError"
#define kXMPP_MUC_CODE_INVALID_PARAMETERS       1002

// for logging
#ifdef DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_ERROR;
#endif

enum XMPPUpdateElement: NSInteger {
    kXMPP_UPDATE_FLAG_AVATAR,
    kXMPP_UPDATE_FLAG_DISPLAYNAME,
    kXMPP_UPDATE_FLAG_NONE
};
typedef enum XMPPUpdateElement XMPPUpdateFlag;

enum XMPPUpdatePresence: NSInteger {
    kXMPP_PRESENCE_UPDATE_FLAG_STATUS,
    kXMPP_PRESENCE_UPDATE_FLAG_NONE
};
typedef enum XMPPUpdatePresence XMPPUpdatePresenceFlag;

enum XMPPChatState: NSInteger {
    kXMPP_CHAT_STATE_ACTIVE,
    kXMPP_CHAT_STATE_COMPOSING,
    kXMPP_CHAT_STATE_PAUSED,
};
typedef enum XMPPChatState XMPPChatStateFlag;

enum XMPPConnectState: NSInteger {
    XMPP_CONNECT_STATE_CONNECTED,
    XMPP_CONNECT_STATE_DISCONNECTED
};
typedef enum XMPPConnectState XMPPConnectStateFlag;

@interface XMPPAdapter()
{
    NSString *XMPP_HOST_NAME;
    NSString *XMPP_MUC_HOST_NAME;
    NSString *XMPP_PORT_NUMBER;
    NSString *XMPP_RESOURCE;
    
    NSString *userJID;
    NSString *password;
    NSString *displayname;
    XMPPvCardTemp *myvCard;
    
    BOOL customCertEvaluation;
    BOOL isXmppConnected;
    
    NSMutableDictionary *tempRoomCreating;
}

@property (nonatomic, strong, readwrite) NSString *currentJID;
@property (nonatomic, readwrite) XMPPUpdateFlag xmppUpdateFlag;
@property (nonatomic, readwrite) XMPPUpdatePresenceFlag xmppUpdatePresenceFlag;
@property (nonatomic, readwrite) XMPPConnectStateFlag xmppConnectStateFlag;
@property (nonatomic, strong) NSMutableArray *arrFriendsList;
@property (nonatomic, strong) NSMutableArray *arrSubsRequestList;
@property (nonatomic, strong) NSMutableArray *arrPenddingList;
@property (nonatomic, strong) NSMutableDictionary *tempRoomCreating;

- (void)setupXMPPStream;

@end

@implementation XMPPAdapter

static id _instance;
@synthesize fileTransfer;
@synthesize xmppStream;
@synthesize xmppCapabilities;
@synthesize xmppCapabilitiesStorage;
@synthesize xmppReconnect;
@synthesize xmppRoster;
@synthesize xmppRosterStorage;
@synthesize xmppRosterMemoryStorage;
@synthesize xmppvCardAvatarModule;
@synthesize xmppvCardTempModule;
@synthesize xmppAutoPing, xmppPing;
@synthesize xmppLastActivity, xmppMDR;
@synthesize xmppMUC;
@synthesize xmppSM;
@synthesize delegate;
@synthesize currentJID;
@synthesize xmppUpdateFlag, xmppUpdatePresenceFlag, xmppConnectStateFlag;
@synthesize arrFriendsList, arrSubsRequestList, arrPenddingList, tempRoomCreating;

void (^requestCompleteCallBack)(BOOL success, NSString *message ,NSDictionary *response, NSError *error);

+ (XMPPAdapter *)share
{
    static dispatch_once_t once;
    static XMPPAdapter * share;
    dispatch_once(&once, ^{
        share = [self instanceWithDefaultConfig];
    });
    return share;
}

+ (id)instanceWithDefaultConfig
{
    @synchronized (self)
    {
        if (!_instance) {
            _instance = [[self alloc] initWithDefaultConfig];
            
            setenv("XcodeColors", "YES", 0);
            
            [DDLog_XMPP addLogger:[DDASLLogger_XMPP sharedInstance]];
            [DDLog_XMPP addLogger:[DDTTYLogger_XMPP sharedInstance]];
            
            [[DDTTYLogger_XMPP sharedInstance] setColorsEnabled:YES];
            [[DDTTYLogger_XMPP sharedInstance] setForegroundColor:[UIColor greenColor] backgroundColor:nil forFlag:LOG_FLAG_INFO];
            [[DDTTYLogger_XMPP sharedInstance] setForegroundColor:[UIColor redColor] backgroundColor:nil forFlag:LOG_FLAG_ERROR];
            [[DDTTYLogger_XMPP sharedInstance] setForegroundColor:[UIColor orangeColor] backgroundColor:nil forFlag:LOG_FLAG_WARN];
            [[DDTTYLogger_XMPP sharedInstance] setForegroundColor:[UIColor cyanColor] backgroundColor:nil forFlag:LOG_FLAG_VERBOSE];
        }
    }
    
    return _instance;
}

+ (id)instanceWithConfig:(NSDictionary *)configInfo
{
    @synchronized (self)
    {
        if (!_instance) {
            _instance = [[self alloc] initWithConfig:configInfo];
            
            setenv("XcodeColors", "YES", 0);
            
            [DDLog_XMPP addLogger:[DDASLLogger_XMPP sharedInstance]];
            [DDLog_XMPP addLogger:[DDTTYLogger_XMPP sharedInstance]];
            
            [[DDTTYLogger_XMPP sharedInstance] setColorsEnabled:YES];
            [[DDTTYLogger_XMPP sharedInstance] setForegroundColor:[UIColor greenColor] backgroundColor:nil forFlag:LOG_FLAG_INFO];
            [[DDTTYLogger_XMPP sharedInstance] setForegroundColor:[UIColor redColor] backgroundColor:nil forFlag:LOG_FLAG_ERROR];
            [[DDTTYLogger_XMPP sharedInstance] setForegroundColor:[UIColor orangeColor] backgroundColor:nil forFlag:LOG_FLAG_WARN];
            [[DDTTYLogger_XMPP sharedInstance] setForegroundColor:[UIColor cyanColor] backgroundColor:nil forFlag:LOG_FLAG_VERBOSE];
        }
    }
    
    return _instance;
}

- (void)reConfigXMPP:(NSDictionary *)configInfo
{
    XMPP_HOST_NAME      = [configInfo valueForKey:kXMPP_HOST_NAME];
    XMPP_MUC_HOST_NAME  = [configInfo valueForKey:kXMPP_MUC_HOST_NAME];
    XMPP_PORT_NUMBER    = [configInfo valueForKey:kXMPP_PORT_NUMBER];
    XMPP_RESOURCE       = [configInfo valueForKey:kXMPP_RESOURCE];
    
    if (!xmppStream) {
        [self setupXMPPStream];
    } else {
        [xmppStream setHostName:XMPP_HOST_NAME];
        [xmppStream setHostPort:[XMPP_PORT_NUMBER integerValue]];
    }
}

- (NSDictionary *)getCurrentConfig
{
    NSMutableDictionary *m = [[NSMutableDictionary alloc] init];
    [m setObject:XMPP_HOST_NAME forKey:kXMPP_HOST_NAME];
    [m setObject:XMPP_MUC_HOST_NAME forKey:kXMPP_MUC_HOST_NAME];
    [m setObject:XMPP_PORT_NUMBER forKey:kXMPP_PORT_NUMBER];
    [m setObject:XMPP_RESOURCE forKey:kXMPP_RESOURCE];
    
    return m;
}

- (id)initWithDefaultConfig
{
    self = [super init];
    
    if (self) {
        NSString *resourceStr = [[NSString stringWithFormat:@"%@_IOS_%@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"], [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]] uppercaseString];
        XMPP_HOST_NAME      = @"ssim.mtouche-mobile.com";
        XMPP_MUC_HOST_NAME  = @"conference.ssim.mtouche-mobile.com";
        XMPP_PORT_NUMBER    = @"5222";
        XMPP_RESOURCE       = resourceStr;//app_name + IOS + version
        
        [self setupXMPPStream];
        tempRoomCreating = [NSMutableDictionary new];
    }
    
    return self;
}

- (id)initWithConfig:(NSDictionary *)configInfo
{
    self = [super init];
    if (self) {
        XMPP_HOST_NAME      = [configInfo valueForKey:kXMPP_HOST_NAME];
        XMPP_MUC_HOST_NAME  = [configInfo valueForKey:kXMPP_MUC_HOST_NAME];
        XMPP_PORT_NUMBER    = [configInfo valueForKey:kXMPP_PORT_NUMBER];
        XMPP_RESOURCE       = [configInfo valueForKey:kXMPP_RESOURCE];
        
        [self setupXMPPStream];
    }
    
    return self;
}

- (BOOL)isConnected
{
    return [xmppStream isConnected];
}

- (BOOL)isConnecting
{
    return [xmppStream isConnecting];
}

- (BOOL)isDisconnected
{
    return [xmppStream isDisconnected];
}

- (BOOL)connectWithInfo:(NSDictionary *)userInfo
{
    // fire the delegate xmppDomainWillConnect to app layer
    [delegate xmppDomainWillConnect:self];
    
    if (!userInfo) {
        NSMutableDictionary* details = [NSMutableDictionary dictionary];
        [details setValue:@"Please enter the jid and password" forKey:NSLocalizedDescriptionKey];
        NSError *err = [NSError errorWithDomain:kXMPP_STREAM_ERROR_DOMAIN code:kXMPP_STREAM_CODE_INVALID_PARAMETERS userInfo:details];
        [delegate xmppDomainDidFailLogIn:self withError:err];
        return NO;
    }
    
    NSString *jid       = [userInfo objectForKey:kXMPP_USER_JID];
    NSString *jpassword = [userInfo objectForKey:kXMPP_USER_PASSWORD];
    
    self.currentJID = [NSString stringWithFormat:@"%@@%@", jid, XMPP_HOST_NAME];
    
    if ([self isConnected]) {
        [delegate xmppDomainDidConnect:self];
        return YES;
    }
    
    if (jid == nil || jpassword == nil) {
        NSMutableDictionary* details = [NSMutableDictionary dictionary];
        [details setValue:@"Please enter the jid and password" forKey:NSLocalizedDescriptionKey];
        NSError *err = [NSError errorWithDomain:kXMPP_STREAM_ERROR_DOMAIN code:kXMPP_STREAM_CODE_INVALID_PARAMETERS userInfo:details];
        [delegate xmppDomainDidFailLogIn:self withError:err];
        return NO;
    }
    
    
    [xmppStream setMyJID:[XMPPJID jidWithUser:jid domain:XMPP_HOST_NAME resource:XMPP_RESOURCE]];
    password = jpassword;
    userJID = jid;
    
    NSError *error = nil;
    
    if (![xmppStream connectWithTimeout:10.f error:&error])
    {
        DDLogError(@"XXXX2: ERROR");
        [delegate xmppDomainDidDisconnect:self withError:error];
        
        return NO;
    }
    
    return YES;
}

- (void)connectTimeOut
{
    [self goOffline];
}

- (BOOL)connect {
    
    // fire the delegate xmppDomainWillConnect to app layer
    [delegate xmppDomainWillConnect:self];
    
    if (!xmppStream) {
        [self setupXMPPStream];
    }
    
    // get Username and Password
    NSString *jabberID = userJID;
    
    
    if (jabberID == nil){
        return NO;
    }
    
    if (![xmppStream isDisconnected]){
        return YES;
    }
    
    [xmppStream setMyJID:[XMPPJID jidWithUser:userJID domain:XMPP_HOST_NAME resource:XMPP_RESOURCE]];
    
    NSError *error = nil;
    
    if (![xmppStream connectWithTimeout:10.f error:&error])
    {
        DDLogError(@"XXXX3: ERROR");
        [delegate xmppDomainDidDisconnect:self withError:error];
        
        return NO;
    }
    
    return YES;
}

- (void)disconnect
{
    [self goOffline];
    [xmppStream disconnect];
}

- (void)reconnectXMPP
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (![xmppStream isConnected]) {
            // fire the delegate xmppDomainWillConnect to app layer
            [delegate xmppDomainWillConnect:self];
            
            [self connect];
        }
    });
}

- (void)setupXMPPStream
{
    NSAssert(xmppStream == nil, @"Method setupStream invoked multiple times");
    
    if (!xmppStream) {
        xmppStream = [[XMPPStream alloc] init];
    }
    
#if !TARGET_IPHONE_SIMULATOR
    {
        xmppStream.enableBackgroundingOnSocket = YES;
    }
#endif
    xmppUpdateFlag = kXMPP_UPDATE_FLAG_NONE;
    xmppUpdatePresenceFlag = kXMPP_PRESENCE_UPDATE_FLAG_NONE;
    
    if (!arrFriendsList) {
        arrFriendsList = [[NSMutableArray alloc] init];
    }
    [arrFriendsList removeAllObjects];
    
    if (!arrSubsRequestList) {
        arrSubsRequestList = [[NSMutableArray alloc] init];
    }
    [arrSubsRequestList removeAllObjects];
    
    if (!arrPenddingList) {
        arrPenddingList = [[NSMutableArray alloc] init];
    }
    [arrPenddingList removeAllObjects];
    
    xmppReconnect           = [[XMPPReconnect alloc] init];
    xmppReconnect.reconnectDelay = 5.0f;
    
    xmppRosterStorage       = [[XMPPRosterCoreDataStorage alloc] init];
    xmppRosterMemoryStorage = [[XMPPRosterMemoryStorage alloc] init];
    xmppRoster              = [[XMPPRoster alloc] initWithRosterStorage:xmppRosterMemoryStorage];
    xmppRoster.autoFetchRoster = YES;
    xmppRoster.autoAcceptKnownPresenceSubscriptionRequests = YES;
    
    xmppAutoPing                = [[XMPPAutoPing alloc] init];
    xmppAutoPing.pingInterval   = 30.f;
    xmppAutoPing.pingTimeout    = 30.f;
    xmppAutoPing.respondsToQueries = YES;
    
    //xmppPing                    = [[XMPPPing alloc] init];
    //xmppPing.respondsToQueries  = YES;
    
    xmppMUC             = [[XMPPMUC alloc] init];
    
    xmppLastActivity    = [[XMPPLastActivity alloc] init];
    
    xmppvCardStorage        = [XMPPvCardCoreDataStorage sharedInstance];
    xmppvCardTempModule     = [[XMPPvCardTempModule alloc] initWithvCardStorage:xmppvCardStorage];
    xmppvCardAvatarModule   = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:xmppvCardTempModule];
    
    xmppCapabilitiesStorage = [XMPPCapabilitiesCoreDataStorage sharedInstance];
    xmppCapabilities        = [[XMPPCapabilities alloc] initWithCapabilitiesStorage:xmppCapabilitiesStorage];
    
    xmppCapabilities.autoFetchHashedCapabilities = YES;
    xmppCapabilities.autoFetchNonHashedCapabilities = NO;
    
    fileTransfer = [XMPPIncomingFileTransfer new];
    [fileTransfer activate:xmppStream];
    [fileTransfer addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [fileTransfer setAutoAcceptFileTransfers:YES];
    
    xmppMDR = [[XMPPMessageDeliveryReceipts alloc] initWithDispatchQueue:dispatch_get_main_queue()];
    xmppMDR.autoSendMessageDeliveryReceipts = YES;
    xmppMDR.autoSendMessageDeliveryRequests = YES;
    
    XMPPStreamManagementMemoryStorage *xmppSMMS = [[XMPPStreamManagementMemoryStorage alloc] init];
    xmppSM = [[XMPPStreamManagement alloc] initWithStorage:xmppSMMS dispatchQueue:dispatch_get_main_queue()];
    [xmppSM setAutoResume:YES];
    
    [xmppSM                 activate:xmppStream];
    [xmppReconnect          activate:xmppStream];
    [xmppRoster             activate:xmppStream];
    [xmppvCardTempModule    activate:xmppStream];
    [xmppvCardAvatarModule  activate:xmppStream];
    [xmppCapabilities       activate:xmppStream];
    [xmppAutoPing           activate:xmppStream];
    //[xmppPing               activate:xmppStream];
    [xmppLastActivity       activate:xmppStream];
    [xmppMUC                activate:xmppStream];
    [xmppMDR                activate:xmppStream];
    
    [xmppSM                 addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [xmppStream             addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [xmppReconnect          addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [xmppRoster             addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [xmppAutoPing           addDelegate:self delegateQueue:dispatch_get_main_queue()];
    //[xmppPing               addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [xmppLastActivity       addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [xmppMUC                addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [xmppvCardAvatarModule  addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [xmppvCardTempModule    addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    [xmppStream setHostName:XMPP_HOST_NAME];
    [xmppStream setHostPort:[XMPP_PORT_NUMBER integerValue]];
    
    [xmppStream setStartTLSPolicy:XMPPStreamStartTLSPolicyAllowed];
    
    // You may need to alter these settings depending on the server you're connecting to
    customCertEvaluation = YES;
}

- (void)teardownStream
{
    [xmppStream         removeDelegate:self];
    [xmppRoster         removeDelegate:self];
    [fileTransfer       removeDelegate:self];
    [xmppAutoPing       removeDelegate:self];
    [xmppMUC            removeDelegate:self];
    [xmppLastActivity   removeDelegate:self];
    
    [xmppReconnect         deactivate];
    [xmppRoster            deactivate];
    [xmppvCardTempModule   deactivate];
    [xmppvCardAvatarModule deactivate];
    [xmppCapabilities      deactivate];
    [fileTransfer          deactivate];
    
    [xmppStream disconnect];
    
    xmppStream = nil;
    xmppReconnect = nil;
    xmppRoster = nil;
    xmppRosterStorage = nil;
    xmppvCardStorage = nil;
    xmppvCardTempModule = nil;
    xmppvCardAvatarModule = nil;
    xmppCapabilities = nil;
    xmppCapabilitiesStorage = nil;
}

#pragma mark - XMPPStream Delegate
- (void)xmppStream:(XMPPStream *)sender socketDidConnect:(GCDAsyncSocket *)socket
{
    DDLogInfo(@"%s", __PRETTY_FUNCTION__);
}

- (void)xmppStream:(XMPPStream *)sender willSecureWithSettings:(NSMutableDictionary *)settings
{
    DDLogInfo(@"%s", __PRETTY_FUNCTION__);
    
    NSString *expectedCertName = [xmppStream.myJID domain];
    if (expectedCertName) {
        [settings setObject:expectedCertName forKey:(NSString *)kCFStreamSSLPeerName];
    }
    
    if (customCertEvaluation) {
        [settings setObject:@(YES) forKey:GCDAsyncSocketManuallyEvaluateTrust];
    }
}

- (void)xmppStream:(XMPPStream *)sender didReceiveTrust:(SecTrustRef)trust completionHandler:(void (^)(BOOL))completionHandler
{
    DDLogInfo(@"%s", __PRETTY_FUNCTION__);
    
    dispatch_queue_t bgQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(bgQueue, ^{
        SecTrustResultType result = kSecTrustResultDeny;
        OSStatus status = SecTrustEvaluate(trust, &result);
        
        if (status == noErr && (result == kSecTrustResultProceed || result == kSecTrustResultUnspecified)) {
            completionHandler(YES);
        } else {
            completionHandler(NO);
        }
    });
}

- (void)xmppStreamDidSecure:(XMPPStream *)sender
{
    DDLogInfo(@"%s %@", __PRETTY_FUNCTION__, sender);
}

- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    DDLogInfo(@"%s %@", __PRETTY_FUNCTION__, sender);
    xmppConnectStateFlag = XMPP_CONNECT_STATE_CONNECTED;
    [delegate xmppDomainDidConnect:self];
    isXmppConnected = YES;
    
    NSError *error = nil;
    
    if (![[self xmppStream] authenticateWithPassword:password error:&error]) {
        DDLogError(@"Error authenticating: %@", error);
        [delegate xmppDomainDidFailLogIn:self withError:error];
    }
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    DDLogVerbose(@"%s %@", __PRETTY_FUNCTION__, sender);
    [xmppvCardTempModule fetchvCardTempForJID:[xmppStream myJID]];
    [delegate xmppDomainDidSuccessLogIn:self];
    
    [xmppSM enableStreamManagementWithResumption:YES maxTimeout:0];
    [xmppSM automaticallySendAcksAfterStanzaCount:5 orTimeout:20];
    [xmppSM automaticallyRequestAcksAfterStanzaCount:5 orTimeout:20];
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error
{
    if (error) {
        DDLogError(@"%s %@", __PRETTY_FUNCTION__, error);
        NSMutableDictionary* details = [NSMutableDictionary dictionary];
        [details setValue:@"Could not authenticate you" forKey:NSLocalizedDescriptionKey];
        // populate the error object with the details
        NSError *err = [NSError errorWithDomain:kXMPP_STREAM_ERROR_DOMAIN code:kXMPP_STREAM_CODE_NOTAUTHENTICATE userInfo:details];
        [delegate xmppDomainDidFailLogIn:self withError:err];
    }
    [self disconnect];
}

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
    DDLogVerbose(@"%s %@", __PRETTY_FUNCTION__, [iq XMLString]);
    if ([iq isMUCIQ]) {
        //DDLogInfo(@"%s %@", __PRETTY_FUNCTION__, [iq XMLString]);
    }
    
    if ([iq isErrorIQ]) {
        if ([iq isMUCIQ]) {
            /*
             <iq xmlns="jabber:client" from="155277483acf02155277483acf8c@conference.snim.mtouche-mobile.com" to="lu7t9og34@snim.mtouche-mobile.com/iOS_TEST" type="error" id="2A137507-90A3-46CC-861E-38DB7CF1B990"><query xmlns="http://jabber.org/protocol/muc#owner"/><error code="404" type="cancel"><item-not-found xmlns="urn:ietf:params:xml:ns:xmpp-stanzas"/><text xmlns="urn:ietf:params:xml:ns:xmpp-stanzas">Conference room does not exist</text></error></iq>
             */
            NSXMLElement *err = [iq childErrorElement];
            /*
            <error code="404" type="cancel">
                <item-not-found xmlns="urn:ietf:params:xml:ns:xmpp-stanzas"/>
                <text xmlns="urn:ietf:params:xml:ns:xmpp-stanzas">Conference room does not exist</text>
            </error>
             */
            NSInteger code = [err attributeIntValueForName:@"code"];
            NSMutableDictionary* details = [NSMutableDictionary dictionary];
            [details setObject:[err attributeStringValueForName:@"code"] forKey:@"code"];
            [details setObject:[err attributeStringValueForName:@"type"] forKey:@"type"];
            [details setValue:[[err elementForName:@"text"] stringValue] forKey:NSLocalizedDescriptionKey];
            NSError *error = [NSError errorWithDomain:kXMPP_MUC_ERROR_DOMAIN code:code userInfo:details];
            
            [delegate xmppDomainDidFailCreateRoom:error];
            
            return NO;
        }
        
        NSXMLElement *pingError = [iq elementForName:@"ping" xmlns:@"urn:xmpp:ping"];
        if (pingError)
        {
            //
        }
        
        if ([iq isLastActivityQuery])
        {
            // no need logging here, this for LastActivity response
        }
        
        NSXMLElement *vCardError = [iq elementForName:@"vCard" xmlns:@"vcard-temp"];
        if (vCardError) {
            NSXMLElement *errorElement = [iq childErrorElement];
            switch (xmppUpdateFlag) {
                case kXMPP_UPDATE_FLAG_AVATAR:
                {
                    if ([delegate respondsToSelector:@selector(xmppDomainDidFailUpdateOwnAvatar:)]) {
                        NSMutableDictionary *m = [[NSMutableDictionary alloc] init];
                        [m setObject:errorElement forKey:kXMPP_ERROR];
                        [delegate xmppDomainDidFailUpdateOwnAvatar:m];
                    }
                }
                    break;
                    
                case kXMPP_UPDATE_FLAG_DISPLAYNAME:
                {
                    if ([delegate respondsToSelector:@selector(xmppDomainDidFailUpdateOwnDisplayname:)]) {
                        NSMutableDictionary *m = [[NSMutableDictionary alloc] init];
                        [m setObject:errorElement forKey:kXMPP_ERROR];
                        [delegate xmppDomainDidFailUpdateOwnDisplayname:m];
                    }
                }
                    break;
                    
                default:
                    break;
            }
        }
    }
    
    // for display name
    XMPPElement *ele = (XMPPElement *)[iq elementForName:@"vCard"];
    if (ele != nil) {
        if ([[iq fromStrWithoutResource] isEqualToString:currentJID]) {
            myvCard = [XMPPvCardTemp vCardTempFromElement:ele];
        }
        
        NSMutableDictionary *m = [[NSMutableDictionary alloc] init];
        [m setObject:[iq fromStrWithoutResource] forKey:kXMPP_USER_JID];
        NSString *domain = [iq fromDomain];
        NSString *jidKind = ([domain isEqualToString:XMPP_HOST_NAME]) ? kXMPP_JID_KIND_S : kXMPP_JID_KIND_MUC;
        [m setObject:jidKind forKey:kXMPP_JID_KIND];
        if (![domain isEqualToString:XMPP_HOST_NAME]) {
            [m setObject:[iq XMLString] forKey:@"more_detail"];
        }
        
        XMPPvCardTemp *vCardTemp = [XMPPvCardTemp vCardTempFromElement:ele];
        
        NSString *mkid = [vCardTemp getMaskingID];
        NSString *dn = [vCardTemp getDisplayName];
        
        if (dn) {
            [m setObject:dn forKey:kXMPP_USER_DISPLAYNAME];
        }
        
        if (mkid) {
            [m setObject:mkid forKey:kXMPP_USER_MASKING_ID];
        }
        
        if ([delegate respondsToSelector:@selector(xmppDomain:didReceiveProfileInfo:)]) {
            [delegate xmppDomain:self didReceiveProfileInfo:m];
        }
    }
    
    XMPPElement *vCardPhotoElement = (XMPPElement *)[[iq elementForName:@"vCard"] elementForName:@"PHOTO"];
    if (vCardPhotoElement != nil) {
        // avatar data
        NSString *base64DataString = [[vCardPhotoElement elementForName:@"BINVAL"] stringValue];
        NSData *imageData = [NSData dataWithBase64EncodedString:base64DataString];   // you need to get NSData BASE64 category
        
        NSString *senderJID = [iq fromStrWithoutResource];
        BOOL isMyself = ([senderJID isEqualToString:currentJID]) ? TRUE : FALSE;
        NSNumber *isMe = @(isMyself);
        NSMutableDictionary *m = [[NSMutableDictionary alloc] init];
        [m setObject:[iq fromStrWithoutResource] forKey:kAVATAR_TARGET_JID];
        [m setObject:imageData forKey:kAVATAR_IMAGE_DATA];
        [m setObject:isMe forKey:kAVATAR_IS_ME];
        
        if ([delegate respondsToSelector:@selector(xmppDomain:didReceiveAvatar:)]) {
            [delegate xmppDomain:self didReceiveAvatar:m];   // this is my custom delegate method where I save new avatar to cache
        }
    }
    
    if ([TURNSocket isNewStartTURNRequest:iq]) {
        DDLogVerbose(@"IS NEW TURN request..");
        TURNSocket *turnSocket = [[TURNSocket alloc] initWithStream:[self xmppStream] incomingTURNRequest:iq];
        //        [turnSockets addObject:turnSocket];
        [turnSocket startWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    
    if ([iq isResultIQ]) {
        //
        return NO;
    }
    
//    DDLogVerbose(@"%s %@", __PRETTY_FUNCTION__, [iq XMLString]);
    
    return NO;
}

- (void)xmppStream:(XMPPStream *)sender didSendIQ:(XMPPIQ *)iq
{
    DDLogInfo(@"%s %@",__PRETTY_FUNCTION__, [iq XMLString]);
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    // for templ check body of message
    NSDictionary *bodyDic = (NSDictionary *)[JSONHelper_XMPP decodeJSONToObject:[message body]];
    if (bodyDic) {
        /*
        if ([[bodyDic objectForKey:kXMPP_BODY_MESSAGE_TYPE] isEqualToString:kSUB_BODY_MT_IDEN_XCHANGE_ADD]) {
            // message for add friend request, fire delegate to app layer
            [xmppRoster fetchRoster];
            if ([delegate respondsToSelector:@selector(xmppDomainDidReceiveAddFriendRequest:)]) {
                NSString *msg = [message body];
                NSString *from = [message fromStrWithoutResource];
                
                NSMutableDictionary *m = [[NSMutableDictionary alloc] init];
                [m setObject:msg forKey:kXMPP_SUBSCRIPTION_BODY];
                [m setObject:from forKey:kXMPP_FROM_JID];
                
                [delegate xmppDomainDidReceiveAddFriendRequest:m];
                return;
            }
        }
        
        if ([[bodyDic objectForKey:kXMPP_BODY_MESSAGE_TYPE] isEqualToString:kSUB_BODY_MT_IDEN_XCHANGE_APPROVE]) {
            // message for approve friend request, fire delegate to app layer
            if ([delegate respondsToSelector:@selector(xmppDomainDidReceiveAddFriendApproved:)]) {
                NSString *msg = [message body];
                NSString *from = [message fromStrWithoutResource];
                
                NSMutableDictionary *m = [[NSMutableDictionary alloc] init];
                [m setObject:msg forKey:kXMPP_SUBSCRIPTION_BODY];
                [m setObject:from forKey:kXMPP_FROM_JID];
                
                [delegate xmppDomainDidReceiveAddFriendApproved:m];
                return;
            }
        }
        
        if ([[bodyDic objectForKey:kXMPP_BODY_MESSAGE_TYPE] isEqualToString:kSUB_BODY_MT_IDEN_XCHANGE_DENY]) {
            // message for deny friend request, fire delegate to app layer
            //<message xmlns="jabber:client" from="f4dce13bog@satay.mooo.com/KRYPTO_IOS_1.0" to="qlv8940w@satay.mooo.com" type="chat" id="Er2LUOz8"><body>{"mt":"iden_xchange_deny","ct":""}</body><request xmlns="urn:xmpp:receipts"/></message>
            if ([delegate respondsToSelector:@selector(xmppDomainDidReceiveAddFriendDenied:)]) {
                NSString *from = [message fromStrWithoutResource];
                
                NSDictionary *m = @{kXMPP_FROM_JID: from};
                
                [delegate xmppDomainDidReceiveAddFriendDenied:m];
                return;
            }
        }
        
        if ([[bodyDic objectForKey:kXMPP_BODY_MESSAGE_TYPE] isEqualToString:kSUB_BODY_MT_IDEN_XCHANGE_DELETE]) {
            if ([delegate respondsToSelector:@selector(xmppDomainDidDeletedFriendFromJID:)]) {
                NSString *from = [message fromStrWithoutResource];
                
                [delegate xmppDomainDidDeletedFriendFromJID:from];
                return;
            }
        }
        
        if ([[bodyDic objectForKey:kXMPP_BODY_MESSAGE_TYPE] isEqualToString:kSUB_BODY_MT_IDEN_XCHANGE_DONE]) {
            // message for approved friend
            [xmppRoster fetchRoster];
            if ([delegate respondsToSelector:@selector(xmppDomainDidApprovedFromFriend:)]) {
                NSString *from = [message fromStrWithoutResource];
                
                NSMutableDictionary *m = [[NSMutableDictionary alloc] init];
                [m setObject:from forKey:kXMPP_FROM_JID];
                
                [delegate xmppDomainDidApprovedFromFriend:m];
                return;
            }
        }
        */
        
        if ([[bodyDic objectForKey:kXMPP_BODY_MESSAGE_TYPE] isEqualToString:kXMPP_BODY_MESSAGE_TYPE_TEXT]) {
            if ([xmppMUC isMUCRoomMessage:message]) {
                NSDictionary *messageMUCInfo = [[MUCManager share] processGroupMessage:message];
                if (messageMUCInfo) {
                    if ([delegate respondsToSelector:@selector(xmppDomain:didReceiveMUCMessage:)]) {
                        [delegate xmppDomain:self didReceiveMUCMessage:messageMUCInfo];
                        return;
                    }
                }
            } else {
                if (![message body]) {
                    return;// no body, no deal
                }
                NSString *msg = [message body];
                NSString *from = [message fromStrWithoutResource];
                NSString *strID = [[message attributeForName:@"id"] stringValue] ? [[message attributeForName:@"id"] stringValue] : @"";
                
                NSMutableDictionary *m = [[NSMutableDictionary alloc] init];
                [m setObject:msg forKey:kTEXT_MESSAGE_BODY];
                [m setObject:from forKey:kTEXT_MESSAGE_FROM];
                [m setObject:strID forKey:kTEXT_MESSAGE_ID];
                [m setObject:@"chat" forKey:kTEXT_MESSAGE_TYPE];
                
                if ([message wasDelayed] && [message delayedDeliveryDate])
                {
                    [m setObject:[message delayedDeliveryDate] forKey:kTEXT_MESSAGE_DELAYED_DATE];
                }
                
                if ([delegate respondsToSelector:@selector(xmppDomain:didReceiveMessage:)]) {
                    [delegate xmppDomain:self didReceiveMessage:m];
                    return;
                }
            }
        }
    }
    
    // handle error message
    if ([message isErrorMessage]) {
        NSDictionary *errorInfo = [[XMPPManager share] handleErrorWhenSendMessage:message];
        if (errorInfo) {
            if ([delegate respondsToSelector:@selector(xmppDomain:didReceiveMessageError:)]) {
                [delegate xmppDomain:self didReceiveMessageError:errorInfo];
            }
            DDLogError(@"%s %@\n%@", __PRETTY_FUNCTION__, message, errorInfo);
            return;
        }
    }
    
    // handle receipt message
    if ([message hasReceiptResponse] && ![message hasChatState] && ![message hasVcardUpdateAvatar] && ![message hasVcardUpdateDisplayname] && ![xmppMUC isMUCRoomMessage:message]) {
        NSDictionary *receiptResponseInfo = [[XMPPManager share] handleReceiptResponseMessage:message];
        if (receiptResponseInfo) {
            if ([delegate respondsToSelector:@selector(xmppDomain:didReceiveReceiptResponse:)]) {
                [delegate xmppDomain:self didReceiveReceiptResponse:receiptResponseInfo];
            }
        }
    }
    
    if ([message hasReceiptRequest] && ![message hasVcardUpdateAvatar] && ![message hasVcardUpdateDisplayname] && ![xmppMUC isMUCRoomMessage:message]) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^(void) {
            XMPPMessage *receipt = [message generateReceiptResponse];
            [xmppStream sendElement:receipt];
            return;
        }];
    }
    
    // handle vcard update
    NSMutableDictionary *m = [[NSMutableDictionary alloc] init];
    BOOL isUpdateV = NO;
    if ([message hasVcardUpdateAvatar]) {
        isUpdateV = YES;
    }
    if ([message hasVcardUpdateDisplayname]) {
        /*
        XMPPvCardTemp *vCardTemp = [xmppvCardTempModule vCardTempForJID:[message from] shouldFetch:YES];
        if ([vCardTemp getDisplayName]) {
            [m setObject:[vCardTemp getDisplayName] forKey:kXMPP_USER_DISPLAYNAME];
        }
         */
        isUpdateV = YES;
    }
    
    if (isUpdateV) {
        [m setObject:[message fromStrWithoutResource] forKey:kXMPP_USER_JID];
        if ([message wasDelayed] && [message delayedDeliveryDate]) {
            [m setObject:[message delayedDeliveryDate] forKey:kTEXT_MESSAGE_DELAYED_DATE];
        }
        
        if ([delegate respondsToSelector:@selector(xmppDomainDidReceiverVcardUpdate:)]) {
            [delegate xmppDomainDidReceiverVcardUpdate:m];
        }
    }
    
    // handle single message
    if ([message isChatMessageWithBody] && ![xmppMUC isMUCRoomMessage:message])
    {
        DDLogVerbose(@"%s %@", __PRETTY_FUNCTION__, [message XMLString]);
        NSDictionary *messageInfo = [[XMPPManager share] handleChatTextMessage:message];
        if (messageInfo) {
            if ([delegate respondsToSelector:@selector(xmppDomain:didReceiveMessage:)]) {
                [delegate xmppDomain:self didReceiveMessage:messageInfo];
                return;
            }
        }
    }
    
    // handle MUC message
    if ([xmppMUC isMUCRoomMessage:message]) {
        DDLogVerbose(@"%s %@", __PRETTY_FUNCTION__, [message XMLString]);
        NSDictionary *messageMUCInfo = [[MUCManager share] processGroupMessage:message];
        if (messageMUCInfo) {
            if ([delegate respondsToSelector:@selector(xmppDomain:didReceiveMUCMessage:)]) {
                [delegate xmppDomain:self didReceiveMUCMessage:messageMUCInfo];
                return;
            }
        }
    }
    
    // handle chat state message
    NSDictionary *dicUserInfo = [[XMPPManager share] handleChatStateMessage:message];
    if (dicUserInfo) {
        if ([delegate respondsToSelector:@selector(xmppDomain:didReceiveChatState:)]) {
            [delegate xmppDomain:self didReceiveChatState:dicUserInfo];
            return;
        }
    }
}

- (void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message
{
    if ([message hasChatState] || [message hasReceiptResponse] || [message hasVcardUpdateAvatar] || [message hasVcardUpdateDisplayname]) {
        return;
    }
    
    if ([message isGroupInvite]) {
        /*
         <message to="cjintswzxxzsmfe8xg5tzlsbk@conference.satay.mooo.com"><x xmlns="http://jabber.org/protocol/muc#user"><invite to="nh5cgo@satay.mooo.com"><reason>Join me :)</reason></invite></x></message>
         */
        DDLogVerbose(@"%s %@ %@", __PRETTY_FUNCTION__, sender, message);
        
        NSString *roomjid = [message toStrWithoutResource];
        
        NSDictionary *roomInfo = @{kMUC_ROOM_JID: roomjid,
                                   kXMPP_TO_JID: [message inviteToJID]
                                   };
        
        if ([delegate respondsToSelector:@selector(xmppDomain:didInviteToChatRoom:)]) {
            [delegate xmppDomain:self didInviteToChatRoom:roomInfo];
        }
        
        return;
    }
    
    DDLogVerbose(@"%s %@ %@", __PRETTY_FUNCTION__, sender, message);
    
    NSMutableDictionary *m = [[NSMutableDictionary alloc] init];
    NSString *strID = [[message attributeForName:@"id"] stringValue] ? [[message attributeForName:@"id"] stringValue] : @"";
    [m setObject:strID forKey:kTEXT_MESSAGE_ID];
    [m setObject:kMESSAGE_STATUS_SENT forKey:kMESSAGE_STATUS];
    if ([delegate respondsToSelector:@selector(xmppDomain:didSendMessage:)]) {
        [delegate xmppDomain:self didSendMessage:m];
    }
}

- (void)xmppStream:(XMPPStream *)sender didSendCustomElement:(DDXMLElement *)element
{
    DDLogVerbose(@"%s %@ %@", __PRETTY_FUNCTION__, sender, element);
}

- (void)xmppStream:(XMPPStream *)sender didReceiveCustomElement:(NSXMLElement *)element
{
    DDLogVerbose(@"%s %@ %@", __PRETTY_FUNCTION__, sender, element);
}

- (void)xmppStream:(XMPPStream *)sender didFailToSendMessage:(XMPPMessage *)message error:(NSError *)error
{
    if ([message hasChatState] || [message hasReceiptResponse]) {
        return;
    }
    
    DDLogError(@"%s %@ %@ %@", __PRETTY_FUNCTION__, sender, message, error);
    
    NSMutableDictionary *m = [[NSMutableDictionary alloc] init];
    NSString *strID = [[message attributeForName:@"id"] stringValue] ? [[message attributeForName:@"id"] stringValue] : @"";
    [m setObject:strID forKey:kTEXT_MESSAGE_ID];
    [m setObject:kMESSAGE_STATUS_SEND_FAILED forKey:kMESSAGE_STATUS];
    [m setObject:error forKey:kTEXT_MESSAGE_ERROR];
    if ([delegate respondsToSelector:@selector(xmppDomain:didFailToSendMessage:)]) {
        [delegate xmppDomain:self didFailToSendMessage:m];
    }
    
    // try to resend this message
    // <message type="chat" to="qlv8940w@satay.mooo.com" from="f4dce13bog@satay.mooo.com" id="pOYpXSw1"><body>{"mt":"iden_xchange_deny","ct":""}</body></message>
    NSString* toUser = [message toStr];
    NSString* fromUser = currentJID;
    NSString* msgID = [message elementID];
    NSString* messageBody = [message body];
    
    if ([toUser isEqualToString:@""] || [messageBody isEqualToString:@""]) {
        return;
    }
    
    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
    [body setStringValue:messageBody];
    
    NSXMLElement *messageElement = [NSXMLElement elementWithName:@"message"];
    [messageElement addAttributeWithName:@"type" stringValue:@"chat"];
    [messageElement addAttributeWithName:@"to" stringValue:toUser];
    [messageElement addAttributeWithName:@"from" stringValue:fromUser];
    [messageElement addAttributeWithName:@"id" stringValue:msgID];
    [messageElement addChild:body];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([self isConnected]) {
            [xmppStream sendElement:messageElement];
        } else {
            if ([self connect]) {
                [xmppStream sendElement:messageElement];
            }
        }
    });
}

- (XMPPPresence *)xmppStream:(XMPPStream *)sender willSendPresence:(XMPPPresence *)presence
{
    /*
    if ([[presence type] isEqualToString:@"subscribe"]) {
        presence.type = @"available";
    }
    */
    return presence;
}

- (void)xmppStream:(XMPPStream *)sender didSendPresence:(XMPPPresence *)presence
{
    DDLogVerbose(@"%s %@", __PRETTY_FUNCTION__, presence);
}

- (void)xmppStream:(XMPPStream *)sender didFailToSendPresence:(XMPPPresence *)presence error:(NSError *)error
{
    DDLogVerbose(@"%s %@", __PRETTY_FUNCTION__, presence);
}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
    if ([presence isErrorPresence]) {
        DDLogError(@"%s %@", __PRETTY_FUNCTION__, presence);
    } else {
        DDLogVerbose(@"%s %@", __PRETTY_FUNCTION__, presence);
    }
    
    NSString *presenceType          = [presence type] ? [presence type] : @"";
    NSString *myUsername            = [[sender myJID] user];
    NSString *presenceFromUser      = [[presence from] user] ? [[presence from] user] : @"";
    NSString *presenceFromUserJID   = [presence fromStrWithoutResource];
    NSString *presenceStatus        = [presence status] ? [presence status] : @"";
    BOOL      isMUCRoomPresence     = [xmppMUC isMUCRoomPresence:presence];
    
    if ([presenceType isEqualToString:@"unavailable"] && [presenceStatus isEqualToString:@"Replaced by new connection"]) {
        presenceStatus = @"";
        // this code for handled the replace connection from friend jabber seasion, maybe his connection lost and no tell server he went to offline but reconnect as new seasion after that.
    }
    
    // handling the friend request
    // <presence xmlns="jabber:client" from="f8f319f77030a8f092f373ce1f0ab70a47f3f32f@snim.mtouche-mobile.com" to="782fef21cad2ae602322b6aef285e7d9a75b2694@snim.mtouche-mobile.com" type="subscribe"><status/></presence>
    if ([presenceType isEqualToString:@"subscribe"]) {
        [[XMPPManager share] sendApprovedSubscribedToJID:presenceFromUserJID inXMPPStream:xmppStream];
    }
    
    // handling the status of friends (not chat room id)
    //if (![presenceFromUser isEqualToString:myUsername] && !isMUCRoomPresence)
    if (!isMUCRoomPresence)
    {
        NSMutableDictionary *dicPresence = [NSMutableDictionary new];
        [dicPresence setObject:presenceType forKey:kPRESENCE_TYPE];
        [dicPresence setObject:presenceStatus forKey:kPRESENCE_STATUS];
        [dicPresence setObject:presenceFromUser forKey:kPRESENCE_FROM_USER];
        [dicPresence setObject:presenceFromUserJID forKey:kPRESENCE_FROM_USER_JID];
        if ([delegate respondsToSelector:@selector(xmppDomain:didReceivePresence:)]) {
            [delegate xmppDomain:self didReceivePresence:dicPresence];
        }
        
        //return;
    }
    
    // get the list of joined chat rooms
    if (isMUCRoomPresence) {
        //<presence xmlns="jabber:client" from="danielroom@conference.satay.mooo.com/daniel3" to="daniel3@satay.mooo.com/iOSXMPPAPP"><x xmlns="vcard-temp:x:update"><photo/></x><c xmlns="http://jabber.org/protocol/caps" hash="sha-1" node="https://github.com/robbiehanson/XMPPFramework" ver="1bC6+/6Z9Zo6+9cvs4o+2Gjt3Vo="/><x xmlns="http://jabber.org/protocol/muc#user"><item jid="daniel3@satay.mooo.com/iOSXMPPAPP" affiliation="owner" role="moderator"/><status code="110"/></x></presence>
        //<presence xmlns="jabber:client" from="1551e04c774b7b1551e04c774c00@conference.satay.mooo.com/bwx1g7a4l@satay.mooo.com" to="bwx1g7a4l@satay.mooo.com/iOS_TEST"><x xmlns="vcard-temp:x:update"><photo/></x><c xmlns="http://jabber.org/protocol/caps" hash="sha-1" node="https://github.com/robbiehanson/XMPPFramework" ver="g2AGMaRLrsONiBL/cxe79u9HIW0="/><x xmlns="http://jabber.org/protocol/muc#user"><item affiliation="none" role="participant"/><status code="110"/></x></presence>
        //<presence xmlns="jabber:client" from="1555ae005226d31555ae0052277e@conference.snim.mtouche-mobile.com/4518188cbf3e740b4946bbea333492ed413cf33b@snim.mtouche-mobile.com" to="4518188cbf3e740b4946bbea333492ed413cf33b@snim.mtouche-mobile.com/SATAY_IOS_1.0" type="unavailable"><status>gone where the goblins go</status><x xmlns="vcard-temp:x:update"><photo/></x><x xmlns="http://jabber.org/protocol/muc#user"><item affiliation="owner" role="none"/><status code="110"/></x></presence>
        //DDLogInfo(@"%s %@", __PRETTY_FUNCTION__, presence);
        
        NSString *elementStatus = [[presence elementForName:@"status"] stringValue];
        //<status>Replaced by new connection</status> ->>> set elementStatus to nil
        // maybe check default value when leave chatroom is "gone where the goblins go", if not, set to nil
        if (![[elementStatus lowercaseString] isEqualToString:@"gone where the goblins go"]) {
            elementStatus = nil;
        }
        /*
        if ([elementStatus isEqualToString:@"Replaced by new connection"]) {
            elementStatus = nil;
        }*/
        
        NSXMLElement *elementMUC    = [[presence elementForName:@"x" xmlnsPrefix:XMPPMUCNamespace] elementForName:@"item"];
        NSString *chatRoomJID       = [presence fromStrWithoutResource];
        NSString *toJID             = [presence toStrWithoutResource];
        NSString *affiliation       = ([[elementMUC attributeForName:@"affiliation"] stringValue]) ? [[elementMUC attributeForName:@"affiliation"] stringValue] : @"";
        NSString *role              = ([[elementMUC attributeForName:@"role"] stringValue]) ? [[elementMUC attributeForName:@"role"] stringValue] : @"";
        NSString *type              = [presence type];
        NSString *occupant          = [presence fromStrResource];
        NSString *actor             = [[[elementMUC elementForName:@"actor"] attributeForName:@"nick"] stringValue];
        NSString *reason            = [[elementMUC elementForName:@"reason"] stringValue];
        NSString *status            = [[[[presence elementForName:@"x" xmlnsPrefix:XMPPMUCNamespace] elementForName:@"status"] attributeForName:@"code"] stringValue];
        
        if (!reason && !elementStatus) {
            //DDLogError(@"===================NO THING TO DO===================");
            return;
        }
        
        if (!status) {
            // for leave presence of other member, it not exit room (when quit app).
            NSString *st = [[presence elementForName:@"status"] stringValue];
            if ([st length] > 0 && [type isEqualToString:kPRESENCE_STATUS_TEXT_UNAVAILABLE]) {
                status = @"110";
            }
        }
        
        NSMutableDictionary *dicMUCPresence = [NSMutableDictionary new];
        [dicMUCPresence setObject:chatRoomJID forKey:kMUC_ROOM_JID];
        [dicMUCPresence setObject:affiliation forKey:kMUC_ROOM_AFFILIATION];
        [dicMUCPresence setObject:role forKey:kMUC_ROOM_ROLE];
        [dicMUCPresence setObject:toJID forKey:kXMPP_TO_JID];
        [dicMUCPresence setObject:occupant forKey:kMUC_OCCUPANT];
        if (status) {
            [dicMUCPresence setObject:status forKey:kPRESENCE_STATUS];
        }
        if (actor) {
            [dicMUCPresence setObject:actor forKey:kMUC_ACTOR];
        }
        if (type) {
            [dicMUCPresence setObject:type forKey:kPRESENCE_TYPE];
        }
        
        if ([delegate respondsToSelector:@selector(xmppDomain:didReceiveMUCPresence:)]) {
            [delegate xmppDomain:self didReceiveMUCPresence:dicMUCPresence];
        }
        
        //return;
    }
    
    if ([presenceFromUser isEqualToString:myUsername])
    {
        // we do not allow user add himself to contact list, and ignore check status of him.
        /*
        NSMutableDictionary *dicPresence = [NSMutableDictionary new];
        [dicPresence setObject:presenceType forKey:kPRESENCE_TYPE];
        [dicPresence setObject:presenceStatus forKey:kPRESENCE_STATUS];
        [dicPresence setObject:presenceFromUser forKey:kPRESENCE_FROM_USER];
        [dicPresence setObject:presenceFromUserJID forKey:kPRESENCE_FROM_USER_JID];
        if ([delegate respondsToSelector:@selector(xmppDomain:didReceivePresence:)]) {
            [delegate xmppDomain:self didReceivePresence:dicPresence];
        }
        */
        if (xmppUpdatePresenceFlag == kXMPP_PRESENCE_UPDATE_FLAG_STATUS) {
            if ([presence isErrorPresence]) {
                requestCompleteCallBack(NO, @"Update status failed", nil, nil);
            } else {
                requestCompleteCallBack(YES, @"Update status successfully", nil, nil);
            }
            
            xmppUpdatePresenceFlag = kXMPP_PRESENCE_UPDATE_FLAG_NONE;
        }
        //return;
    }
    
//    if ([presence isErrorPresence]) {
//        DDLogError(@"%s %@", __PRETTY_FUNCTION__, presence);
//    } else {
//        DDLogVerbose(@"%s %@", __PRETTY_FUNCTION__, presence);
//    }
}

- (void)xmppStream:(XMPPStream *)sender didReceiveError:(id)error
{
    DDLogError(@"%s %@", __PRETTY_FUNCTION__, error);
    XMPPElement *element = (XMPPElement *)error;
    
    NSString *elementName = [element name];
    NSString *elementText = [[element elementForName:@"text"] stringValue];
    
    if ([elementName isEqualToString:@"stream:error"] || [elementName isEqualToString:@"error"])
    {
        NSMutableDictionary* details = [NSMutableDictionary dictionary];
        [details setValue:elementText forKey:NSLocalizedDescriptionKey];
        // populate the error object with the details
        NSError *err = [NSError errorWithDomain:kXMPP_ERROR_DOMAIN code:kXMPP_ERROR_CODE_GENERAL userInfo:details];
        [delegate xmppDomainDidDisconnect:self withError:err];
    }
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
    DDLogError(@"%s: %@", __PRETTY_FUNCTION__, error);
    xmppConnectStateFlag = XMPP_CONNECT_STATE_DISCONNECTED;
    
    if (error) {
        [delegate xmppDomainDidDisconnect:self withError:error];
    }
    
    if (!isXmppConnected)
    {
        NSMutableDictionary* details = [NSMutableDictionary dictionary];
        [details setValue:@"Unable to connect to server. Check HOST_NAME info." forKey:NSLocalizedDescriptionKey];
        // populate the error object with the details
        NSError *err = [NSError errorWithDomain:kXMPP_ERROR_DOMAIN code:kXMPP_ERROR_CODE_HOST_NOT_FOUND userInfo:details];
        [delegate xmppDomainDidDisconnect:self withError:err];
    }
    
    if (![self isConnecting]) {
        //[self reconnectXMPP];
    }
}

- (void)xmppStreamConnectDidTimeout:(XMPPStream *)sender
{
    DDLogVerbose(@"%s %@", __PRETTY_FUNCTION__, sender);
    xmppConnectStateFlag = XMPP_CONNECT_STATE_DISCONNECTED;
    if ([delegate respondsToSelector:@selector(xmppDomainDidTimedOut:)]) {
        [delegate xmppDomainDidTimedOut:self];
    }
}

- (void)xmppStreamWillConnect:(XMPPStream *)sender
{
    DDLogVerbose(@"%s %@", __PRETTY_FUNCTION__, sender);
}

#pragma mark - XMPPRoster Delegate
- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence
{
    DDLogInfo(@"%s %@", __PRETTY_FUNCTION__, presence);
    [arrSubsRequestList addObject:presence];
}

- (void)xmppRoster:(XMPPRoster *)sender didReceiveRosterItem:(NSXMLElement *)item
{
    DDLogVerbose(@"%s %@", __PRETTY_FUNCTION__, item);
    //<item subscription="both" jid="utjljki@satay.mooo.com"/>
    NSString *subscription = [[item attributeForName:@"subscription"] stringValue];
    NSString *targetJID = [[item attributeForName:@"jid"] stringValue];
    
    //<item jid="g0pr3@satay.mooo.com" subscription="remove"/>
    if ([subscription isEqualToString:@"remove"]) {
        // fire delegate to tell app layer update local db for contact
        if ([delegate respondsToSelector:@selector(xmppDomainDidDeletedFriendFromJID:)]) {
            [delegate xmppDomainDidDeletedFriendFromJID:targetJID];
        }
        return;
    }
    
    [xmppvCardTempModule fetchvCardTempForJID:[XMPPJID jidWithString:targetJID]];
    
    if ([subscription isEqualToString:@"both"]) {
        [arrFriendsList addObject:targetJID];
        [self sendLastActivityQueryToJID:targetJID];
    }
    
    //<item ask="subscribe" subscription="none" jid="daniel@satay.mooo.com"/>
    NSString *ask = [[item attributeForName:@"ask"] stringValue];
    
    if ([subscription isEqualToString:@"none"] || [subscription isEqualToString:@"from"])
    {
        if([ask isEqualToString:@"subscribe"])
        {
            [arrPenddingList addObject:targetJID];
        }
    }
}

#pragma mark - XMPPRosterMemoryStorage Delegate
- (void)xmppRosterDidPopulate:(XMPPRosterMemoryStorage *)sender
{
    DDLogVerbose(@"%s %@", __PRETTY_FUNCTION__, [sender unsortedUsers]);
}

- (void)xmppRosterDidChange:(XMPPRosterMemoryStorage *)sender
{
    DDLogVerbose(@"%s %@", __PRETTY_FUNCTION__, [sender unsortedUsers]);
}

#pragma mark - XMPPReconnect Delegate
- (void)xmppReconnect:(XMPPReconnect *)sender didDetectAccidentalDisconnect:(SCNetworkConnectionFlags)connectionFlags
{
    DDLogWarn(@"%s didDetectAccidentalDisconnect:%u", __PRETTY_FUNCTION__, connectionFlags);
}

- (BOOL)xmppReconnect:(XMPPReconnect *)sender shouldAttemptAutoReconnect:(SCNetworkConnectionFlags)connectionFlags
{
    DDLogWarn(@"%s shouldAttemptAutoReconnect:%u", __PRETTY_FUNCTION__, connectionFlags);
    // fire the delegate xmppDomainWillConnect to app layer
    [delegate xmppDomainWillConnect:self];

    return YES;
}

#pragma mark - XMPPAutoPing Delegate
- (void)xmppAutoPingDidReceivePong:(XMPPAutoPing *)sender
{
    DDLogVerbose(@"%s %@", __PRETTY_FUNCTION__, sender);
    if ([delegate respondsToSelector:@selector(xmppDomainDidReceivePong:)]) {
        [delegate xmppDomainDidReceivePong:self];
    }
}

- (void)xmppAutoPingDidTimeout:(XMPPAutoPing *)sender
{
    DDLogVerbose(@"%s %@", __PRETTY_FUNCTION__, sender);
    if ([delegate respondsToSelector:@selector(xmppDomainDidTimedOut:)]) {
        [delegate xmppDomainDidTimedOut:self];
    }
}

- (void)xmppAutoPingDidSendPing:(XMPPAutoPing *)sender
{
    DDLogVerbose(@"%s %@", __PRETTY_FUNCTION__, sender);
}

#pragma mark - XMPPPing Delegate
- (void)xmppPing:(XMPPPing *)sender didReceivePong:(XMPPIQ *)pong withRTT:(NSTimeInterval)rtt
{
    DDLogVerbose(@"%s %@ %@ %f", __PRETTY_FUNCTION__, sender, pong, rtt);
    if ([delegate respondsToSelector:@selector(xmppDomainDidReceivePong:)]) {
        [delegate xmppDomainDidReceivePong:self];
    }
}

- (void)xmppPing:(XMPPPing *)sender didNotReceivePong:(NSString *)pingID dueToTimeout:(NSTimeInterval)timeout
{
    DDLogVerbose(@"%s %@\npingID: %@, dueToTimeout: %f", __PRETTY_FUNCTION__, sender, pingID, timeout);
    if ([delegate respondsToSelector:@selector(xmppDomainDidTimedOut:)]) {
        [delegate xmppDomainDidTimedOut:self];
    }
}

#pragma mark - XMPPLastActivity Delegate
- (NSUInteger)numberOfIdleTimeSecondsForXMPPLastActivity:(XMPPLastActivity *)sender queryIQ:(XMPPIQ *)iq currentIdleTimeSeconds:(NSUInteger)idleSeconds
{
    // can define XMPP_LAST_ACTIVITY_TIMEOUT
    DDLogVerbose(@"xmppLastActivity numberOfIdleTimeSecondsForXMPPLastActivity sender:%@, queryID:%@, currentIdleTimeSeconds:%lu",sender,iq,(unsigned long)idleSeconds);
    return 10;
}

- (void)xmppLastActivity:(XMPPLastActivity *)sender didNotReceiveResponse:(NSString *)queryID dueToTimeout:(NSTimeInterval)timeout
{
    DDLogVerbose(@"xmppLastActivity didNotReceiveResponse sender:%@, queryID:%@, dueToTimeout:%f",sender,queryID,timeout);
    [delegate xmppDomainDidNotReceiveResponseOfLastActivity];
}

- (void)xmppLastActivity:(XMPPLastActivity *)sender didReceiveResponse:(XMPPIQ *)response
{
    NSInteger currentETS = (NSInteger)([[NSDate date] timeIntervalSince1970]);
    NSInteger lastActTS = currentETS - [response lastActivitySeconds];
    NSString *fromJID = [response fromStrWithoutResource];
    NSString *type = [response type];
    
    if (![type isEqualToString:@"error"]) {
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:lastActTS];
        if ([delegate respondsToSelector:@selector(xmppDomainDidReceiveResponseOfLastActivity:forBuddy:)]) {
            [delegate xmppDomainDidReceiveResponseOfLastActivity:date forBuddy:fromJID];
        }
    }
}

#pragma mark - XMPP vCardAvatarModule Delegate
- (void)xmppvCardAvatarModule:(XMPPvCardAvatarModule *)vCardTempModule didReceivePhoto:(UIImage *)photo forJID:(XMPPJID *)jid
{
//    NSData *imageData = UIImagePNGRepresentation(photo);
//    
//    NSString *senderJID = [jid full];
//    BOOL isMyself = ([senderJID isEqualToString:currentJID]) ? TRUE : FALSE;
//    NSNumber *isMe = @(isMyself);
//    NSMutableDictionary *m = [[NSMutableDictionary alloc] init];
//    [m setObject:senderJID forKey:kAVATAR_TARGET_JID];
//    [m setObject:imageData forKey:kAVATAR_IMAGE_DATA];
//    [m setObject:isMe forKey:kAVATAR_IS_ME];
//    
//    if ([delegate respondsToSelector:@selector(xmppDomain:didReceiveAvatar:)]) {
//        [delegate xmppDomain:self didReceiveAvatar:m];   // this is my custom delegate method where I save new avatar to cache
//    }
}

#pragma mark - ROOM Delegate
- (void)xmppRoomDidCreate:(XMPPRoom *)sender
{
    DDLogInfo(@"%s %@", __PRETTY_FUNCTION__, [[sender myRoomJID] full]);
    
    //[sender fetchModeratorsList];
    
    if ([delegate respondsToSelector:@selector(xmppDomain:didCreatedChatRoom:)]) {
        [delegate xmppDomain:self didCreatedChatRoom:[[sender myRoomJID] full]];
    }
}

- (void)xmppRoomDidDestroy:(XMPPRoom *)sender
{
    DDLogInfo(@"%s", __PRETTY_FUNCTION__);
}

- (void)xmppRoomDidJoin:(XMPPRoom *)sender
{
    DDLogInfo(@"%s %@", __PRETTY_FUNCTION__, [[sender myRoomJID] full]);
    [sender fetchConfigurationForm];
    [sender fetchMembersList];
    [sender fetchModeratorsList];
    if ([delegate respondsToSelector:@selector(xmppDomain:didJoinChatRoom:)]) {
        NSDictionary *roomInfo = @{kMUC_ROOM_JID:[[sender myRoomJID] full]};
        [delegate xmppDomain:self didJoinChatRoom:roomInfo];
    }
}

- (void)xmppRoomDidLeave:(XMPPRoom *)sender
{
    DDLogInfo(@"%s %@", __PRETTY_FUNCTION__, sender);
    if ([delegate respondsToSelector:@selector(xmppDomain:didLeaveChatRoom:)] && xmppConnectStateFlag == XMPP_CONNECT_STATE_CONNECTED) {
        NSDictionary *roomInfo = @{kMUC_ROOM_JID: [sender.roomJID full]};
        [delegate xmppDomain:self didLeaveChatRoom:roomInfo];
    }
}

- (void)xmppRoom:(XMPPRoom *)sender didConfigure:(XMPPIQ *)iqResult
{
    DDLogInfo(@"%s %@", __PRETTY_FUNCTION__, iqResult);
}

- (void)xmppRoom:(XMPPRoom *)sender didNotConfigure:(XMPPIQ *)iqResult
{
    DDLogInfo(@"%s %@", __PRETTY_FUNCTION__, iqResult);
}

- (void)xmppRoom:(XMPPRoom *)sender didFetchMembersList:(NSArray *)items
{
    DDLogInfo(@"%s %@ %@", __PRETTY_FUNCTION__, [sender.myRoomJID full], items);
}

- (void)xmppRoom:(XMPPRoom *)sender didFetchModeratorsList:(NSArray *)items
{
    DDLogInfo(@"%s %@", __PRETTY_FUNCTION__, items);
}

- (void)xmppRoom:(XMPPRoom *)sender didFetchConfigurationForm:(DDXMLElement *)configForm
{
    //DDLogInfo(@"%s configForm %@", __PRETTY_FUNCTION__, configForm);
    
    BOOL hasMaxHistoryFetch = NO;

    NSXMLElement *newConfig = [configForm copy];
    NSArray* fields = [newConfig elementsForName:@"field"];
    for (NSXMLElement *field in fields) {
        NSString *var = [field attributeStringValueForName:@"var"];
        if ([var isEqualToString:@"muc#roomconfig_persistentroom"]) {
            [field removeChildAtIndex:0];
            [field addChild:[NSXMLElement elementWithName:@"value" stringValue:@"1"]];
        }
        if ([var isEqualToString:@"muc#maxhistoryfetch"]) {
            /*
            [field removeChildAtIndex:0];
            [field addChild:[NSXMLElement elementWithName:@"value" stringValue:@"0"]];
            hasMaxHistoryFetch = YES;
             */
        }
        if ([var isEqualToString:@"muc#roomconfig_moderatedroom"]) {
            [field removeChildAtIndex:0];
            [field addChild:[NSXMLElement elementWithName:@"value" stringValue:@"0"]];
        }
    }

    /*
    if (!hasMaxHistoryFetch) {
        NSXMLElement *ele = [NSXMLElement elementWithName:@"field"];
        [ele addAttributeWithName:@"var" stringValue:@"muc#maxhistoryfetch"];
        [ele addChild:[NSXMLElement elementWithName:@"value" stringValue:@"0"]];
        [newConfig addChild:ele];
    }
     */

    // reference: http://xmpp.org/extensions/xep-0045.html#roomconfig
    [sender configureRoomUsingOptions:newConfig];
}

#pragma mark - MUC Delegate
- (void)xmppMUCFailedToDiscoverServices:(XMPPMUC *)sender withError:(NSError *)error
{
    DDLogInfo(@"%s %@", __PRETTY_FUNCTION__, error);
}

- (void)xmppMUC:(XMPPMUC *)sender didDiscoverRooms:(NSArray *)rooms forServiceNamed:(NSString *)serviceName
{
    //
}

- (void)xmppMUC:(XMPPMUC *)sender didDiscoverServices:(NSArray *)services
{
    DDLogInfo(@"%s %@", __PRETTY_FUNCTION__, services);
}


- (void)xmppMUC:(XMPPMUC *)sender roomJID:(XMPPJID *)roomJID didReceiveInvitation:(XMPPMessage *)message
{
    if ([message isErrorMessage]) {
        DDLogError(@"%s %@", __PRETTY_FUNCTION__, message);
    } else {
        DDLogInfo(@"%s %@ %@", __PRETTY_FUNCTION__, [roomJID full], message);
    }
    
    /*
     <message xmlns="jabber:client" from="osopqaapgvp3xtj5m8i5ksds5@conference.satay.mooo.com" to="nh5cgo@satay.mooo.com" type="normal"><x xmlns="http://jabber.org/protocol/muc#user"><invite from="y956e@satay.mooo.com/KRYPTO_IOS_1.0"><reason>Join me :)</reason></invite></x><x xmlns="jabber:x:conference" jid="osopqaapgvp3xtj5m8i5ksds5@conference.satay.mooo.com">Join me :)</x><body>y956e@satay.mooo.com/KRYPTO_IOS_1.0 invites you to the room osopqaapgvp3xtj5m8i5ksds5@conference.satay.mooo.com (Join me :)) </body></message>
     */
    
    NSMutableDictionary *roomInfo = [[NSMutableDictionary alloc] init];
    
    NSString *roomjid = [message fromStr];
    NSString *mess = [message body];
    NSString *inviteMsg = [message inviteMessage];
    NSString *from = [message inviteFromJID];
    
    if ([message wasDelayed] && [message delayedDeliveryDate])
    {
        [roomInfo setObject:[message delayedDeliveryDate] forKey:kTEXT_MESSAGE_DELAYED_DATE];
    }
    
    [roomInfo setObject:roomjid forKey:kMUC_ROOM_JID];
    [roomInfo setObject:from forKey:kXMPP_FROM_JID];
    [roomInfo setObject:mess forKey:kMUC_ROOM_INVITE_MESSAGE_FULL];
    [roomInfo setObject:inviteMsg forKey:kMUC_ROOM_INVITE_MESSAGE];
    /*
     NSDictionary *roomInfo = @{kMUC_ROOM_JID: roomjid,
     kMUC_ROOM_INVITE_MESSAGE: inviteMsg,
     kXMPP_FROM_JID: from,
     kMUC_ROOM_INVITE_MESSAGE_FULL: mess
     };
     */
    
    DDLogWarn(@"%s %@", __PRETTY_FUNCTION__, roomInfo);
    
    if ([delegate respondsToSelector:@selector(xmppDomain:didReceiveInvitationToChatRoom:)]) {
        [delegate xmppDomain:self didReceiveInvitationToChatRoom:roomInfo];
    }
    
    // fire delegate to App Layer to process flow of chatroom featured
    // will get key and accept or deline the invitation
    
    /*
    NSXMLElement *x = [message elementForName:@"x" xmlns:XMPPMUCUserNamespace];
    NSXMLElement *invite  = [x elementForName:@"invite"];
    if (invite && ![message isErrorMessage])
    {
        NSString *conferenceRoomJID = [[message attributeForName:@"from"] stringValue];
        [self joinChatRoom:conferenceRoomJID withNickName:currentJID andPassword:@""];
    }
    */
}

#pragma mark - CardTempModule Delegate
- (void)xmppvCardTempModuleDidUpdateMyvCard:(XMPPvCardTempModule *)vCardTempModule
{
    DDLogInfo(@"%s %@", __PRETTY_FUNCTION__, [vCardTempModule myvCardTemp]);
    //<vCard xmlns="vcard-temp"><display_name>Neo</display_name></vCard>
    XMPPvCardTemp *vCardTemp = [vCardTempModule myvCardTemp];
    switch (xmppUpdateFlag) {
        case kXMPP_UPDATE_FLAG_AVATAR:
        {
            if ([vCardTemp hasPhoto]) {
                // for update Avatar
                if ([delegate respondsToSelector:@selector(xmppDomainDidUpdateOwnAvatar:)]) {
                    NSMutableDictionary *m = [[NSMutableDictionary alloc] init];
                    [m setObject:[vCardTemp photo] forKey:kAVATAR_IMAGE_DATA];
                    [delegate xmppDomainDidUpdateOwnAvatar:m];
                    xmppUpdateFlag = kXMPP_UPDATE_FLAG_NONE;
                    
                    // send update event to friends
                    if ([arrFriendsList count] > 0) {
                        for (int i=0; i< [arrFriendsList count]; i++) {
                            NSString *item = [arrFriendsList objectAtIndex:i];
                            [[XMPPManager share] sendUpdateVcardEventFrom:currentJID toJID:item inXMPPStream:xmppStream withType:kVCARD_UPDATE_AVATAR];
                        }
                    }
                }
            }
        }
            break;
            
        case kXMPP_UPDATE_FLAG_DISPLAYNAME:
        {
            if ([vCardTemp hasDisplayName]) {
                // for update Display Name
                if ([delegate respondsToSelector:@selector(xmppDomainDidUpdateOwnDisplayname:)]) {
                    NSMutableDictionary *m = [[NSMutableDictionary alloc] init];
                    [m setObject:[vCardTemp getDisplayName] forKey:kXMPP_USER_DISPLAYNAME];
                    [delegate xmppDomainDidUpdateOwnDisplayname:m];
                    xmppUpdateFlag = kXMPP_UPDATE_FLAG_NONE;
                    
                    // send update event to friends
                    if ([arrFriendsList count] > 0) {
                        for (int i=0; i< [arrFriendsList count]; i++) {
                            NSString *item = [arrFriendsList objectAtIndex:i];
                            [[XMPPManager share] sendUpdateVcardEventFrom:currentJID toJID:item inXMPPStream:xmppStream withType:kVCARD_UPDATE_DISPLAYNAME];
                        }
                    }
//                    [[XMPPManager share] sendUpdateVcardEventFrom:currentJID toJID:@"daniel2@satay.mooo.com" inXMPPStream:xmppStream withType:kVCARD_UPDATE_DISPLAYNAME];
                }
            }
        }
            break;
            
        default:
            xmppUpdateFlag = kXMPP_UPDATE_FLAG_NONE;
            break;
    }
}

- (void)xmppvCardTempModule:(XMPPvCardTempModule *)vCardTempModule failedToUpdateMyvCard:(DDXMLElement *)error
{
    DDLogError(@"%s %@ %@", __PRETTY_FUNCTION__, [vCardTempModule myvCardTemp], error);
    XMPPvCardTemp *vCardTemp = [vCardTempModule myvCardTemp];
    
    switch (xmppUpdateFlag) {
        case kXMPP_UPDATE_FLAG_AVATAR:
        {
            if ([vCardTemp hasPhoto]) {
                // for update avatar
                if ([delegate respondsToSelector:@selector(xmppDomainDidFailUpdateOwnAvatar:)]) {
                    NSMutableDictionary *m = [[NSMutableDictionary alloc] init];
                    [m setObject:[vCardTemp photo] forKey:kAVATAR_IMAGE_DATA];
                    [m setObject:error forKey:kXMPP_ERROR];
                    [delegate xmppDomainDidFailUpdateOwnAvatar:m];
                }
            }
        }
            break;
        
        case kXMPP_UPDATE_FLAG_DISPLAYNAME:
        {
            if ([vCardTemp hasDisplayName]) {
                // for update display name
                if ([delegate respondsToSelector:@selector(xmppDomainDidFailUpdateOwnDisplayname:)]) {
                    NSMutableDictionary *m = [[NSMutableDictionary alloc] init];
                    [m setObject:[vCardTemp getDisplayName] forKey:kXMPP_USER_DISPLAYNAME];
                    [m setObject:error forKey:kXMPP_ERROR];
                    [delegate xmppDomainDidFailUpdateOwnDisplayname:m];
                }
            }
        }
            break;
            
        default:
            xmppUpdateFlag = kXMPP_UPDATE_FLAG_NONE;
            break;
    }
    
    xmppUpdateFlag = kXMPP_UPDATE_FLAG_NONE;
}

- (void)xmppvCardTempModule:(XMPPvCardTempModule *)vCardTempModule didReceivevCardTemp:(XMPPvCardTemp *)vCardTemp forJID:(XMPPJID *)jid
{
    DDLogInfo(@"%s %@ %@", __PRETTY_FUNCTION__, vCardTemp, [jid full]);
}

#pragma mark - For XMPPStreamManageent
- (void)xmppStreamManagement:(XMPPStreamManagement *)sender wasEnabled:(DDXMLElement *)enabled
{
    DDLogInfo(@"%s %@", __PRETTY_FUNCTION__, enabled);
}

- (void)xmppStreamManagement:(XMPPStreamManagement *)sender wasNotEnabled:(DDXMLElement *)failed
{
    DDLogInfo(@"%s %@", __PRETTY_FUNCTION__, failed);
}

#pragma mark - For Status
- (void)goOnline
{
    XMPPPresence *presence = [XMPPPresence presence];
    
    NSXMLElement *priority = [NSXMLElement elementWithName:@"priority" stringValue:@"5"];
    [presence addChild:priority];
    
    [[self xmppStream] sendElement:presence];
    
    DDLogInfo(@"presence = %@",presence.XMLString);
}

- (void)goOffline
{
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    
    [[self xmppStream] sendElement:presence];
    
    DDLogInfo(@"presence = %@",presence.XMLString);
}

- (void) goAway
{
    XMPPPresence *presence = [XMPPPresence presence];
    [presence addAttributeWithName:@"from" stringValue:[xmppStream.myJID bare]];
    
    NSXMLElement *status = [NSXMLElement elementWithName:@"status"];
    [status setStringValue:@"Away"];
    [presence addChild:status];
    
    NSXMLElement *priority = [NSXMLElement elementWithName:@"priority"];
    [priority setStringValue:@"0"];
    [presence addChild:priority];
    
    NSXMLElement *show = [NSXMLElement elementWithName:@"show"];
    [show setStringValue:@"away"];
    [presence addChild:show];
    
    [[self xmppStream] sendElement:presence];
    
    DDLogInfo(@"presence = %@",presence.XMLString);
}

- (void) goBusy
{
    XMPPPresence *presence = [XMPPPresence presence];
    [presence addAttributeWithName:@"from" stringValue:[xmppStream.myJID bare]];
    
    NSXMLElement *status = [NSXMLElement elementWithName:@"status"];
    [status setStringValue:@"Do not disturb"];
    [presence addChild:status];
    
    NSXMLElement *priority = [NSXMLElement elementWithName:@"priority"];
    [priority setStringValue:@"0"];
    [presence addChild:priority];
    
    NSXMLElement *show = [NSXMLElement elementWithName:@"show"];
    [show setStringValue:@"dnd"];
    [presence addChild:show];
    
    [[self xmppStream] sendElement:presence];
    
    DDLogInfo(@"presence = %@",presence.XMLString);
}

- (void) goAvailable
{
    XMPPPresence *presence = [XMPPPresence presence];
    [presence addAttributeWithName:@"from" stringValue:[xmppStream.myJID bare]];
    
    NSXMLElement *status = [NSXMLElement elementWithName:@"status"];
    [status setStringValue:@"Available"];
    [presence addChild:status];
    
    NSXMLElement *priority = [NSXMLElement elementWithName:@"priority"];
    [priority setStringValue:@"5"];
    [presence addChild:priority];
    
    NSXMLElement *show = [NSXMLElement elementWithName:@"show"];
    [show setStringValue:@"Show Available"];
    [presence addChild:show];
    
    [[self xmppStream] sendElement:presence];
    
    DDLogInfo(@"presence = %@",presence.XMLString);
}

- (void) setStatusMessage:(NSString *)statusMsg callback:(requestCompleteBlock)callback
{
    requestCompleteCallBack = callback;
    xmppUpdatePresenceFlag = kXMPP_PRESENCE_UPDATE_FLAG_STATUS;
    
    XMPPPresence *presence = [XMPPPresence presence];
    [presence addAttributeWithName:@"from" stringValue:[xmppStream.myJID bare]];
    
    NSXMLElement *status = [NSXMLElement elementWithName:@"status"];
    [status setStringValue:statusMsg];
    [presence addChild:status];
    
    if (xmppStream.isConnected) {
        [[self xmppStream] sendElement:presence];
        DDLogInfo(@"presence = %@",presence.XMLString);
    } else {
        requestCompleteCallBack(NO, @"Update status failed", nil, nil);
    }
}

#pragma mark - For Profile
- (NSString *)getDisplayNameForJID:(NSString *)jid
{
    if ([jid isEqualToString:currentJID]) {
        return displayname;
    }
    
    XMPPvCardTemp *vCardTemp = [xmppvCardTempModule vCardTempForJID:[XMPPJID jidWithString:jid] shouldFetch:YES];
    DDLogError(@"%@", vCardTemp);
    if (vCardTemp) {
        return [vCardTemp getDisplayName];
    }
    return @"";
}

- (void)setDisplayName:(NSString *)newDisplayName
{
    if (!newDisplayName) {
        DDLogError(@"New Display Name must be not empty!");
        return;
    }
    
    XMPPvCardTemp *newvC = [XMPPvCardTemp vCardTempFromElement:myvCard];
    [newvC setDisplayName:newDisplayName];
    
    DDLogInfo(@"%s %@", __PRETTY_FUNCTION__, newvC);
    
    xmppUpdateFlag = kXMPP_UPDATE_FLAG_DISPLAYNAME;
    [xmppvCardTempModule updateMyvCardTemp:newvC];
}

#pragma mark - For Avatar
- (NSData *)getAvatarFromJID:(NSString *)fullJID
{
    return [xmppvCardAvatarModule photoDataForJID:[XMPPJID jidWithString:fullJID]];
}

- (void)updateAvatar:(NSData *)imageData
{
    NSXMLElement *vCardXML = [NSXMLElement elementWithName:@"vCard" xmlns:@"vcard-temp"];
    NSXMLElement *photoXML = [NSXMLElement elementWithName:@"PHOTO"];
    NSXMLElement *typeXML = [NSXMLElement elementWithName:@"TYPE"stringValue:@"image/jpeg"];
    NSXMLElement *binvalXML = [NSXMLElement elementWithName:@"BINVAL" stringValue:[imageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength]];
    
    [photoXML addChild:typeXML];
    [photoXML addChild:binvalXML];
    [vCardXML addChild:photoXML];

    DDLogWarn(@"%s UPLOADING AVATAR...", __PRETTY_FUNCTION__);
    
    xmppUpdateFlag = kXMPP_UPDATE_FLAG_AVATAR;
    XMPPvCardTemp *newvCardTemp = [XMPPvCardTemp vCardTempFromElement:vCardXML];
    [xmppvCardTempModule updateMyvCardTemp:newvCardTemp];
}

#pragma mark - For Chat State
- (void)sendMessageChatState:(NSDictionary *)stateInfo
{
    if (stateInfo != nil) {
        NSString *toJID = [stateInfo objectForKey:kCHAT_STATE_TARGET_JID];
        int chatState = [[stateInfo objectForKey:kCHAT_STATE_TYPE] intValue];
        if (toJID == nil || chatState < 1 || chatState > 5) {
            return;
        }
        [[XMPPManager share] sendComposingChatStateFrom:currentJID toJID:toJID inXMPPStream:xmppStream withState:chatState];
    }
}

#pragma mark - For LastActivity Query
- (void)sendLastActivityQueryToJID:(NSString *)jid
{
    NSString *tmp = @"";
    tmp = [xmppLastActivity sendLastActivityQueryToJID:[XMPPJID jidWithString:jid]];
    
    DDLogVerbose(@"%s %@ %@", __PRETTY_FUNCTION__, tmp, jid);
}

- (void)sendUpdatevCardNotice:(int)flag
{
    if ([arrFriendsList count] > 0) {
        for (int i=0; i< [arrFriendsList count]; i++) {
            NSString *item = [arrFriendsList objectAtIndex:i];
            // flag = kVCARD_UPDATE_AVATAR
            // or
            // flag = kVCARD_UPDATE_DISPLAYNAME
            
            [[XMPPManager share] sendUpdateVcardEventFrom:currentJID toJID:item inXMPPStream:xmppStream withType:flag];
        }
    }
}

#pragma mark - For Roster (Subscription)
- (void)sendFriendRequest:(NSDictionary *)objInfo
{
    DDLogInfo(@"%s %@", __PRETTY_FUNCTION__, objInfo);
    NSMutableDictionary *m = [objInfo mutableCopy];
    [m setObject:currentJID forKey:kXMPP_FROM_JID];
    [m removeObjectForKey:kXMPP_SUBSCRIPTION_BODY];
    
    if ([self sendAddFriendRequest:objInfo]) {
        if ([delegate respondsToSelector:@selector(xmppDomainDidSuccessSendFriendRequest:)]) {
            [delegate xmppDomainDidSuccessSendFriendRequest:m];
        }
        [[XMPPManager share] sendRequestSubscribeToJID:[objInfo objectForKey:kXMPP_TO_JID] inXMPPStream:xmppStream];
    } else {
        if ([delegate respondsToSelector:@selector(xmppDomainDidFailSendFriendRequest:)]) {
            [delegate xmppDomainDidFailSendFriendRequest:m];
        }
    }
}

- (void)sendFriendApproval:(NSDictionary *)objInfo
{
    DDLogInfo(@"%s Nothing to do in here", __PRETTY_FUNCTION__);
}

- (void)sendFriendUnapproval:(NSDictionary *)objInfo
{
    DDLogInfo(@"%s %@", __PRETTY_FUNCTION__, objInfo);
    if ([self sendAddFriendRequest:objInfo]) {
        // deny success, fire delegate to app layer to update UI
        if ([delegate respondsToSelector:@selector(xmppDomainDidDenyARequest:)]) {
            NSDictionary *m = @{kXMPP_FROM_JID: [objInfo objectForKey:kXMPP_TO_JID]};
            [delegate xmppDomainDidDenyARequest:m];
        }
    }
}

- (void)sendFriendApprovedNotice:(NSDictionary *)objInfo
{
    DDLogInfo(@"%s Nothing to do in here", __PRETTY_FUNCTION__);
}

- (BOOL)isFriendWithJID:(NSString *)jid
{
    if ([arrFriendsList count] > 0) {
        for (int i=0; i<[arrFriendsList count]; i++) {
            if ([[arrFriendsList objectAtIndex:i] isEqualToString:jid]) {
                return YES;
            }
        }
    }
    
    return NO;
}

- (BOOL)isPenddingRequestFromJID:(NSString *)jid
{
    if ([arrPenddingList count] > 0) {
        for (int i=0; i<[arrPenddingList count]; i++) {
            if ([[arrPenddingList objectAtIndex:i] isEqualToString:jid]) {
                return YES;
            }
        }
    }
    
    return NO;
}

- (BOOL)sendAddFriendRequest:(NSDictionary *)objInfo{
    
    if (!objInfo) {
        return NO;
    }
    
    NSString* toUser = [objInfo objectForKey:kXMPP_TO_JID];
    NSString* fromUser = currentJID;
    NSString* msgID = [objInfo objectForKey:kXMPP_SUBSCRIPTION_ID];
    NSString* messageBody = [objInfo objectForKey:kXMPP_SUBSCRIPTION_BODY];
    
    if ([toUser isEqualToString:@""] || [messageBody isEqualToString:@""]) {
        return NO;
    }
    
    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
    [body setStringValue:messageBody];
    
    NSXMLElement *messageElement = [NSXMLElement elementWithName:@"message"];
    [messageElement addAttributeWithName:@"type" stringValue:@"chat"];
    [messageElement addAttributeWithName:@"to" stringValue:toUser];
    [messageElement addAttributeWithName:@"from" stringValue:fromUser];
    [messageElement addAttributeWithName:@"id" stringValue:msgID];
    [messageElement addChild:body];
    
    if ([self isConnected]) {
        [xmppStream sendElement:messageElement];
    } else {
        if ([self connect]) {
            [xmppStream sendElement:messageElement];
        }
    }
    
    return YES;
}

- (void)sendNoticeDeleteToFriend:(NSDictionary *)objInfo
{
    if (!objInfo) {
        return;
    }
    
    NSString* toUser = [objInfo objectForKey:kXMPP_TO_JID];
    NSString* fromUser = currentJID;
    NSString* msgID = [objInfo objectForKey:kXMPP_SUBSCRIPTION_ID];
    NSString* messageBody = [objInfo objectForKey:kXMPP_SUBSCRIPTION_BODY];
    
    if ([toUser isEqualToString:@""] || [messageBody isEqualToString:@""]) {
        return;
    }
    
    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
    [body setStringValue:messageBody];
    
    NSXMLElement *messageElement = [NSXMLElement elementWithName:@"message"];
    [messageElement addAttributeWithName:@"type" stringValue:@"chat"];
    [messageElement addAttributeWithName:@"to" stringValue:toUser];
    [messageElement addAttributeWithName:@"from" stringValue:fromUser];
    [messageElement addAttributeWithName:@"id" stringValue:msgID];
    [messageElement addChild:body];
    
    if ([self isConnected]) {
        [xmppStream sendElement:messageElement];
    } else {
        if ([self connect]) {
            [xmppStream sendElement:messageElement];
        }
    }
}

- (void)sendFriendSubscriptionTo:(NSString *)fullJID
{
    [[XMPPManager share] sendRequestSubscribeToJID:fullJID inXMPPStream:xmppStream];
}

- (void)sendFriendUnSubscriptionTo:(NSString *)fullJID
{
    [[XMPPManager share] sendRequestUnsubscribeToJID:fullJID inXMPPStream:xmppStream];
}

#pragma mark - For Single Chat
- (void)sendTextMessage:(NSString *)message toJID:(NSString *)jid withID:(NSString *)messageID withType:(NSString *)type
{
    if (!message || !jid) {
        return;
    }
    
    NSString* toUser = jid;
    NSString* fromUser = currentJID;
    NSString* msgID = messageID;
    NSString* messageType = [type isEqualToString:kXMPP_MESSAGE_STREAM_TYPE_MUC] ? @"groupchat" : @"chat";
    
    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
    [body setStringValue:message];
    
    NSXMLElement *messageElement = [NSXMLElement elementWithName:@"message"];
    [messageElement addAttributeWithName:@"type" stringValue:messageType];
    [messageElement addAttributeWithName:@"to" stringValue:toUser];
    [messageElement addAttributeWithName:@"from" stringValue:fromUser];
    [messageElement addAttributeWithName:@"id" stringValue:msgID];
    [messageElement addChild:body];
    
    if ([type isEqualToString:kXMPP_MESSAGE_STREAM_TYPE_SINGLE]) {
        NSXMLElement *request = [NSXMLElement elementWithName:@"request"];
        [request addAttributeWithName:@"xmlns" stringValue:@"urn:xmpp:receipts"];
        [messageElement addChild:request];
    }
    
    if ([self isConnected]) {
        [xmppStream sendElement:messageElement];
    } else {
        if ([self connect]) {
            [xmppStream sendElement:messageElement];
        }
    }
    // resend the chat state "Active" to target jid after sent text, by this user can receive chat state from target jid again.
    if ([type isEqualToString:kXMPP_MESSAGE_STREAM_TYPE_SINGLE]) {
        [[XMPPManager share] sendComposingChatStateFrom:fromUser toJID:toUser inXMPPStream:xmppStream withState:kCHAT_STATE_TYPE_ACTIVE];
    }
}

- (void)sendTextMessage:(NSDictionary *)messageInfo
{
    if (messageInfo) {
        [self sendTextMessage:[messageInfo objectForKey:kSEND_TEXT_MESSAGE_VALUE] toJID:[messageInfo objectForKey:kSEND_TEXT_TARGET_JID] withID:[messageInfo objectForKey:kSEND_TEXT_MESSAGE_ID] withType:[messageInfo objectForKey:kXMPP_MESSAGE_STREAM_TYPE]];
    }
}

#pragma mark - For MUC
- (void)fetchRoom
{
    //
}

- (void)addUserToChatRoomByCreateGroup:(NSString *)roomJID TargetJID:(NSString *)targetJID withMessage:(NSString *)message Password:(NSString *)roomPassword
{
    XMPPJID *chatRoomJID = [XMPPJID jidWithUser:roomJID domain:XMPP_MUC_HOST_NAME resource:@""];
    
    if (!chatRoomJID) {
        NSMutableDictionary* details = [NSMutableDictionary dictionary];
        [details setValue:@"Invalid parameter not satisfying: aRoomJID != nil" forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:kXMPP_MUC_ERROR_DOMAIN code:kXMPP_MUC_CODE_INVALID_PARAMETERS userInfo:details];
        
        [delegate xmppDomainDidFailCreateRoom:error];
        return;
    }
    
    XMPPRoomMemoryStorage *roomMemoryStorage = [[XMPPRoomMemoryStorage alloc] init];
    XMPPRoom *xmppRoom = [[XMPPRoom alloc] initWithRoomStorage:roomMemoryStorage jid:chatRoomJID dispatchQueue:dispatch_get_main_queue()];
    [xmppRoom activate:xmppStream];
    [xmppRoom addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    [xmppRoom joinRoomUsingNickname:self.currentJID history:nil password:roomPassword];
    [xmppRoom fetchConfigurationForm];
    [xmppRoom configureRoomUsingOptions:nil];
    
    if (targetJID) {
        [xmppRoom inviteUser:[XMPPJID jidWithString:targetJID] withMessage:message];
    }
}

- (void)createChatRoom:(NSDictionary *)infoObj
{
    NSString *jidString = [NSString stringWithFormat:@"%@@%@", [infoObj objectForKey:kMUC_ROOM_JID], [infoObj objectForKey:kXMPP_MUC_HOST_NAME]];
    XMPPJID *chatRoomJID = [XMPPJID jidWithString:jidString];
    
    if (!chatRoomJID) {
        NSMutableDictionary* details = [NSMutableDictionary dictionary];
        [details setValue:@"Invalid parameter not satisfying: aRoomJID != nil" forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:kXMPP_MUC_ERROR_DOMAIN code:kXMPP_MUC_CODE_INVALID_PARAMETERS userInfo:details];
        
        [delegate xmppDomainDidFailCreateRoom:error];
        return;
    }
    
    if (!tempRoomCreating) {
        tempRoomCreating = [NSMutableDictionary new];
    }
    
    [tempRoomCreating setObject:currentJID forKey:jidString];
    
    XMPPRoomMemoryStorage *roomMemoryStorage = [[XMPPRoomMemoryStorage alloc] init];
    XMPPRoom *xmppRoom = [[XMPPRoom alloc] initWithRoomStorage:roomMemoryStorage jid:chatRoomJID dispatchQueue:dispatch_get_main_queue()];
    [xmppRoom activate:xmppStream];
    [xmppRoom addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    [xmppRoom joinRoomUsingNickname:self.currentJID history:nil password:[infoObj objectForKey:kMUC_ROOM_PASSWORD]];
    [xmppRoom fetchConfigurationForm];
}

- (void)addUserToChatRoom:(NSString *)roomJID TargetJID:(NSString *)targetJID withMessage:(NSString *)message Password:(NSString *)roomPassword
{
    XMPPJID *rJID = [XMPPJID jidWithUser:roomJID domain:XMPP_MUC_HOST_NAME resource:@""];
    XMPPRoomMemoryStorage *roomMemStorage = [[XMPPRoomMemoryStorage alloc] init];
    XMPPRoom *room = [[XMPPRoom alloc] initWithRoomStorage:roomMemStorage jid:rJID dispatchQueue:dispatch_get_main_queue()];
    [room activate:xmppStream];
    [room addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [room inviteUser:[XMPPJID jidWithString:targetJID] withMessage:message];
}

- (void)addUserToRoom:(NSDictionary *)infoObj
{
    NSString *jidString = [NSString stringWithFormat:@"%@@%@", [infoObj objectForKey:kMUC_ROOM_JID], [infoObj objectForKey:kXMPP_MUC_HOST_NAME]];
    XMPPJID *rJID = [XMPPJID jidWithString:jidString];
    
    XMPPRoomMemoryStorage *roomMemStorage = [[XMPPRoomMemoryStorage alloc] init];
    XMPPRoom *room = [[XMPPRoom alloc] initWithRoomStorage:roomMemStorage jid:rJID dispatchQueue:dispatch_get_main_queue()];
    [room activate:xmppStream];
    [room addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [room inviteUser:[XMPPJID jidWithString:[infoObj objectForKey:kXMPP_TO_JID]] withMessage:[infoObj objectForKey:kMUC_ROOM_INVITE_MESSAGE]];
}

- (void)joinChatRoom:(NSString *)chatRoomJID withNickName:(NSString *)nickName andPassword:(NSString *)roomPassword
{
    XMPPJID *roomJID = [XMPPJID jidWithString:chatRoomJID];
    XMPPRoomMemoryStorage *roomMemoryStorage = [[XMPPRoomMemoryStorage alloc] init];
    XMPPRoom *xmppRoom = [[XMPPRoom alloc] initWithRoomStorage:roomMemoryStorage jid:roomJID dispatchQueue:dispatch_get_main_queue()];
    [xmppRoom activate:xmppStream];
    [xmppRoom addDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSXMLElement *history = [NSXMLElement elementWithName:@"history"];
    [history addAttributeWithName:@"maxstanzas" stringValue:@"0"];
    [xmppRoom joinRoomUsingNickname:nickName history:history password:roomPassword];
}

- (void)joinToRoom:(NSDictionary *)infoObj
{
    XMPPJID *roomJID = [XMPPJID jidWithString:[infoObj objectForKey:kMUC_ROOM_JID]];
    XMPPRoomMemoryStorage *roomMemoryStorage = [[XMPPRoomMemoryStorage alloc] init];
    XMPPRoom *xmppRoom = [[XMPPRoom alloc] initWithRoomStorage:roomMemoryStorage jid:roomJID dispatchQueue:dispatch_get_main_queue()];
    [xmppRoom activate:xmppStream];
    [xmppRoom addDelegate:self delegateQueue:dispatch_get_main_queue()];
    /**
     *  @author Daniel Nguyen, 15-05-05 16:05
     *
     *  @brief  this code will set no history for chat room, this will disable xmpp re-send old messages (not offline messages) to user when he rejoin again - after re-lunch app
     */
    NSXMLElement *history = [NSXMLElement elementWithName:@"history"];
    if ([infoObj objectForKey:kMUC_HISTORY]) {
        NSDate *sinceDate = [NSDate dateWithTimeIntervalSince1970:[[infoObj objectForKey:kMUC_HISTORY] doubleValue]];
        [history addAttributeWithName:@"since" stringValue:[sinceDate xmppDateTimeString]];
    } else {
        history = nil;
    }
    
    DDLogInfo(@"%s with history: %@", __PRETTY_FUNCTION__, [history XMLString]);
    
    [xmppRoom joinRoomUsingNickname:[infoObj objectForKey:kXMPP_USER_DISPLAYNAME] history:history password:[infoObj objectForKey:kMUC_ROOM_PASSWORD]];
}

- (void)leaveChatRoom:(NSString *)chatRoomJID
{
    XMPPPresence *presence = [XMPPPresence presence];
    [presence addAttributeWithName:@"from" stringValue:currentJID];
    [presence addAttributeWithName:@"to" stringValue:chatRoomJID];
    [presence addAttributeWithName:@"type" stringValue:kPRESENCE_STATUS_TEXT_UNAVAILABLE];
    NSXMLElement *status = [NSXMLElement elementWithName:@"status" stringValue:@"gone where the goblins go"];
    [presence addChild:status];
    [xmppStream sendElement:presence];
}

- (void)kickUser:(NSString *)targetJID fromRoom:(NSString *)roomJID
{
    // reference: http://xmpp.org/extensions/xep-0045.html#kick
    /*
    <iq from='fluellen@shakespeare.lit/pda'
         id='kick1'
         to='harfleur@chat.shakespeare.lit'
         type='set'>
        <query xmlns='http://jabber.org/protocol/muc#admin'>
            <item nick='pistol' role='none'>
                <reason>Avaunt, you cullion!</reason>
            </item>
        </query>
    </iq>
    */
    
    NSXMLElement *item = [NSXMLElement elementWithName:@"item"];
    [item addAttributeWithName:@"nick" stringValue:targetJID];
    [item addAttributeWithName:@"role" stringValue:@"none"];
    [item addChild:[NSXMLElement elementWithName:@"reason" stringValue:@"Sorry, you are not allowed to be here."]];
    
    NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:XMPPMUCOwnerNamespace];
    [query addChild:item];
    
    XMPPIQ *iq = [XMPPIQ iqWithType:@"set"
                                 to:[XMPPJID jidWithString:roomJID]
                          elementID:[xmppStream generateUUID]
                              child:query];
    [xmppStream sendElement:iq];
}

- (void)banUser:(NSString *)targetJID fromRoom:(NSString *)roomJID;
{
    // reference: http://xmpp.org/extensions/xep-0045.html#ban
    /*
     <iq from='kinghenryv@shakespeare.lit/throne'
            id='ban1'
            to='southampton@chat.shakespeare.lit'
            type='set'>
        <query xmlns='http://jabber.org/protocol/muc#admin'>
            <item affiliation='outcast' jid='earlofcambridge@shakespeare.lit'>
                <reason>Treason</reason>
            </item>
        </query>
     </iq>
     */
    NSXMLElement *item = [NSXMLElement elementWithName:@"item"];
    [item addAttributeWithName:@"affiliation" stringValue:@"outcast"];
    [item addAttributeWithName:@"jid" stringValue:targetJID];
    [item addChild:[NSXMLElement elementWithName:@"reason" stringValue:@"Treason"]];
    
    NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:XMPPMUCOwnerNamespace];
    [query addChild:item];
    
    XMPPIQ *iq = [XMPPIQ iqWithType:@"set"
                                 to:[XMPPJID jidWithString:roomJID]
                          elementID:[xmppStream generateUUID]
                              child:query];
    [xmppStream sendElement:iq];
}

- (void)sendGroupTextMessage:(NSDictionary *)messageInfo
{
    /*
     <message
     from='hag66@shakespeare.lit/pda'
     id='hysf1v37'
     to='coven@chat.shakespeare.lit'
     type='groupchat'>
     <body>Harpier cries: 'tis time, 'tis time.</body>
     </message>
     */
    NSString *toID = [[XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@", [messageInfo objectForKey:kMUC_SEND_TEXT_TARGET_ROOMJID], kXMPP_MUC_HOST_NAME]] full];
    NSString *msgID = [[NSString stringWithFormat:@"%@:%@", toID, [NSString getCurrentTime]] MD5String];
    
    NSXMLElement *body = [NSXMLElement elementWithName:@"body" stringValue:[messageInfo objectForKey:kMUC_SEND_TEXT_MESSAGE_VALUE]];
    XMPPMessage *message = [XMPPMessage message];
    [message addAttributeWithName:@"to" stringValue:toID];
    [message addAttributeWithName:@"type" stringValue:@"groupchat"];
    [message addAttributeWithName:@"id" stringValue:msgID];
    [message addAttributeWithName:@"from" stringValue:currentJID];
    [message addChild:body];
    [xmppStream sendElement:message];
}

- (void)bookmarkGroupChat:(NSDictionary *)infoObj
{
    NSXMLElement *pubsub = [[NSXMLElement alloc] initWithName:@"pubsub" xmlns:@"http://jabber.org/protocol/pubsub"];
    NSXMLElement *publish = [[NSXMLElement alloc] initWithName:@"publish"];
    [publish addAttributeWithName:@"node" stringValue:@"storage:bookmarks"];
    NSXMLElement *item = [[NSXMLElement alloc] initWithName:@"item"];
    [item addAttributeWithName:@"id" stringValue:@"current"];
    NSXMLElement *storage = [[NSXMLElement alloc] initWithName:@"storage" xmlns:@"storage:bookmarks"];
    NSXMLElement *conference = [[NSXMLElement alloc] initWithName:@"conference"];
    [conference addAttributeWithName:@"name" stringValue:[infoObj objectForKey:kMUC_ROOM_JID]];//optinal
    [conference addAttributeWithName:@"autojoin" stringValue:@"true"];
    [conference addAttributeWithName:@"jid" stringValue:[infoObj objectForKey:kMUC_ROOM_JID]];//full room jid
    NSXMLElement *nick = [[NSXMLElement alloc] initWithName:@"nick" stringValue:currentJID];//full jid of current user
    [conference addChild:nick];
    [storage addChild:conference];
    [item addChild:storage];
    [publish addChild:item];
    
    NSXMLElement *publish_options = [[NSXMLElement alloc] initWithName:@"publish-options"];
    NSXMLElement *x = [[NSXMLElement alloc] initWithName:@"x" xmlns:@"jabber:x:data"];
    [x addAttributeWithName:@"type" stringValue:@"submit"];
    NSXMLElement *field1 = [[NSXMLElement alloc] initWithName:@"field"];
    [field1 addAttributeWithName:@"var" stringValue:@"FORM_TYPE"];
    [field1 addAttributeWithName:@"type" stringValue:@"hidden"];
    NSXMLElement *value1 = [[NSXMLElement alloc] initWithName:@"value" stringValue:@"http://jabber.org/protocol/pubsub#publish-options"];
    [field1 addChild:value1];
    [x addChild:field1];
    NSXMLElement *field2 = [[NSXMLElement alloc] initWithName:@"field"];
    [field2 addAttributeWithName:@"var" stringValue:@"pubsub#persist_items"];
    NSXMLElement *value2 = [[NSXMLElement alloc] initWithName:@"value" stringValue:@"whitelist"];
    [field2 addChild:value2];
    [x addChild:field2];
    [publish_options addChild:x];
    
    [pubsub addChild:publish];
    [pubsub addChild:publish_options];
    
    XMPPIQ *iq = [[XMPPIQ alloc] initWithType:@"set" child:pubsub];
    [iq addAttributeWithName:@"from" stringValue:currentJID];
    [iq addAttributeWithName:@"id" stringValue:[[NSString getCurrentTime] MD5String]];
    
    [xmppStream sendElement:iq];
}

- (void)setNoDiscussionHistory:(NSString *)fullRoomJID
{
    /*
     <presence from='hag66@shakespeare.lit/pda' id='n13mt3l' to='coven@chat.shakespeare.lit/thirdwitch'>
        <x xmlns='http://jabber.org/protocol/muc'>
            <history maxchars='0'/>
        </x>
     </presence>
     */
    XMPPPresence *presence = [XMPPPresence presence];
    [presence addAttributeWithName:@"from" stringValue:currentJID];
    [presence addAttributeWithName:@"to" stringValue:fullRoomJID];
    [presence addAttributeWithName:@"id" stringValue:[[NSString getCurrentTime] MD5String]];
    [xmppStream sendElement:presence];
    
    NSXMLElement *x = [NSXMLElement elementWithName:@"x" xmlns:XMPPMUCNamespace];
    
    NSXMLElement *history = [NSXMLElement elementWithName:@"maxchars" stringValue:@"0"];
    [x addChild:history];
    
    [presence addChild:x];
    
    [[self xmppStream] sendElement:presence];
}

#pragma mark - Utils
- (NSDictionary *)parsevCardInfoFromXMLString:(NSString *)xmlstring
{
    NSError *error = nil;
    DDXMLElement *elem = [[DDXMLElement alloc] initWithXMLString:xmlstring error:&error];
    
    if (!error) {
        NSMutableDictionary *tmp = [[NSMutableDictionary alloc] init];
        if ([elem elementForName:@"display_name"]) {
            [tmp setObject:[[elem elementForName:@"display_name"] stringValue] forKey:kXMPP_USER_DISPLAYNAME];
        }
        if ([elem elementForName:@"masking_id"]) {
            [tmp setObject:[[elem elementForName:@"masking_id"] stringValue] forKey:kXMPP_USER_MASKING_ID];
        }
        if ([elem elementForName:@"email"]) {
            [tmp setObject:[[elem elementForName:@"email"] stringValue] forKey:kXMPP_USER_EMAIL];
        }
        
        NSData *decodedData = nil;
        NSXMLElement *photo = [elem elementForName:@"PHOTO"];

        if (photo != nil) {
            NSXMLElement *binval = [photo elementForName:@"BINVAL"];

            if (binval) {
                NSData *base64Data = [[binval stringValue] dataUsingEncoding:NSASCIIStringEncoding];
                decodedData = [base64Data xmpp_base64Decoded];
                
                if (decodedData != nil) {
                    [tmp setObject:decodedData forKey:kAVATAR_IMAGE_DATA];
                }
            }
        }
        
        if (tmp) {
            return tmp;
        }
    }
    
    return nil;
}

- (void)startAutoReconnect
{
    if (xmppReconnect) {
        xmppReconnect.autoReconnect = TRUE;
        [xmppReconnect manualStart];
    }
}

- (void)stopAutoReconnect
{
    if (xmppReconnect) {
        xmppReconnect.autoReconnect = FALSE;
        [xmppReconnect stop];
    }
}

- (void)resetStreamManagement
{
    if (xmppSM) {
        [xmppSM removeDelegate:self];
        [xmppSM deactivate];
        
        xmppSM = nil;
    }
    
    XMPPStreamManagementMemoryStorage *xmppSMMS = [[XMPPStreamManagementMemoryStorage alloc] init];
    xmppSM = [[XMPPStreamManagement alloc] initWithStorage:xmppSMMS dispatchQueue:dispatch_get_main_queue()];
    [xmppSM setAutoResume:YES];
    
    [xmppSM activate:xmppStream];
    [xmppSM addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    [xmppSM enableStreamManagementWithResumption:YES maxTimeout:0];
    [xmppSM automaticallySendAcksAfterStanzaCount:5 orTimeout:20];
    [xmppSM automaticallyRequestAcksAfterStanzaCount:5 orTimeout:20];
}

@end
