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
    var dataPrompt = [String]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var currentModel:CurrentModel!
    
    override func viewDidLoad() {
        selectModel.delegate = self
        selectModel.dataSource = self
        data = ["gpt-4", "gpt-3.5-turbo","gpt-4-0314","gpt-3.5-turbo-0301"]
        dataPrompt = []
        
//        pickerViewContainer.layer.borderColor = UIColor.black.cgColor
//        pickerViewContainer.layer.borderWidth = 2.0
//        pickerViewContainer.layer.cornerRadius = 10.0

    }
       
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
            // Access the variable from the sceneDelegate instance
            for i in (0 ..< data.count) {
                let _ = fetchCurrentModel()
                if fetchCurrentModel() == data[i]{
                    selectModel.selectRow(i, inComponent: 0, animated: true)
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
            return dataPrompt.count // number of items in the dropdown list
        }
        
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == selectModel {
            return data[row]
        } else if pickerView == selectPrompt{
            return dataPrompt[row]
        }
        
        return  ""
    }
       
   func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
       // handle the selection of an item in the dropdown list
       
       currentModel.model = self.data[row]
       do {
           try context.save()
       } catch let error as NSError {
           print("Could not save. \(error), \(error.userInfo)")
       }
       
       if pickerView == selectModel {
           currentModel.model = self.data[row]
           do {
               try context.save()
           } catch let error as NSError {
               print("Could not save. \(error), \(error.userInfo)")
           }
       } else if pickerView == selectPrompt{
           //
       }


   }
    
    
    func fetchCurrentModel() -> String {
        
        let fetchRequest: NSFetchRequest<CurrentModel> = CurrentModel.fetchRequest()
        do {
            let model = try context.fetch(fetchRequest)
            if model.count == 0{
                var currentModel = NSEntityDescription.entity(forEntityName: "CurrentModel", in: context)!
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

}
