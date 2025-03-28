// SoundManager.swift
import AVFoundation


class SoundManager: ObservableObject {
    @MainActor static let shared = SoundManager()
    
    @Published var isSoundEnabled: Bool = true {
        didSet {
            UserDefaults.standard.set(isSoundEnabled, forKey: "isSoundEnabled")
        }
    }
    
    @Published var volume: Float = 1.0 {
        didSet {
            UserDefaults.standard.set(volume, forKey: "soundVolume")
        }
    }
    
    private var audioPlayers: [Sound: AVAudioPlayer] = [:]
    
    private init() {
        // Set default to true if no value is stored
        isSoundEnabled = UserDefaults.standard.bool(forKey: "isSoundEnabled")
        
        // Ensure volume is not 0
        volume = UserDefaults.standard.float(forKey: "soundVolume")
        if volume == 0 {
            volume = 1.0
        }
        
        // Print status for debugging
        print("Sound Enabled: \(isSoundEnabled), Volume: \(volume)")
    }
    //    func playRippleSound() {
    //        guard isEnabled else { return }
    //
    //        // Randomize between sounds for variety
    //        let soundName = Bool.random() ? "waterDrop" : "ripple"
    //
    //        guard let url = Bundle.main.url(forResource: soundName, withExtension: "mp3"),
    //              let player = audioPlayers[url] else { return }
    //
    //        // Randomize volume and pitch slightly for natural feel
    //        player.volume = Float.random(in: 0.1...0.3) // Keep volume subtle
    //        player.rate = Float.random(in: 0.9...1.1)   // Slight pitch variation
    //
    //        // Create new player instance for overlapping sounds
    //        do {
    //            let newPlayer = try AVAudioPlayer(contentsOf: url)
    //            newPlayer.volume = player.volume
    //            newPlayer.rate = player.rate
    //            newPlayer.play()
    //
    //            // Clean up after playing
    //            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
    //                newPlayer.stop()
    //            }
    //        } catch {
    //            print("Failed to play ripple sound")
    //        }
    //    }
    private func prepareSound(_ sound: Sound) {
        guard let url = Bundle.main.url(forResource: sound.rawValue, withExtension: "mp3") else {
            print("Failed to find sound file: \(sound.rawValue)")
            return
        }
        
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            audioPlayers[sound] = player
        } catch {
            print("Failed to prepare sound \(sound.rawValue): \(error)")
        }
    }
    
    func playRippleSound() {
        guard isSoundEnabled else { return }
        
        // Randomize between sounds for variety
        let soundName: Sound = Bool.random() ? .waterDrop : .buttonTap // Use Sound enum
        
        // Prepare the sound if not already prepared
        prepareSound(soundName)
        
        // Access the player using the Sound enum
        guard let player = audioPlayers[soundName] else { return }
        
        // Randomize volume and pitch slightly for natural feel
        player.volume = Float.random(in: 0.1...0.3) // Keep volume subtle
        player.rate = Float.random(in: 0.9...1.1)   // Slight pitch variation
        
        // Create new player instance for overlapping sounds
        do {
            let newPlayer = try AVAudioPlayer(contentsOf: Bundle.main.url(forResource: soundName.rawValue, withExtension: "mp3")!)
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
    
    func playSound(_ sound: Sound) {
        // Add debug prints
        print("Attempting to play sound: \(sound.rawValue)")
        print("Sound enabled: \(isSoundEnabled)")
        
        guard isSoundEnabled else {
            print("Sound is disabled")
            return
        }
        
        if let player = audioPlayers[sound] {
            player.currentTime = 0
            player.volume = volume
            print("Playing sound with volume: \(volume)")
            player.play()
        } else {
            print("Player not found for sound: \(sound.rawValue)")
            // Try to prepare and play if not already loaded
            prepareSound(sound)
            audioPlayers[sound]?.play()
        }
    }
}
