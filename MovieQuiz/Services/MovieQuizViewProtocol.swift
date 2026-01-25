//
//  MovieQuizViewProtocol.swift
//  MovieQuiz
//
//  Created by Наринэ  Овсепян on 25.01.2026.
//
protocol MovieQuizViewProtocol: AnyObject {
    func showQuestion (step: QuizStepViewModel)
    func show (result: QuizResultsViewModel)
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func showNetworkError(message: String)
    func highlightImageBorder(isCorrect: Bool)
}
