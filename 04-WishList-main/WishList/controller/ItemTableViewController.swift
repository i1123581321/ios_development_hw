//
//  ItemTableViewController.swift
//  WishList
//
//  Created by 钱正轩 on 2020/11/4.
//

import UIKit
import os.log

class ItemTableViewController: UITableViewController {
    
    //MARK: Properties
    
    var items = [Item]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = editButtonItem
        
        if let savedItems = loadItems(){
            items += savedItems
        }
        else {
            loadSampleItems()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "ItemTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ItemTableViewCell else {
            fatalError("The dequeued cell is not an instance of ItemTableViewCell")
        }

        // Configure the cell...
        
        let item = items[indexPath.row]
        
        cell.nameLabel.text = item.name
        cell.photoImageView.image = item.photo
        cell.ratingControl.rating = item.rating

        return cell
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            items.remove(at: indexPath.row)
            saveItems()
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch (segue.identifier ?? "") {
        case "AddItem":
            os_log("Adding a new item", log: .default, type: .debug)
        case "ShowDetail":
            guard let itemDetailViewController = segue.destination as? ItemViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            guard let selectedItemCell = sender as? ItemTableViewCell else {
                fatalError("Unexpected sender: \(sender ?? "")")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedItemCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedItem = items[indexPath.row]
            itemDetailViewController.item = selectedItem
        default:
            fatalError("Unexpected Segue Identifier: \(segue.identifier ?? "")")
        }
    }
    
    
    //MARK: Actions
    
    @IBAction func unwindToItemList(sender: UIStoryboardSegue){
        if let sourceViewController = sender.source as? ItemViewController, let item = sourceViewController.item{
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                items[selectedIndexPath.row] = item
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            } else {
                let newIndexPath = IndexPath(row: items.count, section: 0)
                items.append(item)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
            print("call saveItems")
            saveItems()
        }
    }

    
    //MARK: Private Methods
    
    private func loadSampleItems() {
        let photo1 = UIImage(named: "item1")
        let photo2 = UIImage(named: "item2")
        let photo3 = UIImage(named: "item3")
        
        guard let item1 = Item(name: "Play Station 5", photo: photo1, rating: 5, wish: nil) else {
            fatalError("Unable to instantiate item1")
        }
        
        guard let item2 = Item(name: "RTX 3080", photo: photo2, rating: 2, wish: nil) else {
            fatalError("Unable to instantiate item2")
        }
        
        guard let item3 = Item(name: "Airpods Pro", photo: photo3, rating: 4, wish: nil) else {
            fatalError("Unable to instantiate item3")
        }
        
        items += [item1, item2, item3]
    }
    
    private func saveItems(){
        if let dataToBeArchived = try? NSKeyedArchiver.archivedData(withRootObject: items, requiringSecureCoding: false){
            try? dataToBeArchived.write(to: Item.ArchiveURL)
        }
    }
    
    private func loadItems() -> [Item]? {
        if let archivedData = try? Data(contentsOf: Item.ArchiveURL){
            return try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(archivedData) as? [Item]
        }
        return nil
    }
}
