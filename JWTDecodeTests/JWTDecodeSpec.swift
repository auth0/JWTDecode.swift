import XCTest
import JWTDecode
import Foundation

class JWTDecodeSpec: XCTestCase {

    func testExpiredJWT() {
        let sut = expiredJWT()
        XCTAssertTrue(sut.expired)
    }

    func testNonExpiredJWT() {
        let sut = nonExpiredJWT()
        XCTAssertFalse(sut.expired)
    }

    func testExpiredJWTWithCloseEnoughTimestamp() {
        let sut = jwtThatExpiresAt(date: Date())
        XCTAssertTrue(sut.expired)
    }

    func testJWTWillExpire() {
        let sut = jwtThatExpiresAt(date: Date().addingTimeInterval(500))
        XCTAssertTrue(sut.expires(in: 600))
    }

    func testJWTWillNotExpire() {
        let sut = jwtThatExpiresAt(date: Date().addingTimeInterval(500))
        XCTAssertFalse(sut.expires(in: 400))
    }

    func testObtainPayload() {
        let jwt = jwt(withBody: ["sub": "myid", "name": "Shawarma Monk"])
        let payload = jwt.body as! [String: String]
        XCTAssertEqual(payload, ["sub": "myid", "name": "Shawarma Monk"])
    }

    func testReturnOriginalJWTStringRepresentation() {
        let jwtString = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJjb20uc29td2hlcmUuZmFyLmJleW9uZDphcGki"
        + "LCJpc3MiOiJhdXRoMCIsInVzZXJfcm9sZSI6ImFkbWluIn0.sS84motSLj9HNTgrCPcAjgZIQ99jXNN7_W9fEIIfxz0"
        let jwt = try! decode(jwt: jwtString)
        XCTAssertEqual(jwt.string, jwtString)
    }

    func testReturnExpireDate() {
        let sut = expiredJWT()
        XCTAssertNotNil(sut.expiresAt)
    }

    func testDecodeValidJWT() {
        let jwtString = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJjb20uc29td2hlcmUuZmFyLmJleW9uZDphcGki"
        + "LCJpc3MiOiJhdXRoMCIsInVzZXJfcm9sZSI6ImFkbWluIn0.sS84motSLj9HNTgrCPcAjgZIQ99jXNN7_W9fEIIfxz0"
        XCTAssertNotNil(try! decode(jwt: jwtString))
    }

    func testDecodeValidJWTWithEmptyJSONBody() {
        let jwtString = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.e30.Et9HFtf9R3GEMA0IICOfFMVXY7kkTX1wr4qCyhIf58U"
        XCTAssertNotNil(try! decode(jwt: jwtString))
    }

    func testRaiseExceptionWithInvalidBase64Encoding() {
        let invalidChar = "%"
        let jwtString = "\(invalidChar).BODY.SIGNATURE"
        XCTAssertThrowsError(try decode(jwt: jwtString)) { error in
            XCTAssertEqual(error as? JWTDecodeError, .invalidBase64URL(invalidChar))
        }
    }

    func testRaiseExceptionWithInvalidJSONInJWT() {
        let jwtString = "HEADER.BODY.SIGNATURE"
        XCTAssertThrowsError(try decode(jwt: jwtString)) { error in
            XCTAssertEqual(error as? JWTDecodeError, .invalidJSON("HEADER"))
        }
    }

    func testRaiseExceptionWithMissingParts() {
        let jwtString = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJzdWIifQ"
        XCTAssertThrowsError(try decode(jwt: jwtString)) { error in
            XCTAssertEqual(error as? JWTDecodeError, .invalidPartCount(jwtString, 2))
        }
    }

    func testReturnHeader() {
        let jwtString = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJzdWIifQ.xXcD7WOvUDHJ94E6aVHYgXdsJHLl2oW7Z"
        + "Xm4QpVvXnY"
        let sut = try! decode(jwt: jwtString)
        XCTAssertEqual(sut.header as? [String: String], ["alg": "HS256", "typ": "JWT"])
    }

    func testReturnBody() {
        let jwtString = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJzdWIifQ.xXcD7WOvUDHJ94E6aVHYgXdsJHLl2oW7Z"
        + "Xm4QpVvXnY"
        let sut = try! decode(jwt: jwtString)
        XCTAssertEqual(sut.body as? [String: String], ["sub": "sub"])
    }

    func testReturnSignature() {
        let jwtString = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJzdWIifQ.xXcD7WOvUDHJ94E6aVHYgXdsJHLl2oW7Z"
        + "Xm4QpVvXnY"
        let sut = try! decode(jwt: jwtString)
        XCTAssertEqual(sut.signature, "xXcD7WOvUDHJ94E6aVHYgXdsJHLl2oW7ZXm4QpVvXnY")
    }

    func testExpiresAtClaimExpiredJWT() {
        let sut = expiredJWT()
        XCTAssertNotNil(sut.expiresAt)
        XCTAssertTrue(sut.expired)
    }

    func testExpiresAtClaimNonExpiredJWT() {
        let sut = nonExpiredJWT()
        XCTAssertNotNil(sut.expiresAt)
        XCTAssertFalse(sut.expired)
    }

    func testExpiresAtClaimJWTWithoutExpiresAtClaim() {
        let sut = jwt(withBody: ["sub": UUID().uuidString])
        XCTAssertNil(sut.expiresAt)
        XCTAssertFalse(sut.expired)
    }

    func testIssuerClaim() {
        let jwtString = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL2V4YW1wbGUudXMuYXV0aDAuY29t"
        + "Iiwic3ViIjoiYXV0aDB8MTAxMDEwMTAxMCIsImF1ZCI6Imh0dHBzOi8vZXhhbXBsZS51cy5hdXRoMC5jb20iLCJleHAiOjE"
        + "zNzI2NzQzMzYsImlhdCI6MTM3MjYzODMzNiwianRpIjoicXdlcnR5MTIzNDU2IiwibmJmIjoxMzcyNjM4MzM2fQ.PmTa620"
        + "SkKEawqtY8sFsxesdnN8C9ffFTmstfjPPR84"
        let sut = try! decode(jwt: jwtString)
        XCTAssertEqual(sut.issuer, "https://example.us.auth0.com")
    }

    func testSubjectClaim() {
        let jwtString = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL2V4YW1wbGUudXMuYXV0aDAuY29t"
        + "Iiwic3ViIjoiYXV0aDB8MTAxMDEwMTAxMCIsImF1ZCI6Imh0dHBzOi8vZXhhbXBsZS51cy5hdXRoMC5jb20iLCJleHAiOjE"
        + "zNzI2NzQzMzYsImlhdCI6MTM3MjYzODMzNiwianRpIjoicXdlcnR5MTIzNDU2IiwibmJmIjoxMzcyNjM4MzM2fQ.PmTa620"
        + "SkKEawqtY8sFsxesdnN8C9ffFTmstfjPPR84"
        let sut = try! decode(jwt: jwtString)
        XCTAssertEqual(sut.subject, "auth0|1010101010")
    }

    func testSingleAudienceClaim() {
        let jwtString = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL2V4YW1wbGUudXMuYXV0aDAuY29t"
        + "Iiwic3ViIjoiYXV0aDB8MTAxMDEwMTAxMCIsImF1ZCI6Imh0dHBzOi8vZXhhbXBsZS51cy5hdXRoMC5jb20iLCJleHAiOjE"
        + "zNzI2NzQzMzYsImlhdCI6MTM3MjYzODMzNiwianRpIjoicXdlcnR5MTIzNDU2IiwibmJmIjoxMzcyNjM4MzM2fQ.PmTa620"
        + "SkKEawqtY8sFsxesdnN8C9ffFTmstfjPPR84"
        let sut = try! decode(jwt: jwtString)
        XCTAssertEqual(sut.audience, ["https://example.us.auth0.com"])
    }

    func testMultipleAudiencesClaim() {
        let jwtString = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOlsiaHR0cHM6Ly9leGFtcGxlLnVzLmF1dGgw"
        + "LmNvbSIsImh0dHBzOi8vYXBpLmV4YW1wbGUudXMuYXV0aDAuY29tIl19.sw24la9mmCmykudpyE-U1Ar5bbyuDMyKaW"
        + "ksSkBXhrM"
        let sut = try! decode(jwt: jwtString)
        XCTAssertEqual(sut.audience, ["https://example.us.auth0.com", "https://api.example.us.auth0.com"])
    }

    func testIssuedAtClaim() {
        let jwtString = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL2V4YW1wbGUudXMuYXV0aDAuY29t"
        + "Iiwic3ViIjoiYXV0aDB8MTAxMDEwMTAxMCIsImF1ZCI6Imh0dHBzOi8vZXhhbXBsZS51cy5hdXRoMC5jb20iLCJleHAiOjE"
        + "zNzI2NzQzMzYsImlhdCI6MTM3MjYzODMzNiwianRpIjoicXdlcnR5MTIzNDU2IiwibmJmIjoxMzcyNjM4MzM2fQ.PmTa620"
        + "SkKEawqtY8sFsxesdnN8C9ffFTmstfjPPR84"
        let sut = try! decode(jwt: jwtString)
        XCTAssertEqual(sut.issuedAt, Date(timeIntervalSince1970: 1372638336))
    }

    func testNotBeforeClaim() {
        let jwtString = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL2V4YW1wbGUudXMuYXV0aDAuY29t"
        + "Iiwic3ViIjoiYXV0aDB8MTAxMDEwMTAxMCIsImF1ZCI6Imh0dHBzOi8vZXhhbXBsZS51cy5hdXRoMC5jb20iLCJleHAiOjE"
        + "zNzI2NzQzMzYsImlhdCI6MTM3MjYzODMzNiwianRpIjoicXdlcnR5MTIzNDU2IiwibmJmIjoxMzcyNjM4MzM2fQ.PmTa620"
        + "SkKEawqtY8sFsxesdnN8C9ffFTmstfjPPR84"
        let sut = try! decode(jwt: jwtString)
        XCTAssertEqual(sut.notBefore, Date(timeIntervalSince1970: 1372638336))
    }

    func testJWTIdClaim() {
        let jwtString = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL2V4YW1wbGUudXMuYXV0aDAuY29t"
        + "Iiwic3ViIjoiYXV0aDB8MTAxMDEwMTAxMCIsImF1ZCI6Imh0dHBzOi8vZXhhbXBsZS51cy5hdXRoMC5jb20iLCJleHAiOjE"
        + "zNzI2NzQzMzYsImlhdCI6MTM3MjYzODMzNiwianRpIjoicXdlcnR5MTIzNDU2IiwibmJmIjoxMzcyNjM4MzM2fQ.PmTa620"
        + "SkKEawqtY8sFsxesdnN8C9ffFTmstfjPPR84"
        let sut = try! decode(jwt: jwtString)
        XCTAssertEqual(sut.identifier, "qwerty123456")
    }

    func testClaimByName() {
        let sut = jwt(withBody: ["sub": UUID().uuidString,
                                 "custom_string_claim": "Shawarma Friday!",
                                 "custom_integer_claim": 10,
                                 "custom_integer_claim_0": 0,
                                 "custom_integer_claim_1": 1,
                                 "custom_integer_claim_string": "13"])
        let claim = sut.claim(name: "custom_string_claim")
        XCTAssertNotNil(claim.rawValue)
    }

    func testCustomStringClaim() {
        let sut = jwt(withBody: ["sub": UUID().uuidString,
                                 "custom_string_claim": "Shawarma Friday!",
                                 "custom_integer_claim": 10,
                                 "custom_integer_claim_0": 0,
                                 "custom_integer_claim_1": 1,
                                 "custom_integer_claim_string": "13"])

        let claim = sut.claim(name: "custom_string_claim")
        XCTAssertEqual(claim.string, "Shawarma Friday!")
        XCTAssertEqual(claim.array, ["Shawarma Friday!"])
        XCTAssertNil(claim.integer)
        XCTAssertNil(claim.double)
        XCTAssertNil(claim.date)
        XCTAssertNil(claim.boolean)
    }

    func testCustomIntegerClaim() {
        let sut = jwt(withBody: ["sub": UUID().uuidString,
                                 "custom_string_claim": "Shawarma Friday!",
                                 "custom_integer_claim": 10,
                                 "custom_integer_claim_0": 0,
                                 "custom_integer_claim_1": 1,
                                 "custom_integer_claim_string": "13"])
        let claim = sut["custom_integer_claim"]
        XCTAssertNil(claim.string)
        XCTAssertNil(claim.array)
        XCTAssertEqual(claim.integer, 10)
        XCTAssertEqual(claim.double, 10.0)
        XCTAssertEqual(claim.date, Date(timeIntervalSince1970: 10))
        XCTAssertNil(claim.boolean)
    }

    func testCustomIntegerClaim0() {
        let sut = jwt(withBody: ["sub": UUID().uuidString,
                                 "custom_string_claim": "Shawarma Friday!",
                                 "custom_integer_claim": 10,
                                 "custom_integer_claim_0": 0,
                                 "custom_integer_claim_1": 1,
                                 "custom_integer_claim_string": "13"])
        let claim = sut["custom_integer_claim_0"]
        XCTAssertNil(claim.string)
        XCTAssertNil(claim.array)
        XCTAssertEqual(claim.integer, 0)
        XCTAssertEqual(claim.double, 0.0)
        XCTAssertEqual(claim.date, Date(timeIntervalSince1970: 0))
        XCTAssertNil(claim.boolean)
    }

    func testCustomIntegerClaim1() {
        let sut = jwt(withBody: ["sub": UUID().uuidString,
                                 "custom_string_claim": "Shawarma Friday!",
                                 "custom_integer_claim": 10,
                                 "custom_integer_claim_0": 0,
                                 "custom_integer_claim_1": 1,
                                 "custom_integer_claim_string": "13"])
        let claim = sut["custom_integer_claim_1"]
        XCTAssertNil(claim.string)
        XCTAssertNil(claim.array)
        XCTAssertEqual(claim.integer, 1)
        XCTAssertEqual(claim.double, 1.0)
        XCTAssertEqual(claim.date, Date(timeIntervalSince1970: 1))
        XCTAssertNil(claim.boolean)
    }

    func testCustomIntegerClaimString() {
        let sut = jwt(withBody: ["sub": UUID().uuidString,
                                 "custom_string_claim": "Shawarma Friday!",
                                 "custom_integer_claim": 10,
                                 "custom_integer_claim_0": 0,
                                 "custom_integer_claim_1": 1,
                                 "custom_integer_claim_string": "13"])
        let claim = sut["custom_integer_claim_string"]
        XCTAssertEqual(claim.string, "13")
        XCTAssertEqual(claim.array, ["13"])
        XCTAssertEqual(claim.integer, 13)
        XCTAssertEqual(claim.double, 13.0)
        XCTAssertEqual(claim.date, Date(timeIntervalSince1970: 13))
        XCTAssertNil(claim.boolean)
    }

    func testCustomDoubleClaim() {
        let sut = jwt(withBody: ["sub": UUID().uuidString,
                                 "custom_string_claim": "Shawarma Friday!",
                                 "custom_integer_claim": 10,
                                 "custom_integer_claim_0": 0,
                                 "custom_integer_claim_1": 1,
                                 "custom_integer_claim_string": "13",
                                 "custom_double_claim": 3.1])
        let claim = sut["custom_double_claim"]
        XCTAssertNil(claim.string)
        XCTAssertNil(claim.array)
        XCTAssertEqual(claim.integer, 3)
        XCTAssertEqual(claim.double, 3.1)
        XCTAssertEqual(claim.date, Date(timeIntervalSince1970: 3.1))
        XCTAssertNil(claim.boolean)
    }

    func testCustomDoubleClaim0() {
        let sut = jwt(withBody: ["sub": UUID().uuidString,
                                 "custom_string_claim": "Shawarma Friday!",
                                 "custom_integer_claim": 10,
                                 "custom_integer_claim_0": 0,
                                 "custom_integer_claim_1": 1,
                                 "custom_integer_claim_string": "13",
                                 "custom_double_claim_0.0": 0.0])
        let claim = sut["custom_double_claim_0.0"]
        XCTAssertNil(claim.string)
        XCTAssertNil(claim.array)
        XCTAssertEqual(claim.integer, 0)
        XCTAssertEqual(claim.double, 0.0)
        XCTAssertEqual(claim.date, Date(timeIntervalSince1970: 0))
        XCTAssertNil(claim.boolean)
    }

    func testCustomDoubleClaim1() {
        let sut = jwt(withBody: ["sub": UUID().uuidString,
                                 "custom_string_claim": "Shawarma Friday!",
                                 "custom_integer_claim": 10,
                                 "custom_integer_claim_0": 0,
                                 "custom_integer_claim_1": 1,
                                 "custom_integer_claim_string": "13",
                                 "custom_double_claim_1.0": 1.0])
        let claim = sut["custom_double_claim_1.0"]
        XCTAssertNil(claim.string)
        XCTAssertNil(claim.array)
        XCTAssertEqual(claim.integer, 1)
        XCTAssertEqual(claim.double, 1.0)
        XCTAssertEqual(claim.date, Date(timeIntervalSince1970: 1))
        XCTAssertNil(claim.boolean)
    }

    func testCustomDoubleClaimString() {
        let sut = jwt(withBody: ["sub": UUID().uuidString,
                                 "custom_string_claim": "Shawarma Friday!",
                                 "custom_integer_claim": 10,
                                 "custom_integer_claim_0": 0,
                                 "custom_integer_claim_1": 1,
                                 "custom_integer_claim_string": "13",
                                 "custom_double_claim_string": "1.3"])
        let claim = sut["custom_double_claim_string"]
        XCTAssertEqual(claim.string, "1.3")
        XCTAssertEqual(claim.array, ["1.3"])
        XCTAssertNil(claim.integer)
        XCTAssertEqual(claim.double, 1.3)
        XCTAssertEqual(claim.date, Date(timeIntervalSince1970: 1.3))
        XCTAssertNil(claim.boolean)
    }

    func testCustomBooleanClaimTrue() {
        let sut = jwt(withBody: ["sub": UUID().uuidString,
                                 "custom_string_claim": "Shawarma Friday!",
                                 "custom_integer_claim": 10,
                                 "custom_integer_claim_0": 0,
                                 "custom_integer_claim_1": 1,
                                 "custom_integer_claim_string": "13",
                                 "custom_boolean_claim_true": true])
        let claim = sut["custom_boolean_claim_true"]
        XCTAssertNil(claim.string)
        XCTAssertNil(claim.array)
        XCTAssertNil(claim.integer)
        XCTAssertNil(claim.double)
        XCTAssertNil(claim.date)
        XCTAssertEqual(claim.boolean, true)
    }

    func testCustomBooleanClaimFalse() {
        let sut = jwt(withBody: ["sub": UUID().uuidString,
                                 "custom_string_claim": "Shawarma Friday!",
                                 "custom_integer_claim": 10,
                                 "custom_integer_claim_0": 0,
                                 "custom_integer_claim_1": 1,
                                 "custom_integer_claim_string": "13",
                                 "custom_boolean_claim_false": false])
        let claim = sut["custom_boolean_claim_false"]
        XCTAssertNil(claim.string)
        XCTAssertNil(claim.array)
        XCTAssertNil(claim.integer)
        XCTAssertNil(claim.double)
        XCTAssertNil(claim.date)
        XCTAssertEqual(claim.boolean, false)
    }

    func testMissingClaim() {
        let sut = jwt(withBody: ["sub": UUID().uuidString,
                                 "custom_string_claim": "Shawarma Friday!",
                                 "custom_integer_claim": 10,
                                 "custom_integer_claim_0": 0,
                                 "custom_integer_claim_1": 1,
                                 "custom_integer_claim_string": "13"])
        let unknownClaim = sut["missing_claim"]
        XCTAssertNil(unknownClaim.array)
        XCTAssertNil(unknownClaim.string)
        XCTAssertNil(unknownClaim.integer)
        XCTAssertNil(unknownClaim.double)
        XCTAssertNil(unknownClaim.date)
        XCTAssertNil(unknownClaim.boolean)
    }

    func testRawClaimEmail() {
        let jwtString = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL3NhbXBsZXMuYXV0aDAuY29tIiwic3ViIjoiYXV0aDB8MTAxMDEwMTAxMCIsImF1ZCI6Imh0dHBzOi8vc2FtcGxlcy5hdXRoMC5jb20iLCJleHAiOjEzNzI2NzQzMzYsImlhdCI6MTM3MjYzODMzNiwianRpIjoicXdlcnR5MTIzNDU2IiwibmJmIjoxMzcyNjM4MzM2LCJlbWFpbCI6InVzZXJAaG9zdC5jb20iLCJjdXN0b20iOlsxLDIsM119.JeMRyHLkcoiqGxd958B6PABKNvhOhIgw-kbjecmhR_E"
        let sut = try! decode(jwt: jwtString)
        XCTAssertEqual(sut["email"].rawValue as? String, "user@host.com")
    }

    func testRawClaimArray() {
        let jwtString = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL3NhbXBsZXMuYXV0aDAuY29tIiwic3ViIjoiYXV0aDB8MTAxMDEwMTAxMCIsImF1ZCI6Imh0dHBzOi8vc2FtcGxlcy5hdXRoMC5jb20iLCJleHAiOjEzNzI2NzQzMzYsImlhdCI6MTM3MjYzODMzNiwianRpIjoicXdlcnR5MTIzNDU2IiwibmJmIjoxMzcyNjM4MzM2LCJlbWFpbCI6InVzZXJAaG9zdC5jb20iLCJjdXN0b20iOlsxLDIsM119.JeMRyHLkcoiqGxd958B6PABKNvhOhIgw-kbjecmhR_E"
        let sut = try! decode(jwt: jwtString)
        XCTAssertNotNil(sut["custom"].rawValue as? [Int])
    }

    func testRawClaimDict() {
        let jwtString = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL3NhbXBsZXMuYXV0aDAuY29tIiwic3ViIjoiYXV0aDB8MTAxMDEwMTAxMCIsImF1ZCI6Imh0dHBzOi8vc2FtcGxlcy5hdXRoMC5jb20iLCJleHAiOjEzNzI2NzQzMzYsImlhdCI6MTM3MjYzODMzNiwianRpIjoicXdlcnR5MTIzNDU2IiwibmJmIjoxMzcyNjM4MzM2LCJlbWFpbCI6InVzZXJAaG9zdC5jb20iLCJjdXN0b20iOnsiZm9vIjoiYmFyIiwiYmF6IjoxMjN9fQ.scStGGBQrySWIeJEoCgHhx7fUQT-ciUGG_itliv1nKQ"
        let sut = try! decode(jwt: jwtString)
        XCTAssertNotNil(sut["custom"].rawValue as? [String: Any])
    }

    // MARK: - Data Property Tests

    func testClaimDataFromString() {
        let sut = jwt(withBody: ["custom_string_claim": "Shawarma Friday!"])
        let claim = sut["custom_string_claim"]
        // Primitives should return nil - use .string instead
        XCTAssertNil(claim.data)
    }

    func testClaimDataFromInteger() {
        let sut = jwt(withBody: ["custom_integer_claim": 42])
        let claim = sut["custom_integer_claim"]
        // Primitives should return nil - use .integer instead
        XCTAssertNil(claim.data)
    }

    func testClaimDataFromArray() {
        let sut = jwt(withBody: ["custom_array_claim": ["one", "two", "three"]])
        let claim = sut["custom_array_claim"]
        XCTAssertNotNil(claim.data)
        if let data = claim.data {
            let decoded = try? JSONSerialization.jsonObject(with: data) as? [String]
            XCTAssertEqual(decoded, ["one", "two", "three"])
        }
    }

    func testClaimDataFromDictionary() {
        let sut = jwt(withBody: ["custom_dict_claim": ["foo": "bar", "baz": 123]])
        let claim = sut["custom_dict_claim"]
        XCTAssertNotNil(claim.data)
        if let data = claim.data {
            let decoded = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
            XCTAssertNotNil(decoded)
        }
    }

    func testClaimDataFromNilValue() {
        let sut = jwt(withBody: ["existing": "value"])
        let claim = sut["missing_claim"]
        XCTAssertNil(claim.data)
    }

    // MARK: - Decode Method Tests

    func testDecodeClaimToDecodableType() throws {
        struct Address: Decodable, Equatable {
            let street: String
            let city: String
        }
        
        let addressData = ["street": "MG Road, Koramangala", "city": "Bangalore"]
        let sut = jwt(withBody: ["address": addressData])
        
        let address = try sut["address"].decode(Address.self)
        XCTAssertEqual(address.street, "MG Road, Koramangala")
        XCTAssertEqual(address.city, "Bangalore")
    }

    func testDecodeClaimArray() throws {
        struct Role: Decodable, Equatable {
            let name: String
            let level: Int
        }
        
        let rolesData: [[String: Any]] = [
            ["name": "admin", "level": 10],
            ["name": "user", "level": 1]
        ]
        let sut = jwt(withBody: ["roles": rolesData])
        
        let roles = try sut["roles"].decode([Role].self)
        XCTAssertEqual(roles.count, 2)
        XCTAssertEqual(roles[0].name, "admin")
        XCTAssertEqual(roles[1].level, 1)
    }

    func testDecodeClaimWithCustomDecoder() throws {
        struct User: Decodable, Equatable {
            let firstName: String
            let lastName: String
        }
        
        let userData = ["first_name": "Rahul", "last_name": "Gupta"]
        let sut = jwt(withBody: ["user_info": userData])
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let user = try sut["user_info"].decode(User.self, using: decoder)
        XCTAssertEqual(user.firstName, "Rahul")
        XCTAssertEqual(user.lastName, "Gupta")
    }

    func testDecodeClaimThrowsErrorForNilValue() {
        struct SomeType: Decodable {}
        
        let sut = jwt(withBody: ["existing": "value"])
        
        XCTAssertThrowsError(try sut["missing_claim"].decode(SomeType.self)) { error in
            XCTAssertEqual(error as? JWTDecodeError, .claimDecodingFailed("Claim not found or has nil value"))
        }
    }

    func testDecodeClaimThrowsErrorForInvalidType() {
        struct Address: Decodable {
            let street: String
            let city: String
        }
        
        let sut = jwt(withBody: ["invalid": ["wrong": "structure"]])
        
        XCTAssertThrowsError(try sut["invalid"].decode(Address.self))
    }
    
    func testDecodeClaimThrowsErrorForPrimitiveString() {
        struct SomeType: Decodable {
            let value: String
        }
        
        let sut = jwt(withBody: ["primitive": "just a string"])
        
        XCTAssertThrowsError(try sut["primitive"].decode(SomeType.self)) { error in
            XCTAssertEqual(error as? JWTDecodeError, .claimDecodingFailed("Claim value must be an object or array. Use .string, .integer, .boolean, etc. for primitive values"))
        }
    }
    
    func testDecodeClaimThrowsErrorForPrimitiveInteger() {
        struct SomeType: Decodable {
            let value: Int
        }
        
        let sut = jwt(withBody: ["primitive": 42])
        
        XCTAssertThrowsError(try sut["primitive"].decode(SomeType.self)) { error in
            XCTAssertEqual(error as? JWTDecodeError, .claimDecodingFailed("Claim value must be an object or array. Use .string, .integer, .boolean, etc. for primitive values"))
        }
    }
    
    func testDecodeClaimThrowsErrorForPrimitiveBoolean() {
        struct SomeType: Decodable {
            let value: Bool
        }
        
        let sut = jwt(withBody: ["primitive": true])
        
        XCTAssertThrowsError(try sut["primitive"].decode(SomeType.self)) { error in
            XCTAssertEqual(error as? JWTDecodeError, .claimDecodingFailed("Claim value must be an object or array. Use .string, .integer, .boolean, etc. for primitive values"))
        }
    }
    
    func testDecodeClaimThrowsErrorForTypeMismatch() {
        struct User: Decodable {
            let name: String
            let age: Int
        }
        
        // Provide wrong types for the fields
        let sut = jwt(withBody: ["user": ["name": 123, "age": "not a number"]])
        
        XCTAssertThrowsError(try sut["user"].decode(User.self))
    }
    
    func testDecodeClaimThrowsErrorForMissingRequiredFields() {
        struct User: Decodable {
            let name: String
            let age: Int
            let email: String
        }
        
        // Missing 'email' field
        let sut = jwt(withBody: ["user": ["name": "Sanchit Gupta", "age": 25]])
        
        XCTAssertThrowsError(try sut["user"].decode(User.self))
    }

    func testDecodeNestedComplexClaim() throws {
        struct Profile: Decodable, Equatable {
            let user: UserInfo
        }
        
        struct UserInfo: Decodable, Equatable {
            let name: String
            let location: String
        }
        
        let profileData: [String: Any] = [
            "user": [
                "name": "Rahul Gupta",
                "location": "Indiranagar, Bangalore"
            ]
        ]
        let sut = jwt(withBody: ["profile": profileData])
        
        let profile = try sut["profile"].decode(Profile.self)
        XCTAssertEqual(profile.user.name, "Rahul Gupta")
        XCTAssertEqual(profile.user.location, "Indiranagar, Bangalore")
    }
}

extension JWTDecodeError: @retroactive Equatable {}

public func ==(lhs: JWTDecodeError, rhs: JWTDecodeError) -> Bool {
    return lhs.localizedDescription == rhs.localizedDescription && lhs.errorDescription == rhs.errorDescription
}
