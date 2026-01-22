//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Наринэ  Овсепян on 19.01.2026.

//
import UIKit
import Foundation

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    let statisticService: StatisticServiceProtocol!
    private var questionFactory: QuestionFactoryProtocol?
    weak var viewController: MovieQuizViewController?
    var currentQuestion: QuizQuestion?
    let questionsAmount: Int = 10
    var currentQuestionIndex: Int = 0
    var correctAnswers: Int = 0
    
    init(viewController: MovieQuizViewController) {
        print("инициализируем")
        self.viewController = viewController
        statisticService = StatisticService()
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: any Error) {
        let message = error.localizedDescription
        viewController?.showNetworkError(message: message)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        /*print("Данные изображения")*/
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async{ [weak self] in
            self?.viewController?.showQuestion(step: viewModel) // в учебнике self?.viewController?.showQuestion(step: viewModel)
        }
    }
    
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
       print("Данные изображения \(model.image.count)")
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
    
    func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = isYes
        
        proceedWithAnswer(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    func proceedToQuestionOrResult() {  // Определяет, показывать следующий вопрос или результаты
        
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
    
    func proceedWithAnswer(isCorrect: Bool) { // Показываем результат ответа (правильно/неправильно)
        /*buttonsEnable(enabled: false)*/
        didAnswer(isYes: true)
       /* viewController?.highlightImageBorder(isYes: true)*/
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {[weak self] in
            guard let self = self else { return }
            // код, который мы хотим вызвать через 1 секунду
            self.proceedToNextQuestionOrResilts()
        }
    }
    
    func proceedToNextQuestionOrResilts() {
        if self.isLastQuestion() {
            let text = correctAnswers == self.questionsAmount ?
            "Поздравляем, вы ответили на 10 из 10!" : "Вы ответили на \(correctAnswers) из 10, попробуйте ещё раз!"
            
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            viewController?.show(result: viewModel)
        } else {
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    
    /*func enableButtons(enable: Bool) {
        yesButton.isEnabled = enabled
        noButton.isEnabled = enabled
    }*/
    
    func makeResultsMessage() -> String {
        statisticService.store(correct: correctAnswers, total: questionsAmount)
        
        let bestGame = statisticService.bestGame
        
        let totalPlaysCountLine = "Количество сыгранных квизов: \(statisticService.gamesCount)"
        let currentGameResultLine = "Ваш результат: \(correctAnswers)\\\(questionsAmount)"
        let bestGameInfoLine = "Рекорд: \(bestGame.correct)\\\(bestGame.total)" /*+ " (\(bestGame.date.dateTtimeString))"*/
        let averageAccuracyLine = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
        
        let resultMessage = [
            currentGameResultLine, totalPlaysCountLine, bestGameInfoLine, averageAccuracyLine].joined(separator: "\n")
        return resultMessage
    }
    
}
