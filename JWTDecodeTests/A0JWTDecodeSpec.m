//
//  A0JWTDecodeSpec.m
//  JWTDecode
//
//  Created by Hernan Zalazar on 6/25/15.
//  Copyright (c) 2015 Auth0. All rights reserved.
//

#define QUICK_DISABLE_SHORT_SYNTAX 1

#import <Quick/Quick.h>
#import <Nimble/Nimble.h>

@import JWTDecode;

QuickSpecBegin(A0JWTDecodeSpec)

__block JWTDecoder *decoder;
__block NSError *error;

describe(@"Objc support", ^{

    beforeEach(^{
        decoder = [[JWTDecoder alloc] initWithJwt:@"INVALID"];
        error = nil;
    });

    it(@"should return no payload and an error", ^{
        expect([decoder payloadWithError:&error]).to(beNil());
        expect(error).toNot(beNil());
    });

    it(@"should check expiration", ^{
        expect(@(decoder.expired)).to(beTruthy());
    });

    it(@"should return exp date", ^{
        expect(decoder.expiredDate).to(beNil());
    });
});

QuickSpecEnd
