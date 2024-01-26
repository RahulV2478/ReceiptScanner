import Foundation
import UIKit
import Vision

struct ImageNote: Codable, Hashable, Identifiable {
    var id = UUID()
    var image: Data
    var title: String
    var description: String
    var companyName: String? // Existing field
    var caseDescription: String? // New field for case description
}



@MainActor
class ImageData: ObservableObject {
    private let IMAGES_KEY = "ImagesKey"
    @Published var imageNotes: [ImageNote] = []

    init() {
        loadSavedData()
    }

    private func loadSavedData() {
        if let data = UserDefaults.standard.data(forKey: IMAGES_KEY),
           let decodedNotes = try? JSONDecoder().decode([ImageNote].self, from: data) {
            imageNotes = decodedNotes
        }
    }

    func performOCR(on image: UIImage, completion: @escaping (String) -> Void) {
        guard let cgImage = image.cgImage else {
            completion("")
            return
        }

        let request = VNRecognizeTextRequest { (request, error) in
            guard error == nil else {
                completion("")
                return
            }

            var extractedText = ""
            if let observations = request.results as? [VNRecognizedTextObservation] {
                for observation in observations {
                    if let topCandidate = observation.topCandidates(1).first {
                        extractedText += topCandidate.string + "\n"
                    }
                }
            }
            DispatchQueue.main.async {
                completion(extractedText)
            }
        }

        request.recognitionLevel = .accurate
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try requestHandler.perform([request])
            } catch {
                DispatchQueue.main.async {
                    completion("")
                }
            }
        }
    }
    
    func searchForMatch(scannedText: String, completion: @escaping (String?) -> Void) {
        guard let url = URL(string: "http://localhost:3000/search") else {
            print("Invalid URL")
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = ["text": scannedText]
        print("Sending text: \(scannedText)")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            print("Error: Unable to encode request body: \(error)")
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                completion(nil)
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  let data = data,
                  httpResponse.statusCode == 200 else {
                print("Error: Invalid response or status code")
                completion(nil)
                return
            }

            do {
                if let result = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let matchFound = result["matchFound"] as? Bool,
                   matchFound {
                    let companyName = result["companyName"] as? String
                    completion(companyName)
                } else {
                    completion(nil)
                }
            } catch {
                print("Error parsing response: \(error)")
                completion(nil)
            }
        }.resume()
    }



    func addNoteWithOCR(image: UIImage) {
        performOCR(on: image) { [weak self] recognizedText in
            guard let self = self else { return }

            self.searchForMatch(scannedText: recognizedText) { companyName in
                DispatchQueue.main.async {
                    // Use a default title or any other logic for the title
                    let title = "Scanned Result"
                    self.addNote(image: image, title: title, desc: recognizedText, companyName: companyName)
                }
            }
        }
    }




    func addNote(image: UIImage, title: String, desc: String, companyName: String?) {
        if let pngRepresentation = image.pngData() {
            let newNote = ImageNote(image: pngRepresentation, title: title, description: desc, companyName: companyName)
            imageNotes.insert(newNote, at: 0)
            saveData()
        }
    }


    func editNote(id: UUID, title: String, description: String) {
        if let index = imageNotes.firstIndex(where: { $0.id == id }) {
            imageNotes[index].title = title
            imageNotes[index].description = description
            saveData()
        }
    }

    func saveData() {
        if let encodedNotes = try? JSONEncoder().encode(imageNotes) {
            UserDefaults.standard.set(encodedNotes, forKey: IMAGES_KEY)
        }
    }

    func resetUserData() {
        UserDefaults.standard.removeObject(forKey: IMAGES_KEY)
        UserDefaults.resetStandardUserDefaults()
        imageNotes = []
    }
}
