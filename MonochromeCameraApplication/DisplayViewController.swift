//
//  DisplayViewController.swift
//  MonochromeCameraApplication
//
//  Created by 弓削　敦信 on 2024/05/18.
//

import UIKit

class DisplayViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func closeModal(_ sender: UIButton) {
        /*
        MARK: UINavigationControllerを利用して戻るやり方
        pushViewController()メソッド、あるいはSegueのShowで遷移してこないと、
        popViewController()やpopToRootViewController()が利用できないらしい。
        不本意だが、元の画面から遷移したのと同じ方法で戻る。
         */
        let vc = self.storyboard?.instantiateViewController(identifier: "Initial") as! ViewController
        let uinc = UINavigationController(rootViewController: vc)
        // スワイプで戻れてしまうプッシュ遷移でなく、モーダル遷移のフルスクリーンにする
        uinc.modalPresentationStyle = .fullScreen
        self.navigationController?.present(uinc, animated: true)
    }
}
