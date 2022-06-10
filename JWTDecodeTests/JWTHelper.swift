import Foundation
import JWTDecode

func jwt(withBody body: [String: Any]) -> JWT {
    var jwt: String = ""
    do {
        let data = try JSONSerialization.data(withJSONObject: body, options: JSONSerialization.WritingOptions())
        let base64 = data.base64EncodedString(options: NSData.Base64EncodingOptions())
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
        jwt = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.\(base64).SIGNATURE"
    } catch _ {
        NSException(name: NSExceptionName.invalidArgumentException, reason: "Failed to build jwt", userInfo: nil).raise()
    }
    return try! decode(jwt: jwt)
}

func jwtThatExpiresAt(date: Date) -> JWT {
    return jwt(withBody: ["exp": date.timeIntervalSince1970 as AnyObject])
}

func expiredJWT() -> JWT {
    let seconds = Int(arc4random_uniform(60) + 1) * -1
    let date = (Calendar.current as NSCalendar).date(byAdding: .second, value: seconds, to: Date(), options: NSCalendar.Options())
    return jwtThatExpiresAt(date: date!)
}

func nonExpiredJWT() -> JWT {
    let hours = Int(arc4random_uniform(200) + 1)
    let date = (Calendar.current as NSCalendar).date(byAdding: .hour, value: hours, to: Date(), options: NSCalendar.Options())
    return jwtThatExpiresAt(date: date!)
}

func nonExpiredDate() -> Date {
    let hours = Int(arc4random_uniform(200) + 1)
    return (Calendar.current as NSCalendar).date(byAdding: .hour, value: hours, to: Date(), options: NSCalendar.Options())!
}

func expiredDate() -> Date {
    let seconds = Int(arc4random_uniform(60) + 1) * -1
    return (Calendar.current as NSCalendar).date(byAdding: .second, value: seconds, to: Date(), options: NSCalendar.Options())!
}

struct JWTHelper {
    static func newJWT(withBody body: [String: AnyObject]) -> JWT {
        return jwt(withBody: body)
    }

    static func newJWTThatExpiresAt(date: Date) -> JWT {
        return jwtThatExpiresAt(date: date)
    }

    static func newExpiredJWT() -> JWT {
        return expiredJWT()
    }

    static func newNonExpiredJWT() -> JWT {
        return nonExpiredJWT()
    }
    
    static func newJWT(withIssuer issuer: String, audience: String, expiry: Date, nonce: String? = nil) -> JWT {
        var body: [String: AnyObject] = ["iss" : issuer as AnyObject,
                                         "aud" : audience as AnyObject,
                                         "exp" : expiry.timeIntervalSince1970 as AnyObject]
        
        if let nonce = nonce {
            body["nonce"] = nonce as AnyObject
        }
        
        return newJWT(withBody: body)
    }
}
