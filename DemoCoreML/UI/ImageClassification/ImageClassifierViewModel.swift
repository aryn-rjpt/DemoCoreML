import SwiftUI

@Observable
class ImageClassifierViewModel {
    
    var showMediaUpload = false
    
    var imageUrl: URL?
    
    var selectedImage: UIImage? = UIImage(resource: .dog)
    
    var label: String?
    
    var isProcessing = false
    
    var isAccessingimage = false
    
    private let model = try? FastViTT8F16()
    
    func handleSelectedImage(at url: URL) {
        isAccessingimage = url.startAccessingSecurityScopedResource()
        defer {
            if isAccessingimage {
                url.stopAccessingSecurityScopedResource()
            }
        }
        
        imageUrl = url
        if let data = try? Data(contentsOf: url), let loadedImage = UIImage(data: data) {
            selectedImage = loadedImage
        } else {
            selectedImage = nil
        }
        
        Task.detached { [weak self] in
            await self?.getLabel()
        }
    }

    private func getLabel() async {
        guard let image = selectedImage?.cgImage, let model else { return }
        isProcessing = true
        label = nil
        
        defer { isProcessing = false }
        
        do {
            let prediction = try await model.prediction(input: .init(imageWith: image))
            await MainActor.run {
                label = prediction.classLabel
            }
        } catch {
            label = "Error: \(error.localizedDescription)"
        }
    }
    
    func resetSelection() {
        imageUrl = nil
        selectedImage = nil
        label = nil
        isProcessing = false
    }
}
