//
//  ViewController.h
//  BootMac
//
//  Created by Joseph Diragi on 1/4/15.
//  Copyright (c) 2015 Joseph Diragi. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ViewController : NSViewController
@property (weak) IBOutlet NSTextField *pathText;
@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSPopUpButton *USBListView;
@property (weak) IBOutlet NSTextField *textView;
@property (weak) IBOutlet NSTextField *welcomeText;
@property (weak) IBOutlet NSTextField *driveText;
@property (weak) IBOutlet NSButton *refreshButton;
@property (weak) IBOutlet NSTextField *usbText;
@property (weak) IBOutlet NSButton *help;
@property (weak) IBOutlet NSTextField *usbIndentifierBox;

- (NSString *)USBList;
- (NSMutableArray *)getUSB:(NSString *)output;
- (void)runDD:(NSString *)usb :(NSString *)iso;
- (void)main:(NSString *)usb :(NSString *)iso;
- (void)convertISO:(NSString *)iso;

@end

