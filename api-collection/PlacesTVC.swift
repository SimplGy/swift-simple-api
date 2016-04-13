//
//  ViewController.swift
//  places-collection
//
//  Created by Eric on 3/31/16.
//  Copyright © 2016 Simple Guy. All rights reserved.
//

import UIKit

class PlacesTVC: UITableViewController {

  @IBOutlet var metadata: UILabel!
  
  // ADVANTAGE: underlying model type is obvious
  let places = APICollection<Place>()

  override func viewDidLoad() {
    super.viewDidLoad()
    
    // ADVANTAGE: one call to set up fetch & observation
    // ADVANTAGE: error callback is optional
    // ADVANTAGE: don't need to make this view class a delegate
    places.observe( APIHandler(onPlacesUpdated) )
  }
  
  func onPlacesUpdated(results: [Place]) {
    tableView.reloadData()
    metadata.text = "Count: \(results.count)"
  }


  
  // --------------------------------------------------- MARK: UITableViewController
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return places.latest.count // ADVANTAGE: no optionals, no need to store a separate copy of the latest data in the view controller
  }
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("LeftDetailCell", forIndexPath: indexPath)
    let place = places.latest[indexPath.row]
    cell.textLabel?.text = "[\(place.id)]"
    cell.detailTextLabel?.text = place.name
    return cell
  }

}

