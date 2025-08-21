import SwiftUI
import Apollo
import STARSAPI

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                to: nil, from: nil, for: nil)
    }
}
#endif

struct UploadCoverTestView: View {
    @State private var selectedImage: UIImage? = nil
    @State private var projectID: String = ""
    @State private var isUploading = false
    @State private var resultMessage: String = ""
    @State private var showImagePicker = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                
                // Image preview
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .cornerRadius(10)
                } else {
                    Button("Select Image") {
                        showImagePicker = true
                    }
                }
                
                // Project ID input
                TextField("Enter Project ID", text: $projectID)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                    .submitLabel(.done)
                    .onSubmit {
                        hideKeyboard()
                    }
                    .padding(.horizontal)
                
                // Upload button
                Button(action: uploadCover) {
                    if isUploading {
                        ProgressView()
                    } else {
                        Text("Upload Cover")
                            .bold()
                    }
                }
                .disabled(selectedImage == nil || projectID.isEmpty || isUploading)
                
                // Result message
                if !resultMessage.isEmpty {
                    Text(resultMessage)
                        .foregroundColor(.blue)
                        .multilineTextAlignment(.center)
                        .padding()
                }
                
                Spacer()
            }
            .navigationTitle("Add Cover Test")
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $selectedImage)
            }
            .padding()
        }
    }
    
    func uploadCover() {
        guard let image = selectedImage else { return }
        guard let projectIDInt = Int(projectID) else {
            resultMessage = "Invalid project ID"
            return
        }
        
        isUploading = true
        resultMessage = ""
        
        // Convert UIImage to base64
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            resultMessage = "Failed to convert image"
            isUploading = false
            return
        }
        let base64String = imageData.base64EncodedString()
        
      
        let input = STARSAPI.CoverDataInput(imageFile: base64String)
        
        Network.shared.apollo.perform(mutation: STARSAPI.AddCoverToProjectMutation(projectId: "\(projectIDInt)", data: input)) { result in
            isUploading = false
            switch result {
            case .success(let graphQLResult):
                if let cover = graphQLResult.data?.addCoverToProject {
                    resultMessage = "Upload successful! Cover ID: \(cover.id)\nColors: \(cover.primaryColor), \(cover.secondaryColor)"
                } else if let errors = graphQLResult.errors {
                    resultMessage = "GraphQL error: \(errors.map { $0.message ?? "no error bitch" }.joined(separator: ", "))"
                }
            case .failure(let error):
                resultMessage = "Network error: \(error.localizedDescription)"
            }
        }
    }
}

// Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            picker.dismiss(animated: true)
        }
    }
}

#Preview {
    UploadCoverTestView()
}
