//
//  SettingsViewController.swift
//  chatgpt-ios
//
//  Created by Spiros Raptis on 3/26/23.
//

import Foundation
import UIKit
import CoreData

class SettingsViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate{
    
    @IBOutlet weak var pickerViewContainer: UIPickerView!
    
    @IBOutlet weak var selectModel: UIPickerView!
    
    @IBOutlet weak var selectPrompt: UIPickerView!
    
    var data = [String]()
    var dataPrompts = [String]()
    var dataShorts = [String]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var currentModel:CurrentModel!
    var currentPrompt:CurrentPrompt!
    
    var prompts = [String]()
    var short = [String]()

    override func viewDidLoad() {
        selectModel.delegate = self
        selectModel.dataSource = self
        selectPrompt.delegate = self
        selectPrompt.dataSource = self
        
        data = ["gpt-4", "gpt-3.5-turbo","gpt-4-0314","gpt-3.5-turbo-0301"]
               
        dataPrompts = []
        dataShorts = []
//        pickerViewContainer.layer.borderColor = UIColor.black.cgColor
//        pickerViewContainer.layer.borderWidth = 2.0
//        pickerViewContainer.layer.cornerRadius = 10.0
        
        
//        guard let path = Bundle.main.path(forResource: "prompts", ofType: "csv") else {
//            print("Couldn't find file 'mydata.csv'")
//            return
//        }
//
//        guard let data = try? String(contentsOfFile: path, encoding: .utf8) else {
//            print("Couldn't read data from file")
//            return
//        }
//
//        let rows = data.components(separatedBy: "\n")
//        for row in rows {
//            let columns = row.components(separatedBy: ",")
//            if columns.count > 1{
//                prompts.append(columns[0])
//                short.append(columns[1])
//            }
//        }
//        prompts.removeFirst()
//        short.removeFirst()
//        prompts.insert("Basic helper", at: 0)
//        short.insert("You're a helpful assistant", at: 0)
//
//        dataPrompt = prompts
//        let p = fetchCurrentPrompt()
//        self.prompts.insert(p.0, at: 0)
//        self.short.insert(p.1, at: 0)
//        self.dataPrompts = self.prompts
//        self.dataShorts = self.short

        loadCSVFromURL()
    }
    
    func loadCSVFromURL(){
        guard let url = URL(string: "https://raw.githubusercontent.com/f/awesome-chatgpt-prompts/main/prompts.csv") else {
            print("Invalid URL")
            return
        }

        let session = URLSession.shared
        let task = session.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Error: \(error)")
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200,
                  let data = data else {
                print("Invalid response")
                return
            }
            self.prompts = []
            self.short = []
            if let csvString = String(data: data, encoding: .utf8) {
                let rows = csvString.components(separatedBy: "\n")
                for row in rows {
                    let columns = row.components(separatedBy: ",")
                    if columns.count > 1{
                        self.short.append(columns[0])
                        self.prompts.append(columns[1])
                    }
                }
                self.prompts.removeFirst()
                self.short.removeFirst()
                self.short.insert("Basic helper", at: 0)
                self.prompts.insert("You're a helpful assistant", at: 0)

                self.dataPrompts = self.prompts
                self.dataShorts = self.short

                self.updatePickerViews()
            }
        }

        task.resume()

    }
    
    
    func loadCSVToDict(file: String) -> [[String: String]]? {
        guard let path = Bundle.main.path(forResource: file, ofType: "csv") else {
            print("File not found")
            return nil
        }
        
        do {
            let csvData = try String(contentsOfFile: path)
            let csvLines = csvData.components(separatedBy: .newlines).filter { !$0.isEmpty }
            guard let header = csvLines.first else { return nil }
            
            let keys = header.components(separatedBy: ",")
            let data = csvLines.dropFirst().map { line -> [String: String] in
                let values = line.components(separatedBy: ",")
                return Dictionary(uniqueKeysWithValues: zip(keys, values))
            }

            return data
        } catch {
            print("Error reading file: \(error)")
            return nil
        }
    }

       
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updatePickerViews()
    }
    
    func updatePickerViews(){
        let fc = fetchCurrentModel()
        let pc = fetchCurrentPrompt()
        
        for i in (0 ..< data.count) {
            if fc == data[i]{
                DispatchQueue.main.async {
                    self.selectModel.selectRow(i, inComponent: 0, animated: false)
                }
            }
        }
        
        for i in (0 ..< short.count) {
            if pc.1 == short[i]{
                DispatchQueue.main.async {
                    self.selectPrompt.selectRow(i, inComponent: 0, animated: true)
                    self.selectPrompt.reloadAllComponents()
                }
            }
        }
        

        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
       
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == selectModel {
            
            return data.count // number of items in the dropdown list
            
        } else if pickerView == selectPrompt{
            return dataPrompts.count // number of items in the dropdown list
        }
        
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == selectModel {
            return data[row]
        } else if pickerView == selectPrompt{
            return dataShorts[row]
        }
        
        return  ""
    }
       
   func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
       // handle the selection of an item in the dropdown list
              
       if pickerView == selectModel {
           currentModel.model = self.data[row]
           do {
               try context.save()
           } catch let error as NSError {
               print("Could not save. \(error), \(error.userInfo)")
           }
       } else if pickerView == selectPrompt{
           currentPrompt.short = self.dataPrompts[row]
           currentPrompt.prompt = self.dataShorts[row]
           do {
               try context.save()
           } catch let error as NSError {
               print("Could not save. \(error), \(error.userInfo)")
           }
           
       }

   }
    
    
    func fetchCurrentModel() -> String {
        
        let fetchRequest: NSFetchRequest<CurrentModel> = CurrentModel.fetchRequest()
        do {
            let model = try context.fetch(fetchRequest)
            if model.count == 0{
                let currentModel = NSEntityDescription.entity(forEntityName: "CurrentModel", in: context)!
                let c = CurrentModel(entity: currentModel, insertInto: context)
                c.model = "gpt-4"
                self.currentModel = c
                do {
                    try context.save()
                } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                }
            } else {
                currentModel = model[0]
                return model[0].model!
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        return "gpt-4"

    }
    
    func fetchCurrentPrompt() -> (String,String) {
        
        let fetchRequest: NSFetchRequest<CurrentPrompt> = CurrentPrompt.fetchRequest()
        do {
            let model = try context.fetch(fetchRequest)
            if model.count == 0{
                let currentPrompt = NSEntityDescription.entity(forEntityName: "CurrentPrompt", in: context)!
                let c = CurrentPrompt(entity: currentPrompt, insertInto: context)
                c.prompt = "Basic helper"
                c.short = "You're a helpful assistant"
                self.currentPrompt = c
                do {
                    try context.save()
                } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                }
            } else {
                currentPrompt = model[0]
                return (model[0].short!,model[0].prompt!)
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        return ("Basic helper","You're a helpful assistant")

    }


}
