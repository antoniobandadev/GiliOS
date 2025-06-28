//
//  NewEventViewController.swift
//  Gil
//
//  Created by Antonio Banda  on 14/06/25.
//

import UIKit
import MaterialComponents
import AVFoundation

class NewEventViewController: KeyboardViewController, UITextFieldDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate{
    
    let context = DataManager.shared.persistentContainer.viewContext
    var URLImage : String?
    let userId = UserDefaults.standard.integer(forKey: "userId")
    var friendId = 0
    
    let attributes: [NSAttributedString.Key: Any] = [
        .font: Constants.Fonts.font16
        //.foregroundColor: UIColor.systemBlue
    ]
    
    @IBOutlet weak var btnAddImage: UIButton!
    
    @IBAction func btnAddImage(_ sender: UIButton) {
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true)
    }
    
    @IBOutlet weak var btnDelImage: UIButton!
    
    @IBAction func btnDelImageAction(_ sender: UIButton) {
        ivImageEvent.image = nil
        ivImageEvent.isHidden = true
        let attributedTitle = NSAttributedString(string: "add_image".localized(), attributes: attributes)
        btnAddImage.setAttributedTitle(attributedTitle, for: .normal)
        btnDelImage.isHidden = true
    }
    
    @IBOutlet weak var ivImageEvent: UIImageView!
    
    @IBOutlet weak var eventName: MDCOutlinedTextField!
    
    @IBOutlet weak var eventDesc: MDCOutlinedTextField!
    
    @IBOutlet weak var eventType: MDCOutlinedTextField!
    
    private var datePickerStart: UIDatePicker?
    private var datePickerEnd: UIDatePicker?
    
    @IBOutlet weak var eventDateStart: MDCOutlinedTextField!
    
    @IBOutlet weak var eventDateEnd: MDCOutlinedTextField!
    
    @IBOutlet weak var eventStreet: MDCOutlinedTextField!
    
    @IBOutlet weak var eventCity: MDCOutlinedTextField!
    
    @IBOutlet weak var eventScan: MDCOutlinedTextField!
    
    let categories = Utils.eventCategories
    var friends = DataManager.shared.getFriendsArray()
    
    
    let imagePicker = UIImagePickerController()
    let serviceManager = ServiceManager.shared

    let picker = UIPickerView()
    var currentOptions: [String] = []
    var activeTextField: UITextField?
    
    @IBAction func btnSaveEvent(_ sender: UIButton) {
        if(validateInputs()){
            saveNewEvent()
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        [eventName, eventDesc, eventStreet, eventCity].forEach { $0?.clearTextFieldError() }
        
        eventName.delegate = self
        eventDesc.delegate = self
        eventType.delegate = self
        eventDateStart.delegate = self
        eventDateEnd.delegate = self
        eventStreet.delegate = self
        eventCity.delegate = self
        eventScan.delegate = self
        
        picker.delegate = self
        picker.dataSource = self
        initUI()
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if(isConnected){
           // let alertLoading = Utils.LoadigAlert.showAlert(on: self)
            updateContactsApi {
                //self.currentOptions = Array(self.friends.values)
                //self.scanTypePicker()
               // alertLoading.dismiss(animated: true)
            }
        }
    }
    
    
    
    
    
    func initUI(){
        
        Utils.TextField.config(eventName, label: NSLocalizedString("event_name".localized(), comment: ""), icon: "ic_event", iconTrailing: "xmark.circle.fill")
        eventName.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        Utils.TextField.config(eventDesc, label: NSLocalizedString("event_description".localized(), comment: ""), icon: "ic_event_desc", iconTrailing: "xmark.circle.fill")
        eventDesc.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        Utils.TextField.config(eventType, label: NSLocalizedString("event_type".localized(), comment: ""), icon: "ic_event_type", iconTrailing: "xmark.circle.fill")
        eventType.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        Utils.TextField.config(eventDateStart, label: NSLocalizedString("start_date".localized(), comment: ""), icon: "ic_calendar", iconTrailing: "xmark.circle.fill")
        eventDateStart.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        Utils.TextField.config(eventDateEnd, label: NSLocalizedString("end_date".localized(), comment: ""), icon: "ic_calendar", iconTrailing: "xmark.circle.fill")
        eventDateEnd.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        Utils.TextField.config(eventStreet, label: NSLocalizedString("street".localized(), comment: ""), icon: "ic_event_street", iconTrailing: "xmark.circle.fill")
        eventStreet.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        Utils.TextField.config(eventCity, label: NSLocalizedString("city".localized(), comment: ""), icon: "ic_event_city", iconTrailing: "xmark.circle.fill")
        eventCity.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        Utils.TextField.config(eventScan, label: NSLocalizedString("friends".localized(), comment: ""), icon: "ic_qr_scan", iconTrailing: "xmark.circle.fill")
        eventScan.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        dateStart()
        dateEnd()
        scanTypePicker()
    }
    
    func validateInputs() -> Bool{
        
        let eventNameVal = eventName.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let eventDescVal = eventDesc.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let eventTypeVal = eventType.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let eventDateStartVal = eventDateStart.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let eventDateEndVal = eventDateEnd.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let eventStreetVal = eventStreet.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let eventCityVal = eventCity.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let eventScanVal = eventScan.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        if(eventNameVal.isEmpty){
            Utils.ValidTextField.error(textField: eventName, messageError: "required_field".localized())
            return false
        }
        if(eventDescVal.isEmpty){
            Utils.ValidTextField.error(textField: eventDesc, messageError: "required_field".localized())
            return false
        }
        if(eventTypeVal.isEmpty){
            Utils.ValidTextField.error(textField: eventType, messageError: "required_field".localized())
            return false
        }
        if(!validTypes()){
            eventType.text = ""
            Utils.ValidTextField.error(textField: eventType, messageError: "required_field".localized())
            return false
        }
        if(eventDateStartVal.isEmpty){
            Utils.ValidTextField.error(textField: eventDateStart, messageError: "required_field".localized())
            return false
        }
        if(eventDateEndVal.isEmpty){
            Utils.ValidTextField.error(textField: eventDateEnd, messageError: "required_field".localized())
            return false
        }
        
        if(!startDateValid(dateStart:eventDateStartVal)){
            Utils.ValidTextField.error(textField: eventDateStart, messageError: "invalid_date".localized())
            return false
        }
               
        if(eventDateStartVal > eventDateEndVal){
            Utils.ValidTextField.error(textField: eventDateStart, messageError: "invalid_date_bigger".localized())
            return false
        }
        
        if(eventStreetVal.isEmpty){
            Utils.ValidTextField.error(textField: eventStreet, messageError: "required_field".localized())
            return false
        }
        if(eventCityVal.isEmpty){
            Utils.ValidTextField.error(textField: eventCity, messageError: "required_field".localized())
            return false
        }
        if(eventScanVal.isEmpty){
            Utils.ValidTextField.error(textField: eventScan, messageError: "required_field".localized())
            return false
        }
        if(!validFriends()){
            eventScan.text = ""
            Utils.ValidTextField.error(textField: eventScan, messageError: "required_field".localized())
            return false
        }
        return true
       /* if(valName.isEmpty || valName.count < 3){
            Utils.ValidTextField.error(textField: tfName, messageError: "invalid_name".localized())
            valid = false
        }*/
        
        
    }
    
    
    
    
    //MARK: DatePickers
    
    func dateStart(){
        
        datePickerStart = UIDatePicker()
        datePickerStart?.datePickerMode = .dateAndTime
        datePickerStart?.preferredDatePickerStyle = .wheels
        datePickerStart?.addTarget(self, action: #selector(dateStartChanged(_:)), for: .valueChanged)

        if let languageCode = Locale.preferredLanguages.first {
            datePickerStart?.locale = Locale(identifier: languageCode)
        }
        
        eventDateStart.inputView = datePickerStart

        let doneButton = UIBarButtonItem(title: "done".localized(), style: .plain, target: self, action: #selector(dismissPicker))
        doneButton.tintColor = Constants.Colors.secondary
                
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        toolbar.setItems([flexibleSpace,doneButton], animated: true)

        eventDateStart.inputAccessoryView = toolbar
    }
    
    @objc func dateStartChanged(_ sender: UIDatePicker) {
        eventDateStart.clearTextFieldError()
        let currentLocale = Locale.current
        let formatter = DateFormatter()
        
        if(currentLocale.identifier == "es_MX"){
            formatter.dateFormat = "dd/MM/yyyy HH:mm"
        }else{
            formatter.dateFormat = "MM/dd/yyyy HH:mm"
        }
        eventDateStart.text = formatter.string(from: sender.date)
    }
    
    func dateEnd(){
       
        datePickerEnd = UIDatePicker()
        datePickerEnd?.datePickerMode = .dateAndTime
        datePickerEnd?.preferredDatePickerStyle = .wheels
        datePickerEnd?.addTarget(self, action: #selector(dateEndChanged(_:)), for: .valueChanged)
        
        if let languageCode = Locale.preferredLanguages.first {
            datePickerEnd?.locale = Locale(identifier: languageCode)
        }
        
        eventDateEnd.inputView = datePickerEnd
        

        let doneButton = UIBarButtonItem(title: "done".localized(), style: .plain, target: self, action: #selector(dismissPicker))
        doneButton.tintColor = Constants.Colors.secondary
                
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        toolbar.setItems([flexibleSpace,doneButton], animated: true)

        eventDateEnd.inputAccessoryView = toolbar
    }
    
    @objc func dateEndChanged(_ sender: UIDatePicker) {
        eventDateEnd.clearTextFieldError()
        let currentLocale = Locale.current
        let formatter = DateFormatter()
        //print(currentLocale.identifier)
        if(currentLocale.identifier == "es_MX"){
            formatter.dateFormat = "dd/MM/yyyy HH:mm"
        }else{
            formatter.dateFormat = "MM/dd/yyyy HH:mm"
        }
        eventDateEnd.text = formatter.string(from: sender.date)
    }
    
    func startDateValid(dateStart: String) -> Bool {
        let currentLocale = Locale.current
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        if(currentLocale.identifier == "es_MX"){
            formatter.dateFormat = "dd/MM/yyyy HH:mm"
        }else{
            formatter.dateFormat = "MM/dd/yyyy HH:mm"
        }
        
        guard let inputDate = formatter.date(from: dateStart) else {
            print("Fecha inválida")
            return false
        }

        let now = Date()
        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: now)

        return inputDate >= todayStart
    }

    @objc func dismissPicker() {
        view.endEditing(true)
    }
    
    
    
    // MARK: UIPickerView
    
    func scanTypePicker(){
        ivImageEvent.isHidden = true
        btnDelImage.isHidden = true
        
        eventScan.inputView = picker
        eventType.inputView = picker

        eventScan.delegate = self
        eventType.delegate = self

        eventScan.tintColor = .clear
        eventType.tintColor = .clear
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()

        let doneButton = UIBarButtonItem(title: "done".localized(), style: .plain, target: self, action: #selector(dismissPickers))
        doneButton.tintColor = Constants.Colors.secondary
        toolbar.setItems([UIBarButtonItem.flexibleSpace(), doneButton], animated: true)

        eventScan.inputAccessoryView = toolbar
        eventType.inputAccessoryView = toolbar
    }
    
    func validTypes() -> Bool {
        guard let ciudad = eventType.text, categories.contains(ciudad) else {
            return false
        }
        return true
    }
    
    func validFriends() -> Bool {
        if let found = friends.first(where: { $0.value == eventScan.text }) {
            friendId = Int(found.key)!
            print("Encontrado con id: \(found.key)")
            return true
        }else{
            return false
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField

        if textField == eventScan {
            eventScan.clearTextFieldError()
            friends = DataManager.shared.getFriendsArray()
            currentOptions = Array(friends.values)
            //print("Cargando Amigos en el Picker")
            if let selected = textField.text, let index = currentOptions.firstIndex(of: selected) {
                picker.selectRow(index, inComponent: 0, animated: false)
            }
            else {
                picker.selectRow(0, inComponent: 0, animated: false)
                textField.text = currentOptions.first
            }
        } else if textField == eventType {
            eventType.clearTextFieldError()
            currentOptions = categories
            
            if let selected = textField.text, let index = currentOptions.firstIndex(of: selected) {
                picker.selectRow(index, inComponent: 0, animated: false)
            }
            else {
                picker.selectRow(0, inComponent: 0, animated: false)
                textField.text = currentOptions.first
            }
        }

        picker.reloadAllComponents()
    }
    
    func updateContactsApi(completion: @escaping () -> Void) {
        let userId = UserDefaults.standard.integer(forKey: "userId")
        
        DataManager.shared.deleteAllContacts(context: self.context)
        
        serviceManager.getContacts(userId: userId) { result in
            DispatchQueue.main.async {
                switch result {
                    case .success(let contacts):
                    var contactsApiArray: [ContactEntity] = []
                    
                        for contactDto in contacts {
                            let contactsApi = ContactEntity(context: self.context)
                            contactsApi.contactId = contactDto.contactId
                            contactsApi.userId = Int16(contactDto.userId!)
                            contactsApi.contactName = contactDto.contactName
                            contactsApi.contactEmail = contactDto.contactEmail
                            contactsApi.contactStatus = contactDto.contactStatus
                            contactsApi.contactType = contactDto.contactType
                            contactsApi.contactSync = 1
                            contactsApiArray.append(contactsApi)
                        }
                    
                        DataManager.shared.insertContacts(contactsApiArray)
                        
                    print("Amigos Actualizados")
                    case .failure(let error):
                    print("Error al actualizar desde el api : \(error)")
                }
                completion()
            }
            
        }
       
    }
    
    
    
    // MARK: ImagePicker
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let imgEvent = info[.editedImage] as? UIImage{
            ivImageEvent.isHidden = false
            ivImageEvent.image = imgEvent
            let attributedTitle = NSAttributedString(string: "edit_image".localized(), attributes: attributes)
            btnAddImage.setAttributedTitle(attributedTitle, for: .normal)
            btnDelImage.isHidden = false
            /*let url = info[.imageURL] as? URL
            URLImage = url?.absoluteString
            picker.dismiss(animated: true)*/
            
            if let data = imgEvent.jpegData(compressionQuality: 0.8) {
               // Directorio temporal
               let tempDir = FileManager.default.temporaryDirectory
               let fileName = UUID().uuidString + ".jpg"
               let fileURL = tempDir.appendingPathComponent(fileName)

               do {
                   try data.write(to: fileURL)
    
                   URLImage = fileURL.absoluteString
                   picker.dismiss(animated: true)

               } catch {
                   picker.dismiss(animated: true)
                  // print("Error al guardar la imagen editada:", error)
               }
            }
            
            
            
            //serviceManager.uploadImageWithAlamofire(image: imgProfile, fileName: "profileImge.jpg", userId: userId)
            // UIImageWriteToSavedPhotosAlbum(imgProfile, nil, nil, nil)
            /*picker.dismiss(animated: true){
                Utils.Snackbar.snackbarNoAction(message: "image_updated_success".localized(), bgColor: Constants.Colors.green!, duration: 3.0)
            }*/
        }
        
        //let URL = info[.imageURL] ?? ""
        //print(URL)
        //UserDefaults.standard.set(URL, forKey: "userProfile")
        
    }
    
    // MARK: Save Contacts
    
    func saveNewEvent() {
        let alertLoading = Utils.LoadigAlert.showAlert(on: self)
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        let currentLocale = Locale.current
        let toFormat = "yyyy-MM-dd HH:mm"
        var fromFormat = ""
        
        if(currentLocale.identifier == "es_MX"){
            fromFormat = "dd/MM/yyyy HH:mm" // HH:mm
        }else{
            fromFormat = "MM/dd/yyyy HH:mm" //HH:mm
        }

        /*
         let eventDateStartVal =  Utils.dateFormatString(date: eventDateStart.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "", fromFormat: fromFormat, toFormat: toFormat)
         let eventDateEndVal = Utils.dateFormatString(date: eventDateEnd.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "", fromFormat: fromFormat, toFormat: toFormat)
         */
        let eventNameVal = eventName.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let eventDescVal = eventDesc.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let eventTypeVal = eventType.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let eventDateStartVal = eventDateStart.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let eventDateEndVal = eventDateEnd.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let eventStreetVal = eventStreet.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let eventCityVal = eventCity.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let eventScanVal = friendId
        
        let newEvent = EventEntity(context: context)
            newEvent.eventId = 0
            newEvent.eventName = eventNameVal
            newEvent.eventDesc = eventDescVal
            newEvent.eventType = eventTypeVal
            newEvent.eventDateStart = Utils.dateFormatString(date: eventDateStartVal, fromFormat: fromFormat, toFormat: toFormat)
            newEvent.eventDateEnd = Utils.dateFormatString(date: eventDateEndVal, fromFormat: fromFormat, toFormat: toFormat)
            newEvent.eventStreet = eventStreetVal
            newEvent.eventCity = eventCityVal
            newEvent.eventStatus = "A"
            newEvent.eventImg = URLImage
            newEvent.eventCreatedAt = ""
            newEvent.userId = Int16(userId)
            newEvent.eventSync = 0
            newEvent.userIdScan = Int16(eventScanVal)
        
        if(isConnected){
            newEvent.eventSync = 1
            serviceManager.uploadEvent(image: ivImageEvent?.image, fileName: "eventImge.jpg", event: newEvent){ result in
                print(result)
                switch result {
                    case .success(let event):
                    if event.eventImg != nil{
                        newEvent.eventImg = Constants.URLs.eventApi + event.eventImg!
                    }else{
                        newEvent.eventImg = event.eventImg
                    }
                        
                        newEvent.eventId = Int16(event.eventId!)
                        
                        if(DataManager.shared.saveEventDB(event: newEvent)){
                            alertLoading.dismiss(animated: true){
                                Utils.Snackbar.snackbarNoAction(message: "event_save_success".localized(), bgColor: Constants.Colors.green!, duration: 5.0)
                                print("Evento guardado exitosamente.")
                                NotificationCenter.default.post(name: NSNotification.Name("ADD_EVENT"), object:nil)
                                self.clearData()
                            }
                        }else{
                            alertLoading.dismiss(animated: true){
                                Utils.Snackbar.snackbarNoAction(message: "server_error".localized(), bgColor: Constants.Colors.green!, duration: 5.0)
                                print("Evento no se pudo guardar.")
                            }
                            
                        }
                    
                    case .failure(let error):
                        print("\(error.localizedDescription)")
                }
            }
            
        }else{
            if(DataManager.shared.saveEventDB(event: newEvent)){
                alertLoading.dismiss(animated: true){
                    Utils.Snackbar.snackbarNoAction(message: "event_save_success".localized(), bgColor: Constants.Colors.green!, duration: 5.0)
                    print("Evento guardado exitosamente.")
                    NotificationCenter.default.post(name: NSNotification.Name("ADD_EVENT"), object:nil)
                    self.clearData()
                }
            }else{
                alertLoading.dismiss(animated: true){
                    Utils.Snackbar.snackbarNoAction(message: "server_error".localized(), bgColor: Constants.Colors.green!, duration: 5.0)
                    print("Evento no se pudo guardar.")
                }
            }
        }
        
        
        
    }
    
    // MARK: Clear info
    
    func clearData(){
        ivImageEvent.image = nil
        ivImageEvent.isHidden = true
        let attributedTitle = NSAttributedString(string: "add_image".localized(), attributes: attributes)
        btnAddImage.setAttributedTitle(attributedTitle, for: .normal)
        btnDelImage.isHidden = true
        
        eventName.text = ""
        eventDesc.text = ""
        eventType.text = ""
        eventDateStart.text = ""
        eventDateEnd.text = ""
        eventStreet.text = ""
        eventCity.text = ""
        eventScan.text = ""
        
        tabBarController?.selectedIndex = 0
       
    }
    
    
   
    
    // MARK: TextField
    
    @objc func textFieldDidChange(_ textField: MDCOutlinedTextField) {
        textField.applyValidStyle()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension NewEventViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return currentOptions.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard row < currentOptions.count else {
                print("Índice fuera de rango: \(row)")
                return nil
            }
            return currentOptions[row]
       // return currentOptions[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (currentOptions.count > 0) {
            activeTextField?.text = currentOptions[row]
        }else{
            activeTextField?.text = ""
        }
        
        
    }
    @objc func dismissPickers() {
        activeTextField?.resignFirstResponder()
    }
}
