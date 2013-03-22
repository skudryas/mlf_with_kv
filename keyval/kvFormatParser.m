#import "kvFormatParser.h"
#import <Foundation/NSMapTable.h>
#import <Foundation/NSString.h>

enum KVMSGCODE
{
	KVMSGGET = 1,
	KVMSGSET,
	KVMSGDEL
};

extern NSMapTable * g_map;

@interface kvFormatParser(private)
@end

@implementation kvFormatParser

+ (uint32_t) get_uint32:(uint8_t *) buf
{
	uint32_t retval = 0;
	retval = buf[3];
	retval <<= 8;
	retval |= buf[2];
	retval <<= 8;
	retval |= buf[1];
	retval <<= 8;
	retval |= buf[0];
//	NSLog([NSString stringWithFormat:@"get_uint32: %d", retval]);
	return retval;
}

+ (void) make_u32_field:(uint32_t) val buffer:(char *) buf
{
//  NSLog([NSString stringWithFormat: @"%d", val]);
  buf[0] = (char) (val & 0xff);
  buf[1] = (char) ((val >> 8) & 0xff);
  buf[2] = (char) ((val >> 16) & 0xff);
  buf[3] = (char) (val >> 24);
}

- init
{
	if (!(self = [super init])) return nil;
	[self reset];
	return self;
}

- (void) reset
{
	msgSize_ = 0;
}

- (void) drainStream:(id <MLStream>) stream
{
	while (YES)
	{
		uint64_t avail = [stream length];
	       	char * dbgbuf = (char*)[stream bytes];
//		NSLog([NSString stringWithFormat:@"avail:%d", avail]);
//		NSLog([NSString stringWithCString:[stream bytes] length: avail]);
		if (!msgSize_) //msg size is not readed
		{
			if (avail < sizeof(uint32_t))
			{
				return;
			}
			else
			{
				msgSize_ = [kvFormatParser get_uint32:[stream bytes]];
//				NSLog([NSString stringWithFormat:@"msgSize_:%d", msgSize_]);
				[stream drainBytes:sizeof(uint32_t)];
				continue;//return [self drainStream: stream];
			}
		}
		else
		{
			if (avail < msgSize_)
			{
				return;
			}
			else
			{
				uint8_t * buf = [stream bytes];
				//handling...
				switch (buf[0])
				{
				case KVMSGSET:
				{
					if (msgSize_ < 1 + 2*sizeof(uint32_t))
					{
						return;
					}
					uint32_t keylen = [kvFormatParser get_uint32:&buf[1]],
						 vallen = [kvFormatParser get_uint32:&buf[1 + sizeof(uint32_t)]];
					if (msgSize_ < 1 + 2*sizeof(uint32_t) + keylen + vallen)
					{
						return;
					}
					//set value...
					NSString * str_key = [NSString stringWithCString:(char*)&buf[1 + sizeof(uint32_t)*2] length: keylen];
					NSString * str_val = [NSString stringWithCString:(char*)&buf[1 + sizeof(uint32_t)*2 + keylen] length: vallen];
					[g_map setObject:str_val forKey:str_key];
					NSLog([NSString stringWithFormat:@"setting g_map[%s] = %s", [str_key lossyCString], [str_val lossyCString]]);

					//set value end...
					[stream drainBytes: msgSize_];
					[self reset];
					continue;
				}
				case KVMSGGET:
				{
					if (msgSize_ < 1 + sizeof(uint32_t))
					{
						return;
					}
					uint32_t keylen = [kvFormatParser get_uint32:&buf[1]];
					if (msgSize_ < 1 + sizeof(uint32_t) + keylen)
					{
						return;
					}
					//get value...
					NSString * str_key = [NSString stringWithCString:(char*)&buf[1 + sizeof(uint32_t)] length: keylen];
					NSString * str_val = [g_map objectForKey:str_key];
					NSLog([NSString stringWithFormat:@"getting g_map[%s] = %s", [str_key lossyCString], [str_val lossyCString]]);
					[stream drainBytes: msgSize_];
					[stream stop];
					[stream resetBuffers];
					[stream start];
					uint8_t * bytes = [stream reserveBytes: 1 + sizeof(uint32_t) + [str_val length]];
					[kvFormatParser make_u32_field: [str_val length] buffer: bytes];
					[str_val getCString: (char*)&bytes[4]];
					NSLog(str_val);
					NSLog([NSString stringWithFormat: @"%c", bytes[4]]);
					//copy value...
					if (YES == [stream writtenBytes: sizeof(uint32_t) + [str_val length]])
						NSLog(@"Written returned YES...");
					[self reset];
					continue;
				}
				case KVMSGDEL:
				{
					if (msgSize_ < 1 + sizeof(uint32_t))
					{
						return;
					}
					uint32_t keylen = [kvFormatParser get_uint32:&buf[1]];
					if (msgSize_ < 1 + sizeof(uint32_t) + keylen)
					{
						return;
					}
					NSString * str_key = [NSString stringWithCString:(char*)&buf[1 + sizeof(uint32_t)] length: keylen];
					[g_map removeObjectForKey:str_key];
					NSLog([NSString stringWithFormat:@"deleting g_map[%s]", [str_key lossyCString]]);
					[stream drainBytes: msgSize_];
					[self reset];
					continue;
				}
				default:
				{
					NSLog([NSString stringWithFormat:@"unknown msg type: %d", buf[0]]);
					[stream drainBytes: msgSize_];
					[self reset];
					continue;
				}
				} //end of switch
				continue;
			}
	        }
	}
}
@end

