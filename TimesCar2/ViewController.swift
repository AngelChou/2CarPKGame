//
//  ViewController.swift
//  TimesCar2
//
//  Created by SHIH-YING PAN on 2018/10/19.
//  Copyright © 2018 SHIH-YING PAN. All rights reserved.
//

import UIKit



class ViewController: UIViewController {

    @IBOutlet var carImageViews: [UIImageView]!
    @IBOutlet var questionViews: [UIView]!
    @IBOutlet var questionLabels: [UILabel]!
    @IBOutlet var bottomChoiceButtons: [UIButton]!
    @IBOutlet var topChoiceButtons: [UIButton]!
    @IBOutlet weak var winButton: UIButton!
    @IBOutlet weak var finalLineImageView: UIImageView!
    
    // 上層玩家的array index
    let top = 1
    
    // 題庫
    var questions = [Question]()
    
    // 選項的答案
    let choiceNumbers = [Int](1...99)
    
    // 記錄目前玩家玩到第幾題
    var questionIndexes = [Int](repeating: 0, count: 2)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        // 將上層玩家的題組旋轉180度顯示
        questionViews[top].transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        
        initGame()
    }
    
    func initGame() {
        // 清除題庫
        questions.removeAll()
        // 產生第一題
        let question = createQuestion()
        for i in 0...1 {
            // 將玩家遊戲進度歸零
            questionIndexes[i] = 0
            // 顯示第一題
            showQuestion(location: i, question: question)
            // 將玩家汽車移回起始位置
            carImageViews[i].frame.origin.x = 91
        }
    }

    func createQuestion() -> Question {
        let numberRange = 1...9
        let number1 = Int.random(in: numberRange)
        let number2 = Int.random(in: numberRange)
        let choiceRange = 0...3
        let answerIndex = Int.random(in: choiceRange)
        let answer = number1 * number2
        
        // 過濾掉choiceNumbers陣列中和answer一樣的項目, 並將過濾後的結果存到新陣列
        var choices = choiceNumbers.filter { (number) -> Bool in
            return answer != number
        }
        
        //將不含解答的陣列重新洗牌
        choices.shuffle()
        
        // 把答案放進選定的位置
        choices[answerIndex] = answer
        
        // 取出choices陣列中chocieRange這個區間的值，由於取出的型別是ArraySlice所以要再轉型回Array
        let question = Question(title: (number1, number2), choices: Array(choices[choiceRange]))
        
        // 將新產生的題目加入題庫中
        questions.append(question)
        return question
    }
    
    func showQuestion(location: Int, question: Question) {
        questionLabels[location].text = "\(question.title.0) x \(question.title.1)"
        if location == top {
            for (i, button) in topChoiceButtons.enumerated() {
               button.setTitle(question.choices[i].description, for: .normal)
            }
        } else {
            for (i, button) in bottomChoiceButtons.enumerated() {
                button.setTitle(question.choices[i].description, for: .normal)
            }
        }
        
    }
    
    @IBAction func winButtonPressed(_ sender: Any) {
        winButton.isHidden = true
        initGame()
    }
    
    @IBAction func choiceButtonPressed(_ sender: UIButton) {
        let questionViewTag = sender.superview!.tag // 取得目前按下選項的是哪個玩家
        var questionIndex = questionIndexes[questionViewTag] // 取得此玩家目前玩到第幾題
        let question = questions[questionIndex] //取得此題的題目
        let answer = question.title.0 * question.title.1 //取得此題的答案
        let choice = question.choices[sender.tag]   //取得目前按下的這個選項的值
        if choice == answer {
            UIView.animate(withDuration: 0.5) {
                self.carImageViews[questionViewTag].center.x += 50
            }
        }
        
        // 檢查車子是否到達終點
        if carImageViews[questionViewTag].frame.maxX >= finalLineImageView.frame.minX {
            var msg = ""
            if questionViewTag == 0 {
//                winButton.setTitle("維尼獲勝！", for: .normal)
                msg = "維尼獲勝！"
            } else {
//                winButton.setTitle("唐老鴨獲勝！", for: .normal)
                msg = "唐老鴨獲勝！"
            }
            // 顯示哪位玩家獲勝
//            winButton.isHidden = false
            let alertController = UIAlertController(title: msg, message: "", preferredStyle: .alert)
            let okAction = UIAlertAction(
                title: "再玩一次",
                style: .default,
                handler: {
                    (action: UIAlertAction!) -> Void in
                    self.initGame()
            })
            alertController.addAction(okAction)

            // 顯示提示框
            self.present(
                alertController,
                animated: true,
                completion: nil)
        }
        
        questionIndex += 1 //進入下一題
        questionIndexes[questionViewTag] = questionIndex // 更新玩家目前玩到第幾題
        // 假設題目還沒產生
        if questionIndex >= questions.count {
            _ = createQuestion()
        }
        showQuestion(location: questionViewTag, question: questions[questionIndex])
    }
    
}

