//
//  ViewController.swift
//  places-collection
//
//  Created by Eric on 3/31/16.
//  Copyright © 2016 Simple Guy. All rights reserved.
//

import UIKit

class BudapestTVC: UITableViewController {
  
  @IBOutlet var metadata: UILabel!
  
  // ADVANTAGE: underlying model type and path key is obvious and defined by the consumer
  var places = CollieCollection<GooglePlace>(path: "/textsearch/json?query=Restaurants+in+Budapest", api: APIs.googlePlaces) // TODO: I prefer the syntax `APIs.googlePlaces.makeCollection(path: "")`, but the generics are fighting me
  
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.title = "CollieCollection<Place> (Budapest)"
    // ADVANTAGE: one call to set up fetch & observation
    // ADVANTAGE: error callback is optional
    // ADVANTAGE: don't need to make this view class a delegate
    // ADVANTAGE: name your callback anything you like
    places.observe( CollieHandler(onPlacesUpdated) )
    refreshControl = UIRefreshControl()
    refreshControl?.backgroundColor = UIColor.darkGrayColor()
    refreshControl?.tintColor = UIColor.whiteColor()
    refreshControl?.addTarget(self, action: #selector(onPullToRefresh), forControlEvents: .ValueChanged)
  }
  
  
  
  // --------------------------------------------------- MARK: APIHandler
  func onPlacesUpdated(results: [GooglePlace]) {
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
      let shortId = "\(place.id)".substringToIndex("\(place.id)".startIndex.advancedBy(8)) // This syntax...
      cell.textLabel?.text = "[\(shortId)]"
      cell.detailTextLabel?.text = "\(place.name) rating: \(place.rating ?? -1)"
    }
    return cell
  }
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if let vc = UIStoryboard(name: "GooglePlaceDisplayerVC", bundle: nil).instantiateInitialViewController() as? GooglePlaceDisplayerVC {
      vc.model = places.latest[indexPath.row]
      self.navigationController?.pushViewController(vc, animated: true)
    }
  }
  
}

