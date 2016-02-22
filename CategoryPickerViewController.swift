//
//  CategoryPickerViewController.swift
//  Charades
//
//  Created by Jeff on 9/3/15.
//  Copyright © 2015 Jeff Berman. All rights reserved.
//

import UIKit

class CategoryPickerViewController: UITableViewController {
    
    struct Category {
        let name: String
        var selected: Bool
    }
    var categories = [Category]()

    // MARK: - Life cycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load master category list from model and restore previous selections
        let model = CharadesGame()
        print("Model loaded into CategoryPickerVC")
        
        var savedCategories = NSUserDefaults.standardUserDefaults().stringArrayForKey("selectedCategories")
        if savedCategories == nil || savedCategories?.count == 0 { // Never saved
            savedCategories = model.masterCategoryList
        }
        
        categories = model.masterCategoryList.map({ Category(name: $0, selected: savedCategories!.contains($0)) })
        
        let background = UIImageView(image: UIImage(named: "title background"))
        self.tableView.backgroundView = background
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CategoryCell", forIndexPath: indexPath) as! CategoryPickerTableViewCell
        cell.titleLabel.text = categories[indexPath.row].name
        cell.checkmarkImage.image = categories[indexPath.row].selected ? UIImage(named: "GreenCheckmark") : nil
        
        return cell
    }
    
    
    // MARK: - Table view delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? CategoryPickerTableViewCell {
            categories[indexPath.row].selected = !categories[indexPath.row].selected
            cell.checkmarkImage.image = categories[indexPath.row].selected ? UIImage(named: "GreenCheckmark") : nil
            
            // Must have at least one item selected
            if categories.filter({ $0.selected == true }).count > 0 {
                navigationItem.rightBarButtonItem?.enabled = true
            } else {
                navigationItem.rightBarButtonItem?.enabled = false
            }
        }
    }


    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PlayGameSegue" {
            if let vc = segue.destinationViewController as? CharadesGameViewController {
                let selectedCategories = categories.filter({ $0.selected }).map({ $0.name })
                vc.selectedCategories = selectedCategories
                NSUserDefaults.standardUserDefaults().setObject(selectedCategories, forKey: "selectedCategories")
                navigationItem.backBarButtonItem = UIBarButtonItem(title: "Abort game", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
            }
        }
    }
    
    
    @IBAction func didUnwindToReplay(unwindSegue: UIStoryboardSegue) {
        // Nothing to do here; this is just the target of the Unwind.
    }
}