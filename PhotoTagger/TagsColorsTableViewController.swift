import UIKit

struct TagsColorTableData {
    var label: String
    var color: UIColor?
}

class TagsColorsTableViewController: UITableViewController {
    var data: [TagsColorTableData]?
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let data = data {
            return data.count
        }
        return 0;
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellData = data?[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier("TagOrColorCell", forIndexPath: indexPath)
        
        cell.textLabel?.text = cellData?.label
        
        return cell
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let cellData = data?[indexPath.row]
        
        if let color = cellData?.color {
            cell.backgroundColor = color
        } else {
            cell.backgroundColor = UIColor.whiteColor()
        }
    }
}

