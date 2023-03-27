//
//  AskViewController.swift
//  chatgpt-ios
//
//  Created by Spiros Raptis on 3/5/23.
//

import UIKit
import OpenAISwift
import ChatGPTSwift
import CoreData

class AskViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var input: UITextView!
    @IBOutlet weak var output: UITextView!
    
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var currentAnswer = ""
    var currentQuestion = ""
    
    var openAI:OpenAISwift!
    var api:ChatGPTAPI!
    var isDataSaved = false
    var modelName = "gpt-4"
    
    var modelChangedHandler: ((String) -> Void)?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        input.delegate = self
        output.delegate = self
        
        submitButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        submitButton.setTitleColor(.red, for: .normal)
        submitButton.layer.borderWidth = 5
        submitButton.layer.borderColor = UIColor.red.cgColor
        
        input.font = UIFont.systemFont(ofSize: 18)
        output.font = UIFont.systemFont(ofSize: 18)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)

    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let fetchRequest: NSFetchRequest<CurrentModel> = CurrentModel.fetchRequest()
        do {
            let model = try context.fetch(fetchRequest)
            if model.count == 0{
                let currentModel = NSEntityDescription.entity(forEntityName: "CurrentModel", in: context)!
                let c = CurrentModel(entity: currentModel, insertInto: context)
                c.model = "gpt-4"
                self.modelName = "gpt-4"
                do {
                    try context.save()
                } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                }
            } else {
                print(model[0].model!)
                self.modelName = model[0].model!

            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }

            
        if let apiKey = getAPIKey(from: "API_Key") {
            openAI = OpenAISwift(authToken: apiKey)
            api = ChatGPTAPI(apiKey: apiKey)
            
        }
            
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = ""
    }
    


    

    func getAPIKey(from fileName: String) -> String? {
        // Get the file URL
        guard let fileURL = Bundle.main.url(forResource: fileName, withExtension: "txt") else {
            print("File not found: \(fileName).txt")
            return nil
        }

        do {
            // Read the file content
            let content = try String(contentsOf: fileURL, encoding: .utf8)
            // Remove any extra white space or new lines
            let apiKey = content.trimmingCharacters(in: .whitespacesAndNewlines)
            return apiKey
        } catch {
            print("Error reading file: \(error.localizedDescription)")
            return nil
        }
    }


    @IBAction func generate(_ sender: Any) {
        
        Task {
            do {
                activityIndicator.startAnimating()
                let stream = try await api.sendMessageStream(text: input.text, model: self.modelName)
                var s = ""
                activityIndicator.stopAnimating()
                input.resignFirstResponder()
                isDataSaved = false
                for try await line in stream {
                    s += line
                    output.text = s
                }
                currentAnswer = s
                currentQuestion = input.text
            } catch {
                print(error.localizedDescription)
                activityIndicator.stopAnimating()
                showAlert(title: "ERROR", message: error.localizedDescription)
            }
        }

        
    }
    
    @IBAction func reset(_ sender: Any) {
        input.text = "INPUT:"
        output.text = "ANSWER:"
        api.deleteHistoryList()
    }
    
    @IBAction func saveAnswer(_ sender: Any) {
        
        if isDataSaved {
            showAlert(title: "!!", message: "The answer has already been saved")
            return
        }

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext

        
        let answerEntity = NSEntityDescription.entity(forEntityName: "Answer", in: context)!
        let newAnswer = Answer(entity: answerEntity, insertInto: context)

        newAnswer.answer = currentAnswer
        newAnswer.question = currentQuestion

        do {
            
            try context.save()
            showAlert(title: "Success", message: "Answer saved")
            isDataSaved = true
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }

    }
}

