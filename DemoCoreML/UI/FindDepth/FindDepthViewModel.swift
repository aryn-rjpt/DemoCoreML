import AVKit

@Observable
final class FindDepthViewModel: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    let captureSession = AVCaptureSession()
    var model: DepthAnythingV2SmallF32?
    var outputImage: CGImage?
    
    var processedImageBuffer: CVPixelBuffer?
    let context = CIContext()
    let width = 518
    let height = 392
    
    
    var isAuthorized: Bool {
        get async {
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            
            // Determine if the user previously authorized camera access.
            var isAuthorized = status == .authorized
            
            // If the system hasn't determined the user's authorization status,
            // explicitly prompt them for approval.
            if status != .authorized {
                isAuthorized = await AVCaptureDevice.requestAccess(for: .video)
            }
            
            return isAuthorized
        }
    }
    
    func initCamera() async {
        guard await isAuthorized, captureSession.isRunning == false else { return }
        
        captureSession.beginConfiguration()
        
        let videoDevice = AVCaptureDevice.default(for: .video)
        guard
            let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice!),
            captureSession.canAddInput(videoDeviceInput)
        else { return }
        captureSession.addInput(videoDeviceInput)
        
        
        let videoOutput = AVCaptureVideoDataOutput()
        guard captureSession.canAddOutput(videoOutput) else { return }
        captureSession.addOutput(videoOutput)
        videoOutput.setSampleBufferDelegate(self, queue: .global())
        videoOutput.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA, // try with ARGB
        ]
            
        
        captureSession.commitConfiguration()
        captureSession.startRunning()
        
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            width,
            height,
            kCVPixelFormatType_32BGRA,
            nil,
            &processedImageBuffer
        )

        guard status == kCVReturnSuccess else {
            return
        }
        
        model = try? DepthAnythingV2SmallF32()
        
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let model else { return }
        
        let imageBuffer: CVImageBuffer? = CMSampleBufferGetImageBuffer(sampleBuffer)

        guard let imageBuffer, let processedImageBuffer else { return }
        let inputImage: CIImage = CIImage(cvImageBuffer: imageBuffer)
        let scaleTransform = CGAffineTransform(
            scaleX: CGFloat(width) / inputImage.extent.width,
            y: CGFloat(height) / inputImage.extent.height
        )

        let scaledImage = inputImage.transformed(by: scaleTransform)

        let rotatedImage = scaledImage.transformed(
            by: CGAffineTransform(rotationAngle: -.pi / 2)
        )

        let translatedImage = rotatedImage.transformed(
            by: CGAffineTransform(
                translationX: -rotatedImage.extent.minX,
                y: -rotatedImage.extent.minY
            )
        )
        
        context.render(translatedImage, to: processedImageBuffer)
        
        
        
//        let resizedImage: CIImage = inputImage.transformed(by: .init(scaleX: 518.0/inputImage.extent.width, y: 392.0/inputImage.extent.height))
//        let rotatedImage: CIImage = resizedImage.transformed(by: .init(rotationAngle: -.pi/2))
//        
//        let inputCGImage = context.createCGImage(rotatedImage, from: rotatedImage.extent)
        
        let output = try? model.prediction(image: processedImageBuffer)
        
        guard let output else { return }
        
        let ciImage = CIImage(cvPixelBuffer: output.depth)
        
        outputImage = context.createCGImage(ciImage, from: ciImage.extent)
    }
    
}
