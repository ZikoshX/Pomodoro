//
//  TimerViewController.swift
//  GroupProject
//
//  Created by Admin on 18.11.2023.
//

import UIKit
import AVFoundation
import UserNotifications
class TimerViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UNUserNotificationCenterDelegate {
    var audioPlayer: AVAudioPlayer?
    var duration: TimeInterval = 0
    var durationtime: UITextField?
    var isTimerRunning = false
    var timer: Timer?
    var secondsRemaining = 15 * 60
    
    let durationPicker: UIPickerView = {
        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints =  false
        return picker
    }()
    
    let durations = [15, 25, 30, 45, 60]
    lazy var segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Pomodoro", "Short Break", "Long Break"])
        control.selectedSegmentIndex = 0
        control.frame = CGRect(x: 100, y: 100, width: 400, height: 400)
        control.translatesAutoresizingMaskIntoConstraints = false
        control.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)
        return control
    }()
    
    let shortBreakDuration = 5 * 60 // 5 minutes
    let longBreakDuration = 10 * 60 // 10 minutes
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.text = "15:00"
        label.font = UIFont.systemFont(ofSize: 40, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    lazy var startButton: UIButton = {
        let button = UIButton()
        button.setTitle("Start", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .blue
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var pauseButton: UIButton = {
        let button = UIButton()
        button.setTitle("Pause", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .blue
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(pauseButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var resetButton: UIButton = {
        let button = UIButton()
        button.setTitle("Reset", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .blue
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        view.addSubview(timeLabel)
        view.addSubview(startButton)
        view.addSubview(pauseButton)
        view.addSubview(resetButton)
        view.addSubview(segmentedControl)
        view.addSubview(durationPicker)
        
        setupUI()
        
        do {
            if let audioPath = Bundle.main.path(forResource: "zvuk-tikajuschego-tajmera", ofType: "mp3") {
                let url = URL(fileURLWithPath: audioPath)
                audioPlayer = try AVAudioPlayer(contentsOf: url)
            }
        } catch {
            print("Error loading audio file")
        }
        
        durationPicker.delegate = self
        durationPicker.dataSource = self
        
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Permission granted")
            } else if let error = error {
                print("Permission denied with error: \(error.localizedDescription)")
            }
        }
      
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
    
    func setupUI() {
        // Set up constraints
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        startButton.translatesAutoresizingMaskIntoConstraints = false
        pauseButton.translatesAutoresizingMaskIntoConstraints = false
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            timeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            timeLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100),
            segmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            segmentedControl.centerYAnchor.constraint(equalTo: timeLabel.topAnchor, constant: -150),
            
            startButton.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant:60),
            startButton.centerXAnchor.constraint(equalTo: view.leftAnchor, constant: 60),
            startButton.widthAnchor.constraint(equalToConstant: 100),
            startButton.heightAnchor.constraint(equalToConstant: 30),
            
            pauseButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            pauseButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pauseButton.widthAnchor.constraint(equalToConstant: 100),
            pauseButton.heightAnchor.constraint(equalToConstant: 30),
            
            resetButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            resetButton.centerXAnchor.constraint(equalTo: view.rightAnchor, constant: -70),
            resetButton.widthAnchor.constraint(equalToConstant: 100),
            resetButton.heightAnchor.constraint(equalToConstant: 30),
            
            durationPicker.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            durationPicker.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 130),
        ])
    }
    
    func playAudio() {
        audioPlayer?.play()
    }
    
    func scheduleNotification(title: String, body: String, timeInterval: TimeInterval, identifier: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            } else {
                print("Notification scheduled: \(identifier)")
            }
        }
    }
    
    
    func cancelNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    
    @objc func startButtonTapped() {
        if timer == nil {
            if let durationText = durationtime?.text,
               let durationValue = Int(durationText),
               durationValue > 0 {
                secondsRemaining = durationValue * 60
                startTimer()
                scheduleNotification(title: "Timer Started", body: "Good luck with your task!", timeInterval: 0.5, identifier: "timerStartedNotification")
                
            } else {
                startTimer()
            }
        }
    }
    
    
    @objc func pauseButtonTapped() {
        pauseTimer()
        scheduleNotification(title: "Timer Paused", body: "Are you tired?", timeInterval: 0.5, identifier: "timerStartedNotification")
        
    }
    
    @objc func resetButtonTapped() {
        resetTimer()
        scheduleNotification(title: "Timer Resetted", body: "Are you want to started again?", timeInterval: 0.5, identifier: "timerStartedNotification")
        
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        startButton.isEnabled = false
        isTimerRunning = true
        scheduleNotification(title: "Timer Started", body: "Good luck with your task!", timeInterval: 1, identifier: "timerStartedNotification")
    }
    
    func pauseTimer() {
        if timer != nil {
            timer?.invalidate()
            timer = nil
            startButton.isEnabled = true
            audioPlayer?.pause()
            cancelNotifications()
            
            
        }
    }
    
    func resetTimer() {
        timer?.invalidate()
        timer = nil
        
        startButton.isEnabled = true
        switch segmentedControl.selectedSegmentIndex {
        case 0: // Pomodoro
            secondsRemaining = durations[durationPicker.selectedRow(inComponent: 0)] * 60
        case 1: // Short Break
            secondsRemaining = shortBreakDuration
        case 2: // Long Break
            secondsRemaining = longBreakDuration
        default:
            break
        }
        
        updateUI()
        cancelNotifications()
    }
    @objc func updateTimer() {
        if secondsRemaining > 0 {
            secondsRemaining -= 1
            updateUI()
        } else {
            resetTimer()
            playEndSound()
        }
    }
    
    func updateUI() {
        let minutes = secondsRemaining / 60
        let seconds = secondsRemaining % 60
        timeLabel.text = String(format: "%02d:%02d", minutes, seconds)
    }
    
    func playEndSound() {
        audioPlayer?.play()
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.startTimer()
        }
    }
    
    @objc func segmentedControlValueChanged() {
        switch segmentedControl.selectedSegmentIndex {
        case 0: // Pomodoro
            durationPicker.isHidden = false
            secondsRemaining = durations[durationPicker.selectedRow(inComponent: 0)] * 60
        case 1, 2: // Short Break or Long Break
            durationPicker.isHidden = true
            secondsRemaining = (segmentedControl.selectedSegmentIndex == 1) ? shortBreakDuration : longBreakDuration
        default:
            break
        }
        updateUI()
        startTimer()
        pauseTimer()
        
        
    }
    
    
    
}

extension TimerViewController {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return durations.count
    }
}

extension TimerViewController {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(durations[row]) minutes"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        timer?.invalidate()
        timer = nil
        
        let selectedDuration = durations[row] * 60
        secondsRemaining = selectedDuration
        
        updateUI()
        startTimer()
    }
}







