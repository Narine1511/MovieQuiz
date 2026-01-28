//
//  MovieQuizTests.swift
//  MovieQuizTests
//
//  Created by Наринэ  Овсепян on 26.01.2026.
//

import XCTest
@testable import MovieQuiz

final class MovieQuizViewControllerMock: MovieQuizViewProtocol {
    var lastStepModel: QuizStepViewModel?
    func showQuestion (step: QuizStepViewModel) {
        lastStepModel = step
    }
    func show (result: QuizResultsViewModel) {
        
    }
    func showLoadingIndicator() {
        
    }
    func hideLoadingIndicator() {
        
    }
    func showNetworkError(message: String) {
        
    }
    func highlightImageBorder(isCorrect: Bool) {
        
    }
    func enableButtons(enable: Bool) {
        
    }
}

final class MovieQuizPresenterTests: XCTestCase {
    func testPresenterControllerModel() throws {
        let viewControllerMock = MovieQuizViewControllerMock()
        let sut = MovieQuizPresenter(viewController: viewControllerMock)
        
        let emptyData = Data()
        let question = QuizQuestion(image: emptyData, text: "Question Text", correctAnswer: true)
        
        print("проверяем конверт")
        let viewModel = sut.convert(model: question)
        
        let viewModell = sut.convert(model: question)
        XCTAssertEqual(viewModell.question, "Question Text")
        XCTAssertEqual(viewModell.questionNumber, "1/10")
        
        sut.currentQuestion = question
        sut.didReceiveNextQuestion(question: question)
        
        guard let lastStepModel = viewControllerMock.lastStepModel else {return}
        XCTAssertEqual(viewModel.question, "Question Text")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
}
