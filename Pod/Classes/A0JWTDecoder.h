//  A0JWTDecoder.h
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

#import <Foundation/Foundation.h>

/**
 *  `A0JWTDecoder` provides convenience methods to parse a JWT token and extract it's values. It only decodes the JWT token which is in Base64, it doesn't validate the signature of the token.
 */
@interface A0JWTDecoder : NSObject

/**
 *  Decode and parse the JWT token and returns a `NSDate` with the expiration date of the JSON WebToken.
 *  If there is an error when parsing the JWT, the parameter `error` will have the failure reason.
 *
 *  @param jwt   a JWT Token
 *  @param error NSError if the decode fails
 *
 *  @return the expire date or nil if an error ocurrs.
 */
+ (NSDate *)expireDateOfJWT:(NSString *)jwt error:(NSError **)error;

/**
 *  Check if the token is expired using the device local time
 *
 *  @param jwt token to check expiration
 *
 *  @return if the token is expired or invalid it will return YES. Otherwise NO.
 */
+ (BOOL)isJWTExpired:(NSString *)jwt;

/**
 *  Parse the token and returns it's values as a NSDictionary.
 *
 *  @param jwt   token to parse
 *  @param error if the token has an invalid value it will be non-nil.
 *
 *  @return token payload as NSDictionary or nil if the token is invalid.
 */
+ (NSDictionary *)payloadOfJWT:(NSString *)jwt error:(NSError **)error;

@end
