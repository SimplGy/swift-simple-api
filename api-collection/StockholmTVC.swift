//
//  ViewController.swift
//  places-collection
//
//  Created by Eric on 3/31/16.
//  Copyright © 2016 Simple Guy. All rights reserved.
//

import UIKit

class StockholmTVC: UITableViewController {
  
  @IBOutlet var metadata: UILabel!
  
  var places = CollieCollection<WaitressPlace>(path: "/places/nearby?region=8&lat=59.33&lng=18.06&meters=15000000", api: APIs.waitress)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.title = "CollieCollection<Place> (Stockholm)"
    // ADVANTAGE: one call to set up fetch & observation
    // ADVANTAGE: error callback is optional
    // ADVANTAGE: don't need to make this view class a delegate
    places.observe( CollieHandler(onPlacesUpdated) ) // TODO: put this in viewDidAppear. This will battle-test that handlers don't cause memory leaks, and prompt a data check when you open this screen.
    refreshControl = UIRefreshControl()
    refreshControl?.backgroundColor = UIColor.darkGrayColor()
    refreshControl?.tintColor = UIColor.whiteColor()
    refreshControl?.addTarget(self, action: #selector(onPullToRefresh), forControlEvents: .ValueChanged)
  }
  
  
  
  // --------------------------------------------------- MARK: APIHandler
  func onPlacesUpdated(results: [WaitressPlace]) {
    print("onPlacesUpdated \(results.count)")
    tableView.reloadData()
    metadata.text = "Count: \(results.count)"
  }
  
  
  func onPullToRefresh() {
    places.get() {
      self.refreshControl?.endRefreshing()
    }
  }
  
  
  
  // --------------------------------------------------- MARK: UITableViewController
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return places.latest.count // ADVANTAGE: no optionals, no need to store a separate copy of the latest data in the view controller
  }
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("LeftDetailCell", forIndexPath: indexPath)
    if let place = places.latest[safe: indexPath.row] {
      cell.textLabel?.text = "[\(place.id)]"
      cell.detailTextLabel?.text = "\(place.name)"
    }
    return cell
  }
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if let vc = UIStoryboard(name: "WaitressPlaceDisplayerVC", bundle: nil).instantiateInitialViewController() as? WaitressPlaceDisplayerVC {
      vc.model = places.latest[indexPath.row]
      self.navigationController?.pushViewController(vc, animated: true)
    }
  }
  
}

