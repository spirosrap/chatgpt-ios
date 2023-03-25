import UIKit
import CoreData

class MyTableViewController: UITableViewController {

    // MARK: - Properties
    
    var myData = [String]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var answers  = [Answer]()
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register cell classes if necessary
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.rowHeight = 80
        
        tableView.separatorColor = .gray
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)

        // Set up data source
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadData()
        tableView.reloadData()
    }
    
    // MARK: - Table View Data Source
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let baseHeight: CGFloat = 44 // The base height for the cell
        let extraLineHeight: CGFloat = 20 // The height of each extra line

        // Add the extra height for the two empty lines
        return baseHeight + 2 * extraLineHeight

    }

    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.text = myData[indexPath.row] + "\n\n"
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.font = UIFont.systemFont(ofSize: 12) // or any other font size you prefer
        

        // Customize the textLabel appearance if needed
        cell.textLabel?.numberOfLines = 0 // Allows the label to have multiple lines

        // Configure the cell, e.g., set text, images, etc.

        // Add a custom border view
        let borderView = UIView(frame: CGRect(x: 0, y: cell.frame.height - 1, width: cell.frame.width, height: 1))
        borderView.backgroundColor = .gray
        borderView.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        cell.addSubview(borderView)

        return cell

        
    }

    // MARK: - Table View Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Handle cell selection
        print("Selected item at index \(indexPath.row)")
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let detailViewController = storyboard.instantiateViewController(withIdentifier: "detailView") as! DetailViewController
        detailViewController.text = myData[indexPath.row]
        
        present(detailViewController, animated: true, completion: nil)


    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Remove the item from your data source
            myData.remove(at: indexPath.row)
            context.delete(answers[indexPath.row])
            try! context.save()
            // Delete the row from the table view with an animation
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    


    
    // MARK: - Other Methods
    
    func addNewItem(_ item: String) {
        myData.append(item)
        tableView.reloadData()
    }
    
    func loadData() {
        let fetchRequest: NSFetchRequest<Answer> = Answer.fetchRequest()
        do {
            answers = try context.fetch(fetchRequest)
            
            myData = answers.map { $0.question! + " - \n\n" + $0.answer!  }
            tableView.reloadData()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
}
