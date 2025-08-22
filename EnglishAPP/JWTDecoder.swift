import Foundation

struct JWTClaims: Codable {
    let claims: Claims
    let exp: Int
    
    struct Claims: Codable {
        let is_first: String
        let id: Int
        let email: String
        let username: String
    }
}

class JWTDecoder {
    static func decode(jwt: String) -> JWTClaims? {
        let parts = jwt.components(separatedBy: ".")
        guard parts.count == 3 else { return nil }
        
        // 解码payload部分（第二部分）
        let payload = parts[1]
        
        // 添加padding
        let paddedPayload = payload.padding(toLength: ((payload.count + 3) / 4) * 4, withPad: "=", startingAt: 0)
        
        guard let data = Data(base64Encoded: paddedPayload, options: .ignoreUnknownCharacters) else {
            return nil
        }
        
        do {
            let claims = try JSONDecoder().decode(JWTClaims.self, from: data)
            return claims
        } catch {
            print("JWT解码失败: \(error)")
            return nil
        }
    }
    
    static func isFirstLogin(jwt: String) -> Bool {
        guard let claims = decode(jwt: jwt) else { return true }
        return claims.claims.is_first == "114514"
    }
}

