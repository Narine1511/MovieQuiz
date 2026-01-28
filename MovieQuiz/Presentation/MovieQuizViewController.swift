import UIKit
import Foundation

final class MovieQuizViewController: UIViewController, MovieQuizViewProtocol {
    
    
    // MARK: - Lifecyclef
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    
  /* private let statisticService: StatisticServiceProtocol*/
    /*private weak var viewController: MovieQuizViewController?*/
    
    private var presenter: MovieQuizPresenter!

    private lazy var alertPresenter = AlertPresenter(statisticService: StatisticService())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("работаем?")
        presenter = MovieQuizPresenter(viewController: self)
      /*  presenter.viewController = self */
        
        imageView.layer.cornerRadius = 20
    }
    
    @IBAction private func ButtonNo(_ sender: UIButton) {
        presenter.ButtonNo()
    }
    @IBAction private func ButtonYes(_ sender: UIButton) {
        presenter.ButtonYes()
    }
    
    func showQuestion(step: QuizStepViewModel) {
        imageView.layer.borderWidth = 0 // сбрасываем цвет рамки перед показом нового вопроса
        imageView.image = UIImage(data: step.image) ?? UIImage()
        imageView.layer.cornerRadius = 20
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    func show(result: QuizResultsViewModel) {
        
        let message = presenter.makeResultsMessage()
        
        let alert = UIAlertController (
            title: result.title,
            message: message,
            preferredStyle: .alert)
        
        let action = UIAlertAction (
            title: result.buttonText,
            style: .default) { [weak self] _ in
                // весь код сброса игры
                guard let self = self else {return}
                self.presenter.restartGame()
                self.imageView.layer.borderWidth = 0
            }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    func showLoadingImdicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func highlightImageBorder(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false // индикатор не скрыт
        activityIndicator.startAnimating() // включаем анимацию
    }
    
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true // индикатор скрыт
    }
    
    func enableButtons(enable: Bool) {
        yesButton.isEnabled = enable
        noButton.isEnabled = enable
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let alertModel = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать ещё раз",
            completion:{ [weak self]
                in
                // весь код сброса игры
                guard let self = self else {return}
                self.imageView.layer.borderWidth = 0
                
                self.presenter.restartGame()
            }
        )
        alertPresenter.show(alert: alertModel, on: self)
    }
}
/*
 UserDefaults.standard.set(true, forKey: "viewDidLoad") 
 Mock-данные
 
 
 Картинка: The Godfather
 Настоящий рейтинг: 9,2
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Dark Knight
 Настоящий рейтинг: 9
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Kill Bill
 Настоящий рейтинг: 8,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Avengers
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Deadpool
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Green Knight
 Настоящий рейтинг: 6,6
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Old
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: The Ice Age Adventures of Buck Wild
 Настоящий рейтинг: 4,3
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: Tesla
 Настоящий рейтинг: 5,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: Vivarium
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
*/
