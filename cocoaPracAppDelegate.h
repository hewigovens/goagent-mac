//
//  cocoaPracAppDelegate.h
//  cocoaPrac
//
//  Created by hewig xu on 10/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface cocoaPracAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
	NSStatusItem *testItem;
	IBOutlet NSTextView *resultTextView;
	NSTask *cmdTask;
	NSPipe *cmdPipe;
	NSBundle *mainBundle;
	NSString *goagentPath;
	NSString *displayOwn;
}

@property (assign) IBOutlet NSWindow *window;

- (void) initStatusItem;

- (void) runGoagent;

- (void) taskTerminated:(NSNotification *)n;

- (void) dataReady:(NSNotification *)n;

@end
