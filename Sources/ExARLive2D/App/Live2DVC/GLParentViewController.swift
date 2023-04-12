//
//  GLParentViewController.swift
//  ExARLive2D
//
//  Created by Yifu Yin on 4/7/23.
//

import Foundation


class GLParentViewController: UIViewController {
    @IBOutlet weak var uiview: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "Live2DViewController") as! Live2DViewController
        
        self.uiview.addSubview(vc.view)
        vc.view.frame = CGRect(x:0, y: 0, width:200, height:200)
        vc.view.layer.cornerRadius = vc.view.layer.bounds.width / 2
        vc.view.clipsToBounds = true
        
        
        vc.view.layer.borderColor = UIColor.darkGray.cgColor
        vc.view.layer.borderWidth = 2.0
        
        self.addChild(vc)
        
        self.view.backgroundColor = UIColor.white;
        self.uiview.backgroundColor = UIColor.white;
    }
}
