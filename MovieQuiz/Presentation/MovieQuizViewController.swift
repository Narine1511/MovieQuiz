import UIKit
import Foundation

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    // MARK: - Lifecycle
    
    @IBAction private func ButtonNo(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    @IBAction private func ButtonYes(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = true
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var statisticService: StatisticServiceProtocol!
    private lazy var alertPresenter = AlertPresenter(statisticService: statisticService)
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    
    private func buttonsEnable(enabled: Bool) {
        yesButton.isEnabled = enabled
        noButton.isEnabled = enabled
    }
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false // индикатор не скрыт
        activityIndicator.startAnimating() // включаем анимацию
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true // индикатор скрыт
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let alertModel = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать ещё раз",
            completion:{ [weak self]
                in
                // весь код сброса игры
                guard let self = self else {return}
                self.currentQuestionIndex = 0
                self.correctAnswers = 0
                self.imageView.layer.borderWidth = 0
                
                //пересоздание фабрики
                let newFactoy = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
                newFactoy.setup(delegate: self)
                self.questionFactory = newFactoy
            }
        )
        alertPresenter.show(alert: alertModel, on: self)
    }
    
    func didFailToLoadData(with error: Error) {
        hideLoadingIndicator()
        let message = (error as NSError).localizedDescription
        showNetworkError(message: message)
    }
    
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true
        questionFactory?.requestNextQuestion()
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        imageView.layer.cornerRadius = 20
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        statisticService = StatisticService() // Инициализация сервиса по статистике
        alertPresenter = AlertPresenter(statisticService: statisticService)  // Создаём AlertPresenter, передавая ему statisticService
        showLoadingIndicator()
        questionFactory?.loadData()
        /*questionFactory.requestNextQuestion()*/
    }
    
    // MARK: QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async{ [weak self] in
            self?.showQuestion(viewModel)
        }
    }

    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(image: UIImage(data: model.image) ?? UIImage(),
                                 question: model.text,
                                 questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    } // Преобразование данных. Происходит преобразование из QuizQuestion в QuizStepViewModel, картинка загружается по имени. + Происходит форматирование номера вопроса
    
    private func showQuestion(_ step: QuizStepViewModel) {
        imageView.layer.borderWidth = 0 // сбрасываем цвет рамки перед показом нового вопроса
        imageView.image = step.image
        imageView.layer.cornerRadius = 20
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        
        buttonsEnable(enabled: true)
    } // отображает данные из вью модели на экране
    
    private func showAnswerResult(isCorrect: Bool) { // Показываем результат ответа (правильно/неправильно)
        buttonsEnable(enabled: false)
        
        if isCorrect == true {
            imageView.layer.masksToBounds = true
            imageView.layer.borderWidth = 8
            imageView.layer.borderColor = UIColor.ypGreen.cgColor
            imageView.layer.cornerRadius = 20
            correctAnswers += 1
        } else {
            imageView.layer.masksToBounds = true
            imageView.layer.borderWidth = 8
            imageView.layer.borderColor = UIColor.ypRed.cgColor
            imageView.layer.cornerRadius = 20
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {[weak self] in
            guard let self = self else { return }
            // код, который мы хотим вызвать через 1 секунду
            showNextQuestionOrResult()
        }
    }
    
    private func showNextQuestionOrResult() {  // Определяет, показывать следующий вопрос или результаты
        
        if currentQuestionIndex == questionsAmount-1 {
            // идем в состоние "Результат квиза"
            let text = correctAnswers == questionsAmount ?
            "Поздравляем, вы ответили на 10 из 10!" :
            "Вы ответили на \(correctAnswers) из 10, попробуйте ещё раз!"
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            show(quiz: viewModel)
        } else {
            currentQuestionIndex += 1
            // идем в состонияе "Вопрос показан"
            self.questionFactory?.requestNextQuestion()
        }
    }
    
    private func show(quiz result: QuizResultsViewModel) {
        // Сохранение результата текущей игры
        statisticService.store(correct: correctAnswers, total: 10)
        
        // Получание статистики для отображения
        let bestGame = statisticService.bestGame
        
        // Формируем дату
        let dateString = bestGame.date.dateTimeString
        
        /*let message = presenter.makeResultsMessage()*/
        // Создание текста со статистикой
        let statisticMessage = "Ваш результат: \(correctAnswers)/10\nКоличество сыгранных квизов: \(statisticService.gamesCount)\nРекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(dateString))\nСредняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
        
        // создаем модель для алерта
        let alertModel = AlertModel(
            title: result.title,
            message: statisticMessage,
            buttonText: result.buttonText,
            completion:{ [weak self]
                in
                // весь код сброса игры
                guard let self = self else {return}
                self.currentQuestionIndex = 0
                self.correctAnswers = 0
                self.imageView.layer.borderWidth = 0
                
                //пересоздание фабрики
                let newFactoy = QuestionFactory (moviesLoader: MoviesLoader(), delegate: self)
                newFactoy.setup(delegate: self)
                self.questionFactory = newFactoy
                /* self.showNextQuestionOrResult()*/
                newFactoy.loadData()
                
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
