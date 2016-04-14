//
//  ModelDisplayerVC.swift
//  api-collection
//
//  Created by Eric on 4/13/16.
//  Copyright © 2016 Simple Guy. All rights reserved.
//

import UIKit


class ModelDisplayerVC: UIViewController {

  @IBOutlet var textView: UITextView!
  var model: APIModel?
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(true)
    guard let model = model else { return }
    let json = model.toJSON()
    navigationItem.title = (json["name"] as? [String])?[0]
    textView.text = String( json )
  }
  
}