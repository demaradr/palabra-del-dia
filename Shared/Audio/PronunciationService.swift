//
//  PronunciationService.swift
//  PalabraDD
//
//  Created by Developer on 11/1/25.
//

import AVFoundation

final class PronunciationService: NSObject, AVSpeechSynthesizerDelegate {
    static let shared = PronunciationService()

    private let synthesizer = AVSpeechSynthesizer()
    private var isSpeaking: Bool = false

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    func speak(_ text: String, localeIdentifier: String = "es-ES") {
        if isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: localeIdentifier)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate

        isSpeaking = true
        synthesizer.speak(utterance)
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        isSpeaking = false
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        isSpeaking = false
    }
}
