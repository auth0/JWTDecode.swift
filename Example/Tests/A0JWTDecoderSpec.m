//  A0JWTDecoderSpec.m
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

#import "Specta.h"
#import "A0JWTDecoder.h"

#define kJWTWithSpecialChars @"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJfaWQiOiI1M2VjNjdkODI1NDIyMzE3MDAzNGYxNzciLCJlbWFpbCI6Im15ZW1haWxAZ21haWwuY29tIiwicHJvZmlsZV9waWN0dXJlIjoiaHR0cDovL2Nkbi51YnVidWJ0ZXN0ZXIuaW8vN2Q4MjU0MjIzMTcwMDM0ZjE3Ny5wbmc_dD0xNDEzNDQyMTI4OTAwIiwiaWF0IjoxNDEzNDcyNzUyfQ.WEELiFZqavfxPcnZ7vz44gbPMbEc0xeCaaS53btTYXY"

NSString *A0TokenJWTCreate(NSDate *expireDate) {
    NSString *claims = [NSString stringWithFormat:@"{\"exp\": %f}", expireDate.timeIntervalSince1970];
    NSData *claimsData = [claims dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64Claims = [claimsData base64EncodedStringWithOptions:0];
    return [NSString stringWithFormat:@"HEADER.%@.SIGNATURE", base64Claims];
}

NSString *JWTCreate(NSDictionary *payload) {
    NSData *claimsData = [NSJSONSerialization dataWithJSONObject:payload options:0 error:nil];
    NSString *base64Claims = [claimsData base64EncodedStringWithOptions:0];
    return [NSString stringWithFormat:@"HEADER.%@.SIGNATURE", base64Claims];
}

SpecBegin(A0JWTDecoder)

describe(@"A0JWTDecoder", ^{

    __block NSString *jwt;

    describe(@"id_token expiration date", ^{

        context(@"valid id_token", ^{
            __block NSDate *expireDate;

            beforeEach(^{
                expireDate = [NSDate dateWithTimeIntervalSinceNow:2 * 60 * 60];
                jwt = A0TokenJWTCreate(expireDate);
            });

            it(@"should return expire date form id_token", ^{
                expect([A0JWTDecoder expireDateOfJWT:jwt error:nil].timeIntervalSince1970).to.equal(expireDate.timeIntervalSince1970);
            });

        });

        sharedExamplesFor(@"invalid id_token", ^(NSDictionary *data) {

            __block NSError *error;

            beforeEach(^{
                jwt = data[@"id_token"];
            });

            it(@"should return nil date", ^{
                expect([A0JWTDecoder expireDateOfJWT:jwt error:nil]).to.beNil();
            });

            specify(@"an error", ^{
                [A0JWTDecoder expireDateOfJWT:jwt error:&error];
                expect(error).toNot.beNil();
            });

        });

        itShouldBehaveLike(@"invalid id_token", @{ @"id_token": @"NOPARTS" });
        itShouldBehaveLike(@"invalid id_token", @{ @"id_token": @"NOTENOUGH.PARTS" });
        itShouldBehaveLike(@"invalid id_token", @{ @"id_token": @"HEADER.INVALIDCLAIM.SIGNATURE" });
    });

    describe(@"is JWT Expired?", ^{

        context(@"not expired token", ^{
            __block NSDate *expireDate;

            beforeEach(^{
                expireDate = [NSDate dateWithTimeIntervalSinceNow:2 * 60 * 60];
                jwt = A0TokenJWTCreate(expireDate);
            });

            specify(@"not expired", ^{
                expect([A0JWTDecoder isJWTExpired:jwt]).to.beFalsy();
            });
        });

        sharedExamplesFor(@"expired or invalid id_token", ^(NSDictionary *data) {

            beforeEach(^{
                jwt = data[@"id_token"];
            });

            specify(@"expired token", ^{
                expect([A0JWTDecoder isJWTExpired:jwt]).to.beTruthy();
            });

        });

        itShouldBehaveLike(@"expired or invalid id_token", @{ @"id_token": @"NOPARTS" });
        itShouldBehaveLike(@"expired or invalid id_token", @{ @"id_token": @"NOTENOUGH.PARTS" });
        itShouldBehaveLike(@"expired or invalid id_token", @{ @"id_token": @"HEADER.INVALIDCLAIM.SIGNATURE" });
        itShouldBehaveLike(@"expired or invalid id_token", @{ @"id_token": A0TokenJWTCreate([NSDate dateWithTimeIntervalSinceNow:-2 * 60 * 60]) });
    });

    describe(@"JWT payload", ^{

        __block NSError *error;
        __block NSDictionary *payload;

        context(@"valid id_token", ^{

            beforeEach(^{
                payload = [A0JWTDecoder payloadOfJWT:JWTCreate(@{@"key": @"value"}) error:&error];
            });

            specify(@"payload", ^{
                expect(payload).to.equal(@{@"key": @"value"});
            });

            specify(@"no error", ^{
                expect(error).to.beNil();
            });
        });

        context(@"valid id_token with special chars", ^{

            beforeEach(^{
                payload = [A0JWTDecoder payloadOfJWT:kJWTWithSpecialChars error:&error];
            });

            specify(@"payload", ^{
                expect(payload).notTo.beEmpty();
            });

            specify(@"no error", ^{
                expect(error).to.beNil();
            });
        });

        sharedExamplesFor(@"invalid id_token", ^(NSDictionary *data) {

            beforeEach(^{
                jwt = data[@"id_token"];
                payload = [A0JWTDecoder payloadOfJWT:jwt error:&error];
            });

            it(@"should return nil playload", ^{
                expect(payload).to.beNil();
            });

            specify(@"an error", ^{
                expect(error).toNot.beNil();
            });
            
        });
        
        itShouldBehaveLike(@"invalid id_token", @{ @"id_token": @"NOPARTS" });
        itShouldBehaveLike(@"invalid id_token", @{ @"id_token": @"NOTENOUGH.PARTS" });
        itShouldBehaveLike(@"invalid id_token", @{ @"id_token": @"HEADER.INVALIDCLAIM.SIGNATURE" });
    });
});

SpecEnd