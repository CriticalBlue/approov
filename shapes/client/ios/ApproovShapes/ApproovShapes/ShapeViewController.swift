/*****************************************************************************
 * Project:     ApproovShapes
 * File:        ShapeViewController.swift
 * Original:    Created on 26 Sept 2016 by Simon Rigg
 * Copyright(c) 2002 - 2016 by CriticalBlue Ltd.
 *
 * The Shape view controller class.
 ****************************************************************************/

import UIKit

class ShapeViewController: UIViewController {
    
    @IBOutlet weak var shapeImageView: UIImageView!
    
    /* The name of the random shape we got from our server */
    var shapeName: String!

    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        /* display the shape name and image in the view controller */
        self.navigationItem.title = self.shapeName
        if let shapeImage = UIImage(named: self.shapeName) {
            self.shapeImageView.image = shapeImage
        }
    }
}
