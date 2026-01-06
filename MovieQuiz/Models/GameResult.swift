//
//  Quiz.swift
//  MovieQuiz
//
//  Created by Наринэ  Овсепян on 02.01.2026.
//

import Foundation

struct GameResult {
    var correct: Int // количество правильных ответов
    let total: Int // количество вопросов квиза
    let date: Date // дата завершения раунда
    
    func isBetterThan(_ another: GameResult) -> Bool {
        correct > another.correct
    }
}

