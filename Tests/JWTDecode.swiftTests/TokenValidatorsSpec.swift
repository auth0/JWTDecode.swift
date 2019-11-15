// TokenValidatorsSpec.swift
//
// Copyright (c) 2018 Auth0 (http://auth0.com)
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

import Quick
import Nimble
import JWTDecode

class TokenValidatorsSpec: QuickSpec {
    
    override func spec() {
        
        let issuer = "https://sample.auth0.com"
        let audience = "AAAABBBBCCCCDDDDEEEFFFF"
        
        describe("init") {
            
            it("should set issuer and audience") {
                let validator = IDTokenValidation(issuer: issuer, audience: audience)
                expect(validator.issuer) == issuer
                expect(validator.audience) == audience
            }
            
        }
        
        describe("validation") {
            
            it("should return nil for valid token") {
                let validator = IDTokenValidation(issuer: issuer, audience: audience)
                let jwt = JWTHelper.newJWT(withIssuer: issuer, audience: audience, expiry: nonExpiredDate())
                expect(validator.validate(jwt)).to(beNil())
            }
            
            it("should return invalid iss claim error for invalid issuer") {
                let validator = IDTokenValidation(issuer: issuer, audience: audience)
                let jwt = JWTHelper.newJWT(withIssuer: "invalid_issuer", audience: audience, expiry: nonExpiredDate())
                let result = validator.validate(jwt)
                expect(result).to(matchError(ValidationError.invalidClaim("iss")))
                expect(validator.validate(jwt)).to(beClaimContent { claim in
                    expect(claim).to(equal("iss"))
                })
            }
            
            it("should return invalid aud claim error for invalid audience") {
                let validator = IDTokenValidation(issuer: issuer, audience: audience)
                let jwt = JWTHelper.newJWT(withIssuer: issuer, audience: "invalid_audience", expiry: nonExpiredDate())
                let result = validator.validate(jwt)
                expect(result).to(matchError(ValidationError.invalidClaim("aud")))
                expect(validator.validate(jwt)).to(beClaimContent { claim in
                    expect(claim).to(equal("aud"))
                })
            }
            
            it("should return expired error for expired token") {
                let validator = IDTokenValidation(issuer: issuer, audience: audience)
                let jwt = JWTHelper.newJWT(withIssuer: issuer, audience: audience, expiry: expiredDate())
                expect(validator.validate(jwt)).to(matchError(ValidationError.expired))
            }
            
            context("nonce") {
                let nonce = "NONCE123"
                
                it("should return nil if nonce matches") {
                    let validator = IDTokenValidation(issuer: issuer, audience: audience)
                    let jwt = JWTHelper.newJWT(withIssuer: issuer, audience: audience, expiry: nonExpiredDate(), nonce: nonce)
                    expect(validator.validate(jwt, nonce: nonce)).to(beNil())
                }
                
                it("should return nonce error if nonce miss match") {
                    let validator = IDTokenValidation(issuer: issuer, audience: audience)
                    let jwt = JWTHelper.newJWT(withIssuer: issuer, audience: audience, expiry: nonExpiredDate(), nonce: "nomatch")
                    expect(validator.validate(jwt, nonce: nonce)).to(matchError(ValidationError.nonce))
                }
                
                it("should return nonce error when JWT has nonce but validator nonce missing") {
                    let validator = IDTokenValidation(issuer: issuer, audience: audience)
                    let jwt = JWTHelper.newJWT(withIssuer: issuer, audience: audience, expiry: nonExpiredDate(), nonce: nonce)
                    expect(validator.validate(jwt)).to(matchError(ValidationError.nonce))
                }
                
            }
        }
    }
}

private func beClaimContent(_ test: @escaping (String) -> Void = { _ in }) -> Predicate<ValidationError> {
    return Predicate.define("be <content>") { expression, message in
        if let actual = try expression.evaluate(),
            case let .invalidClaim(response) = actual {
            test(response)
            return PredicateResult(status: .matches, message: message)
        }
        return PredicateResult(status: .fail, message: message)
    }
}
