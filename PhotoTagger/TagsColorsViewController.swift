/*
* Copyright (c) 2015 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import UIKit

class TagsColorsViewController: UIViewController {
    var tags: [String]?
    var colors: [PhotoColor]?
    var tableViewController: TagsColorsTableViewController!
    @IBOutlet var segmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        setupTableData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "DataTable" {
            tableViewController = segue.destinationViewController as! TagsColorsTableViewController
        }
    }

    @IBAction func tagsColorsSegmentedControlChanged(sender: UISegmentedControl) {
        setupTableData()
    }
    
    func setupTableData() {
        if segmentedControl.selectedSegmentIndex == 0 {
            
            if let tags = tags {
                tableViewController.data = tags.map({ (tag: String) -> TagsColorTableData in
                    return TagsColorTableData(label: tag, color: nil)
                })
            } else {
                tableViewController.data = [TagsColorTableData(label: "No tags were fetched.", color: nil)]
            }
        } else {
            if let colors = colors {
                tableViewController.data = colors.map({ (photoColor: PhotoColor) -> TagsColorTableData in
                    let uicolor = UIColor(red: CGFloat(photoColor.red!) / 255, green: CGFloat(photoColor.green!) / 255, blue: CGFloat(photoColor.blue!) / 255, alpha: 1.0)
                    return TagsColorTableData(label: photoColor.colorName!, color: uicolor)
                })
            } else {
                tableViewController.data = [TagsColorTableData(label: "No colors were fetched.", color: nil)]
            }
        }
        
        tableViewController.tableView.reloadData()
    }
}
