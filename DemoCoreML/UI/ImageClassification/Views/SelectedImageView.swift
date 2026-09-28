import SwiftUI

struct SelectedImageView: View {
    
    @Binding var viewModel: ImageClassifierViewModel
    
    var body: some View {
        if let selectedImage = viewModel.selectedImage {
            ZStack(alignment: .topTrailing) {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 280)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                    )
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.12), radius: 10, x: 0, y: 4)
                
                Button(role: .destructive) {
                    viewModel.resetSelection()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.white, Color.black.opacity(0.6))
                }
                .padding(12)
            }
            .padding(.horizontal)
        } else {
            Button {
                viewModel.showMediaUpload = true
            } label: {
                VStack(spacing: 12) {
                    Image(systemName: "photo.badge.plus")
                        .font(.system(size: 40))
                        .foregroundStyle(.tint)
                    
                    Text("Tap to upload an image")
                        .font(.callout.weight(.medium))
                        .foregroundStyle(.primary)
                    
                    Text("Supports PNG, JPEG, and common formats")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 200)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.accentColor.opacity(0.4), style: StrokeStyle(lineWidth: 2, dash: [6]))
                )
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.accentColor.opacity(0.05))
                )
            }
            .buttonStyle(.plain)
            .padding(.horizontal)
        }
    }
}
