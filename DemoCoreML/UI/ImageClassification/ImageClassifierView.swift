import SwiftUI
internal import UniformTypeIdentifiers

struct ImageClassifierView: View {
    
    @State var viewModel = ImageClassifierViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                   
                    ImageClassifierHeaderView(isProcessing: $viewModel.isProcessing)
                    
                    SelectedImageView(viewModel: $viewModel)
                    
                    // Primary Action Button
                    Button {
                        viewModel.showMediaUpload = true
                    } label: {
                        Label(viewModel.selectedImage == nil ? "Choose Image" : "Change Image", systemImage: "photo.on.rectangle")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                    }
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.capsule)
                    .padding(.horizontal)
                    
                    ImageResultView(viewModel: $viewModel)
                }
                .padding(.bottom, 24)
            }
            .navigationTitle("Classifier")
            .navigationBarTitleDisplayMode(.inline)
            .fileImporter(isPresented: $viewModel.showMediaUpload, allowedContentTypes: [.image]) { result in
                switch result {
                case .success(let url):
                    viewModel.handleSelectedImage(at: url)
                case .failure(let err):
                    print("File import failed: \(err)")
                }
            }
        }
    }

}


#Preview {
    ImageClassifierView()
}



