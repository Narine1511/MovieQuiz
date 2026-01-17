//
//  MoviesLoader.swift
//  MovieQuiz
//
//  Created by Наринэ  Овсепян on 07.01.2026.
//
import Foundation
protocol MoviesLoading {
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
}

struct MoviesLoader: MoviesLoading {
    private let networkClient = NetworkClient()
    private var mostPopularMoviesUrl: URL {
        guard let url = URL(string: "https://tv-api.com/en/API/Top250Movies/k_zcuw1ytf") else {
            preconditionFailure("Unable to construct mostPopularMoviesUrl")
        }
        return url
    }
    
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void) {
        networkClient.fetch(url: mostPopularMoviesUrl) {result in
            switch result {
            case .success(let data):
                print("Данные пришли")
                if let jsonString = String(data: data, encoding: .utf8) {
                    print(jsonString.prefix(1000))
                }
                do {
                    let mostPopularMovies = try JSONDecoder().decode(MostPopularMovies.self, from: data)
                    handler(.success(mostPopularMovies))
                } catch {
                    handler(.failure(error))
                }
            case .failure(let error):
                print("сетевая ошибка при запросе")
                handler(.failure(error))
            }
        }
    }
}
