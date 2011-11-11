//
//  cocoaPracAppDelegate.m
//  cocoaPrac
//
//  Created by hewig xu on 10/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "cocoaPracAppDelegate.h"

@implementation cocoaPracAppDelegate

@synthesize window;

- (void) dealloc{
	[[NSStatusBar systemStatusBar] removeStatusItem:(testItem)];
	[testItem release];
	[super dealloc];
}

- (void) initStatusItem{
	
	NSLog(@"init Status Items");
	if (testItem == nil) {
		
		testItem=[[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];
		[testItem setImage:[NSImage imageNamed:@"python-crysta-24"]];
		[testItem setHighlightMode:YES];
	}
	
	NSMenu *menu;
	menu=[[NSMenu alloc] initWithTitle: @""];
	[menu addItemWithTitle:@"Show" action:@selector(showWindow) keyEquivalent:@""];
	[menu addItemWithTitle:@"Hide" action:@selector(hideWindow) keyEquivalent:@""];
	[menu addItemWithTitle:@"Exit" action:@selector(exitWindow) keyEquivalent:@""];
	[testItem setMenu:menu];
	[menu release];
}

- (void) applicationDidFinishLaunching:(NSNotification *)aNotification {
	
	[self initStatusItem];
	mainBundle = [NSBundle mainBundle];
	//goagentPath = [[mainBundle bundlePath] stringByAppendingString:[mainBundle objectForInfoDictionaryKey:@"GoAgentPath"]];
	goagentPath = [mainBundle objectForInfoDictionaryKey:@"GoAgentPath"];
	displayOwn = [mainBundle objectForInfoDictionaryKey:@"DisplayOwn"];
	NSLog(@"%@",displayOwn);
	[resultTextView setString:@"GoAgent Starting..."];
	[self runGoagent];
	//[self performSelectorInBackground:@selector(runGoagent) withObject:nil];
	
}

- (void) showWindow{
	NSLog(@"in function showWindow");
	[[self window] makeKeyAndOrderFront:self];
}

- (void) hideWindow{
	NSLog(@"in function hideWindow");
	[[self window] orderOut:nil];
}

- (void) exitWindow{
	NSLog(@"in function exitWindow");
	if (cmdTask) {
		[cmdTask interrupt];
	}
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[NSApp terminate:self];
}


- (void) runGoagent{
	NSLog(@"in function runGoagent");
	
	if (cmdTask) {
		[cmdTask interrupt];
	}else {
		cmdTask =[[NSTask alloc]init];
		[cmdTask setLaunchPath:@"/usr/bin/python"];
				
		NSLog(@"GoAgent Path is %@",goagentPath);
		NSArray *args = [NSArray arrayWithObjects:goagentPath,nil];
		[cmdTask setArguments:args];
		
		[cmdPipe release];
		cmdPipe = [[NSPipe alloc] init];
		
		[cmdTask setStandardOutput:cmdPipe];
		[cmdTask setStandardError:[cmdTask standardOutput]];
		NSFileHandle *fh = [cmdPipe fileHandleForReading];
		
		NSNotificationCenter *nc=[NSNotificationCenter defaultCenter];
		[nc removeObserver:self];
		[nc addObserver:self selector:@selector(dataReady:) name:NSFileHandleReadCompletionNotification object:fh];
		[nc addObserver:self selector:@selector(taskTerminated:) name:NSTaskDidTerminateNotification object:cmdTask];
		
		[cmdTask launch];
		[fh readInBackgroundAndNotify];
	}
	
}

- (void) dataReady:(NSNotification *) n{
	NSData *d = [[n userInfo] valueForKey:NSFileHandleNotificationDataItem];
	//NSLog(@"dataReady:%d bytes",[d length]);
	
	if ([d length]) {
		NSString *str = [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding];
		NSLog(@"%@",str);
		
		if ([displayOwn boolValue]) {
			NSTextStorage *ts = [resultTextView textStorage];
			[ts replaceCharactersInRange:NSMakeRange([ts length], 0) withString:str];
		}
		[str release];
	}
	if (cmdTask){
		[[cmdPipe fileHandleForReading] readInBackgroundAndNotify];
	}
}

- (void) taskTerminated:(NSNotification *) n{
	NSLog(@"task terminated");
	[cmdTask release];
	cmdTask = nil;
	
}

@end
