//
//  ViewController.swift
//  places-collection
//
//  Created by Eric on 3/31/16.
//  Copyright © 2016 Simple Guy. All rights reserved.
//

import UIKit

class PlacesTVC: UITableViewController {

  let places = APICollection<Place>()

  override func viewDidLoad() {
    super.viewDidLoad()
    
    // ADVANTAGE: one call to set up fetch & observation
    // ADVANTAGE: error callback is optional
    // ADVANTAGE: don't need to make this view class a delegate
    places.observe( APIHandler(onPlacesUpdated) )
  }
  
  func onPlacesUpdated(places: [Place]) {
    print("places.observe callback:")
    places.forEach { print($0) }
    tableView.reloadData()
  }
  
  
  
  // --------------------------------------------------- MARK: UITableViewController
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return places.latest.count // ADVANTAGE: no optionals, no need to store a separate copy of the latest data in the view controller
  }
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("LeftDetailCell", forIndexPath: indexPath)
    let place = places.latest[indexPath.row]
    cell.textLabel?.text = place.name
    cell.detailTextLabel?.text = "[\(place.id)]"
    return cell
  }

}

