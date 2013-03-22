#import "kvStreamDelegator.h"

@interface kvStreamDelegator(private)
@end

@implementation kvStreamDelegator

- init
{
	if (!(self = [super init])) return nil;
        parser_ = [[kvFormatParser alloc] init];
	NSLog(@"in kvStreamDelegator init");
	return self;
}

- (void) dealloc
{
	[parser_ release];
	[super dealloc];
}

- (void)dataAvailableOnEvent:(id <MLBufferedEvent>)bufEvent
{
	NSLog(@"dataAvailableOnEvent called");
	[parser_ drainStream: bufEvent];
}

- (void)writtenToEvent:(id <MLBufferedEvent>)bufEvent
{
	NSLog(@"dataWrittenToEvent called");
}

- (void)timeout:(int)what onEvent:(id <MLBufferedEvent>)bufEvent
{
	NSLog(@"conn timeout - releasing");
	[bufEvent release];
}

- (void)error:(NSError *)details onEvent:(id <MLBufferedEvent>)bufEvent
{
	NSLog(@"conn error - releasing");
	[bufEvent release];
}

@end
