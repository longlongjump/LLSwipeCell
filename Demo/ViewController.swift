//
//  ViewController.swift
//  LLSwipeCell
//
//  Created by eugene on 2/24/16.
//  Copyright © 2016 Eugene Ovchynnykov. All rights reserved.
//

import UIKit

class Cell: LLSwipeCell {
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let button1 = UIButton()
        button1.setTitle("1", forState: .Normal)
        button1.frame = CGRect(x: 0, y: 0, width: 50, height: 10)
        button1.backgroundColor = UIColor.redColor()
        let button2 = UIButton()
        button2.setTitle("2", forState: .Normal)
        button2.frame = CGRect(x: 0, y: 0, width: 50, height: 10)
        button2.backgroundColor = UIColor.greenColor()
        leftButtons = [button1, button2]
        
        let button3 = UIButton()
        button3.setTitle("3", forState: .Normal)
        button3.frame = CGRect(x: 0, y: 0, width: 50, height: 10)
        button3.backgroundColor = UIColor.cyanColor()
        let button4 = UIButton()
        button4.setTitle("4", forState: .Normal)
        button4.frame = CGRect(x: 0, y: 0, width: 50, height: 10)
        button4.backgroundColor = UIColor.blueColor()
        rightButtons = [button3, button4]
    }
}

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        return cell
    }
}

