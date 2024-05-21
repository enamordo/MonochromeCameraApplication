//
//  DisplayViewController.swift
//  MonochromeCameraApplication
//
//  Created by 弓削　敦信 on 2024/05/18.
//

import UIKit

class DisplayViewController: UIViewController {
    
    @IBOutlet weak var uiImageView: UIImageView!
    // モノクロに加工した写真
    var monochromeUIImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uiImageView.image = monochromeUIImage;
    }
    
    @IBAction func dismiss(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
