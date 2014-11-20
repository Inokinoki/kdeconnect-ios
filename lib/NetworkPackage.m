//Copyright 27/4/14  YANG Qiao yangqiao0505@me.com
//kdeconnect is distributed under two licenses.
//
//* The Mozilla Public License (MPL) v2.0
//
//or
//
//* The General Public License (GPL) v2.1
//
//----------------------------------------------------------------------
//
//Software distributed under these licenses is distributed on an "AS
//IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
//implied. See the License for the specific language governing rights
//and limitations under the License.
//kdeconnect is distributed under both the GPL and the MPL. The MPL
//notice, reproduced below, covers the use of either of the licenses.
//
//---------------------------------------------------------------------

#import "NetworkPackage.h"
#import "SecKeyWrapper.h"
#import "KeychainItemWrapper.h"
#import "PluginFactory.h"

#define LFDATA [NSData dataWithBytes:"\x0D\x0A" length:2]

__strong static NSString* _publicKeyStr;
__strong static NSString* _UUID;

#pragma mark Implementation
@implementation NetworkPackage

- (NetworkPackage*) initWithType:(NSString *)type
{
    if ((self=[super init]))
    {
        _Id=[[NSNumber numberWithLong:[[NSDate date] timeIntervalSince1970]] stringValue];
        _Type=type;
        _Body=[NSMutableDictionary dictionary];
        _publicKeyStr=nil;
    }
    return self;
}

@synthesize _Id;
@synthesize _Type;
@synthesize _Body;
@synthesize _Payload;
@synthesize _PayloadSize;
@synthesize _PayloadTransferInfo;

#pragma mark create Package
+(NetworkPackage*) createIdentityPackage
{
    NetworkPackage* np=[[NetworkPackage alloc] initWithType:PACKAGE_TYPE_IDENTITY];
    [np setObject:[NetworkPackage getUUID]forKey:@"deviceId"];
    [np setObject:[UIDevice currentDevice].name forKey:@"deviceName"];
    [np setInteger:ProtocolVersion forKey:@"protocolVersion"];
    [np setObject:@"Phone" forKey:@"deviceType"];
    [np setInteger:1714 forKey:@"tcpPort"];
    [np setObject:[[[PluginFactory sharedInstance] getSupportedIncomingInterfaces] componentsJoinedByString:@","] forKey:@"SupportedIncomingInterfaces"];
    [np setObject:[[[PluginFactory sharedInstance] getSupportedOutgoingInterfaces] componentsJoinedByString:@"," ] forKey:@"SupportedOutgoingInterfaces"];
//    [np setObject:[[PluginFactory sharedInstance] getSupportedIncomingInterfaces] forKey:@"SupportedIncomingInterfaces"];
//    [np setObject:[[PluginFactory sharedInstance] getSupportedOutgoingInterfaces] forKey:@"SupportedOutgoingInterfaces"];
//    
    return np;
}

//Never touch these!
+ (NSString*) getUUID
{
    if (!_UUID) {
        NSString* group=@"34RXKJTKWE.org.kde.kdeconnect-ios";
        KeychainItemWrapper* wrapper=[[KeychainItemWrapper alloc] initWithIdentifier:@"org.kde.kdeconnect-ios" accessGroup:group];
        _UUID=[wrapper objectForKey:(__bridge id)(kSecValueData)];
        if (!_UUID) {
            _UUID=[[UIDevice currentDevice].identifierForVendor UUIDString];
            _UUID=[_UUID stringByReplacingOccurrencesOfString:@"-" withString:@""];
            _UUID=[_UUID stringByReplacingOccurrencesOfString:@"_" withString:@""];
            [wrapper setObject:_UUID forKey:(__bridge id)(kSecValueData)];
        }
    }
    return _UUID;
}

+ (NetworkPackage*) createPublicKeyPackage
{
    NetworkPackage* np=[[NetworkPackage alloc] initWithType:PACKAGE_TYPE_PAIR];
    if (!_publicKeyStr) {
        NSString* publicKeyStr=[[SecKeyWrapper sharedWrapper] getRSAPublicKeyAsBase64];
        _publicKeyStr=[NSString stringWithFormat:@"%@\n%@\n%@\n",
                       @"-----BEGIN PUBLIC KEY-----",
                       publicKeyStr,
                       @"-----END PUBLIC KEY-----"];
    }
    [np setObject:_publicKeyStr forKey:@"publicKey"];
    [np setBool:YES forKey:@"pair"];

    return np;
}

- (NSData*) retrievePublicKeyBits
{
    NSString* publickeyStr=[_Body valueForKey:@"publicKey"];
    NSArray* strArray=[publickeyStr componentsSeparatedByString:@"\n"];
    NSRange keyRange;
    keyRange.location=1;
    keyRange.length=[strArray count]-3;
    publickeyStr=[[strArray subarrayWithRange:keyRange] componentsJoinedByString:@"\n"];
    return [[NSData alloc] initWithBase64EncodedString:publickeyStr options:NSDataBase64DecodingIgnoreUnknownCharacters];
}

//
- (BOOL) bodyHasKey:(NSString*)key
{
    if ([self._Body valueForKey:key]!=nil) {
        return true;
    }
    return false;
};

- (void)setBool:(BOOL)value forKey:(NSString*)key {
    [self setObject:[NSNumber numberWithBool:value] forKey:key];
}

- (void)setFloat:(float)value forKey:(NSString*)key {
    [self setObject:[NSNumber numberWithFloat:value] forKey:key];
}

- (void)setInteger:(NSInteger)value forKey:(NSString*)key {
    [self setObject:[NSNumber numberWithInteger:value] forKey:key];
}

- (void)setDouble:(double)value forKey:(NSString*)key {
    [self setObject:[NSNumber numberWithDouble:value] forKey:key];
}

- (void)setObject:(id)value forKey:(NSString *)key{
    [_Body setObject:value forKey:key];
}

- (BOOL)boolForKey:(NSString*)key {
    return [[self objectForKey:key] boolValue];
}

- (float)floatForKey:(NSString*)key {
    return [[self objectForKey:key] floatValue];
}
- (NSInteger)integerForKey:(NSString*)key {
    return [[self objectForKey:key] integerValue];
}

- (double)doubleForKey:(NSString*)key {
    return [[self objectForKey:key] doubleValue];
}

- (id)objectForKey:(NSString *)key{
    return [_Body objectForKey:key];
}

#pragma mark Serialize
- (NSData*) serialize
{
    NSArray* keys=[NSArray arrayWithObjects:@"id",@"type",@"body", nil];
    NSArray* values=[NSArray arrayWithObjects:[self _Id],[self _Type],[self _Body], nil];
    NSMutableDictionary* info=[NSMutableDictionary dictionaryWithObjects:values forKeys:keys];
    if (_Payload) {
        [info setObject:[NSNumber numberWithLong:(_PayloadSize?_PayloadSize:-1)] forKey:@"payloadSize"];
        [info setObject:_PayloadTransferInfo forKey:@"payloadTransferInfo"];
    }
    NSError* err=nil;
    NSMutableData* jsonData=[[NSMutableData alloc] initWithData:[NSJSONSerialization dataWithJSONObject:info options:0 error:&err]];
    if (err) {
        //NSLog(@"NP serialize error");
        return nil;
    }
    [jsonData appendData:LFDATA];
    return jsonData;
}

+ (NetworkPackage*) unserialize:(NSData*)data
{
    NetworkPackage* np=[[NetworkPackage alloc] init];
    NSError* err=nil;
    NSDictionary* info=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];

    [np set_Id:[info valueForKey:@"id"]];
    [np set_Type:[info valueForKey:@"type"]];
    [np set_Body:[info valueForKey:@"body"]];
    [np set_PayloadSize:[[info valueForKey:@"payloadSize"]longValue]];
    [np set_PayloadTransferInfo:[info valueForKey:@"payloadTransferInfo"]];
    
    //TO-DO should change for laptop
    if ([np _PayloadSize]==-1) {
        NSInteger temp;
        long size=(temp=[np integerForKey:@"size"])?temp:-1;
        [np set_PayloadSize:size];
    }
    [np set_PayloadTransferInfo:[info valueForKey:@"payloadTransferInfo"]];
    
    if (err) {
        return nil;
    }
    return np;
}

#pragma mark Encyption
- (BOOL) isEncrypted
{
    return [_Type isEqual:PACKAGE_TYPE_ENCRYPTED];
};

- (NetworkPackage*) encryptWithPublicKeyRef:(SecKeyRef)publicKeyRef
{
    NetworkPackage* np=[[NetworkPackage alloc] initWithType:PACKAGE_TYPE_ENCRYPTED];
    NSData* data=[self serialize];
    NSArray* encryptedArray=[[SecKeyWrapper sharedWrapper] encryptDataToArray:data  withPublicKeyRef:publicKeyRef];
    [np setObject:encryptedArray forKey:@"data"];
    return np;
};

- (NetworkPackage*) decrypt
{
    if (![_Type isEqualToString:PACKAGE_TYPE_ENCRYPTED]) {
        return nil;
    }
    NSArray* encryptedDataStrArray=[_Body valueForKey:@"data"];
    NSData* decryptedData=[[SecKeyWrapper sharedWrapper] decryptDataArray:encryptedDataStrArray];
    
    return [NetworkPackage unserialize:decryptedData];
};

@end
