//  A0JWTDecoder.m
//
// Copyright (c) 2014 Auth0 (http://auth0.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "A0JWTDecoder.h"

NSError *ErrorWithDescription(NSString *description) {
    return [NSError errorWithDomain:@"com.auth0.JWTDecode"
                               code:0
                           userInfo:@{
                                      NSLocalizedDescriptionKey: description
                                      }];
}

@implementation A0JWTDecoder

+ (NSDate *)expireDateOfJWT:(NSString *)jwt error:(NSError *__autoreleasing *)error {
    NSDate *expiresAt = nil;
    NSError *decodeError;
    NSDictionary *claimsJSON = [self payloadOfJWT:jwt error:&decodeError];
    if (!decodeError && claimsJSON[@"exp"] && [claimsJSON[@"exp"] isKindOfClass:NSNumber.class]) {
        NSNumber *expireFromEpoch = claimsJSON[@"exp"];
        expiresAt = [NSDate dateWithTimeIntervalSince1970:expireFromEpoch.doubleValue];
    }
    if (error) {
        *error = decodeError;
    }
    return expiresAt;
}

+ (BOOL)isJWTExpired:(NSString *)jwt {
    NSDate *expireDate = [self expireDateOfJWT:jwt error:nil];
    return !expireDate || [expireDate compare:[NSDate date]] == NSOrderedAscending;
}

+ (NSDictionary *)payloadOfJWT:(NSString *)jwt error:(NSError *__autoreleasing *)error {
    NSDictionary *payload;
    NSError *decodeError;
    NSArray *parts = [jwt componentsSeparatedByString:@"."];
    if (parts.count == 3) {
        NSString *claimsBase64 = parts[1];
        NSInteger claimsLength = claimsBase64.length;
        NSInteger requiredLength = (4 * ceil((double)claimsLength / 4.0));
        NSInteger paddingCount = requiredLength - claimsLength;

        claimsBase64 = [claimsBase64 stringByReplacingOccurrencesOfString:@"-" withString:@"+"];
        claimsBase64 = [claimsBase64 stringByReplacingOccurrencesOfString:@"_" withString:@"/"];

        if (paddingCount > 0) {
            NSString *padding =
            [[NSString string] stringByPaddingToLength:paddingCount
                                            withString:@"=" startingAtIndex:0];
            claimsBase64 = [claimsBase64 stringByAppendingString:padding];
        }

        NSData *claimsData = [[NSData alloc] initWithBase64EncodedString:claimsBase64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
        if (claimsData) {
            payload = [NSJSONSerialization JSONObjectWithData:claimsData options:0 error:&decodeError];
        } else {
            decodeError = ErrorWithDescription(@"Invalid id_token claims part. Failed to decode base64");
        }
    } else {
        decodeError = ErrorWithDescription(@"Invalid id_token. Not enough parts  (Required 3 parts)");
    }
    if (error) {
        *error = decodeError;
    }
    return payload;
}

@end
