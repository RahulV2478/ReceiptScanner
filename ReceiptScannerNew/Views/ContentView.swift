import SwiftUI

struct ContentView: View {
    @State var showImagePicker: Bool = false
    @StateObject var imageData = ImageData()
    
    var body: some View {
        NavigationView {
            VStack {
                if imageData.imageNotes.isEmpty {
                    Text("Try adding a receipt!").italic().foregroundColor(.gray)
                } else {
                    HomeView()
                }
            }
            .navigationTitle("iReceipt")
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(sourceType: .photoLibrary) { image in
                    imageData.addNoteWithOCR(image: image)  // Using OCR function
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showImagePicker.toggle()
                    }) {
                        Label("Add Image", systemImage: "plus")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        withAnimation {
                            imageData.resetUserData()
                        }
                    }) {
                        Label("Trash", systemImage: "trash")
                    }
                }
            }
        }
        .environmentObject(imageData)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
