//
//  ViewController.swift
//  DetectFaceLandmarks
//
//  Created by tommy19970714 on 2019/10/26.
//  Copyright © 2019 mathieu. All rights reserved.
//
import UIKit
import AVFoundation
import Vision
import BubbleTransition

class ViewController: UIViewController {

    let faceDetector = FaceLandmarksDetector()
    let captureSession = AVCaptureSession()
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var faceSampleView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var transitionButton: UIButton!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var estimatedLabel: UILabel!
    
    var currentWord: String?
    var wordBuffer: [String] = []
    var sentenceBuffer = [[String]]()
    var templeteMassage = "口をパクパクして，\n文字を入力してください"
    
    let transition = BubbleTransition()
    let interactiveTransition = BubbleInteractiveTransition()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view, typically from a nib.
        configureDevice()
        SocketIOClient.shared.connect()
        
    }

    private func getDevice() -> AVCaptureDevice? {
        let discoverSession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera, .builtInTelephotoCamera, .builtInWideAngleCamera], mediaType: .video, position: .front)
        return discoverSession.devices.first
    }

    private func configureDevice() {
        if let device = getDevice() {
            do {
                try device.lockForConfiguration()
                if device.isFocusModeSupported(.continuousAutoFocus) {
                    device.focusMode = .continuousAutoFocus
                }
                device.unlockForConfiguration()
            } catch { print("failed to lock config") }

            do {
                let input = try AVCaptureDeviceInput(device: device)
                captureSession.addInput(input)
            } catch { print("failed to create AVCaptureDeviceInput") }

            captureSession.startRunning()

            let videoOutput = AVCaptureVideoDataOutput()
            videoOutput.videoSettings = [String(kCVPixelBufferPixelFormatTypeKey): Int(kCVPixelFormatType_32BGRA)]
            videoOutput.alwaysDiscardsLateVideoFrames = true
            videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue.global(qos: .utility))

            if captureSession.canAddOutput(videoOutput) {
                captureSession.addOutput(videoOutput)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //UIImageをデータベースに格納できるStringに変換する
    func image2String(image:UIImage) -> String? {
        //画像をNSDataに変換
        let data = UIImagePNGRepresentation(image) as NSData?
        //NSDataへの変換が成功していたら
        if let pngData = data {
              //BASE64のStringに変換する
            let encodeString:String = pngData.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength64Characters)
              return encodeString
         }
         return nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      if let controller = segue.destination as? ModalViewController {
        self.messageLabel.text = templeteMassage
        controller.transitioningDelegate = self
        controller.modalPresentationStyle = .custom
        controller.interactiveTransition = interactiveTransition
        var newSentence = [String]()
        for s in sentenceBuffer {
            newSentence.append(s.joined(separator: ""))
        }
        newSentence.append(wordBuffer.joined(separator: ""))
        print(newSentence)
        SocketIOClient.shared.sendText(stringArray: newSentence)
        self.wordBuffer = []
        self.sentenceBuffer = []
        interactiveTransition.attach(to: controller)
      }
    }
    
    @IBAction func addWord(sender: UIButton) {
        if let w = currentWord {
            self.wordBuffer.append(w)
            self.messageLabel.text = makeDiscription()
        }
    }
    
    @IBAction func deleteButton(sender: UIButton) {
        if !wordBuffer.isEmpty {
            wordBuffer = wordBuffer.dropLast()
            self.messageLabel.text = makeDiscription()
        }
    }
    
    @IBAction func splitButton(sender: UIButton) {
        if !wordBuffer.isEmpty {
            sentenceBuffer.append(wordBuffer)
            wordBuffer = []
        }
    }
    
    func makeDiscription() -> String {
        var newText = ""
        for sentence in sentenceBuffer {
            newText += sentence.joined(separator: " ") + "    "
        }
        newText += self.wordBuffer.joined(separator: " ")
        return newText
    }
}

extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {

        // Scale image to process it faster
        let maxSize = CGSize(width: 1024, height: 1024)

        if let image = UIImage(sampleBuffer: sampleBuffer)?.flipped()?.imageWithAspectFit(size: maxSize) {
            faceDetector.highlightFaces(for: image) { (resultImage, lipImage, word) in
                DispatchQueue.main.async {
                    self.imageView?.image = resultImage
                    if lipImage == nil {
                        self.faceSampleView.image = #imageLiteral(resourceName: "mouth")
                    } else {
                        self.faceSampleView.image = lipImage
                    }
                    if let w = word {
                        self.estimatedLabel.text = w
                        self.currentWord = w
                    }
                    
                    if let image = lipImage, let base64 = self.image2String(image: image) {
                        if lipImage?.size == CGSize(width: 320.0, height: 160.0) {
//                            SocketIOClient.shared.send(string: base64)
                        }
                    }
                    
                }
            }
        }
    }
}

extension ViewController: UIViewControllerTransitioningDelegate {
    
    // MARK: UIViewControllerTransitioningDelegate
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
      transition.transitionMode = .present
      transition.startingPoint = transitionButton.center
      transition.bubbleColor = transitionButton.backgroundColor!
      return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
      transition.transitionMode = .dismiss
      transition.startingPoint = transitionButton.center
      transition.bubbleColor = transitionButton.backgroundColor!
      return transition
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
      return interactiveTransition
    }
}
