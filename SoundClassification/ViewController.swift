//
//  ViewController.swift
//  SoundClassification
//
//  Created by Shailesh Patel on 30/12/2020.
//

import UIKit
import AVFoundation
import SoundAnalysis

class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var recordButton: ThreeButtonState!
    
    private var recordingLength: Double = 10.0
    private var classification: Animal?
    private var recording: Bool = false
    
    /*
    private lazy var audioRecorder: AVAudioRecorder? = {
        return initialiseAudioRecorder()
    }()
    */
    private var audioRecorder: AVAudioRecorder?
    
    private lazy var recordedAudioFilename: URL = {
        //let directory = FileManager.default.temporaryDirectory
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        var fileName: URL = directory.appendingPathComponent("recording.m4a")
        //return directory.appendingPathComponent("recording.m4a")
        print(fileName)
        return fileName
    }()
    
    // The following line won't work as you can't catch exceptions
    //private let classifier = AudioClassifier(model: SoundClassifier1(configuration: MLModelConfiguration()).model)
    private let classifier = AudioClassifier()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        progressBar.isHidden = true
        progressBar.progress = 0

        collectionView.dataSource = self
    }

    private func refresh(clear: Bool = false) {
        if clear { classification = nil }
        collectionView.reloadData()
    }
    
    @IBAction func recordButtonPressed(_ sender: Any) {
        if recording {
            finishRecording()
        } else {
            recordAudio()
        }
    }
    
    private func recordAudio() {
        // Initialise the AudioRecorder object
        //guard let audioRecorder = audioRecorder else { return }
        audioRecorder = initialiseAudioRecorder()
        
        refresh(clear: true)
        
        //classification = nil
        //collectionView.reloadData()
        
        recordButton.changeState(to: .inProgress(title: "Recording/Stop...", color: .systemRed))
        progressBar.isHidden = false
        
        recording = true
        //audioRecorder?.record(forDuration: TimeInterval(recordingLength))
        audioRecorder?.record()
        UIView.animate(withDuration: recordingLength) {
            self.progressBar.setProgress(Float(self.recordingLength), animated: true)
        }
    }
    
    private func finishRecording(success: Bool = true) {
        progressBar.isHidden = true
        progressBar.progress = 0
        recording = false
        
        //if success, let audioFile = try? AVAudioFile(forReading: recordedAudioFilename) {
        if success {
            audioRecorder?.stop()
            recordButton.changeState(to: .disabled(title: "Record Sound", color: .systemGray))
            classifySound(file: recordedAudioFilename)
        } else {
            // summonAlertView()
            classify(nil)
        }
    }
    
    private func classify(_ animal: Animal?) {
        classification = animal
        recordButton.changeState(to: .enabled(title: "Record Sound", color: .systemBlue))
        //collectionView.reloadData()
        refresh()
        
        if classification == nil {
            summonAlertView()
        }
    }
    
    private func classifySound(file: URL) {
        //classify(Animal.allCases.randomElement()!)
        classifier?.classify(audioFile: file)
        {
            result in self.classify(Animal(rawValue: result ?? ""))
            //(result)->() in self.classify(Animal(rawValue: result ?? ""))
        }
    }
}

extension ViewController {
    private func summonAlertView(message: String? = nil) {
        let alertController = UIAlertController(title: "Error", message: message ?? "Action could not be completed", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        
        present(alertController, animated: true)
    }
}

extension ViewController: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        print("audioRecorderDidFinishingRecording")
        //finishRecording(success: flag)
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        print("Error during recording")
    }
    
    private func initialiseAudioRecorder() -> AVAudioRecorder? {
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        var recorder: AVAudioRecorder?
        
        do {
            recorder = try AVAudioRecorder(url: recordedAudioFilename, settings: settings)
            recorder?.delegate = self
            //implicitly called by .record() so not really required here
            recorder?.prepareToRecord()
        } catch {
            print(error)
            //finishRecording(success: false)
        }
        
        return recorder
    }
}

/*
extension ViewController {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        finishRecording(success: flag)
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        print("Error during recording")
    }
    
    private func initialiseAudioRecorder() -> AVAudioRecorder? {
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        var recorder: AVAudioRecorder?
        
        do {
            recorder = try AVAudioRecorder(url: recordedAudioFilename, settings: settings)
        } catch {
            print(error)
        }
        
        recorder?.delegate = self
        return recorder
    }
}
 */

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Animal.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AnimalCell.identifier, for: indexPath) as? AnimalCell else { return UICollectionViewCell() }
        
        let animal = Animal.allCases[indexPath.item]
        
        cell.textLabel.text = animal.icon
        cell.backgroundColor = (animal == self.classification) ? animal.color : .systemGray
        
        return cell
    }
}

class ThreeButtonState: UIButton {
    enum ButtonState {
        case enabled(title: String, color: UIColor)
        case inProgress(title: String, color: UIColor)
        case disabled(title: String, color: UIColor)
    }
    
    func changeState(to state: ThreeButtonState.ButtonState) {
        switch state {
        case .enabled(let title, let color):
            self.setTitle(title, for: .normal)
            self.backgroundColor = color
            self.isEnabled = true
        case .inProgress(let title, let color):
            self.setTitle(title, for: .normal)
            self.backgroundColor = color
            self.isEnabled = true
        case .disabled(let title, let color):
            self.setTitle(title, for: .disabled)
            self.backgroundColor = color
            self.isEnabled = false
        }
    }
}

class AnimalCell: UICollectionViewCell {
    static let identifier = "AnimalCollectionViewCell"
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var textLabel: UILabel!
}
