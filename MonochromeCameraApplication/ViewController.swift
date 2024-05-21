import UIKit
import AVFoundation

class ViewController: UIViewController {
    // <SESSION:セッション系>
    // デバイスからの入力と出力を管理するオブジェクトの作成
    var captureSession = AVCaptureSession()

    // <INPUT:デバイス系>
    // メインカメラの管理オブジェクトの作成
    var mainCamera: AVCaptureDevice?
    // インカメの管理オブジェクトの作成
    var innerCamera: AVCaptureDevice?
    // 現在使用しているカメラデバイスの管理オブジェクトの作成
    var currentDevice: AVCaptureDevice?
    
    // <OUTPUT:出力データ系>
    // キャプチャーの出力データを受け付けるオブジェクト
    var photoOutput : AVCapturePhotoOutput?
    // プレビュー表示用のレイヤ
    var cameraPreviewLayer : AVCaptureVideoPreviewLayer?
    // 撮影後、モノクロに加工した写真
    var monochromeUIImage: UIImage?
    
    // <UIKIT:画面上のパーツ系>
    // シャッターボタン
    @IBOutlet weak var cameraButton: UIButton!
    // カウントラベル
    @IBOutlet weak var countLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCaptureSession()
        setupDevice()
        setupInputOutput()
        setupPreviewLayer()
        styleCaptureButton()
        captureSession.startRunning()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cameraButton_TouchUpInside(_ sender: UIButton) {
        // カウントタイムのリセット、カウント表示
        var time = 3
        self.countLabel.text = String(time)
        self.countLabel.isHidden = false
        // タイマー処理実施
        let timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
            time -= 1
            self.countLabel.text = String(time)
            // カウント０でタイマーの停止、カウント非表示、撮影、画面遷移を実施
            if time == 0 {
                timer.invalidate()
                self.countLabel.isHidden = true
                self.shoot()
                /* MARK:
                   撮影後に画面2に遷移した時、元の画面から渡した白黒写真画像のデータが表示されない。
                   AVCapturePhotoCaptureDelegateの処理が遷移に間に合っていないと思われる。
                   他の適切な方法で実装できると分かるまで、遷移と値渡しは遅延実行で行う。
                 */
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    self.transitionAndPassValue()
                }
            }
        })
    }
    
}

// カメラ設定・撮影・画面遷移・画像加工等のメソッドを追加
extension ViewController{
    // カメラの画質の設定
    func setupCaptureSession() {
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
    }

    // デバイスの設定
    func setupDevice() {
        // カメラデバイスのプロパティ設定
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
        // プロパティの条件を満たしたカメラデバイスの取得
        let devices = deviceDiscoverySession.devices

        for device in devices {
            if device.position == AVCaptureDevice.Position.back {
                mainCamera = device
            } else if device.position == AVCaptureDevice.Position.front {
                innerCamera = device
            }
        }
        // 起動時のカメラを設定
        currentDevice = mainCamera
    }

    // 入出力データの設定
    func setupInputOutput() {
        do {
            // 指定したデバイスを使用するために入力を初期化
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentDevice!)
            // 指定した入力をセッションに追加
            captureSession.addInput(captureDeviceInput)
            // 出力データを受け取るオブジェクトの作成
            photoOutput = AVCapturePhotoOutput()
            // 出力ファイルのフォーマットを指定
            photoOutput!.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])], completionHandler: nil)
            captureSession.addOutput(photoOutput!)
        } catch {
            print(error)
        }
    }

    // カメラのプレビューを表示するレイヤの設定
    func setupPreviewLayer() {
        // 指定したAVCaptureSessionでプレビューレイヤを初期化
        self.cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        // プレビューレイヤが、カメラのキャプチャーを縦横比を維持した状態で、表示するように設定
        self.cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        // プレビューレイヤの表示の向きを設定
        self.cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        self.cameraPreviewLayer?.frame = view.frame
        self.view.layer.insertSublayer(self.cameraPreviewLayer!, at: 0)
    }
    
    // シャッターボタンのスタイルを設定
    func styleCaptureButton() {
        cameraButton.layer.borderColor = UIColor.white.cgColor
        cameraButton.layer.borderWidth = 5
        cameraButton.clipsToBounds = true
        cameraButton.layer.cornerRadius = min(cameraButton.frame.width, cameraButton.frame.height) / 2
    }
    
    // カメラ撮影
    func shoot(){
        // 設定のオブジェクト化
        let settings = AVCapturePhotoSettings()
        // フラッシュの設定
        settings.flashMode = .auto
        // カメラの手ぶれ補正
        settings.isAutoStillImageStabilizationEnabled = true
        // 撮影された画像をdelegateメソッドで処理
        photoOutput?.capturePhoto(with: settings, delegate: self as AVCapturePhotoCaptureDelegate)
    }

    // 撮影後の画面遷移
    func transitionAndPassValue() {
        // 次画面のDisplayViewControllerをインスタンス化
        let dvc = self.storyboard?.instantiateViewController(identifier: "Display") as! DisplayViewController
        // 次画面インスタンスの変数に、画像データを渡す
        dvc.monochromeUIImage = monochromeUIImage
        let uinc = UINavigationController(rootViewController: dvc)
        // スワイプで戻れてしまうプッシュ遷移でなく、モーダル遷移のフルスクリーンにする
        uinc.modalPresentationStyle = .fullScreen
        self.navigationController?.present(uinc, animated: true)
    }
    
    // グレースケールに加工する
    func convertToGrayscale(uiImage: UIImage, orientation: UIImage.Orientation) -> UIImage {
        // 加工用のCIImageクラスへ変換
        let ciImage:CIImage = CIImage(image: uiImage)!
        // フィルター生成
        let ciFilter:CIFilter = CIFilter(name: "CIColorMonochrome")!
        ciFilter.setValue(ciImage, forKey: kCIInputImageKey)
        ciFilter.setValue(CIColor(red: 0.75, green: 0.75, blue: 0.75), forKey: "inputColor")
        ciFilter.setValue(1.0, forKey: "inputIntensity")
        let ciContext:CIContext = CIContext(options: nil)
        let cgimg:CGImage = ciContext.createCGImage(ciFilter.outputImage!, from:ciFilter.outputImage!.extent)!
        // UIImageに再変換
        let monochromeUIImage = UIImage(cgImage: cgimg, scale: 1.0, orientation: orientation)
        
        return monochromeUIImage
    }
    
}

extension ViewController: AVCapturePhotoCaptureDelegate{
    // 撮影した画像データが生成されたときに呼び出されるデリゲートメソッド
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation() {
            // Data型をUIImageオブジェクトに変換
            let uiImage = UIImage(data: imageData)
            // 写真の向き情報を保持する（UIImageからCIImageへ変換・加工し、再度UIImageに戻す時に必要）
            let orientation = uiImage!.imageOrientation
            // グレースケール化
            monochromeUIImage = convertToGrayscale(uiImage: uiImage!, orientation: orientation);
            // 写真ライブラリに画像を保存
            UIImageWriteToSavedPhotosAlbum(monochromeUIImage!, nil,nil,nil)
        }
    }
}
