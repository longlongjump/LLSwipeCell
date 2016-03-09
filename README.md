# LLSwipeCell
Simple UITableViewCell subclass that allows to swipe left or right to reveal custom buttons on the sides of the cell.

<p align="center"><img src="https://raw.githubusercontent.com/longlongjump/LLSwipeCell/master/github-assets/swipe-animation.gif" /></p>

## Usage
**Curently support only Cells instantiated from storyboard or xib files. *slideContentView* variable must be set at this time**

<p align="center"><img src="https://raw.githubusercontent.com/longlongjump/LLSwipeCell/master/github-assets/outlet.png" /></p>


```swift
class SwipeCell: LLSwipeCell {
}
```

You can setup buttons inside ```func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell``` delegate method

```swift
func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
  let cell = tableView.dequeueReusableCellWithIdentifier("SwipeCell", forIndexPath: indexPath) as! SwipeCell
        
  let deleteButton = UIButton()
  deleteButton.setTitle("delete", forState: .Normal)
  deleteButton.frame = CGRect(x: 0, y: 0, width: 50, height: 0)
  deleteButton.backgroundColor = UIColor.redColor()
        
  deleteButton.addTarget(self, action: "deleteTapped:", forControlEvents: .TouchUpInside)
        
  cell.rightButtons = [deleteButton]

  return cell
}
```


## Installation

### From CocoaPods

Add `pod 'LLSwipeCell', git: "https://github.com/longlongjump/LLSwipeCell.git"` to your Podfile. 

### Manually

Just add `LLSwipeCell/LLSwipeCell.swift` file to you project.

## Licence

MIT 
