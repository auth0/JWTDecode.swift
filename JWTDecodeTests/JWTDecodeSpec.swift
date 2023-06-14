import Quick
import Nimble
import JWTDecode
import Foundation

class JWTDecodeSpec: QuickSpec {
    override class func spec() {
        describe("decode") {
            it("should tell a jwt is expired") {
                expect(expiredJWT().expired).to(beTruthy())
            }

            it("should tell a jwt is not expired") {
                expect(nonExpiredJWT().expired).to(beFalsy())
            }

            it("should tell a jwt is expired with a close enough timestamp") {
                expect(jwtThatExpiresAt(date: Date()).expired).to(beTruthy())
            }

            it("should obtain payload") {
                let jwt = jwt(withBody: ["sub": "myid", "name": "Shawarma Monk"])
                let payload = jwt.body as! [String: String]
                expect(payload).to(equal(["sub": "myid", "name": "Shawarma Monk"]))
            }

            it("should return original jwt string representation") {
                let jwtString = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJjb20uc29td2hlcmUuZmFyLmJleW9uZDphcGki"
                    + "LCJpc3MiOiJhdXRoMCIsInVzZXJfcm9sZSI6ImFkbWluIn0.sS84motSLj9HNTgrCPcAjgZIQ99jXNN7_W9fEIIfxz0"
                let jwt = try! decode(jwt: jwtString)
                expect(jwt.string).to(equal(jwtString))
            }

            it("should return expire date") {
                expect(expiredJWT().expiresAt).toNot(beNil())
            }

            it("should decode valid jwt") {
                let jwtString = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJjb20uc29td2hlcmUuZmFyLmJleW9uZDphcGki"
                    + "LCJpc3MiOiJhdXRoMCIsInVzZXJfcm9sZSI6ImFkbWluIn0.sS84motSLj9HNTgrCPcAjgZIQ99jXNN7_W9fEIIfxz0"
                expect(try! decode(jwt: jwtString)).toNot(beNil())
            }

            it("should decode valid jwt with empty json body") {
                let jwtString = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.e30.Et9HFtf9R3GEMA0IICOfFMVXY7kkTX1wr4qCyhIf58U"
                expect(try! decode(jwt: jwtString)).toNot(beNil())
            }

            it("should raise exception with invalid base64 encoding") {
                let invalidChar = "%"
                let jwtString = "\(invalidChar).BODY.SIGNATURE"
                expect { try decode(jwt: jwtString) }
                    .to(throwError { (error: Error) in
                        expect(error).to(beJWTDecodeError(.invalidBase64URL(invalidChar)))
                    })
            }

            it("should raise exception with invalid json in jwt") {
                let jwtString = "HEADER.BODY.SIGNATURE"
                expect { try decode(jwt: jwtString) }
                    .to(throwError { (error: Error) in
                        expect(error).to(beJWTDecodeError(.invalidJSON("HEADER")))
                    })
            }

            it("should raise exception with missing parts") {
                let jwtString = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJzdWIifQ"
                expect { try decode(jwt: jwtString) }
                    .to(throwError { (error: Error) in
                        expect(error).to(beJWTDecodeError(.invalidPartCount(jwtString, 2)))
                    })
            }
        }

        describe("jwt parts") {
            let jwtString = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJzdWIifQ.xXcD7WOvUDHJ94E6aVHYgXdsJHLl2oW7Z"
                + "Xm4QpVvXnY"
            let sut = try! decode(jwt: jwtString)

            it("should return header") {
                expect(sut.header as? [String: String]).to(equal(["alg": "HS256", "typ": "JWT"]))
            }

            it("should return body") {
                expect(sut.body as? [String: String]).to(equal(["sub": "sub"]))
            }

            it("should return signature") {
                expect(sut.signature).to(equal("xXcD7WOvUDHJ94E6aVHYgXdsJHLl2oW7ZXm4QpVvXnY"))
            }
        }

        describe("claims") {
            var sut: JWT!

            describe("expiresAt claim") {
                it("should handle expired jwt") {
                    sut = expiredJWT()
                    expect(sut.expiresAt).toNot(beNil())
                    expect(sut.expired).to(beTruthy())
                }

                it("should handle non-expired jwt") {
                    sut = nonExpiredJWT()
                    expect(sut.expiresAt).toNot(beNil())
                    expect(sut.expired).to(beFalsy())
                }

                it("should handle jwt without expiresAt claim") {
                    sut = jwt(withBody: ["sub": UUID().uuidString])
                    expect(sut.expiresAt).to(beNil())
                    expect(sut.expired).to(beFalsy())
                }
            }

            describe("registered claims") {
                let jwtString = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL2V4YW1wbGUudXMuYXV0aDAuY29t"
                    + "Iiwic3ViIjoiYXV0aDB8MTAxMDEwMTAxMCIsImF1ZCI6Imh0dHBzOi8vZXhhbXBsZS51cy5hdXRoMC5jb20iLCJleHAiOjE"
                    + "zNzI2NzQzMzYsImlhdCI6MTM3MjYzODMzNiwianRpIjoicXdlcnR5MTIzNDU2IiwibmJmIjoxMzcyNjM4MzM2fQ.PmTa620"
                    + "SkKEawqtY8sFsxesdnN8C9ffFTmstfjPPR84"
                let sut = try! decode(jwt: jwtString)

                it("should return issuer") {
                    expect(sut.issuer).to(equal("https://example.us.auth0.com"))
                }

                it("should return subject") {
                    expect(sut.subject).to(equal("auth0|1010101010"))
                }

                it("should return single audience") {
                    expect(sut.audience).to(equal(["https://example.us.auth0.com"]))
                }

                context("multiple audiences") {
                    let jwtString = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOlsiaHR0cHM6Ly9leGFtcGxlLnVzLmF1dGgw"
                        + "LmNvbSIsImh0dHBzOi8vYXBpLmV4YW1wbGUudXMuYXV0aDAuY29tIl19.sw24la9mmCmykudpyE-U1Ar5bbyuDMyKaW"
                        + "ksSkBXhrM"
                    let sut = try! decode(jwt: jwtString)

                    it("should return all audiences") {
                        expect(sut.audience).to(equal(["https://example.us.auth0.com", "https://api.example.us.auth0.com"]))
                    }
                }

                it("should return issued at") {
                    expect(sut.issuedAt).to(equal(Date(timeIntervalSince1970: 1372638336)))
                }

                it("should return not before") {
                    expect(sut.notBefore).to(equal(Date(timeIntervalSince1970: 1372638336)))
                }

                it("should return jwt id") {
                    expect(sut.identifier).to(equal("qwerty123456"))
                }
            }

            describe("custom claim") {
                beforeEach {
                    sut = jwt(withBody: ["sub": UUID().uuidString,
                                         "custom_string_claim": "Shawarma Friday!",
                                         "custom_integer_claim": 10,
                                         "custom_integer_claim_0": 0,
                                         "custom_integer_claim_1": 1,
                                         "custom_integer_claim_string": "13",
                                         "custom_double_claim": 3.1,
                                         "custom_double_claim_0.0": 0.0,
                                         "custom_double_claim_1.0": 1.0,
                                         "custom_double_claim_string": "1.3",
                                         "custom_boolean_claim_true": true,
                                         "custom_boolean_claim_false": false])
                }

                it("should return claim by name") {
                    let claim = sut.claim(name: "custom_string_claim")
                    expect(claim.rawValue).toNot(beNil())
                }

                it("should return string claim") {
                    let claim = sut["custom_string_claim"]
                    expect(claim.string) == "Shawarma Friday!"
                    expect(claim.array) == ["Shawarma Friday!"]
                    expect(claim.integer).to(beNil())
                    expect(claim.double).to(beNil())
                    expect(claim.date).to(beNil())
                    expect(claim.boolean).to(beNil())
                }

                it("should return integer claim") {
                    let claim = sut["custom_integer_claim"]
                    expect(claim.string).to(beNil())
                    expect(claim.array).to(beNil())
                    expect(claim.integer) == 10
                    expect(claim.double) == 10.0
                    expect(claim.date) == Date(timeIntervalSince1970: 10)
                    expect(claim.boolean).to(beNil())
                }

                it("should return '0' integer claim") {
                    let claim = sut["custom_integer_claim_0"]
                    expect(claim.string).to(beNil())
                    expect(claim.array).to(beNil())
                    expect(claim.integer) == 0
                    expect(claim.double) == 0.0
                    expect(claim.date) == Date(timeIntervalSince1970: 0)
                    expect(claim.boolean).to(beNil())
                }

                it("should return '1' integer claim") {
                    let claim = sut["custom_integer_claim_1"]
                    expect(claim.string).to(beNil())
                    expect(claim.array).to(beNil())
                    expect(claim.integer) == 1
                    expect(claim.double) == 1.0
                    expect(claim.date) == Date(timeIntervalSince1970: 1)
                    expect(claim.boolean).to(beNil())
                }

                it("should return integer as string claim") {
                    let claim = sut["custom_integer_claim_string"]
                    expect(claim.string) == "13"
                    expect(claim.array) == ["13"]
                    expect(claim.integer) == 13
                    expect(claim.double) == 13.0
                    expect(claim.date) == Date(timeIntervalSince1970: 13)
                    expect(claim.boolean).to(beNil())
                }

                it("should return double claim") {
                    let claim = sut["custom_double_claim"]
                    expect(claim.string).to(beNil())
                    expect(claim.array).to(beNil())
                    expect(claim.integer) == 3
                    expect(claim.double) == 3.1
                    expect(claim.date) == Date(timeIntervalSince1970: 3.1)
                    expect(claim.boolean).to(beNil())
                }

                it("should return '0.0' double claim") {
                    let claim = sut["custom_double_claim_0.0"]
                    expect(claim.string).to(beNil())
                    expect(claim.array).to(beNil())
                    expect(claim.integer) == 0
                    expect(claim.double) == 0.0
                    expect(claim.date) == Date(timeIntervalSince1970: 0)
                    expect(claim.boolean).to(beNil())
                }

                it("should return '1.0' double claim") {
                    let claim = sut["custom_double_claim_1.0"]
                    expect(claim.string).to(beNil())
                    expect(claim.array).to(beNil())
                    expect(claim.integer) == 1
                    expect(claim.double) == 1.0
                    expect(claim.date) == Date(timeIntervalSince1970: 1)
                    expect(claim.boolean).to(beNil())
                }

                it("should return double as string claim") {
                    let claim = sut["custom_double_claim_string"]
                    expect(claim.string) == "1.3"
                    expect(claim.array) == ["1.3"]
                    expect(claim.integer).to(beNil())
                    expect(claim.double) == 1.3
                    expect(claim.date) == Date(timeIntervalSince1970: 1.3)
                    expect(claim.boolean).to(beNil())
                }

                it("should return true boolean claim") {
                    let claim = sut["custom_boolean_claim_true"]
                    expect(claim.string).to(beNil())
                    expect(claim.array).to(beNil())
                    expect(claim.integer).to(beNil())
                    expect(claim.double).to(beNil())
                    expect(claim.date).to(beNil())
                    expect(claim.boolean) == true
                }

                it("should return false boolean claim") {
                    let claim = sut["custom_boolean_claim_false"]
                    expect(claim.string).to(beNil())
                    expect(claim.array).to(beNil())
                    expect(claim.integer).to(beNil())
                    expect(claim.double).to(beNil())
                    expect(claim.date).to(beNil())
                    expect(claim.boolean) == false
                }

                it("should return no value when claim is not present") {
                    let unknownClaim = sut["missing_claim"]
                    expect(unknownClaim.array).to(beNil())
                    expect(unknownClaim.string).to(beNil())
                    expect(unknownClaim.integer).to(beNil())
                    expect(unknownClaim.double).to(beNil())
                    expect(unknownClaim.date).to(beNil())
                    expect(unknownClaim.boolean).to(beNil())
                }

                context("raw claim") {
                    var sut: JWT!

                    beforeEach {
                        let jwtString = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL3NhbXBsZXMuYXV0aDAu"
                            + "Y29tIiwic3ViIjoiYXV0aDB8MTAxMDEwMTAxMCIsImF1ZCI6Imh0dHBzOi8vc2FtcGxlcy5hdXRoMC5jb20iLCJ"
                            + "leHAiOjEzNzI2NzQzMzYsImlhdCI6MTM3MjYzODMzNiwianRpIjoicXdlcnR5MTIzNDU2IiwibmJmIjoxMzcyNj"
                            + "M4MzM2LCJlbWFpbCI6InVzZXJAaG9zdC5jb20iLCJjdXN0b20iOlsxLDIsM119.JeMRyHLkcoiqGxd958B6PABK"
                            + "NvhOhIgw-kbjecmhR_E"
                        sut = try! decode(jwt: jwtString)
                    }

                    it("should return email") {
                        expect(sut["email"].string) == "user@host.com"
                    }

                    it("should return array") {
                        expect(sut["custom"].rawValue as? [Int]).toNot(beNil())
                    }
                }
            }
        }
    }
}

public func beJWTDecodeError(_ code: JWTDecodeError) -> Predicate<Error> {
     return Predicate<Error>.define("be jwt decode error <\(code)>") { expression, failureMessage -> PredicateResult in
        guard let actual = try expression.evaluate() as? JWTDecodeError else {
            return PredicateResult(status: .doesNotMatch, message: failureMessage)
        }
        return PredicateResult(bool: actual == code, message: failureMessage)
    }
}

extension JWTDecodeError: Equatable {}

public func ==(lhs: JWTDecodeError, rhs: JWTDecodeError) -> Bool {
    return lhs.localizedDescription == rhs.localizedDescription && lhs.errorDescription == rhs.errorDescription
}
