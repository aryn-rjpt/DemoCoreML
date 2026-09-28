
import SwiftUI

struct FindDepthView: View {
    @State var image: UIImage = .dog
    
    @State var viewModel = FindDepthViewModel()
    
    var body: some View {
        GeometryReader { geometryProxy in
            VStack {
                VideoPreviewView(session: viewModel.captureSession)
//                    .frame(height: geometryProxy.size.height/2 )
                .onAppear {
                    Task.detached(priority: .background) {
                        await viewModel.initCamera()
                    }
                }
                if let img = viewModel.outputImage {
                    Image(decorative: img, scale: 1)
                }
            }
        }
    }
    
}

