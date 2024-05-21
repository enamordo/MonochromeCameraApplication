import UIKit

class DisplayViewController: UIViewController {
    // 前画面で撮影後、モノクロに加工した写真
    var monochromeUIImage: UIImage?
    // 写真を表示するUIKitパーツ
    @IBOutlet weak var uiImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uiImageView.image = monochromeUIImage;
    }
    
    @IBAction func dismiss(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
}
