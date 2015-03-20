#import <Foundation/Foundation.h>
#import "HTTPResponse.h"


@interface HTTPDataResponse : NSObject <HTTPResponse>
{
	NSUInteger offset;
	NSData *data;
}
@property (nonatomic) NSDictionary *headers;

- (id)initWithData:(NSData *)data;

@end
