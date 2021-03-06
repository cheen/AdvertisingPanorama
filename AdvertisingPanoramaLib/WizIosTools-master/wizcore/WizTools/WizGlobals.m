//
//  WizGlobals.m
//  Wiz
//
//  Created by Wei Shijun on 3/4/11.
//  Copyright 2011 WizBrother. All rights reserved.
//
#import <CommonCrypto/CommonDigest.h>
#import <QuartzCore/QuartzCore.h>
#import "WizGlobals.h"
#import "WizLogger.h"
#import <mach/mach.h>
#import "WizNetworkEngine.h"
#include "stdio.h"
#define ATTACHMENTTEMPFLITER @"attchmentTempFliter"
#define MD5PART 10*1024
NSUInteger DeviceSystemMajorVersion() {
    static NSUInteger _deviceSystemMajorVersion = -1;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _deviceSystemMajorVersion = [[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."] objectAtIndex:0] intValue];
    });
    return _deviceSystemMajorVersion;
}
const static int WizNoteIphoneId = 599493807;
const static int WizNoteIpadId = 634852089;

NSString* const WizCrashHanppend    = @"WizCrashHanppend";
NSString* accountStatus = WizStrUserNew;

void addArgumentToArray(NSMutableArray* array, id param)
{
    if (param) {
        [array addObject:param];
    }
    else
    {
        [array addObject:[NSNull null]];
    }
}

void (^SendSelectorToObjectInMainThreadWithParams)(SEL selector, id observer, NSArray* params) = ^(SEL selector, id observer, NSArray* params)
{
    if([observer respondsToSelector:selector])
    {
        NSMethodSignature* methodSignature = [[observer class] instanceMethodSignatureForSelector:selector];
        if(methodSignature)
        {
            NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
            [invocation setSelector:selector];
            [invocation setTarget:observer];
            NSInteger count = [params count];
            for(int i = 2 ; i < count + 2; ++i)
            {
                id argument = [params objectAtIndex:i-2];
                if([argument isKindOfClass:[NSNull class]])
                {
                    continue;
                }
                else
                {
                    [invocation setArgument:&argument atIndex:i];
                }
            }
            [invocation retainArguments];
            if([NSThread isMainThread])
            {
                [invocation invoke];
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [invocation invoke];
                });
            }
        }
    }
};
void (^SendSelectorToObjectInMainThread)(SEL selector, id observer, id params) = ^(SEL selector, id observer, id params){
    NSMutableArray* array = [NSMutableArray array];
    addArgumentToArray(array, params);
    SendSelectorToObjectInMainThreadWithParams(selector, observer, array);
    
};
void (^SendSelectorToObjectInMainThreadWithoutParams)(SEL selecrot, id object) = ^(SEL selecrot, id object)
{
    SendSelectorToObjectInMainThreadWithParams(selecrot,object,nil);
};


void (^SendSelectorToObjectInMainThreadWith2Params)(SEL selector, id observer, id params, id) = ^(SEL selector, id observer, id params1, id param2){
    
    NSMutableArray* array = [NSMutableArray array];
    addArgumentToArray(array, params1);
    addArgumentToArray(array, param2);
    SendSelectorToObjectInMainThreadWithParams(selector, observer, array);
    
};



void (^SendSelectorToObjectInMainThreadWith3Params)(SEL selector, id observer , id param1, id param2, id param3) = ^(SEL selector, id observer , id param1, id param2, id param3)
{
    NSMutableArray* array = [NSMutableArray array];
    addArgumentToArray(array, param1);
    addArgumentToArray(array, param2);
    addArgumentToArray(array, param3);
    SendSelectorToObjectInMainThreadWithParams(selector,observer,array);
};

void PRINT_CGPOINT(CGPoint point)
{
    DDLogCInfo(@"point x:%f y:%f",point.x, point.y);
}

void PRINT_CGSIZE(CGSize size)
{
    DDLogCInfo(@"size width:%f height:%f",size.width, size.height);
}

void PRINT_UIEGDE(UIEdgeInsets ed)
{
    DDLogCInfo(@"EdgeInset top:%f bottom:%f left:%f right:%f", ed.top, ed.bottom, ed.left, ed.right);
}

void PRINT_CGRECT(CGRect rect)
{
    DDLogCInfo(@"x:%f y:%f width:%f height:%f",CGRectGetMinX(rect), CGRectGetMinY(rect), CGRectGetWidth(rect), CGRectGetHeight(rect));
}

@implementation WizGlobals

static NSArray*  pptArray;
static NSArray*  docArray;
static NSArray*  audioArray;
static NSArray* textArray;
static NSArray* imageArray;
static NSArray* excelArray;
static NSArray* htmlArray;
static NSArray* pdfArray;
/**
 *得到本机现在用的语言
 * en:英文  zh-Hans:简体中文   zh-Hant:繁体中文    ja:日本  ......
 */
+ (NSString*)getPreferredLanguage
{
    NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
    NSArray* languages = [defs objectForKey:@"AppleLanguages"];
    NSString* preferredLang = [languages objectAtIndex:0];
    return preferredLang;
}

+ (BOOL) isChineseEnviroment
{
    NSString* currentLanguage = [[WizGlobals getPreferredLanguage] lowercaseString];
    if ([currentLanguage isEqualToString:[@"zh-Hans" lowercaseString]]) {
        return YES;
    }
    else
    {
        return NO;
    }
}
+ (float) WizDeviceVersion
{
    return [[[UIDevice currentDevice] systemVersion] floatValue];
}
+ (NSString*) timerStringFromTimerInver:(NSTimeInterval) ftime
{
    NSInteger totalTime = ceil(ftime);
    NSInteger s = totalTime % 60;
    NSInteger m = totalTime / 60 % 60;
    NSInteger h = totalTime / 60 / 60 % 24;
    return [NSString stringWithFormat:@"%002d:%002d:%002d",h,m,s];
}

+(BOOL)deviceIsRetina
{
    static BOOL isRetina = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIImage* image = WizImageByKind(ImageOfFunctionSetting);
        if (image.scale == 2) {
            isRetina = YES;
        }else{
            isRetina = NO;
        }
    });
    return isRetina;
}

+(BOOL) DeviceIsPad
{
    static BOOL deviceisPad = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if ([[UIDevice currentDevice] respondsToSelector:@selector(userInterfaceIdiom)])
        {
            UIDevice* device = [UIDevice currentDevice];
            UIUserInterfaceIdiom deviceId = device.userInterfaceIdiom;
            if (deviceId == UIUserInterfaceIdiomPad) {
                deviceisPad = YES;
            }
            else
            {
                deviceisPad = NO;
            }
        }
    });
	return deviceisPad;
}

+(BOOL) WizDeviceIsPad
{
	BOOL b =[self DeviceIsPad];
	return b;
}
+(NSString*) md5:(NSData *)input {
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(input.bytes, input.length, md5Buffer);
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH *2];
    for(int i =0; i <CC_MD5_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x",md5Buffer[i]];
    }
    return  output;
}
+ (void) decorateViewWithShadowAndBorder:(UIView*)view
{
    CALayer* layer = [view layer];
    layer.borderColor = [UIColor grayColor].CGColor;
    layer.borderWidth = 0.5f;
    layer.shadowColor = [UIColor grayColor].CGColor;
    layer.shadowOffset = CGSizeMake(2, 2);
    layer.shadowOpacity = 0.5;
    layer.shadowRadius = 2;
    layer.cornerRadius = 5;

}
+ (UIView*) noNotesRemindFor:(NSString*)string
{
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320, 480)];
    UIImageView* pushDownRemind = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"documentWithoutData"]];
    pushDownRemind.frame = CGRectMake(120, 100, 80, 80);
    [view addSubview:pushDownRemind];
    CALayer* layer = [pushDownRemind layer];
    layer.borderColor = [UIColor whiteColor].CGColor;
    layer.borderWidth = 0.5f;
    layer.shadowColor = [UIColor grayColor].CGColor;
    layer.shadowOffset = CGSizeMake(1, 1);
    layer.shadowOpacity = 0.5;
    layer.shadowRadius = 0.5;
    UITextView* remind = [[UITextView alloc] initWithFrame:CGRectMake(80, 200, 160, 480)];
    remind.text = string;
    remind.backgroundColor = [UIColor clearColor];
    remind.textColor = [UIColor grayColor];
    [view addSubview:remind];
    remind.textAlignment = UITextAlignmentCenter;
    
    return view;
}
+ (UIView*) noNotesRemind
{
    UIImageView* pushDownRemind = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pushDownRemind"]];
    UITextView* remind = [[UITextView alloc] initWithFrame:CGRectMake(80, 250, 160, 480)];
    remind.text = NSLocalizedString(@"You can pull down to sync notes or tap the plus (+) icon to create a new a note", nil);
    remind.backgroundColor = [UIColor clearColor];
    remind.textColor = [UIColor grayColor];
    [pushDownRemind addSubview:remind];
    remind.textAlignment = UITextAlignmentCenter;
    pushDownRemind.tag = 10001;
    return pushDownRemind ;
}
+ (BOOL) checkObjectIsDocument:(NSString*)type
{
    return [type isEqualToString:@"document"];
}
+ (BOOL) checkObjectIsAttachment:(NSString*)type
{
    return [type isEqualToString:@"attachment"];
}
+ (NSString*) documentKeyString
{
    return @"document";
}
+ (NSString*) attachmentKeyString
{
    return @"attachment";
}
+(NSString*)fileMD5:(NSString*)path  
{  
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:path];  
    if( handle== nil ) return @"ERROR GETTING FILE MD5"; // file didnt exist  
    
    CC_MD5_CTX md5;  
    
    CC_MD5_Init(&md5);  
    
    BOOL done = NO;  
    while(!done)  
    {  
        NSData* fileData = [handle readDataOfLength: MD5PART ];  
        CC_MD5_Update(&md5, [fileData bytes], [fileData length]);  
        if( [fileData length] == 0 ) done = YES;  
    }  
    unsigned char digest[CC_MD5_DIGEST_LENGTH];  
    CC_MD5_Final(digest, &md5);  
    NSString* s = [NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",  
                   digest[0], digest[1],   
                   digest[2], digest[3],  
                   digest[4], digest[5],  
                   digest[6], digest[7],  
                   digest[8], digest[9],  
                   digest[10], digest[11],  
                   digest[12], digest[13],  
                   digest[14], digest[15]];  
    return s;  
} 

+ (BOOL) checkFileIsEncry:(NSString*)filePath
{
    NSFileHandle* file = [NSFileHandle fileHandleForReadingAtPath:filePath];
    NSData* data  = [file readDataOfLength:4];
    if (data.length < 4) {
        return YES;
    }
    unsigned char* sd =(unsigned char*)[data bytes];
    if (sd[0] == 90 && sd[1] == 73 && sd[2] == 87 && sd[3] == 82) {
        return YES;
    }
    else {
        return NO;
    }
}
+(float) heightForWizTableFooter:(int)exisitCellCount orientation:(UIInterfaceOrientation)orientation
{
    float currentTableHeight = exisitCellCount*44.0;
    CGFloat height = [UIScreen mainScreen].bounds.size.height - 108;
    if (UIDeviceOrientationIsLandscape(orientation)) {
        height = [UIScreen mainScreen].bounds.size.width - 96;
    }
    if (height - currentTableHeight <= 100) {
        return 100;
    }else{
        return height - currentTableHeight;
    }
}

+ (NSString*) folderStringToLocal:(NSString*) str
{
    if (!str) {
        return nil;
    }
    static NSMutableDictionary* folderLocaldictionary  = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        folderLocaldictionary = [NSMutableDictionary new];
    });
    NSString* localStr = folderLocaldictionary[str];
    if (!localStr) {
        NSArray* strArr = [str componentsSeparatedByString:@"/"];
        NSMutableString* ret = [NSMutableString string];
        for (NSString* each in strArr) {
            if ([each isEqualToString:@""]) {
                continue;
            }
            NSString* localStr = NSLocalizedString(each, nil);
            [ret appendFormat:@"/%@",localStr];
        }
        localStr = ret;
        if (localStr) {
            @synchronized(folderLocaldictionary)
            {
                [folderLocaldictionary setObject:localStr forKey:str];
            }
        }
    }
    return localStr;
}

+(int)currentTimeZone
{
	static int hours = 100;
	if (hours == 100)
	{
		NSTimeZone* tz = [NSTimeZone systemTimeZone];
		int seconds = [tz secondsFromGMTForDate:[NSDate date]];
		//
		hours = seconds / 60 / 60;
	}
	//
	return hours;
}
+(long long) getFileSize: (NSString*)filePath
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        NSDictionary* attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
        return [attributes fileSize];
    }
    //
    return 0;
}

+ (BOOL) checkAttachmentType:(NSString*)type   isType:(NSString*)isType
{
    if (![type compare:isType options:NSCaseInsensitiveSearch]) {
        return YES;
    }
    else {
        return NO;
    }
}
+ (BOOL) checkAttachmentTypeInTypeArray:(NSString*)type  typeArray:(NSArray*)typeArray
{
    for (NSString* eachType in typeArray) {
        if ([WizGlobals checkAttachmentType:type isType:eachType]) {
            return YES;
        }
    }
    return NO;
}
+ (NSArray*) textArray
{

        textArray = [NSArray arrayWithObjects:@"txt", nil];
    
    return textArray;
}
+ (BOOL) checkAttachmentTypeIsTxt:(NSString*)attachmentType
{
    return [WizGlobals checkAttachmentTypeInTypeArray:attachmentType typeArray:[WizGlobals textArray]];
}
+ (NSArray*) audioArray
{
 
        audioArray = [NSArray arrayWithObjects:
                      @"aif",
                      @"amr",
                      @"mp3",
                      @"wav",
                      nil];
    
    return audioArray;
}
+ (BOOL) checkAttachmentTypeIsAudio:(NSString *)attachmentType
{
    return [WizGlobals checkAttachmentTypeInTypeArray:attachmentType typeArray:[WizGlobals audioArray]];
}
+ (NSArray*) imageArray
{

        imageArray = [NSArray arrayWithObjects:
                      @"png",
                      @"jpg",
                      @"jpeg",
                      @"bmp",
                      @"gif",
                      @"tiff",
                      @"eps",
                      nil];
    return imageArray;
}
+ (BOOL) checkAttachmentTypeIsImage:(NSString *)attachmentType
{
    return [WizGlobals checkAttachmentTypeInTypeArray:attachmentType typeArray:[self imageArray]];
}
+ (NSArray*) pptArray
{
        pptArray = [NSArray arrayWithObjects:
                    @"ppt",
                    @"pptx",
                    nil];
    return pptArray;
}
+ (BOOL) checkAttachmentTypeIsPPT:(NSString*)type
{
    return [WizGlobals checkAttachmentTypeInTypeArray:type typeArray:[WizGlobals pptArray]];
}
+ (NSArray*) docArray
{
    if (docArray == nil) {
        docArray = [NSArray arrayWithObjects:
                    @"doc",
                    @"docx",
                    nil];
    }
    return docArray;
}
+ (BOOL) checkAttachmentTypeIsWord:(NSString*)type
{
    return [WizGlobals checkAttachmentTypeInTypeArray:type typeArray:[WizGlobals docArray]];
}

 + (NSArray*) htmlArray
{
    if (htmlArray == nil) {
        htmlArray = [NSArray arrayWithObjects:
                     @"html",
                     nil];
    }
    return htmlArray;
}

+ (BOOL) checkAttachmentTypeIsHtml:(NSString *)attachmentType
{
    return [WizGlobals checkAttachmentTypeInTypeArray:attachmentType typeArray:[WizGlobals htmlArray]];
}
+ (BOOL)checkAttachmentTypeIsPdf:(NSString*)attachmentType
{
    return [WizGlobals checkAttachmentTypeInTypeArray:attachmentType typeArray:[WizGlobals pdfArray]];
}

+(NSArray*) pdfArray
{
    pdfArray = [NSArray arrayWithObjects:@"pdf", nil];
    return pdfArray;
}

+ (NSArray*) excelArray
{
    excelArray = [NSArray arrayWithObjects:
                      @"xls",
                      @"xlsx",
                      nil];
    
    return excelArray;
}
+(void) reportMemory
{
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    kern_return_t kerr = task_info(mach_task_self(),
                                   TASK_BASIC_INFO,
                                   (task_info_t)&info,
                                   &size);
    if( kerr == KERN_SUCCESS ) {
        NSLog(@"Memory in use (in Mb): %u Mb", info.resident_size/1024/1024);
    } else {
        NSLog(@"Error with task_info(): %s", mach_error_string(kerr));
    }
}
+ (BOOL) checkAttachmentTypeIsExcel:(NSString*)type
{
    return [WizGlobals checkAttachmentTypeInTypeArray:type typeArray:[WizGlobals excelArray]];
}
+ (NSString*) wizDeviceName
{
    return  [[UIDevice currentDevice] model];
}
+ (NSString*) wizSoftName
{
    return @"ios";
}

+ (NSURL*) wizServerUrl
{
    static NSURL* serverUrl = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSError* error = nil;
        NSString* url = [[WizNetworkEngine shareEngine] syncServerURLString:&error];
        if (error || !url) {
            NSLog(@"%@",error);
            url =  @"http://service.wiz.cn/wizkm/xmlrpc";
        }
        serverUrl = [NSURL URLWithString:url];
    });
    return serverUrl;
}

+ (const char *) wizServerUrlStdString
{
    return "http://service.wiz.cn/wizkm/xmlrpc";
}
+(void) showAlertView:(NSString*)title message:(NSString*)message delegate: (id)callback retView:(UIAlertView**) pAlertView
{
	UIAlertView* alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:callback cancelButtonTitle:nil otherButtonTitles:nil];
	UIActivityIndicatorView* progress = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	//
	[alert addSubview:progress];
	[alert show];
	CGRect rc = alert.frame;
	//
	CGPoint pt = CGPointMake(rc.size.width / 2 - 14 , rc.size.height / 2 + 10);
	//
	[progress setCenter:pt];
	[progress startAnimating];
	//
	*pAlertView = alert;
}

+ (NSString*) appIdentifier
{
    static NSString* identifier = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString *build = [infoDictionary objectForKey:(NSString*)kCFBundleIdentifierKey];
        identifier = build;
    });
    return identifier;
}

+ (CGSize)labelSizeFromTextSize:(CGSize)textSize maxLength:(float)maxLength
{
    NSInteger lines = 0;
    if (textSize.width == 0) {
        return CGSizeZero;
    }
    if (textSize.width <= maxLength) {
        lines = 1;
    }else{
        lines = textSize.width / maxLength;
        if (lines * maxLength < textSize.width) {
            lines ++;
        }
    }
    return CGSizeMake(maxLength, lines * textSize.height);
}

+ (NSString*) wizNoteVersion
{
   static  NSString* version  = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString *build = [infoDictionary objectForKey:(NSString*)kCFBundleVersionKey];
        version = build;
    });
    return version;
}

+ (NSString*) localLanguageKey
{
    NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
    NSArray* languages = [defs objectForKey:@"AppleLanguages"];
    NSString* preferredLang = [languages objectAtIndex:0];
    return preferredLang;
}
+(void) reportErrorWithString:(NSString*)error
{
	UIAlertView* alert = [[UIAlertView alloc] initWithTitle:WizStrError message:error delegate:nil cancelButtonTitle:WizStrOK otherButtonTitles:nil];
	[alert show];
}
+(void) reportError:(NSError*)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
       [WizGlobals reportErrorWithString:[error localizedDescription]]; 
    });
}
+(void) reportWarningWithString:(NSString*)error
{
	UIAlertView* alert = [[UIAlertView alloc] initWithTitle:WizStrWarning message:error delegate:nil cancelButtonTitle:WizStrOK otherButtonTitles:nil];
	[alert show];
}

+ (void) reportMessage:(NSString*)string withTitle:(NSString*)title
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:title message:string delegate:nil cancelButtonTitle:WizStrOK otherButtonTitles:nil];
	[alert show];
}
+ (void) reportWarning:(NSError*)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
       [WizGlobals reportWarningWithString:[error localizedDescription]]; 
    });
}


+(NSString*) genGUID
{
	CFUUIDRef theUUID = CFUUIDCreate(NULL);
	CFStringRef string = CFUUIDCreateString(NULL, theUUID);
	CFRelease(theUUID);
	//
	NSString* str = [NSString stringWithString:(__bridge NSString*)string];
	//
	CFRelease(string);
	//
	return [str lowercaseString];
}

+ (NSString*) md5String:(NSString*)string
{
   return  [WizGlobals md5:[string dataUsingEncoding:NSUTF8StringEncoding]];
}

+ (NSString*) md5CString:(const char*)string
{
    return [WizGlobals md5String:[NSString stringWithUTF8String:string]];
}

+ (NSString*) encryptPassword:(NSString*)password
{
    NSString* md5P = [WizGlobals md5:[password dataUsingEncoding:NSUTF8StringEncoding]];
    NSString* md = [NSString stringWithFormat:@"md5.%@",md5P];
    return md;
}
+ (BOOL) checkPasswordIsEncrypt:(NSString*)password
{
    if (password.length > 4 &&[[password substringToIndex:4] isEqualToString:@"md5."]) {
        return YES;
    }
    else {
        return NO;
    }
}
+ (NSString*) ensurePasswordIsEncrypt:(NSString*)password
{
    if ([WizGlobals checkPasswordIsEncrypt:password]) {
        return password;
    }
    else
    {
        return [WizGlobals encryptPassword:password];
    }
}
+ (UIImage *)resizeImage:(UIImage *)image
			   scaledToSize:(CGSize)newSize 
{
    UIGraphicsBeginImageContext(newSize);    
	[image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    return newImage;
}
+ (NSInteger)fileLength:(NSString*)path
{
    NSError* error = nil;
    NSDictionary* dic = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:&error];
    if (nil == error) {
        return [dic fileSize];
    }
    return NSNotFound;
}
+(NSNumber*) wizNoteAppleID
{
    if ([self WizDeviceIsPad]) {
        return [NSNumber numberWithInt:WizNoteIpadId];
    }
    else
    {
        return [NSNumber numberWithInt:WizNoteIphoneId];
    }
}
+ (UIImage*) attachmentNotationImage:(NSString*)type
{

    if ([WizGlobals checkAttachmentTypeIsAudio:type]) {
        return [UIImage imageNamed:@"icon_video_img"];
    }
    else  if ([WizGlobals checkAttachmentTypeIsPPT:type])
    {
        return [UIImage imageNamed:@"icon_ppt_img"];
    }
    else  if ([WizGlobals checkAttachmentTypeIsWord:type])
    {
        return [UIImage imageNamed:@"icon_word_img"];
    }
    else  if ([WizGlobals checkAttachmentTypeIsExcel:type])
    {
        return [UIImage imageNamed:@"icon_excel_img"];
    }
    else if ([WizGlobals checkAttachmentTypeIsImage:type])
    {
        return [UIImage imageNamed:@"icon_image_img"];
    }
    else 
    {
        return [UIImage imageNamed:@"icon_file_img"];
    }
}

+ (NSString*) AccountLoginInfo
{
    return accountStatus;
}

+ (void) setAccountInfo:(NSString*)info
{
    accountStatus = info;
}
+(BOOL) wizDeviceIsPhone5
{
    BOOL currenMode = [UIScreen instancesRespondToSelector:@selector(currentMode)];
    if (currenMode) {
        return CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size);
    }else{
        return NO;
    }
}

static BOOL isPasscodingIsShowing = NO;
 + (void) setPasscodeViewControlleringShowing:(BOOL)showing
{
    isPasscodingIsShowing = showing;
}
+ (BOOL) isPasscodeViewControllingShowing
{
    return isPasscodingIsShowing;
}


@end

BOOL DeviceIsPad(void)
{
	if ([[UIDevice currentDevice] respondsToSelector:@selector(userInterfaceIdiom)])
	{
		UIDevice* device = [UIDevice currentDevice];
		UIUserInterfaceIdiom deviceId = device.userInterfaceIdiom;
		return(deviceId == UIUserInterfaceIdiomPad);	
	}
	
	return(NO);
}

BOOL WizDeviceIsPad(void)
{
	BOOL b = DeviceIsPad(); 
	return b;
}

@implementation UIViewController(WizScreenBounds)

- (CGSize) contentViewSize
{
    float height = [UIScreen mainScreen].bounds.size.height;
    height -=  [[UIApplication sharedApplication] statusBarFrame].size.height;
    if (!self.navigationController.navigationBarHidden) {
        height -= self.navigationController.navigationBar.frame.size.height;
    }
    return CGSizeMake(self.view.frame.size.width, height);
}

@end

@interface WizTestSpendTime ()
{
    NSDate* beginDate;
}
@end
@implementation WizTestSpendTime

- (id) init
{
    self = [super init];
    if (self) {
        beginDate = [[NSDate alloc] init];
    }
    return self;
}
- (void) dealloc
{
    NSDate* endDate = [[NSDate alloc] init];
    NSLog(@"spend time is %f",[endDate timeIntervalSinceDate:beginDate]);
}
@end


@implementation UIColor(Wiz)

+ (UIColor *) colorWithHexHex:(int)hex {
    return [UIColor colorWithRed:((float)((hex & 0xFF0000) >> 16))/255.0
                           green:((float)((hex & 0xFF00) >> 8))/255.0
                            blue:((float)(hex & 0xFF))/255.0 alpha:1.0];
}


@end

@implementation NSBundle (Wiz)

+ (NSBundle*) WizBundle
{
    return [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"WizCore" ofType:@"bundle"]];
}
@end

@implementation UIImage (WizBundleImage)

+ (UIImage*)imageWithNameFromWizBundle:(NSString *)name
{
    return nil;
}

@end