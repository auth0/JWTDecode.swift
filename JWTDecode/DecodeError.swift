import Foundation

/**
 A decoding error due to a malformed JWT.

 - invalidBase64Url:  when either the header or body parts cannot be Base64URL-decoded.
 - invalidJSONValue:   when either the decoded header or body is not a valid JSON object.
 - invalidPartCount:     when the JWT doesn't have the required amount of parts (header, body, and signature).
 */
public enum DecodeError: LocalizedError, CustomDebugStringConvertible {
    case invalidBase64Url(String)
    case invalidJSON(String)
    case invalidPartCount(String, Int)

    /**
     Description of the error.

     - Important: You should avoid displaying the error description to the user, it's meant for **debugging** only.
     */
    public var localizedDescription: String { return self.debugDescription }

    /**
     Description of the error.

     - Important: You should avoid displaying the error description to the user, it's meant for **debugging** only.
     */
    public var errorDescription: String? { return self.debugDescription }

    /**
     Description of the error.

     - Important: You should avoid displaying the error description to the user, it's meant for **debugging** only.
     */
    public var debugDescription: String {
        switch self {
        case .invalidJSON(let value):
            return "Failed to parse JSON from Base64URL value \(value)."
        case .invalidPartCount(let jwt, let parts):
            return "The JWT \(jwt) has \(parts) parts when it should have 3 parts."
        case .invalidBase64Url(let value):
            return "Failed to decode Base64URL value \(value)."
        }
    }
}
