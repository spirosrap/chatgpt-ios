//
//  ViewController.swift
//  chatgpt-ios
//
//  Created by Spiros Raptis on 3/5/23.
//

import UIKit
import OpenAISwift
import ChatGPTSwift
import CoreData

class ViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var input: UITextView!
    @IBOutlet weak var output: UITextView!
    
    var currentAnswer = ""
    var currentQuestion = ""
    
    var openAI:OpenAISwift!
    var api:ChatGPTAPI!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        input.delegate = self
        output.delegate = self
        
        if let apiKey = getAPIKey(from: "API_Key") {
            print("API Key: \(apiKey)")
            
            openAI = OpenAISwift(authToken: apiKey)
            api = ChatGPTAPI(apiKey: apiKey, model: "gpt-4")

        } else {
            print("Error retrieving API Key")
        }

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
        
//        openAI.sendCompletion(with: input.text, model: .gpt3(.davinci), maxTokens: 100, temperature: 0.5) { result in // Result<OpenAI, OpenAIError>
//            switch result {
//            case .success(let success):
//                DispatchQueue.main.async {
//                    self.output.text = success.choices.first?.text ?? ""
//                    print(success.choices.first?.text ?? "")
//                }
//            case .failure(let failure):
//                DispatchQueue.main.async {
//                    print(failure.localizedDescription)
//                }
//            }
//        }
        
        Task {
            do {
                
                let stream = try await api.sendMessageStream(text: input.text)
                var s = ""
                input.resignFirstResponder()

                for try await line in stream {
                    s += line
                    output.text = s
                }
                currentAnswer = s
                currentQuestion = input.text
                input.text = ""
                
            } catch {
                print(error.localizedDescription)
            }
        }

        
    }
    
    @IBAction func saveAnswer(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext

        
        let answerEntity = NSEntityDescription.entity(forEntityName: "Answer", in: context)!
        let newAnswer = Answer(entity: answerEntity, insertInto: context)

        newAnswer.answer = currentAnswer
        newAnswer.question = currentQuestion

        do {
            try context.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }

    }
}
