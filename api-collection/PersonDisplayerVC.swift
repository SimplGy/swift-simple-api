//
//  ModelDisplayerVC.swift
//  api-collection
//
//  Created by Eric on 4/13/16.
//  Copyright © 2016 Simple Guy. All rights reserved.
//

import UIKit


class PersonDisplayerVC: UIViewController {
  
  @IBOutlet var textView: UITextView!
  var model: StarWarsPerson?
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(true)
    guard let model = model else { return }
    navigationItem.title = model.name
    let json = model.toJSON()
    textView.text = "model.isSymmetrical()? \(model.isSymmetrical())\n\n" + (json?.description ?? "")
  }
  
}