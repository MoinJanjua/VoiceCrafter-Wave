//
//  VoiceCaptureViewController.swift
//  VoiceCrafter Wave
//
//  Created by UCF 2 on 23/01/2025.
//

import UIKit
import AVFAudio
import Speech
import Foundation

class VoiceCaptureViewController: UIViewController , UITextFieldDelegate, UIGestureRecognizerDelegate, AVSpeechSynthesizerDelegate {
    
    @IBOutlet weak var Micbtn: UIButton!
    @IBOutlet weak var ToTV: UITextView!
    @IBOutlet weak var ToCountryTF: DropDown!  // Dropdown for the target language
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var ToCountryCode = String()
    var FromLanguageCode = String()  // Store the selected language for voice recording
    
    var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask: SFSpeechRecognitionTask?
    let audioEngine = AVAudioEngine()
    var speechSynthesizer = AVSpeechSynthesizer()
    
    let countries: [Country] = [
        Country(name: "United States", flag: "🇺🇸", code: "en"),
        Country(name: "Spain", flag: "🇪🇸", code: "es"),
        Country(name: "France", flag: "🇫🇷", code: "fr"),
        Country(name: "Germany", flag: "🇩🇪", code: "de"),
        Country(name: "Italy", flag: "🇮🇹", code: "it"),
        Country(name: "Japan", flag: "🇯🇵", code: "ja"),
        Country(name: "China", flag: "🇨🇳", code: "zh"),
        Country(name: "Russia", flag: "🇷🇺", code: "ru"),
        Country(name: "India", flag: "🇮🇳", code: "hi"),
        Country(name: "Brazil", flag: "🇧🇷", code: "pt"),
        Country(name: "Canada", flag: "🇨🇦", code: "en"),
        Country(name: "Mexico", flag: "🇲🇽", code: "es"),
        Country(name: "South Korea", flag: "🇰🇷", code: "ko"),
        Country(name: "Turkey", flag: "🇹🇷", code: "tr"),
        Country(name: "Saudi Arabia", flag: "🇸🇦", code: "ar"),
        Country(name: "Sweden", flag: "🇸🇪", code: "sv"),
        Country(name: "Norway", flag: "🇳🇴", code: "no"),
        Country(name: "Denmark", flag: "🇩🇰", code: "da"),
        Country(name: "Finland", flag: "🇫🇮", code: "fi"),
        Country(name: "Netherlands", flag: "🇳🇱", code: "nl"),
        Country(name: "Switzerland", flag: "🇨🇭", code: "de"),
        Country(name: "Australia", flag: "🇦🇺", code: "en"),
        Country(name: "New Zealand", flag: "🇳🇿", code: "en"),
        Country(name: "South Africa", flag: "🇿🇦", code: "af"),
        Country(name: "Argentina", flag: "🇦🇷", code: "es")
    ]
    
    var recordedText = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupSpeech()
        activityIndicator.isHidden = true
        ToCountryTF.isSearchEnable = false
        speechSynthesizer.delegate = self
        
        // Set up FromLanguage dropdown with language options for recording
        let languageOptions = [
            "English (US)": "en-US",
            "Spanish": "es-ES",
            "French": "fr-FR",
            "German": "de-DE",
            "Italian": "it-IT",
            "Japanese": "ja-JP",
            "Chinese": "zh-CN",
            "Russian": "ru-RU",
            "Hindi": "hi-IN"
            // Add more languages as needed
        ]
        
//        FromLanguageTF.optionArray = Array(languageOptions.keys)
//        
//        FromLanguageTF.didSelect { [weak self] (selectedText, index, id) in
//            guard let self = self else { return }
//            let selectedLanguageCode = languageOptions[selectedText] ?? "en-US"
//            self.FromLanguageCode = selectedLanguageCode
//            self.speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: selectedLanguageCode))
//            self.FromLanguageTF.text = selectedText
//            print("Selected language code for recording: \(selectedLanguageCode)")
//        }
        
        // Set up ToCountry dropdown for translation
        let countryNamesAndFlags = countries.map { "\($0.flag) \($0.name)" }
        ToCountryTF.optionArray = countryNamesAndFlags
        
        ToCountryTF.didSelect { [weak self] (selectedText, index, id) in
            guard let self = self else { return }
            let selectedCountryCode = self.countries[index].code
            self.ToCountryCode = selectedCountryCode
            let name = self.countries[index].name
            self.ToCountryTF.text = "(\(name))"
            print("Selected to Country Code: \(selectedCountryCode)")
        }
        
        ToCountryTF.delegate = self
        
        ToTV.text = "Say something, I'm listening!"
        ToTV.textColor = .lightGray
        
        let placeholder = "Select Country"
//        FromLanguageTF.attributedPlaceholder = NSAttributedString(
//            string: placeholder,
//            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white]
//        )
        
        ToCountryTF.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white]
        )
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
        ToTV.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func setupSpeech() {
        self.Micbtn.isEnabled = false
        self.speechRecognizer?.delegate = self
        
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            var isButtonEnabled = false
            
            switch authStatus {
            case .authorized:
                isButtonEnabled = true
            case .denied:
                isButtonEnabled = false
                print("User denied access to speech recognition")
            case .restricted:
                isButtonEnabled = false
                print("Speech recognition restricted on this device")
            case .notDetermined:
                isButtonEnabled = false
                print("Speech recognition not yet authorized")
            }
            
            OperationQueue.main.addOperation() {
                self.Micbtn.isEnabled = isButtonEnabled
            }
        }
    }
    
    func startRecording() {
        // Clear previous session and cancel task
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        // Create instance of audio session for recording
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.record, mode: AVAudioSession.Mode.measurement, options: AVAudioSession.CategoryOptions.defaultToSpeaker)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        let inputNode = audioEngine.inputNode
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            var isFinal = false
            if result != nil {
                self.recordedText = result?.bestTranscription.formattedString ?? ""
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.Micbtn.isEnabled = true
                self.removePulsingAnimation(from: self.Micbtn) // Stop animation
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        self.audioEngine.prepare()
        
        do {
            try self.audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
        
        addPulsingAnimation(to: Micbtn) // Start animation
    }

    @IBAction func Micbtn(_ sender: UIButton) {
        // Check if FromLanguageTF dropdown is selected
//        if FromLanguageTF.text?.isEmpty ?? true {
//            displayshowAlert(title: "Error", message: "Please select a language for recording.")
//            return
//        }

        if audioEngine.isRunning {
            self.audioEngine.stop()
            self.recognitionRequest?.endAudio()
            self.Micbtn.isEnabled = false
            removePulsingAnimation(from: Micbtn) // Stop animation
        } else {
            self.startRecording()
        }
    }

    
    
    func addPulsingAnimation(to button: UIButton) {
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        pulse.duration = 0.8
        pulse.fromValue = 1.0
        pulse.toValue = 1.1
        pulse.autoreverses = true
        pulse.repeatCount = .greatestFiniteMagnitude
        pulse.initialVelocity = 0.5
        pulse.damping = 1.0
        button.layer.add(pulse, forKey: "pulsing")
    }

    func removePulsingAnimation(from button: UIButton) {
        button.layer.removeAnimation(forKey: "pulsing")
    }
    
    func speak(text: String, languageCode: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: languageCode)
        speechSynthesizer.speak(utterance)
    }
    


    @IBAction func translatebtn(_ sender: UIButton) {
        
        if ToCountryTF.text?.isEmpty ?? true {
            displayshowAlert(title: "Error", message: "Please select a target language for translation.")
            return
        }

        let fromText = recordedText
        if fromText.isEmpty {
            displayshowAlert(title: "Error!", message: "Please record speech to translate.")
            return
        }
        
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
        SwiftyTranslate.translate(text: fromText, from: FromLanguageCode, to: ToCountryCode) { result in
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
                switch result {
                case .success(let translation):
                    print("Translated: \(translation.translated)")
                    self.ToTV.text = translation.translated
                case .failure(let error):
                    print("Error: \(error)")
                    self.showAlert(title: "Error!", message: "Translation failed. Please try again.")
                }
            }
        }
    }

    func displayshowAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alertController, animated: true)
    }
    @IBAction func Backbtn(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func TospeakbtnPressed(_ sender: UIButton) {
        speak(text: ToTV.text, languageCode: ToCountryCode)
    }

    @IBAction func TocopybtnPressed(_ sender: UIButton) {
        UIPasteboard.general.string = ToTV.text
        self.showToast(message: "Text Copied", font: .systemFont(ofSize: 14.0))
    }
    
    @IBAction func removebtnPressed(_ sender: UIButton) {
        ToTV.text.removeAll()
    }
}

extension VoiceCaptureViewController: SFSpeechRecognizerDelegate {

    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            self.Micbtn.isEnabled = true
        } else {
            self.Micbtn.isEnabled = false
        }
    }
}


