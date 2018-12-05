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
            
            it("should return true for valid token") {
                let validator = IDTokenValidation(issuer: issuer, audience: audience)
                let jwt = JWTHelper.newJWT(withIssuer: issuer, audience: audience, expiry: nonExpiredDate())
                expect(validator.validate(jwt)).to(beTrue())
            }
            
            it("should fail for invalid issuer") {
                let validator = IDTokenValidation(issuer: issuer, audience: audience)
                let jwt = JWTHelper.newJWT(withIssuer: "invalid_issuer", audience: audience, expiry: nonExpiredDate())
                expect(validator.validate(jwt)).to(beFalse())
            }
            
            it("should fail for invalid audience") {
                let validator = IDTokenValidation(issuer: issuer, audience: audience)
                let jwt = JWTHelper.newJWT(withIssuer: issuer, audience: "invalid_audience", expiry: nonExpiredDate())
                expect(validator.validate(jwt)).to(beFalse())
            }
            
            it("should fail for expired token") {
                let validator = IDTokenValidation(issuer: issuer, audience: audience)
                let jwt = JWTHelper.newJWT(withIssuer: issuer, audience: audience, expiry: expiredDate())
                expect(validator.validate(jwt)).to(beFalse())
            }
            
            context("nonce") {
                let nonce = "NONCE123"
                
                it("should check nonce if set") {
                    let validator = IDTokenValidation(issuer: issuer, audience: audience)
                    let jwt = JWTHelper.newJWT(withIssuer: issuer, audience: audience, expiry: nonExpiredDate(), nonce: nonce)
                    expect(validator.validate(jwt, nonce: nonce)).to(beTrue())
                }
                
                it("should fail nonce if no match") {
                    let validator = IDTokenValidation(issuer: issuer, audience: audience)
                    let jwt = JWTHelper.newJWT(withIssuer: issuer, audience: audience, expiry: nonExpiredDate(), nonce: "nomatch")
                    expect(validator.validate(jwt, nonce: nonce)).to(beFalse())
                }
                
                it("should fail when JWT has nonce but validator doesn't") {
                    let validator = IDTokenValidation(issuer: issuer, audience: audience)
                    let jwt = JWTHelper.newJWT(withIssuer: issuer, audience: audience, expiry: nonExpiredDate(), nonce: nonce)
                    expect(validator.validate(jwt)).to(beFalse())
                }
                
            }
        }
    }
}
