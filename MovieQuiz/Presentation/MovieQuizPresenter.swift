//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Наринэ  Овсепян on 19.01.2026.
//
import UIKit
import Foundation

final class MovieQuizPresenter {
    
    
    private var questionFactory: QuestionFactoryProtocol?
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    let questionsAmount: Int = 10
    var currentQuestionIndex: Int = 0
    
    var correctAnswers: Int = 0
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(image: UIImage(data: model.image) ?? UIImage(),
                                 question: model.text,
                                 questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    } // Преобразование данных. Происходит преобразование из QuizQuestion в QuizStepViewModel, картинка загружается по имени. + Происходит форматирование номера вопроса
    
    func ButtonNo() {
        didAnswer(isYes: false)
    }
    func ButtonYes() {
        didAnswer(isYes: true)
    }
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = isYes
        
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async{ [weak self] in
            self?.viewController?.showQuestion(step: viewModel) // в учебнике self?.viewController?.showQuestion(step: viewModel)
        }
    }
    
    private func showNextQuestionOrResult() {  // Определяет, показывать следующий вопрос или результаты
        
        if self.isLastQuestion() {
            // идем в состоние "Результат квиза"
            let text = correctAnswers == self.questionsAmount ?
            "Поздравляем, вы ответили на 10 из 10!" :
            "Вы ответили на \(correctAnswers) из 10, попробуйте ещё раз!"
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            viewController?.show(result: viewModel)
        } else {
            self.switchToNextQuestion()
            // идем в состонияе "Вопрос показан"
            questionFactory?.requestNextQuestion() // в учебнике self.questionFactory?.requestNextQuestion()
        }
    }
}
