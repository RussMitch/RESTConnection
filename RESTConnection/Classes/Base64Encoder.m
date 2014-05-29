//------------------------------------------------------------------------------
// Base64Encoder.m
//------------------------------------------------------------------------------

#import "Base64Encoder.h"

@implementation Base64Encoder

static char base64[]= "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

//------------------------------------------------------------------------------
+ (NSString *)encodeLogin:(NSString *)loginString withPassword:(NSString *)passwordString 
//------------------------------------------------------------------------------
{
	char encodeArray[512];

	NSMutableString *dataStr = (NSMutableString*)[@"" stringByAppendingFormat:@"%@:%@", loginString, passwordString];
	
	NSData *encodeData= [dataStr dataUsingEncoding:NSUTF8StringEncoding];
	
	memset( encodeArray, '\0', sizeof( encodeArray ));
	
	if ([Base64Encoder encodeWithSrcLen:(unsigned)[encodeData length] andSrc:(char *)[encodeData bytes] andDstLen:sizeof(encodeArray) andDst:encodeArray]) {
		NSLog( @"encodeLogin.Base64Encoder FAILED\n" );
		return nil;
	}
	
	return [[NSString alloc] initWithFormat:@"Basic %@", [NSString stringWithCString:encodeArray encoding:NSASCIIStringEncoding]];
}

//------------------------------------------------------------------------------
+ (int)encodeWithSrcLen:(unsigned)srcLen andSrc:(char *)src andDstLen:(unsigned)dstLen andDst:(char *)dst 
//------------------------------------------------------------------------------
{
	unsigned triad;
	unsigned s_len= srcLen;
	unsigned d_len= dstLen;
	
	for (triad = 0; triad < s_len; triad += 3) {
		unsigned byte;
		unsigned long int sr= 0;
		
		for (byte = 0; (byte<3)&&(triad+byte<s_len); ++byte) {
			sr <<= 8;
			sr |= (*(src+triad+byte) & 0xff);
		}
		
		sr <<= (6-((8*byte)%6))%6; /*shift left to next 6bit alignment*/
		
		if (d_len < 4) 
			return -1; /* error - dest too short */
		
		*(dst+0) = *(dst+1) = *(dst+2) = *(dst+3) = '=';
		
		switch(byte) {
			case 3:
				*(dst+3) = base64[sr&0x3f];
				sr >>= 6;
			case 2:
				*(dst+2) = base64[sr&0x3f];
				sr >>= 6;
			case 1:
				*(dst+1) = base64[sr&0x3f];
				sr >>= 6;
				*(dst+0) = base64[sr&0x3f];
		}
		dst += 4; d_len -= 4;
	}	
	return 0;	
}

@end
