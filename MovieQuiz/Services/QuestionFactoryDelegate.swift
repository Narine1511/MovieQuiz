//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Наринэ  Овсепян on 28.12.2025.
//
protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
}
