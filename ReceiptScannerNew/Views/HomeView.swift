import SwiftUI  // Import SwiftUI

struct HomeView: View {
    @EnvironmentObject var imageData: ImageData

    var body: some View {
        List {
            ForEach(imageData.imageNotes) { note in
                NavigationLink(destination: NoteDetailView(note: note)) {
                    HStack {
                        // Safely unwrap the UIImage
                        if let uiImage = UIImage(data: note.image) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .frame(width: 50, height: 50)
                        } else {
                            // Provide a default image or view in case of nil
                            Image(systemName: "photo")
                                .resizable()
                                .frame(width: 50, height: 50)
                        }

                        VStack(alignment: .leading) {
                            Text(note.title)
                                .lineLimit(2)
                        }
                    }
                }
            }
        }
    }
}
