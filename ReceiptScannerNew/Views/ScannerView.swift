import SwiftUI

struct NoteDetailView: View {
    @EnvironmentObject var imageData: ImageData
    @State var note: ImageNote
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                // Image display
                if let uiImage = UIImage(data: note.image) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(10)
                        .padding()
                        .shadow(radius: 5)
                } else {
                    Image(systemName: "photo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(10)
                        .padding()
                }

                // Potential Lawsuits section
                if let companyName = note.companyName {
                    Text("Potential Lawsuits")
                        .font(.headline)
                        .padding(.horizontal)
                    VStack(alignment: .leading) {
                        Text(companyName)
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)

                        Text("Description: " + (note.caseDescription ?? "No description available"))
                            .font(.subheadline) // Smaller font size and not bolded
                            .padding(.horizontal)
                            .padding(.bottom, 5)
                    }

                }

                // Title editing field
                TextField("Edit me!", text: $note.title)
                    .padding()
                    .background(Color.secondary.opacity(0.2))
                    .cornerRadius(10)
                    .padding(.horizontal)

                // Description editing field
                TextEditor(text: $note.description)
                    .frame(height: 200)
                    .padding()
                    .background(Color.secondary.opacity(0.2))
                    .cornerRadius(10)
                    .padding(.horizontal)

                // Confirm changes button
                Button("Confirm changes") {
                    imageData.editNote(id: note.id, title: note.title, description: note.description)
                    presentationMode.wrappedValue.dismiss()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(Color.white)
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.bottom, 10)
            }
        }
    }
}

struct NoteDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let tempImage = UIImage(systemName: "photo")?.pngData() ?? Data()
        let tempNote = ImageNote(image: tempImage, title: "Sample Title", description: "Sample Description", companyName: "Acme Corp")

        NoteDetailView(note: tempNote)
            .environmentObject(ImageData())
    }
}
