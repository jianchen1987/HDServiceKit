//
//  HDWHCapacityResponse.m
//  HDServiceKit
//
//  Created by VanJay on 2020/3/18.
//

#import "HDWHCapacityResponse.h"
#import "HDLocationManager.h"
#import "HDScanCodeViewController.h"
#import "HDWebViewHostViewController+Callback.h"
#import <ContactsUI/ContactsUI.h>

@interface HDWHCapacityResponse () <CNContactPickerDelegate>
@property (nonatomic, copy) void (^choosedContactHandler)(NSString *name, NSString *phoneNumber, HDWHRespCode code, HDWHCallbackType callbackType);
@property (nonatomic, copy) void (^gotUserLocationHandler)(double latitude, double longitude, HDWHRespCode code, HDWHCallbackType callbackType);
@end

@implementation HDWHCapacityResponse
+ (NSDictionary<NSString *, NSString *> *)supportActionList {
    return @{
        @"getContacts$": kHDWHResponseMethodOn,
        @"getLocation$": kHDWHResponseMethodOn,
        @"scanQRCode_$": kHDWHResponseMethodOn,
    };
}

- (instancetype)init {
    if (self = [super init]) {
        // 监听位置变化
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(locationManagerMonitoredLocationChanged:)
                                                     name:kNotificationNameLocationChanged
                                                   object:nil];
        // 监听权限变化
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationManagerMonitoredLocationPermissionChanged:) name:kNotificationNameLocationPermissionChanged object:nil];
    }
    return self;
}

#pragma mark - inner

// clang-format off
wh_doc_begin(getContacts$, "获取联系人")
wh_doc_code(window.webViewHost.invoke("getContacts", {}, function(params) {
    alert("getContacts:" + JSON.stringify(params));
}))
wh_doc_code_expect("打开通讯录，选择联系人")
wh_doc_end;
// clang-format on
- (void)getContactsWithCallback:(NSString *)callBackKey {
    void (^continueChooseContact)(void) = ^void(void) {
        __weak __typeof(self) weakSelf = self;
        [self selectContactWithCompletion:^(NSString *name, NSString *phoneNumber, HDWHRespCode code, HDWHCallbackType callbackType) {
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
            if (code != HDWHRespCodeSuccess) {
                params[@"reason"] = @"User Cancel";
            } else {
                params[@"name"] = name;
                params[@"phoneNumber"] = phoneNumber;
            }
            [strongSelf.webViewHost fireCallback:callBackKey actionName:@"getContacts" code:code type:callbackType params:params];
        }];
    };

    // 先检查权限
    CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    if (status == CNAuthorizationStatusNotDetermined) {
        CNContactStore *store = [[CNContactStore alloc] init];
        // 记得在 info.plist 中配置 NSContactsUsageDescription 描述
        [store requestAccessForEntityType:CNEntityTypeContacts
                        completionHandler:^(BOOL granted, NSError *_Nullable error) {
                            if (error) {
                                [self.webViewHost fireCallback:callBackKey actionName:@"getContacts" code:HDWHRespCodeUserRejected type:HDWHCallbackTypeFail params:@{@"reason": @"用户拒绝授权"}];
                            } else {
                                continueChooseContact();
                            }
                        }];
    } else if (status == CNAuthorizationStatusAuthorized) {  // 已经授权
        // 有通讯录权限
        continueChooseContact();
    } else {
        [self.webViewHost fireCallback:callBackKey actionName:@"getContacts" code:HDWHRespCodeUserRejected type:HDWHCallbackTypeFail params:@{@"reason": @"用户已拒绝授权"}];
    }
}

// clang-format off
wh_doc_begin(getLocation$, "获取位置")
wh_doc_code(window.webViewHost.invoke("getLocation", {}, function(params) {
    alert("getLocation:" + JSON.stringify(params));
}))
wh_doc_code_expect("获取到用户位置")
wh_doc_end;
// clang-format on
- (void)getLocationWithCallback:(NSString *)callBackKey {

    __weak __typeof(self) weakSelf = self;
    void (^continueGotLocationHandler)(double, double, HDWHRespCode, HDWHCallbackType) = ^void(double latitude, double longitude, HDWHRespCode code, HDWHCallbackType callbackType) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
        if (code != HDWHRespCodeSuccess) {
            params[@"reason"] = @"User Rejected";
        } else {
            params[@"longitude"] = @(longitude);
            params[@"latitude"] = @(latitude);
        }
        [strongSelf.webViewHost fireCallback:callBackKey
                                  actionName:@"getLocation"
                                        code:code
                                        type:callbackType
                                      params:params];
    };

    HDCLAuthorizationStatus status = [HDLocationUtils getCLAuthorizationStatus];
    if (status == HDCLAuthorizationStatusNotDetermined) {
        [HDLocationManager.shared requestWhenInUseAuthorization];

        self.gotUserLocationHandler = ^(double latitude, double longitude, HDWHRespCode code, HDWHCallbackType callbackType) {
            continueGotLocationHandler(latitude, longitude, code, callbackType);
        };
    } else if (status == HDCLAuthorizationStatusNotAuthed) {
        // 回传失败
        [self.webViewHost fireCallback:callBackKey actionName:@"getLocation" code:HDWHRespCodeUserRejected type:HDWHCallbackTypeFail params:@{@"reason": @"用户拒绝授权"}];
    } else {
        // 同意过了
        if (HDLocationManager.shared.isCurrentCoordinate2DValid) {
            CLLocationCoordinate2D coordinate2D = HDLocationManager.shared.coordinate2D;
            continueGotLocationHandler(coordinate2D.latitude, coordinate2D.longitude, HDWHRespCodeSuccess, HDWHCallbackTypeSuccess);
        } else {
            [HDLocationManager.shared startUpdatingLocation];
            self.gotUserLocationHandler = ^(double latitude, double longitude, HDWHRespCode code, HDWHCallbackType callbackType) {
                continueGotLocationHandler(latitude, longitude, code, callbackType);
            };
        }
    }
}

// clang-format off
wh_doc_begin(scanQRCode_$, "扫一扫")
wh_doc_code(window.webViewHost.invoke("scanQRCode", {"needResult": 1, "scanType": ["qrCode","barCode"]}, function(params) {
    alert("scanQRCode:" + JSON.stringify(params));
}))
wh_doc_code_expect("打开扫一扫界面")
wh_doc_end;
// clang-format on
- (void)scanQRCode:(NSDictionary *)paramDict callback:(NSString *)callBackKey {
    BOOL needResult = [[paramDict valueForKey:@"needResult"] boolValue];
    NSArray<NSString *> *scanTypes = [paramDict objectForKey:@"scanType"];

    HDCodeScannerType scanType = HDCodeScannerTypeAll;
    // 不传默认两种
    if (!scanTypes && [scanTypes isKindOfClass:NSArray.class] && scanTypes.count < 2) {
        if ([scanTypes containsObject:@"qrCode"]) {
            scanType = HDCodeScannerTypeQRCode;
        } else if ([scanTypes containsObject:@"barCode"]) {
            scanType = HDCodeScannerTypeBarcode;
        }
    }

    HDWHLog(@"%d ---  %@", needResult, scanTypes);

    dispatch_async(dispatch_get_main_queue(), ^{
        HDScanCodeViewController *scanCodeVC = [HDScanCodeViewController new];
        scanCodeVC.scanType = scanType;
        [self.navigationController pushViewController:scanCodeVC animated:YES];

        __weak __typeof(self) weakSelf = self;
        scanCodeVC.resultBlock = ^(NSString *_Nullable scanString) {
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf.webViewHost fireCallback:callBackKey actionName:@"scanQRCode" code:HDWHRespCodeSuccess type:HDWHCallbackTypeSuccess params:@{@"resultStr": scanString}];
        };
        scanCodeVC.userCancelBlock = ^{
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf.webViewHost fireCallback:callBackKey actionName:@"scanQRCode" code:HDWHRespCodeUserCancel type:HDWHCallbackTypeCancel params:nil];
        };
    });
}

#pragma mark - private methods
- (void)selectContactWithCompletion:(void (^)(NSString *name, NSString *phoneNumber, HDWHRespCode code, HDWHCallbackType callbackType))choosedContactHandler {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.choosedContactHandler = choosedContactHandler;
        CNContactPickerViewController *picker = [[CNContactPickerViewController alloc] init];
        picker.modalPresentationStyle = UIModalPresentationFullScreen;
        picker.delegate = self;
        picker.displayedPropertyKeys = @[CNContactPhoneNumbersKey];
        [self.webViewHost presentViewController:picker animated:YES completion:nil];
    });
}

/// 把-、+86、空格这些过滤掉
/// @param phone 原号码
- (NSString *)handlePhoneNumber:(NSString *)phone {
    phone = [phone stringByReplacingOccurrencesOfString:@"-" withString:@""];
    phone = [phone stringByReplacingOccurrencesOfString:@"+86" withString:@""];
    phone = [phone stringByReplacingOccurrencesOfString:@" " withString:@""];
    phone = [[phone componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet]] componentsJoinedByString:@""];
    return phone;
}

#pragma mark - CNContactPickerDelegate
- (void)contactPickerDidCancel:(CNContactPickerViewController *)picker {

    __weak __typeof(self) weakSelf = self;
    [picker dismissViewControllerAnimated:YES
                               completion:^{
                                   __strong __typeof(weakSelf) strongSelf = weakSelf;
                                   !strongSelf.choosedContactHandler ?: strongSelf.choosedContactHandler(nil, nil, HDWHRespCodeUserCancel, HDWHCallbackTypeCancel);
                               }];
}

/// 在联系人详情里选择了联系人属性，如果实现了下面这个方法，该回调不会触发
/// @param picker 选择联系人控制器
/// @param contactProperty 联系人属性
- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContactProperty:(CNContactProperty *)contactProperty {
    if (![contactProperty.key isEqualToString:CNContactPhoneNumbersKey]) {
        return;
    }
    CNContact *contact = contactProperty.contact;
    NSString *name = [CNContactFormatter stringFromContact:contact style:CNContactFormatterStyleFullName];

    CNPhoneNumber *phoneNumber = contactProperty.value;
    NSString *phone = phoneNumber.stringValue.length ? phoneNumber.stringValue : @"";
    phone = [self handlePhoneNumber:phone];

    // 回调
    !self.choosedContactHandler ?: self.choosedContactHandler(name, phone, HDWHRespCodeSuccess, HDWHCallbackTypeSuccess);
    [picker dismissViewControllerAnimated:YES completion:nil];
}

/// 选择了联系人就会触发，上面个方法便不会触发，二选一
/// @param picker 选择联系人控制器
/// @param contact 选择的联系人
- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContact:(nonnull CNContact *)contact {
    NSArray<CNLabeledValue<CNPhoneNumber *> *> *phoneNums = contact.phoneNumbers;

    void (^pickerDismissedCompletion)(void);

    __weak __typeof(self) weakSelf = self;
    // 超过1个让用户自己选
    if (phoneNums.count > 1) {
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        alertVC.modalPresentationStyle = UIModalPresentationFullScreen;

        NSString *name = [CNContactFormatter stringFromContact:contact style:CNContactFormatterStyleFullName];
        for (CNLabeledValue *labeledValue in phoneNums) {
            CNPhoneNumber *phoneNumer = labeledValue.value;
            NSString *phone = [self handlePhoneNumber:phoneNumer.stringValue];
            [alertVC addAction:[UIAlertAction actionWithTitle:phone
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *_Nonnull action) {
                                                          __strong __typeof(weakSelf) strongSelf = weakSelf;
                                                          !strongSelf.choosedContactHandler ?: strongSelf.choosedContactHandler(name, phone, HDWHRespCodeSuccess, HDWHCallbackTypeSuccess);
                                                      }]];
        }
        [alertVC addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                                    style:UIAlertActionStyleCancel
                                                  handler:^(UIAlertAction *_Nonnull action) {
                                                      __strong __typeof(weakSelf) strongSelf = weakSelf;
                                                      !strongSelf.choosedContactHandler ?: strongSelf.choosedContactHandler(nil, nil, HDWHRespCodeUserCancel, HDWHCallbackTypeCancel);
                                                  }]];

        pickerDismissedCompletion = ^{
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf.webViewHost presentViewController:alertVC animated:YES completion:nil];
        };
    } else if (phoneNums.count == 1) {
        CNLabeledValue *labeledValue = phoneNums.firstObject;
        CNPhoneNumber *phoneNumer = labeledValue.value;
        NSString *name = [CNContactFormatter stringFromContact:contact style:CNContactFormatterStyleFullName];
        NSString *phone = phoneNumer.stringValue;
        phone = [self handlePhoneNumber:phone];

        pickerDismissedCompletion = ^{
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            // 回调
            !strongSelf.choosedContactHandler ?: strongSelf.choosedContactHandler(name, phone, HDWHRespCodeSuccess, HDWHCallbackTypeSuccess);
        };
    } else {
        pickerDismissedCompletion = ^{
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            !strongSelf.choosedContactHandler ?: strongSelf.choosedContactHandler(nil, nil, HDWHRespCodeCommonFailed, HDWHCallbackTypeCancel);
        };
    }

    [picker dismissViewControllerAnimated:YES
                               completion:pickerDismissedCompletion];
}

#pragma mark - HDLocationManagerProtocol
- (void)locationManagerMonitoredLocationChanged:(NSNotification *)notification {
    CLLocationCoordinate2D coordinate2D = HDLocationManager.shared.coordinate2D;
    !self.gotUserLocationHandler ?: self.gotUserLocationHandler(coordinate2D.latitude, coordinate2D.longitude, HDWHRespCodeSuccess, HDWHCallbackTypeSuccess);
}

- (void)locationManagerMonitoredLocationPermissionChanged:(NSNotification *)notification {
    HDCLAuthorizationStatus status = [HDLocationUtils getCLAuthorizationStatus];
    if (status == HDCLAuthorizationStatusAuthed) {
        [HDLocationManager.shared startUpdatingLocation];
    } else if (status == HDCLAuthorizationStatusNotAuthed) {
        !self.gotUserLocationHandler ?: self.gotUserLocationHandler(0, 0, HDWHRespCodeUserRejected, HDWHCallbackTypeFail);
    }
}
@end
