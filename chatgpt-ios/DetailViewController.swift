//
//  DetailViewController.swift
//  chatgpt-ios
//
//  Created by Spiros Raptis on 3/25/23.
//

import Foundation
import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    var text:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.text = text
        textView.font = UIFont.systemFont(ofSize: 18)

    }
}
