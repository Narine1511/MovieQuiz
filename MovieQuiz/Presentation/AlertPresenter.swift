//
//  Alert.swift
//  MovieQuiz
//
//  Created by Наринэ  Овсепян on 31.12.2025.
//
import UIKit
class AlertPresenter {
    private let statisticService: StatisticServiceProtocol
    
    init(statisticService: StatisticServiceProtocol) {
        self.statisticService = statisticService
    }
    // принимает модель алерта и контроллер для отоббражения
    func show(alert : AlertModel, on controller: UIViewController) {
        // создаём UIAlertController (только заголовок и сообщение)
        let alertController = UIAlertController(
            title: alert.title,
            message: alert.message,
            preferredStyle: .alert)
        
        // создаём UIAlertAction (кнопка с текстом и действием)
        let action = UIAlertAction(
            title: alert.buttonText,
            style: .default) { _ in // замыкание выполняется при нажатии
                alert.completion() // вызываем completion из AlertModel
            }
        alertController.addAction(action) // добавляем кнопку в алерт
        controller.present(alertController, animated: true, completion: nil) //показываем алерт на переданном контроллере
    }
}

