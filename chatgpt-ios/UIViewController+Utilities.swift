//
//  UIViewController+Utilities.swift
//  chatgpt-ios
//
//  Created by Spiros Raptis on 3/26/23.
//

import Foundation
import UIKit

extension UIViewController{
    
    func showAlert(title:String, message:String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // Add the action to the alert controller
        let action = UIAlertAction(title: "OK", style: .default) { (action) in
            // Handle the action here
        }
        alertController.addAction(action)
        
        // Present the alert controller
        present(alertController, animated: true, completion: nil)
    }
    
}
