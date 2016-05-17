//
//  ModelDisplayerVC.swift
//  api-collection
//
//  Created by Eric on 4/13/16.
//  Copyright © 2016 Simple Guy. All rights reserved.
//

import UIKit


class APIModelDetailsVC<T where T: CollieModel>: UIViewController {
  
  @IBOutlet var textView: UITextView!
  var model: T?
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(true)
    guard let model = model else { return }
    guard let json = model.toJSON() else { return }
    navigationItem.title = (json["name"] as? [String])?[0]
    textView.text = json.description
  }
  
}