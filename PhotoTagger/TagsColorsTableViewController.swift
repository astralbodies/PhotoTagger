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
            var red = CGFloat(0.0), green = CGFloat(0.0), blue = CGFloat(0.0), alpha = CGFloat(0.0)
            color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            let threshold = CGFloat(105)
            let bgDelta = ((red * 0.299) + (green * 0.587) + (blue * 0.114));
            
            let textColor = (255 - bgDelta < threshold) ? UIColor.blackColor() : UIColor.whiteColor();
            cell.textLabel?.textColor = textColor
            cell.backgroundColor = color
        } else {
            cell.textLabel?.textColor = UIColor.blackColor()
            cell.backgroundColor = UIColor.whiteColor()
        }
    }
}

