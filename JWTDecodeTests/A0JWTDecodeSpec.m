#define QUICK_DISABLE_SHORT_SYNTAX 1

@import Quick;
@import Nimble;
@import JWTDecode;

QuickSpecBegin(A0JWTDecodeSpec)

__block NSError *error;

describe(@"Objective-C support", ^{

    beforeEach(^{
        error = nil;
    });

    it(@"should return nil jwt and an error", ^{
        expect([A0JWT decodeWithJwt:@"INVALID" error:&error]).to(beNil());
        expect(error).toNot(beNil());
    });

});

QuickSpecEnd
