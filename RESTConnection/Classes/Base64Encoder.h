//------------------------------------------------------------------------------
// Base64Encoder.h
//------------------------------------------------------------------------------

@interface Base64Encoder : NSObject;

+ (NSString *)encodeLogin:(NSString *)loginString withPassword:(NSString *)passwordString;
+ (int)encodeWithSrcLen:(unsigned)srcLen andSrc:(char *)src andDstLen:(unsigned)dstLen andDst:(char *)dst;

@end
