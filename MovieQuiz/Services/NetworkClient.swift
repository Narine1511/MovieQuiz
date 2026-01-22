//
//  NetworkClient.swift
//  MovieQuiz
//
//  Created by Наринэ  Овсепян on 07.01.2026.
//
import Foundation

struct NetworkClient {
    
    private enum NetworkError: Error {
        case codeError
    }
    
    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void) {
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                handler(.failure(error))
                print("error")
                return
            }
            if let response = response as? HTTPURLResponse,
               response.statusCode < 200 || response.statusCode >= 300 {
                handler(.failure(NetworkError.codeError))
                print("data.count")
                return
            }
            guard let data = data else { return }
            handler(.success(data))
        }
        task.resume()
    }
}
