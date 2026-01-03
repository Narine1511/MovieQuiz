//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Наринэ  Овсепян on 16.12.2025.
//

import Foundation


class QuestionFactory: QuestionFactoryProtocol {
    private weak var delegate: QuestionFactoryDelegate?
    
    func setup(delegate: QuestionFactoryDelegate) {
        self.delegate = delegate
    }
    
    private let questions: [QuizQuestion] = [
        QuizQuestion(image: "The Godfather", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "The Dark Knight", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "Kill Bill", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "The Avengers", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "Deadpool", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "The Green Knight", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "Old", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
        QuizQuestion(image: "The Ice Age Adventures of Buck Wild", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
        QuizQuestion(image: "Tesla", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
        QuizQuestion(image: "Vivarium", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false)
    ]
    
    // Добавляем индекс текущего вопроса
    private var currentQuestionIndex: Int = 0
    
    func requestNextQuestion() {
        
        // Берём вопрос по текущему индексу
        let question = questions[currentQuestionIndex]
        
        // Увеличиваем индекс для следующего вопроса
        currentQuestionIndex += 1
        
        // Если дошли до конца, то начинаем заново
        if currentQuestionIndex >= questions.count {
            currentQuestionIndex = 0
        }
        
        delegate?.didReceiveNextQuestion(question: question)
    }
}

/* subscript(index: Int) -> Int {
    get {
        //возвращаем соответствующее значение
    }
    set(newValue) {
        // устанавливаем подходящее значение
        }
    }
*/

