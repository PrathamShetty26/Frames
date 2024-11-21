import SwiftUI

struct ContentView: View {
    @State private var currentImageName: String? = nil
    @State private var imageNames: [String] = ["1", "2"]
    @State private var showAddPhotoWindow = false

    var body: some View {
        ZStack {
            if let currentImageName, let image = loadImage(named: currentImageName) {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFit()
                    .onTapGesture { loadImage() }
            } else {
                Text("No Image Selected")
                    .foregroundColor(.white)
                    .font(.headline)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black)
                    .onTapGesture { loadImage() }
            }

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: { showAddPhotoWindow = true }) {
                        Image(systemName: "plus.circle")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(12)
                }
            }
        }
        .background(Color.black)
        .sheet(isPresented: $showAddPhotoWindow) {
            AddPhotoView(imageNames: $imageNames)
        }
        .onAppear { loadImage() }
    }

    func loadImage() {
        guard !imageNames.isEmpty else { currentImageName = nil; return }
        currentImageName = imageNames.randomElement()
    }

    func loadImage(named name: String) -> NSImage? {
        if FileManager.default.fileExists(atPath: localPath(for: name)) {
            return NSImage(contentsOfFile: localPath(for: name))
        } else {
            return NSImage(named: name)
        }
    }

    func localPath(for imageName: String) -> String {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(imageName).path
    }
}

struct AddPhotoView: View {
    @Binding var imageNames: [String]
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            Text("Drag and Drop Your Photos Here")
                .font(.headline)
                .padding()

            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))]) {
                    ForEach(imageNames, id: \.self) { imageName in
                        VStack {
                            if isLocalImage(imageName) {
                                Image(nsImage: NSImage(contentsOfFile: localPath(for: imageName)) ?? NSImage())
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                            } else {
                                Image(imageName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                            }
                            Button("Delete") { deleteImage(imageName) }
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .padding()
            .dropDestination(for: URL.self) { items, _ in
                handleDroppedFiles(items)
                return true
            }

            Button("Done") {
                presentationMode.wrappedValue.dismiss()
            }
            .padding()
        }
        .frame(width: 400, height: 500)
    }

    func handleDroppedFiles(_ files: [URL]) {
        for file in files {
            guard file.isFileURL else { continue }
            let destinationURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                .appendingPathComponent(file.lastPathComponent)
            do {
                if !FileManager.default.fileExists(atPath: destinationURL.path) {
                    try FileManager.default.copyItem(at: file, to: destinationURL)
                }
                imageNames.append(file.lastPathComponent)
            } catch {
                print("Failed to copy file: \(error)")
            }
        }
    }

    func deleteImage(_ imageName: String) {
        if let index = imageNames.firstIndex(of: imageName) {
            imageNames.remove(at: index)
        }
    }

    func isLocalImage(_ imageName: String) -> Bool {
        FileManager.default.fileExists(atPath: localPath(for: imageName))
    }

    func localPath(for imageName: String) -> String {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(imageName).path
    }
}
