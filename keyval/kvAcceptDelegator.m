#import "kvAcceptDelegator.h"
#import "kvStreamDelegator.h"

@implementation kvAcceptDelegator

- init
{
	if (!(self = [super init])) return nil;
	return self;
}

- (void)acceptor:(id<MLAcceptor>)acceptor receivedConnection:(id<MLBufferedEvent>)connectionToRetain
{
	NSLog(@"in acceptor");
	//...
	kvStreamDelegator * sdlg = [[kvStreamDelegator alloc] init];
	[connectionToRetain retain];
	[connectionToRetain setDelegate:sdlg];
	[connectionToRetain start];
}

- (void)acceptor:(id<MLAcceptor>)acceptor error:(NSError *)details
{
	NSLog(@"in acceptor error");
}

@end

