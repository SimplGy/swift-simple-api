//
//  ViewController.swift
//  places-collection
//
//  Created by Eric on 3/31/16.
//  Copyright © 2016 Simple Guy. All rights reserved.
//

import UIKit

class DenverTVC: UITableViewController {
  
  @IBOutlet var metadata: UILabel!
  
  // ADVANTAGE: underlying model type is obvious
  var places = CollieCollection<Place>(path: "/textsearch/json?query=Restaurants+in+Denver", api: APIs.googlePlaces)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.title = "CollieCollection<Place> (Denver)"
    // ADVANTAGE: one call to set up fetch & observation
    // ADVANTAGE: error callback is optional
    // ADVANTAGE: don't need to make this view class a delegate
    places.observe( CollieHandler(onPlacesUpdated) )
    refreshControl = UIRefreshControl()
    refreshControl?.backgroundColor = UIColor.darkGrayColor()
    refreshControl?.tintColor = UIColor.whiteColor()
    refreshControl?.addTarget(self, action: "onPullToRefresh", forControlEvents: .ValueChanged)
  }
  
  
  // --------------------------------------------------- MARK: APIHandler
  func onPlacesUpdated(results: [Place]) {
    print("onPlacesUpdated \(results.count)")
    tableView.reloadData()
    metadata.text = "Count: \(results.count)"
  }
  
  
  func onPullToRefresh() {
    print("")
    print("onPullToRefresh")
    places.get() {
      print("finally")
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
      let shortId = "\(place.id)".substringToIndex("\(place.id)".startIndex.advancedBy(8)) // This syntax...
      cell.textLabel?.text = "[\(shortId)]"
      cell.detailTextLabel?.text = "\(place.name) rating: \(place.rating ?? -1)"
    }
    return cell
  }
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    print("didSelectRowAtIndexPath \(indexPath.row)")
    if let vc = UIStoryboard(name: "PlaceDisplayerVC", bundle: nil).instantiateInitialViewController() as? PlaceDisplayerVC {
      vc.model = places.latest[indexPath.row]
      self.navigationController?.pushViewController(vc, animated: true)
    }
  }
  
}

