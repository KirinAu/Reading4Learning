import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case server(String)
    case decoding

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "无效的请求地址"
        case .server(let msg): return msg
        case .decoding: return "数据解析失败"
        }
    }

    var message: String { errorDescription ?? "发生错误" }
}

final class APIService {
    static let shared = APIService()
    private init() {}

    // 基础域名留空，改为通过相对路径拼接，外部可注入/替换
    // 例如在 App 启动或设置页把 baseURL 设置为 "https://api.yourdomain.com"
    var baseURL: URL? = nil
    private let urlSession = URLSession(configuration: .default)

    func setBaseURL(_ urlString: String) {
        baseURL = URL(string: urlString)
    }

    private func buildURL(path: String) throws -> URL {
        guard let baseURL else { throw APIError.invalidURL }
        guard let url = URL(string: path, relativeTo: baseURL) else { throw APIError.invalidURL }
        return url
    }

    // MARK: - Public endpoints (relative paths)

    struct APIResponse<T: Decodable>: Decodable {
        let code: Int
        let message: String
        let data: T?
        let success: Bool
    }

    func login(email: String, password: String, verificationCode: String) async throws -> String {
        let response: APIResponse<String> = try await request(path: "/api/DoubleAuth/login", body: [
            "email": email,
            "password": password,
            "verificationCode": verificationCode
        ])
        return response.data ?? ""
    }

    func register(username: String, email: String, password: String, verificationCode: String) async throws -> String {
        let response: APIResponse<String> = try await request(path: "/api/DoubleAuth/register", body: [
            "username": username,
            "email": email,
            "password": password,
            "verificationCode": verificationCode
        ])
        return response.data ?? ""
    }
    
    func sendVerificationCode(email: String, operation: String) async throws {
        try await request(path: "/api/DoubleAuth/send-verification", body: [
            "email": email,
            "operation": operation
        ])
    }
    
    func resetPassword(email: String, password: String, confirmPassword: String, verificationCode: String) async throws -> String {
        let response: APIResponse<String> = try await request(path: "/api/DoubleAuth/reset-password", body: [
            "email": email,
            "password": password,
            "confirmPassword": confirmPassword,
            "verificationCode": verificationCode
        ])
        return response.data ?? ""
    }

    // MARK: - Core request

    private func request<T: Decodable>(path: String, body: [String: Any]) async throws -> T {
        let url = try buildURL(path: path)
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])

        let (data, response) = try await urlSession.data(for: req)
        guard let http = response as? HTTPURLResponse else { throw APIError.server("无响应") }
        
        // 打印响应数据用于调试
        if let responseString = String(data: data, encoding: .utf8) {
            print("API Response: \(responseString)")
        }
        
        // 尝试解析API响应
        if let apiResponse = try? JSONDecoder().decode(APIResponse<T>.self, from: data) {
            if apiResponse.success {
                guard let responseData = apiResponse.data else {
                    throw APIError.server("响应数据为空")
                }
                return responseData
            } else {
                throw APIError.server(apiResponse.message)
            }
        }
        
        // 如果解析失败，检查HTTP状态码
        guard (200..<300).contains(http.statusCode) else {
            let message = String(data: data, encoding: .utf8) ?? "服务器错误 \(http.statusCode)"
            throw APIError.server(message)
        }
        
        // 尝试直接解析数据
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            print("Decoding error: \(error)")
            throw APIError.decoding
        }
    }
    
    private func request(path: String, body: [String: Any]) async throws {
        let url = try buildURL(path: path)
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])

        let (data, response) = try await urlSession.data(for: req)
        guard let http = response as? HTTPURLResponse else { throw APIError.server("无响应") }
        
        // 打印响应数据用于调试
        if let responseString = String(data: data, encoding: .utf8) {
            print("API Response: \(responseString)")
        }
        
        // 尝试解析API响应
        if let apiResponse = try? JSONDecoder().decode(APIResponse<String>.self, from: data) {
            if !apiResponse.success {
                throw APIError.server(apiResponse.message)
            }
        }
        
        guard (200..<300).contains(http.statusCode) else {
            let message = String(data: data, encoding: .utf8) ?? "服务器错误 \(http.statusCode)"
            throw APIError.server(message)
        }
    }
}


