//
//  QuicktranslateViewController.swift
//  VoiceCrafter Wave
//
//  Created by UCF 2 on 23/01/2025.
//

import UIKit
import AVFoundation
import Speech

class QuicktranslateViewController: UIViewController,UITextViewDelegate,UIGestureRecognizerDelegate, UITextFieldDelegate, AVSpeechSynthesizerDelegate {
    var translationhistory = [TranslationHistory]()
    
    @IBOutlet weak var translatebtn: UIButton!
    @IBOutlet weak var fromCountryTF: DropDown!
    @IBOutlet weak var ToCountryTF: DropDown!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var FromTView: UITextView!
    @IBOutlet weak var ToTextView: UITextView!
    @IBOutlet weak var FromCountryLb: UILabel!
    @IBOutlet weak var ToCountryLb: UILabel!
    @IBOutlet weak var fromSpeakButton: UIButton!
    @IBOutlet weak var toSpeakButton: UIButton!
    
    
    var isSpeakingFrom = false
    var isSpeakingTo = false
    
    var fromCountryCode = String()
    var ToCountryCode = String()
    let placeholderText = "Enter text to translate..."
    var speechSynthesizer = AVSpeechSynthesizer()
    
    
    var fromCountryName = String()
    var ToCountryName = String()
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.isHidden = true
        fromCountryTF.isSearchEnable = false
        ToCountryTF.isSearchEnable = false
        
        fromCountryTF.delegate = self
        ToCountryTF.delegate = self
        // Create an array of formatted strings with country name and flag
        let countryNamesAndFlags = countries.map { "\($0.flag) \($0.name)" }
        fromCountryTF.optionArray = countryNamesAndFlags
        ToCountryTF.optionArray = countryNamesAndFlags
        
        fromCountryTF.didSelect { [weak self] (selectedText, index, id) in
            guard let self = self else { return }
            let selectedCountryCode = self.countries[index].code
            let name = self.countries[index].name
            self.fromCountryCode = selectedCountryCode
            self.FromCountryLb.text = "(\(name))"
            fromCountryName = self.countries[index].name
            print("Selected from Country Code: \(selectedCountryCode)")
        }
        
        ToCountryTF.didSelect { [weak self] (selectedText, index, id) in
            guard let self = self else { return }
            let selectedCountryCode = self.countries[index].code
            self.ToCountryCode = selectedCountryCode
            let name = self.countries[index].name
            ToCountryName = self.countries[index].name
            self.ToCountryLb.text = "(\(name))"
            print("Selected to Country Code: \(selectedCountryCode)")
        }
        
        FromTView.delegate = self
        FromTView.text = placeholderText
        FromTView.textColor = UIColor.black
        
        let placeholder = "Select Country"
        fromCountryTF.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.black]
        )
        
        ToCountryTF.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.black]
        )
        
        speechSynthesizer.delegate = self
        translationhistory = fetchTranslationHistory()
        
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
        FromTView.resignFirstResponder()
        ToTextView.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    /**
     * Called when the user click on the view (outside the UITextField).
     */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    @IBAction func btnclearinputtext(_ sender: Any) {
        FromTView.text = ""  // Clear the input text view
        FromTView.textColor = UIColor.lightGray
        FromTView.text = placeholderText
    }
    
    @IBAction func btnclearoutputtext(_ sender: Any) {
        ToTextView.text = ""  // Clear the input text view
        ToTextView.textColor = UIColor.lightGray  // Reset the placeholder color
        ToTextView.text = placeholderText
    }
    
    @IBAction func translatebtnPressed(_ sender: UIButton) {
        let fromText = FromTView.text
        if (fromText?.isEmpty) ?? false || fromText == placeholderText {
            showAlert(title: "Error!", message: "Please Enter text to translate")
            return
        }
        
        if !fromCountryCode.isEmpty && !ToCountryCode.isEmpty {
            activityIndicator.startAnimating()
            activityIndicator.isHidden = false
            SwiftyTranslate.translate(text: fromText ?? "", from: fromCountryCode, to: ToCountryCode) { result in
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                    switch result {
                    case .success(let translation):
                        print("Translated: \(translation.translated)")
                        self.ToTextView.text = translation.translated
                        
                        // Save the translation to history
                        self.saveTranslationHistory(
                            inputText: fromText ?? "",
                            outputText: translation.translated,
                            inputLanguage: self.fromCountryName,
                            outputLanguage: self.ToCountryName
                        )
                        
                    case .failure(let error):
                        print("Error: \(error)")
                        self.showAlert(title: "Error!", message: "Translation failed. Please try again.")
                    }
                }
            }
        } else {
            showAlert(title: "Error!", message: "Please Select the Country First")
        }
    }
    
    
    func saveTranslationHistory(inputText: String, outputText: String, inputLanguage: String, outputLanguage: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let currentDate = dateFormatter.string(from: Date())
        
        let newHistory = TranslationHistory(
            date: currentDate,
            inputLanguage: inputLanguage,
            outputLanguage: outputLanguage,
            inputText: inputText,
            outputText: outputText
        )
        
        // Append and save
        translationhistory.append(newHistory)
        print("Translation history count: \(translationhistory.count)") // Debug print
        
        if let encodedData = try? JSONEncoder().encode(translationhistory) {
            UserDefaults.standard.set(encodedData, forKey: "TranslationHistory")
            print("Saved history to UserDefaults.") // Debug print
        } else {
            print("Failed to encode translation history.") // Debug print
        }
    }
    
    
    func fetchTranslationHistory() -> [TranslationHistory] {
        if let data = UserDefaults.standard.data(forKey: "TranslationHistory"),
           let savedHistory = try? JSONDecoder().decode([TranslationHistory].self, from: data) {
            return savedHistory
        }
        return []
    }
    
    
    @IBAction func backbtnPressed(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    
    @IBAction func FromcopybtnPressed(_ sender: UIButton) {
        UIPasteboard.general.string = FromTView.text
        self.showToast(message: "Text Copied", font: .systemFont(ofSize: 14.0))
    }
    
    @IBAction func TocopybtnPressed(_ sender: UIButton) {
        UIPasteboard.general.string = ToTextView.text
        self.showToast(message: "Text Copied", font: .systemFont(ofSize: 14.0))
    }
    
    @IBAction func FromspeakbtnPressed(_ sender: UIButton) {
        if isSpeakingFrom {
            speechSynthesizer.stopSpeaking(at: .immediate) // Stop the speech if it's ongoing
            isSpeakingFrom = false
        } else {
            speak(text: FromTView.text, languageCode: fromCountryCode)
            isSpeakingFrom = true
        }
    }
    
    @IBAction func TospeakbtnPressed(_ sender: UIButton) {
        if isSpeakingTo {
            speechSynthesizer.stopSpeaking(at: .immediate) // Stop the speech if it's ongoing
            isSpeakingTo = false
        } else {
            speak(text: ToTextView.text, languageCode: ToCountryCode)
            isSpeakingTo = true
        }
    }
    
    func speak(text: String, languageCode: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: languageCode)
        
        // Check if a female voice is available for the language
        if let availableVoice = AVSpeechSynthesisVoice(language: languageCode) {
            utterance.voice = availableVoice
        } else {
            // If not, use a default female voice
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US") // You can change this to your desired language code
        }
        
        speechSynthesizer.speak(utterance)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        FromTView.textColor = .black
        if textView.text == placeholderText {
            textView.text = ""
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeholderText
            textView.textColor = UIColor.lightGray
        }
    }
}


extension UIViewController {
    
    func showToast(message : String, font: UIFont) {
        
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-500, width: 180, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.black
        toastLabel.backgroundColor = .systemGreen
        toastLabel.font = font
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}
