import AVFoundation
import SwiftUI

class SoundManager {
    static let shared = SoundManager()
    private var audioPlayers: [URL: AVAudioPlayer] = [:]
    private var isEnabled: Bool = true
    
    private init() {
        // Pre-load sounds
        preloadSound("waterDrop")
        preloadSound("ripple")
    }
    
    private func preloadSound(_ name: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") else {
            print("Failed to find sound file: \(name)")
            return
        }
        
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            audioPlayers[url] = player
        } catch {
            print("Failed to create audio player for: \(name)")
        }
    }
    
    func playRippleSound() {
        guard isEnabled else { return }
        
        // Randomize between sounds for variety
        let soundName = Bool.random() ? "waterDrop" : "ripple"
        
        guard let url = Bundle.main.url(forResource: soundName, withExtension: "mp3"),
              let player = audioPlayers[url] else { return }
        
        // Randomize volume and pitch slightly for natural feel
        player.volume = Float.random(in: 0.1...0.3) // Keep volume subtle
        player.rate = Float.random(in: 0.9...1.1)   // Slight pitch variation
        
        // Create new player instance for overlapping sounds
        do {
            let newPlayer = try AVAudioPlayer(contentsOf: url)
            newPlayer.volume = player.volume
            newPlayer.rate = player.rate
            newPlayer.play()
            
            // Clean up after playing
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                newPlayer.stop()
            }
        } catch {
            print("Failed to play ripple sound")
        }
    }
    
    func toggleSound() {
        isEnabled.toggle()
    }
    
    func setEnabled(_ enabled: Bool) {
        isEnabled = enabled
    }
}