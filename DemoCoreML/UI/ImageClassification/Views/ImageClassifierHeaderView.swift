import SwiftUI

struct ImageClassifierHeaderView: View {
    
    @Binding var isProcessing: Bool
    
    var body: some View {
        // Header Section
        VStack(spacing: 8) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 48))
                .foregroundStyle(.tint)
                .symbolEffect(.bounce, value: isProcessing)
            
            Text("CoreML Image Classifier")
                .font(.title2.bold())
            
            Text("Powered by FastViT Model")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 12)
    }
}
