import Foundation
import AVFoundation
import Combine

class AudioManager: NSObject, ObservableObject, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    @Published var isRecording = false
    @Published var recordedFiles: [String] = []
    
    private var audioRecorder :AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    
    private var recordingsURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    private func startRecording() {
        let session = AVAudioSession.sharedInstance()
        
        session.requestRecordPermission { granted in
            DispatchQueue.main.async {
                if granted {
                    self.beginRecording()
                } else {
                    print("Microphone access denied.")
                }
            }
        }
    }
    
    private func beginRecording() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            let filename = "recording_\(Int(Date().timeIntervalSinceNow)).m4a"
            let fileUrl = recordingsURL.appendingPathComponent(filename)
            
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            audioRecorder = try AVAudioRecorder(url: fileUrl, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
            isRecording = true
            print(recordedFiles)
        } catch {
            print("Failed to start recording \(error)")
        }
    }
    
    private func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
        refreshFiles()
    }
    
    func refreshFiles() {
        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: recordingsURL.path)
            recordedFiles = files.filter { $0.hasSuffix(".m4a") }
        } catch {
            print("Error reading fules: \(error)")
        }
    }
    
    func play(filename: String) {
        let docsUrl = recordingsURL.appendingPathComponent(filename)
        var url = docsUrl
        
        if !FileManager.default.fileExists(atPath: docsUrl.path),
           let bundleURL = Bundle.main.url(forResource: filename.replacingOccurrences(of: ".m4a", with: ""), withExtension: ".m4a") {
            url = bundleURL
        }
        
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .default)
            try session.overrideOutputAudioPort(.speaker)
            try session.setActive(true)
            
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.play()
            print("Playing \(filename)")
        } catch {
            print("Failed to play: \(error)")
        }
    }
    
    func delete(filename: String) {
        let url = recordingsURL.appendingPathComponent(filename)
        do {
            try FileManager.default.removeItem(at: url)
            print("Deleted file: \(filename)")
            refreshFiles()
        } catch {
            print("Failed to delete file \(error)")
        }
    }
}
