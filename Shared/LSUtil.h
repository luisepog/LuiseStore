@import Foundation;
#import "CoreServices.h"

#define LuiseStoreErrorDomain @"LuiseStoreErrorDomain"

#define LS_MARKER @"_LuiseStore"
#define LS_LITE_MARKER @"_LuiseStoreLite"
#define LS_NAME @"LuiseStore"
#define LS_LITE_NAME @"LuiseStore Lite"

#ifdef LUISESTORE_LITE
#define LS_ACTIVE_MARKER LS_LITE_MARKER
#define LS_INACTIVE_MARKER LS_MARKER
#define APP_ID @"com.opa334.LuiseStoreLite"
#define APP_NAME LS_LITE_NAME
#define OTHER_APP_NAME LS_NAME
#else
#define LS_ACTIVE_MARKER LS_MARKER
#define LS_INACTIVE_MARKER LS_LITE_MARKER
#define APP_ID @"com.opa334.LuiseStore"
#define APP_NAME LS_NAME
#define OTHER_APP_NAME LS_LITE_NAME
#endif

extern void chineseWifiFixup(void);
extern NSString *getExecutablePath(void);
extern BOOL shouldRegisterAsUserByDefault(void);
extern NSString* rootHelperPath(void);
extern NSString* getNSStringFromFile(int fd);
extern void printMultilineNSString(NSString* stringToPrint);
extern int spawnRoot(NSString* path, NSArray* args, NSString** stdOut, NSString** stdErr);
extern void killall(NSString* processName, BOOL softly);
extern void respring(void);
extern void fetchLatestLuiseStoreVersion(void (^completionHandler)(NSString* latestVersion));
extern void fetchLatestLdidVersion(void (^completionHandler)(NSString* latestVersion));

extern NSArray* luiseStoreInstalledAppBundlePaths(void);
extern NSArray* luiseStoreInactiveInstalledAppBundlePaths(void);
extern NSArray* luiseStoreInstalledAppContainerPaths(void);
extern NSString* luiseStorePath(void);
extern NSString* luiseStoreAppPath(void);

extern BOOL isRemovableSystemApp(NSString* appId);

#import <UIKit/UIAlertController.h>

@interface UIAlertController (Private)
@property (setter=_setAttributedTitle:,getter=_attributedTitle,nonatomic,copy) NSAttributedString* attributedTitle;
@property (setter=_setAttributedMessage:,getter=_attributedMessage,nonatomic,copy) NSAttributedString* attributedMessage;
@property (nonatomic,retain) UIImage* image;
@end

typedef enum
{
	PERSISTENCE_HELPER_TYPE_USER = 1 << 0,
	PERSISTENCE_HELPER_TYPE_SYSTEM = 1 << 1,
	PERSISTENCE_HELPER_TYPE_ALL = PERSISTENCE_HELPER_TYPE_USER | PERSISTENCE_HELPER_TYPE_SYSTEM
} PERSISTENCE_HELPER_TYPE;

// EXPLOIT_TYPE is defined as a bitmask as some devices are vulnerable to multiple exploits
//
// An app that has had one of these exploits applied ahead of time can declare which exploit
// was used via the TSPreAppliedExploitType Info.plist key. The corresponding value should be
// (number of bits to left-shift + 1).
typedef enum
{
	// CVE-2022-26766
    // TSPreAppliedExploitType = 1
	EXPLOIT_TYPE_CUSTOM_ROOT_CERTIFICATE_V1 = 1 << 0,

	// CVE-2023-41991
    // TSPreAppliedExploitType = 2
	EXPLOIT_TYPE_CMS_SIGNERINFO_V1 = 1 << 1
} EXPLOIT_TYPE;

extern LSApplicationProxy* findPersistenceHelperApp(PERSISTENCE_HELPER_TYPE allowedTypes);

typedef struct __SecCode const *SecStaticCodeRef;

typedef CF_OPTIONS(uint32_t, SecCSFlags) {
	kSecCSDefaultFlags = 0
};
#define kSecCSRequirementInformation 1 << 2
#define kSecCSSigningInformation 1 << 1

OSStatus SecStaticCodeCreateWithPathAndAttributes(CFURLRef path, SecCSFlags flags, CFDictionaryRef attributes, SecStaticCodeRef *staticCode);
OSStatus SecCodeCopySigningInformation(SecStaticCodeRef code, SecCSFlags flags, CFDictionaryRef *information);
CFDataRef SecCertificateCopyExtensionValue(SecCertificateRef certificate, CFTypeRef extensionOID, bool *isCritical);
void SecPolicySetOptionsValue(SecPolicyRef policy, CFStringRef key, CFTypeRef value);

extern CFStringRef kSecCodeInfoEntitlementsDict;
extern CFStringRef kSecCodeInfoCertificates;
extern CFStringRef kSecPolicyAppleiPhoneApplicationSigning;
extern CFStringRef kSecPolicyAppleiPhoneProfileApplicationSigning;
extern CFStringRef kSecPolicyLeafMarkerOid;

extern SecStaticCodeRef getStaticCodeRef(NSString *binaryPath);
extern NSDictionary* dumpEntitlements(SecStaticCodeRef codeRef);
extern NSDictionary* dumpEntitlementsFromBinaryAtPath(NSString *binaryPath);
extern NSDictionary* dumpEntitlementsFromBinaryData(NSData* binaryData);

extern EXPLOIT_TYPE getDeclaredExploitTypeFromInfoDictionary(NSDictionary *infoDict);
extern bool isPlatformVulnerableToExploitType(EXPLOIT_TYPE exploitType);
