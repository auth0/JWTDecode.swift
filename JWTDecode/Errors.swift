import Foundation

/**
A JWT decoding error.

- invalidBase64UrlValue: when either the header or body parts cannot be base64-decoded.
- invalidJSONValue:      when either the decoded header or body is not a valid JSON object.
- invalidPartCount:      when the JWT doesn't have the required amount of parts (header, body, and signature).
*/
public enum DecodeError: LocalizedError {
    case invalidBase64Url(String)
    case invalidJSON(String)
    case invalidPartCount(String, Int)

    public var localizedDescription: String {
        switch self {
        case .invalidJSON(let value):
            return NSLocalizedString("Malformed jwt token, failed to parse JSON value from base64Url \(value)", comment: "Invalid JSON value inside base64Url")
        case .invalidPartCount(let jwt, let parts):
            return NSLocalizedString("Malformed jwt token \(jwt) has \(parts) parts when it should have 3 parts", comment: "Invalid amount of jwt parts")
        case .invalidBase64Url(let value):
            return NSLocalizedString("Malformed jwt token, failed to decode base64Url value \(value)", comment: "Invalid JWT token base64Url value")
        }
    }
}
