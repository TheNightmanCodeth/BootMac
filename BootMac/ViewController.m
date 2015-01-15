//
//  ViewController.m
//  BootMac
//
//  Created by Joseph Diragi on 1/4/15.
//  Copyright (c) 2015 Joseph Diragi. All rights reserved.
//

#import "ViewController.h"
NSString *ISOLoc;

@implementation ViewController
NSArray *usbArray;
- (void)viewDidLoad {
    [super viewDidLoad];
    [_pathText setPlaceholderString:@"Path to iso..."];
    [_usbIndentifierBox setPlaceholderString:@"Usb identifier..."];
    NSString *diskutilOut;
    diskutilOut = [self USBList];
    [_scrollTextView setString:diskutilOut];
    // Do any additional setup after loading the view.
    [_welcomeText setBezeled:NO];
    [_welcomeText setDrawsBackground:NO];
    [_welcomeText setEditable:NO];
    [_welcomeText setSelectable:NO];
    [_welcomeText setStringValue:@"Welcome to BootMac! A GUI bootable USB drive creator for Mac. To get started, select your ISO"];
    
    [_driveText setBezeled:NO];
    [_driveText setDrawsBackground:NO];
    [_driveText setEditable:NO];
    [_driveText setSelectable:NO];
    [_driveText setStringValue:@"Next, locate your USB Drive in the list below."];
    
    [_usbText setBezeled:NO];
    [_usbText setDrawsBackground:NO];
    [_usbText setEditable:NO];
    [_usbText setSelectable:NO];
    [_usbText setStringValue:@"Lastly, type the name of your usb identifier. ie. 'disk1' or 'disk2'"];
    
    [_spinner setBezeled:YES];
    [_spinner setStyle:NSProgressIndicatorSpinningStyle];
    [_spinner setControlSize:NSSmallControlSize];
    [_spinner sizeToFit];
    [_spinner setUsesThreadedAnimation:YES];
    [_spinner setDisplayedWhenStopped:NO];
    
}
- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}
- (NSString *)USBList{
    
    //int pid = [[NSProcessInfo processInfo] processIdentifier];
    NSPipe *pipe = [NSPipe pipe];
    NSFileHandle *file = pipe.fileHandleForReading;
    
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = @"/usr/sbin/diskutil";
    task.arguments = @[@"list"];
    task.standardOutput = pipe;
    
    [task launch];
    
    NSData *data = [file readDataToEndOfFile];
    [file closeFile];
    
    NSString *diskutilOutput = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    //NSLog(@"Diskutil said: /n%@", diskutilOutput);
    return diskutilOutput;
    
}
- (IBAction)iso:(id)sender {
    
    //ISOSelecter button was pressed
    //Dispplay a file picker (NSOpenPanel)
    
    NSOpenPanel *filePicker = [NSOpenPanel openPanel];
    //We want to choose an ISO so we allow chooseFiles and not chooseDirectories
    [filePicker setCanChooseFiles:true];
    [filePicker setCanChooseDirectories:false];
    //We only want one ISO, not multiple
    [filePicker setAllowsMultipleSelection:false];
    NSArray *fileTypes = [[NSArray alloc] initWithObjects:@"iso", @"ISO", nil];
    [filePicker setAllowedFileTypes:fileTypes];
    [filePicker setTitle:@"Select ISO"];
    
    NSInteger clicked = [filePicker runModal];
    
    if (clicked == NSFileHandlingPanelOKButton) {
        //The user clicked the okay button, so we need to set the file directory as the textbox text
        for (NSURL *url in [filePicker URLs]) {
            //url is the file path (I hope)
            
            NSLog(@"The file path is: %@", url);
            
            //Well this kind of works I guess. The file URL looks like this shit: "file:///Users/User/Path/To/File.type" which is wrong so let's change that shit.
            //we need to remove the 'file://' from the URL
            //First we need to make the NSUrl an NSString
            NSString *urlString = [url absoluteString];
            
            //Now we can remove file://
            NSRange r;
            while ((r = [urlString rangeOfString:@"file://" options:NSRegularExpressionSearch]).location != NSNotFound){
                
                urlString = [urlString stringByReplacingCharactersInRange:r withString:@""];
                
            }
            
            //Now urlString shouldn't have the file:// part
            //So let's set the editText to the file path
            [_pathText setStringValue:urlString];
            ISOLoc = urlString;
            //This string is the ouput from running 'diskutil list'
        }
    }
    
}
- (IBAction)helpButton:(id)sender {
    
    //Make a dialog that explains what the user should do
    //In the future this will direct to a web page with illustrated instructions
    NSWindow *window = _window;
    NSAlert *helpDialog = [[NSAlert alloc] init];
    [helpDialog addButtonWithTitle:@"OK"];
    [helpDialog setMessageText:@"Help"];
    [helpDialog setInformativeText:@"Look at the list of attached USB drives. Along the top, you should see a few titles, such as: 'TYPE', 'NAME', 'SIZE', and 'IDENTIFIER'. Look under 'NAME' and look for the name of your USB drive. Now look under the 'IDENTIFIER' title and write down the first one under your drive. Make sure it says 'disk#' and not 'disk#s#'"];
    [helpDialog setAlertStyle:NSWarningAlertStyle];
    
    [helpDialog beginSheetModalForWindow:[self window] modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:nil];
    
}
- (void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    
    if (returnCode == NSModalResponseOK) {
        NSLog(@"OKButton clicked");
    }
    
}
- (IBAction)startButton:(id)sender {
    
    [_spinner startAnimation:self];
    
    NSString *usbIdentifier = [_usbIndentifierBox stringValue];
    
    //check if the user entered /dev/ in front of the identifier. If not, add it
    NSRange r;
    if ((r = [usbIdentifier rangeOfString:@"/dev/" options:NSRegularExpressionSearch]).location != NSNotFound){
        
        //It does have /dev/ so do nothing
        NSString *usbIdentifierFinal = usbIdentifier;
        [self main:usbIdentifierFinal:ISOLoc];
        
    } else {
        
        //It doesn't have /dev/ so add it
        NSString *usbIdentifierFinal = [NSString stringWithFormat:@"/dev/%@", usbIdentifier];
        NSLog(usbIdentifierFinal);
        [self main:usbIdentifierFinal:ISOLoc];
        
    }
    
    [_spinner stopAnimation:self];

    
}
- (void)main:(NSString *)usb :(NSString *)iso{
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"main" ofType:@"scpt"];
    if (path != nil) {
        NSURL *url = [NSURL fileURLWithPath:path];
        if (url != nil) {
            NSString *fileImg = [@"~/BootMac.img.dmg" stringByExpandingTildeInPath];
            bool img = [[NSFileManager defaultManager] fileExistsAtPath:fileImg isDirectory:false];
            if (img) {
                NSError *error;
                [[NSFileManager defaultManager] removeItemAtPath:fileImg error:&error];
                
            }
            //path is the location to the applescript
            int pid = [[NSProcessInfo processInfo] processIdentifier];
            NSPipe *pipe = [NSPipe pipe];
            NSFileHandle *file = pipe.fileHandleForReading;
            
            NSTask *task = [[NSTask alloc] init];
            task.launchPath = @"/usr/bin/osascript";
            task.arguments = @[path, usb, iso];
            task.standardOutput = pipe;
            
            [task launch];
            
            NSData *data = [file readDataToEndOfFile];
            [file closeFile];
            
            NSString *unmountOutput = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(unmountOutput);
            //listen for errors
            NSRange r;
            if ((r = [unmountOutput rangeOfString:@"failed" options:NSRegularExpressionSearch]).location != NSNotFound){
                
                NSLog(@"Looks like there was an error");
                
            }

        }
    }
    
}

- (IBAction)refreshUSBList:(id)sender {
    //When the user clicks refresh, the list should refresh
    NSString *diskutilOut;
    diskutilOut = [self USBList];
    [_scrollTextView setString:diskutilOut];
    
}

@end
