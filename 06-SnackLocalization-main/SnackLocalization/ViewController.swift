//
//  ViewController.swift
//  SnackLocalization
//
//  Created by 钱正轩 on 2020/11/30.
//

import UIKit
import Vision
import AVFoundation
import CoreMedia
import VideoToolbox

class ViewController: UIViewController {
    
    @IBOutlet weak var videoPreview: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var debugImageView: UIImageView!
    
    let useVision = false
    let drawBoundingBoxes = true
    
    static let maxInflightBuffers = 3
    
    let yolo = YOLO()
    
    var videoCapture:VideoCapture!
    var requests = [VNCoreMLRequest]()
    var startTimes:[CFTimeInterval] = []
    
    var boundingBox = BoundingBox()
    var colors: [UIColor] = []
    
    let ciContext = CIContext()
    var resizedPixelBuffers: [CVPixelBuffer?] = []
    
    var framesDone = 0
    var frameCapturingStartTime = CACurrentMediaTime()
    
    var inflightBuffer = 0
    let semaphore = DispatchSemaphore(value: ViewController.maxInflightBuffers)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        timeLabel.text = ""
        
        setUpBoundingBoxes()
        setUpCoreImage()
        setUpCamera()
        
        frameCapturingStartTime = CACurrentMediaTime()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print(#function)
    }
    
    func setUpBoundingBoxes() {
        // Make colors for the bounding boxes. There is one color for each class,
        // 20 classes in total.
        for r: CGFloat in [0.2, 0.4, 0.6, 0.8, 1.0] {
            for g: CGFloat in [0.3, 0.7] {
                for b: CGFloat in [0.4, 0.8] {
                    let color = UIColor(red: r, green: g, blue: b, alpha: 1)
                    colors.append(color)
                }
            }
        }
    }
    
    func setUpCoreImage() {
        // Since we might be running several requests in parallel, we also need
        // to do the resizing in different pixel buffers or we might overwrite a
        // pixel buffer that's already in use.
        for _ in 0..<ViewController.maxInflightBuffers {
            var resizedPixelBuffer: CVPixelBuffer?
            let status = CVPixelBufferCreate(nil, YOLO.inputWidth, YOLO.inputHeight,
                                             kCVPixelFormatType_32BGRA, nil,
                                             &resizedPixelBuffer)
            
            if status != kCVReturnSuccess {
                print("Error: could not create resized pixel buffer", status)
            }
            resizedPixelBuffers.append(resizedPixelBuffer)
        }
    }
    
    func setUpCamera() {
        videoCapture = VideoCapture()
        videoCapture.delegate = self
        videoCapture.desiredFrameRate = 240
        videoCapture.setUp(sessionPreset: AVCaptureSession.Preset.hd1280x720) { success in
            if success {
                // Add the video preview into the UI.
                if let previewLayer = self.videoCapture.previewLayer {
                    self.videoPreview.layer.addSublayer(previewLayer)
                    self.resizePreviewLayer()
                }
                
                // Add the bounding box layers to the UI, on top of the video preview.

                self.boundingBox.addToLayer(self.videoPreview.layer)
                // Once everything is set up, we can start capturing live video.
                self.videoCapture.start()
            }
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        resizePreviewLayer()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func resizePreviewLayer() {
        videoCapture.previewLayer?.frame = videoPreview.bounds
    }
    
    // MARK: - Doing inference
    
    func predict(image: UIImage) {
        if let pixelBuffer = image.pixelBuffer(width: YOLO.inputWidth, height: YOLO.inputHeight) {
            predict(pixelBuffer: pixelBuffer, inflightIndex: 0)
        }
    }
    
    func predict(pixelBuffer: CVPixelBuffer, inflightIndex: Int) {
        // Measure how long it takes to predict a single video frame.
        let startTime = CACurrentMediaTime()
        
        // This is an alternative way to resize the image (using vImage):
        //if let resizedPixelBuffer = resizePixelBuffer(pixelBuffer,
        //                                              width: YOLO.inputWidth,
        //                                              height: YOLO.inputHeight) {
        
        // Resize the input with Core Image to 416x416.
        
        if let resizedPixelBuffer = resizedPixelBuffers[inflightIndex] {
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            let sx = CGFloat(YOLO.inputWidth) / CGFloat(CVPixelBufferGetWidth(pixelBuffer))
            let sy = CGFloat(YOLO.inputHeight) / CGFloat(CVPixelBufferGetHeight(pixelBuffer))
            let scaleTransform = CGAffineTransform(scaleX: sx, y: sy)
            let scaledImage = ciImage.transformed(by: scaleTransform)
            ciContext.render(scaledImage, to: resizedPixelBuffer)
            

            // Give the resized input to our model.
            if let boundingBox = yolo.predict(image: resizedPixelBuffer) {
                let elapsed = CACurrentMediaTime() - startTime
                showOnMainThread(boundingBox, elapsed)
            } else {
                print("BOGUS")
            }
        }
        
        self.semaphore.signal()
    }
    
    func showOnMainThread(_ boundingBox: YOLO.Prediction, _ elapsed: CFTimeInterval) {
        if drawBoundingBoxes {
            DispatchQueue.main.async { [self] in
                // For debugging, to make sure the resized CVPixelBuffer is correct.
//                var debugImage: CGImage?
//                VTCreateCGImageFromCVPixelBuffer(resizedPixelBuffers[inflightBuffer]!, options: nil, imageOut: &debugImage)
//                self.debugImageView.image = UIImage(cgImage: debugImage!)
                
                self.show(prediction: boundingBox)
                
                let fps = self.measureFPS()
                self.timeLabel.text = String(format: "Elapsed %.5f seconds - %.2f FPS", elapsed, fps)
            }
        }
    }
    
    func measureFPS() -> Double {
        // Measure how many frames were actually delivered per second.
        framesDone += 1
        let frameCapturingElapsed = CACurrentMediaTime() - frameCapturingStartTime
        let currentFPSDelivered = Double(framesDone) / frameCapturingElapsed
        if frameCapturingElapsed > 1 {
            framesDone = 0
            frameCapturingStartTime = CACurrentMediaTime()
        }
        return currentFPSDelivered
    }
    
    func show(prediction: YOLO.Prediction) {
        
        // The predicted bounding box is in the coordinate space of the input
        // image, which is a square image of 416x416 pixels. We want to show it
        // on the video preview, which is as wide as the screen and has a 16:9
        // aspect ratio. The video preview also may be letterboxed at the top
        // and bottom.
        let width = view.bounds.width
        let height = width * 16 / 9
        let scaleX = width / CGFloat(YOLO.inputWidth)
        let scaleY = height / CGFloat(YOLO.inputHeight)
        let top = (view.bounds.height - height) / 2
        
        // Translate and scale the rectangle to our own coordinate system.
        
        var rect = prediction.rect
        rect.origin.x *= scaleX
        rect.origin.y *= scaleY
        rect.origin.y += top
        rect.size.width *= scaleX
        rect.size.height *= scaleY
        
        // Show the bounding box.
        let label = labels[prediction.classIndex]
        let color = colors[prediction.classIndex]
        boundingBox.show(frame: rect, label: label, color: color)
    }
    
}


extension ViewController: VideoCaptureDelegate {
    func videoCapture(_ capture: VideoCapture, didCaptureVideoFrame pixelBuffer: CVPixelBuffer?, timestamp: CMTime) {
        // For debugging.
        //predict(image: UIImage(named: "dog416")!); return
        
        if let pixelBuffer = pixelBuffer {
            // The semaphore will block the capture queue and drop frames when
            // Core ML can't keep up with the camera.
            semaphore.wait()
            
            // For better throughput, we want to schedule multiple prediction requests
            // in parallel. These need to be separate instances, and inflightBuffer is
            // the index of the current request.
            let inflightIndex = inflightBuffer
            inflightBuffer += 1
            if inflightBuffer >= ViewController.maxInflightBuffers {
                inflightBuffer = 0
            }
            
            if useVision {
                // This method should always be called from the same thread!
                // Ain't nobody likes race conditions and crashes.
            } else {
                // For better throughput, perform the prediction on a concurrent
                // background queue instead of on the serial VideoCapture queue.
                DispatchQueue.global().async {
                    self.predict(pixelBuffer: pixelBuffer, inflightIndex: inflightIndex)
                }
            }
        }
    }
}
