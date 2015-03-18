#import <Foundation/Foundation.h>
#import "HTTPResponse.h"


@interface HTTPRedirectResponse : NSObject <HTTPResponse>
{
	NSString *redirectPath;
}
@property (nonatomic) NSDictionary *headers;

- (id)initWithPath:(NSString *)redirectPath;

@end
