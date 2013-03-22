#import "kvFormatParser.h"
#import <MLFoundation/Protocols/MLBufferedEventDelegate.h>

@interface kvStreamDelegator : MLObject <MLBufferedEventDelegate>
{
@private
	kvFormatParser * parser_;
}
// methods
@end


