//
//  TasksViewController.swift
//  OgurecApp

import UIKit
import UserNotifications

class SettingsViewController: UIViewController, UICalendarSelectionSingleDateDelegate,UITableViewDelegate, UITableViewDataSource {
    
    private var selectedDateLabel: UILabel!
    
    private var selectedDates: [DateComponents] = []
    private var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createCalendar()
        setupSelectedDateLabel()
        setupTableView()
    }
    
    func createCalendar(){
        view.backgroundColor = .systemGray5
        let calendarView = UICalendarView()
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        let selection = UICalendarSelectionSingleDate(delegate: self)
        calendarView.selectionBehavior = selection
        calendarView.calendar = .current
        calendarView.locale = .current
        calendarView.fontDesign = .rounded
        calendarView.delegate = self
        calendarView.layer.cornerRadius = 12
        calendarView.backgroundColor = .systemBackground
        
        view.addSubview(calendarView)
        
        NSLayoutConstraint.activate([
            calendarView.leadingAnchor.constraint(equalTo:  view.leadingAnchor, constant: 10),
            calendarView.trailingAnchor.constraint(equalTo:  view.trailingAnchor, constant: -10),
            calendarView.heightAnchor.constraint(equalToConstant: 350),
            calendarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        ])
        
        // Добавление кнопки "Сохранить" в навигационную панель
        let saveButton = UIBarButtonItem(title: "Сохранить", style: .plain, target: self, action: #selector(saveButtonTapped))
        navigationItem.rightBarButtonItem = saveButton
    }
    
    func setupSelectedDateLabel() {
           selectedDateLabel = UILabel()
           selectedDateLabel.translatesAutoresizingMaskIntoConstraints = false
           selectedDateLabel.textAlignment = .center
           selectedDateLabel.textColor = .black
           selectedDateLabel.font = UIFont.systemFont(ofSize: 16)
           selectedDateLabel.text = "Selected Date: Not chosen"
           
           view.addSubview(selectedDateLabel)
           
           NSLayoutConstraint.activate([
            selectedDateLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -200),
            selectedDateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            selectedDateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            selectedDateLabel.heightAnchor.constraint(equalToConstant: 200),
           ])
       }
    func setupTableView() {
           tableView = UITableView()
           tableView.translatesAutoresizingMaskIntoConstraints = false
           tableView.delegate = self
           tableView.dataSource = self
           tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")

           view.addSubview(tableView)

        NSLayoutConstraint.activate([
                 tableView.topAnchor.constraint(equalTo: selectedDateLabel.bottomAnchor, constant: -50),
                 tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                 tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                 tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -60)
             ])
       }
    @objc func saveButtonTapped() {
           UserDefaults.standard.set(selectedDates.map { formatDateComponents($0) }, forKey: "SelectedDates")
           UserDefaults.standard.synchronize()
           let indexPath = IndexPath(row: selectedDates.count - 1, section: 0)
           tableView.beginUpdates()
           tableView.insertRows(at: [indexPath], with: .automatic)
           tableView.endUpdates()
           let formattedDates = selectedDates.map { formatDateComponents($0) }.joined(separator: ", ")
                selectedDateLabel.text = "Selected Date: \(formattedDates)"
           scheduleNotifications(for: selectedDates)
        if let lastSelectedDate = selectedDates.last {

              let formattedDate = formatDateComponents(lastSelectedDate)

              // Schedule a notification for the selected date with a custom message
              scheduleNotificationForDate(date: lastSelectedDate, message: formattedDate)
          }
     
    }
    func scheduleNotificationForDate(date: DateComponents, message: String) {
        let content = UNMutableNotificationContent()
        content.title = "Task Reminder"
        content.body = "You have a task on \(message)"
        content.sound = UNNotificationSound.default

        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: false)

        let request = UNNotificationRequest(identifier: "CustomNotification", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            } else {
                print("Notification scheduled for \(message)")
            }
        }
    }

    func scheduleNotifications(for dates: [DateComponents]) {
            let center = UNUserNotificationCenter.current()

            // Remove existing notifications
            center.removeAllPendingNotificationRequests()

            // Schedule notifications for each selected date
            for dateComponents in dates {
                if let date = Calendar.current.date(from: dateComponents) {
                    scheduleNotification(for: date)
                }
            }
        }
    
    func scheduleNotification(for date: Date) {
           let content = UNMutableNotificationContent()
           if Calendar.current.isDateInToday(date) {
                   content.title = "Today's Task"
                   content.body = "You have a task scheduled for today!"
               } else {
                   content.title = "Notification Title"
                   content.body = "Notification Body"
               }

           content.sound = UNNotificationSound.default

           let calendar = Calendar.current
           let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
           let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

           let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

           UNUserNotificationCenter.current().add(request) { error in
               if let error = error {
                   print("Error scheduling notification: \(error)")
               } else {
                   print("Notification scheduled for \(date)")
               }
           }
       }
    func showSaveConfirmation() {
           let alertController = UIAlertController(title: "Данные сохранены", message: "Ваши данные были успешно сохранены.", preferredStyle: .alert)

           let okAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
               if let lastSelectedDate = self?.selectedDates.last {
                   self?.tableView.beginUpdates()
                   self?.tableView.insertRows(at: [IndexPath(row: self?.selectedDates.count ?? 0 - 1, section: 0)], with: .automatic)
                   self?.tableView.endUpdates()
               }
           }

           alertController.addAction(okAction)
           present(alertController, animated: true, completion: nil)
       }

    func dateSelection(_selection: UICalendarSelectionSingleDate, canSelectDate dateComponents: DateComponents?) -> Bool{
        return true
    }
    func dateSelection(_ _selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?){
        if let selectedDate = dateComponents {
                   selectedDates.append(selectedDate)
               }
    }
    private func formatDateComponents(_ dateComponents: DateComponents) -> String {
           let dateFormatter = DateFormatter()
           dateFormatter.dateFormat = "dd MMMM yyyy"
           
           if let date = Calendar.current.date(from: dateComponents) {
               return dateFormatter.string(from: date)
           } else {
               return "Not chosen"
           }
       }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return selectedDates.count
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            let formattedDate = formatDateComponents(selectedDates[indexPath.row])
            cell.textLabel?.text = formattedDate
            return cell
        }

        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            
        }
        func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
          if editingStyle == .delete {
              selectedDates.remove(at: indexPath.row)
              tableView.deleteRows(at: [indexPath], with: .automatic)
              let formattedDates = selectedDates.map { formatDateComponents($0) }.joined(separator: ", ")
              selectedDateLabel.text = "Selected Date: \(formattedDates)"
          }
      }

}

extension SettingsViewController: UICalendarViewDelegate  {
    @available(iOS 16.0, *)
    func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
        return nil
    }
  

}
