// 7k4w_design_a_automa.swift

import Foundation

// API Specification for Automated API Service Notifier

struct NotifierAPI {
    let baseURL: String = "https://api.notifier.com/v1"
    let apiKey: String = "YOUR_API_KEY"

    enum Endpoints {
        case services
        case notifications(serviceID: Int)

        var stringValue: String {
            switch self {
            case .services:
                return "/services"
            case .notifications(let serviceID):
                return "/services/\(serviceID)/notifications"
            }
        }
    }

    func makeRequest(_ endpoint: Endpoints, method: String = "GET", headers: [String: String] = [:], parameters: [String: Any] = [:]) -> URLRequest {
        var components = URLComponents(string: baseURL)!
        components.path = endpoint.stringValue

        var request = URLRequest(url: components.url!, timeoutInterval: 30)
        request.httpMethod = method
        request.httpHeaders = headers
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)

        return request
    }

    func fetchServices(completion: @escaping ([Service]?, Error?) -> Void) {
        let request = makeRequest(.services)
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }

            guard let data = data else { return }
            do {
                let services = try JSONDecoder().decode([Service].self, from: data)
                completion(services, nil)
            } catch {
                completion(nil, error)
            }
        }.resume()
    }

    func fetchNotifications(for serviceID: Int, completion: @escaping ([Notification]?, Error?) -> Void) {
        let request = makeRequest(.notifications(serviceID: serviceID))
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }

            guard let data = data else { return }
            do {
                let notifications = try JSONDecoder().decode([Notification].self, from: data)
                completion(notifications, nil)
            } catch {
                completion(nil, error)
            }
        }.resume()
    }
}

struct Service: Codable {
    let id: Int
    let name: String
    let status: String
}

struct Notification: Codable {
    let id: Int
    let serviceID: Int
    let message: String
    let timestamp: Date
}