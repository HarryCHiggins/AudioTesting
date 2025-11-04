import SwiftUI

struct ContentView: View {
    @StateObject private var audioManager = AudioManager()
    @State private var selectedFile: String = ""
    
    
    var body: some View {
        VStack(spacing: 20) {
            Button(action: {
                audioManager.toggleRecording()
            }) {
                Text(audioManager.isRecording ? "Stop Recording" : "Start Recording")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(audioManager.isRecording ? Color.red : Color.green)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }
            
            Picker("Select Audio", selection: $selectedFile) {
                if audioManager.recordedFiles.isEmpty {
                    Text("No recordings").tag("")
                } else {
                    ForEach(audioManager.recordedFiles, id: \.self) { file in
                        Text(file).tag(file)
                    }
                }
            }
            .pickerStyle(.menu)
            .onChange(of: audioManager.recordedFiles) { newFiles in
                if newFiles.isEmpty {
                    selectedFile = ""
                } else if !newFiles.contains(selectedFile) {
                    selectedFile = newFiles.first ?? ""
                }
            }
            
            Button("Play Selected") {
                audioManager.play(filename: selectedFile)
            }
            .disabled(selectedFile.isEmpty)
            .frame(maxWidth: .infinity)
            .padding()
            .background(selectedFile.isEmpty ? Color.gray : Color.blue)
            .foregroundColor(.white)
            .clipShape(Capsule())
            
            Button("Delete Selected") {
                audioManager.delete(filename: selectedFile)
            }
            .disabled(selectedFile.isEmpty)
            .frame(maxWidth: .infinity)
            .padding()
            .background(selectedFile.isEmpty ? Color.gray : Color.red)
            .foregroundColor(.white)
            .clipShape(Capsule())
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
