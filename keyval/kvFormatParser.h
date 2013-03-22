#import <Foundation/Foundation.h>
#import <MLFoundation/MLObject/MLObject.h>
#import <MLFoundation/Protocols/MLStream.h>

@interface kvFormatParser : MLObject
{
@private
        uint32_t msgSize_;
}
// methods
+ (uint32_t) get_uint32:(uint8_t *) buf;
- (void) reset;
- (void) drainStream:(id <MLStream>) stream;
@end

