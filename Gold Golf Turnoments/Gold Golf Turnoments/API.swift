//
//  API.swift
//  Gold Golf Turnoments
//
//  Created by Mark Jensen on 4/1/26.
//

import Foundation

class APIService {
    static let shared = APIService()
    
    private let baseURL = "http://localhost:8080" // change if deployed

    // MARK: - REGISTER
    func register(user: RegisterRequest, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)/register") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        request.httpBody = try? JSONEncoder().encode(user)

        URLSession.shared.dataTask(with: request) { _, response, error in
            completion(error == nil)
        }.resume()
    }

    // MARK: - LOGIN
    func login(username: String, password: String, completion: @escaping (String?) -> Void) {
        guard let url = URL(string: "\(baseURL)/login") else { return }

        let body = LoginRequest(username: username, password: password)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder().encode(body)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data,
                  let response = try? JSONDecoder().decode(TokenResponse.self, from: data) else {
                completion(nil)
                return
            }

            completion(response.token)
        }.resume()
    }

    // MARK: - GET STATS
    func getStats(userID: String, completion: @escaping (Double) -> Void) {
        guard let url = URL(string: "\(baseURL)/stats/\(userID)") else { return }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data,
                  let ratio = try? JSONDecoder().decode(Double.self, from: data) else {
                completion(0)
                return
            }

            completion(ratio)
        }.resume()
    }

    // MARK: - GET FRIENDS
    func getFriends(userID: String, completion: @escaping ([User_DEP]) -> Void) {
        guard let url = URL(string: "\(baseURL)/friends/\(userID)") else { return }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data,
                  let friends = try? JSONDecoder().decode([User_DEP].self, from: data) else {
                completion([])
                return
            }

            completion(friends)
        }.resume()
    }
}
