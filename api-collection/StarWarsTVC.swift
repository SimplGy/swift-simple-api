import UIKit

class StarWarsTVC: UITableViewController {
  
  @IBOutlet var metadata: UILabel!
  
  // ADVANTAGE: underlying model type is obvious
  var collie = CollieCollection<StarWarsPerson>(path: "/people/", api: APIs.starWars)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.title = "CollieCollection<StarWarsPerson>"
    // ADVANTAGE: one call to set up fetch & observation
    // ADVANTAGE: error callback is optional
    // ADVANTAGE: don't need to make your view class a delegate
    collie.observe( CollieHandler(onUpdate) )
    refreshControl = UIRefreshControl()
    refreshControl?.backgroundColor = UIColor.darkGrayColor()
    refreshControl?.tintColor = UIColor.whiteColor()
    refreshControl?.addTarget(self, action: #selector(onPullToRefresh), forControlEvents: .ValueChanged)
  }
  
  
  // --------------------------------------------------- MARK: APIHandler
  func onUpdate(results: [StarWarsPerson]) {
    print("onUpdate \(results.count)")
    tableView.reloadData()
    metadata.text = "Count: \(results.count)"
  }
  
  func onPullToRefresh() {
    print("")
    print("onPullToRefresh")
    collie.get() {
      print("finally")
      self.refreshControl?.endRefreshing()
    }
  }
  
  // --------------------------------------------------- MARK: UITableViewController
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return collie.latest.count // ADVANTAGE: no optionals, no need to store a separate copy of the latest data in the view controller
  }
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("LeftDetailCell", forIndexPath: indexPath)
    if let model = collie.latest[safe: indexPath.row] {
      cell.textLabel?.text = model.name
      cell.detailTextLabel?.text = "\(model.id)"
    }
    return cell
  }
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    print("didSelectRowAtIndexPath \(indexPath.row)")
    if let vc = UIStoryboard(name: "APIModelDetailsVC", bundle: nil).instantiateInitialViewController() as? APIModelDetailsVC<StarWarsPerson> {
      vc.model = collie.latest[indexPath.row]
      self.navigationController?.pushViewController(vc, animated: true)
    }
  }
  
}

