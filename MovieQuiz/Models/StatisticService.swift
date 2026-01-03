//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Наринэ  Овсепян on 02.01.2026.
//
import Foundation

final class StatisticService: StatisticServiceProtocol {
    
    private let storage: UserDefaults = .standard
    private enum Keys: String {
        case gamesCount
        case bestGameCorrect
        case bestGameTotal
        case bestGameDate
        case totalCorrectAnswers
        case totalQuestionsAsked
    }
    
    var gamesCount: Int {
        get {
            
            // Чтение значения из UserDefaults
            return storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            // Запись нового значения в UserDefaults
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameResult {
        get {
            // Чтение количества правильных ответов из UserDefaults
            let correct = storage.integer(forKey: Keys.bestGameCorrect.rawValue)
            
            // Читаем общее количество вопросов
            let total = storage.integer(forKey: Keys.bestGameTotal.rawValue)
            
            // Читаем дату с безопасным приведением типа
            let date: Date
            if let saveDate = storage.object(forKey: Keys.bestGameDate.rawValue) as? Date {
                date = saveDate
            } else {
                date = Date()
            }
            
            // Создаём и возвращаем структуру
            return GameResult(correct: correct, total: total, date: date)
        }
        set {
            // Сохраняем количество правильных ответов
            storage.set(newValue.correct, forKey: Keys.bestGameCorrect.rawValue)
            
            // Сохраняем общее количество вопросов
            storage.set(newValue.total, forKey: Keys.bestGameTotal.rawValue)
            
            // Сохраняем дату
            storage.set(newValue.date, forKey: Keys.bestGameDate.rawValue)
        }
    }
    
    
    private var totalCorrectAnswers: Int {
        get { return
            storage.integer(forKey: Keys.totalCorrectAnswers.rawValue)}
        set { storage.set(newValue, forKey: Keys.totalCorrectAnswers.rawValue)}
    }
    
    private var totalCorrectAsked: Int {
        get { return
            storage.integer(forKey: Keys.totalQuestionsAsked.rawValue)}
        set { storage.set(newValue, forKey: Keys.totalQuestionsAsked.rawValue)}
    }
    
    var totalAccuracy: Double {
        get {
            // Преобразуем Int в Double перед делением
        let correct = Double(totalCorrectAnswers)
        let total = Double(totalCorrectAsked)
            
            guard total > 0 else {
                return 0.0
            }
            return (correct/total)*100
        }
    }
        func store(correct count: Int, total amount: Int) {
            gamesCount += 1
            
            totalCorrectAnswers += count
            totalCorrectAsked += amount
            
            let currentGame = GameResult(correct: count, total: amount, date: Date())
            
            
            // Если текущая игра лучше сохранённой лучшей игры
            if currentGame.isBetterThan(bestGame) {
                    bestGame = currentGame
                }
            
            
        }
    }
