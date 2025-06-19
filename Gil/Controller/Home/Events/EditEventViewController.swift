//
//  EditEventViewController.swift
//  Gil
//
//  Created by Antonio Banda  on 18/06/25.
//

import UIKit
import MaterialComponents
import Kingfisher

class EditEventViewController: KeyboardViewController, UITextFieldDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    
    var eventRecived : EventEntity?
    
    let context = DataManager.shared.persistentContainer.viewContext
    var URLImage : String?
    let userId = UserDefaults.standard.integer(forKey: "userId")
    var friendId = 0
    var eventId = 0
    
    let attributes: [NSAttributedString.Key: Any] = [
        .font: Constants.Fonts.font16
        //.foregroundColor: UIColor.systemBlue
    ]
    
    @IBAction func btnClose(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBOutlet weak var btnAddImage: UIButton!
    @IBOutlet weak var btnDelImage: UIButton!
    
    @IBAction func btnAddImageAction(_ sender: UIButton) {
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true)
    }
    
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
    
    @IBOutlet weak var eventDateStart: MDCOutlinedTextField!
    
    @IBOutlet weak var eventDateEnd: MDCOutlinedTextField!
    
    @IBOutlet weak var eventStreet: MDCOutlinedTextField!
    
    @IBOutlet weak var eventCity: MDCOutlinedTextField!
    
    @IBOutlet weak var eventScan: MDCOutlinedTextField!

    @IBAction func btnUpdateAction(_ sender: UIButton) {
        
        if(validateInputs()){
            updateEvent()
        }
    }
    
    @IBAction func btnAddGuestsAction(_ sender: UIButton) {
        
    }
    
    let categories = Utils.eventCategories
    let friends = DataManager.shared.getFriendsArray()
    
    
    let imagePicker = UIImagePickerController()
    let serviceManager = ServiceManager.shared

    let picker = UIPickerView()
    var currentOptions: [String] = []
    var activeTextField: UITextField?
    
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
        
        eventId = Int(eventRecived?.eventId ?? 0)
        
        picker.delegate = self
        picker.dataSource = self
        initUI()
        initVals()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if(isConnected){
           // let alertLoading = Utils.LoadigAlert.showAlert(on: self)
            updateContactsApi {
               // alertLoading.dismiss(animated: true)
            }
        }
    }
    
    
    func initVals(){
        eventName.text = eventRecived?.eventName
        eventDesc.text = eventRecived?.eventDesc
        eventType.text = eventRecived?.eventType
        
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        let currentLocale = Locale.current
        let fromFormat = "yyyy-MM-dd HH:mm"
        var toFormat = ""
        
        if(currentLocale.identifier == "es_MX"){
            toFormat = "dd/MM/yyyy HH:mm"
        }else{
            toFormat = "MM/dd/yyyy HH:mm"
        }
       
        eventDateStart.text =  Utils.dateFormatString(date: (eventRecived?.eventDateStart)!, fromFormat: fromFormat, toFormat: toFormat)
        
        eventDateEnd.text =  Utils.dateFormatString(date: (eventRecived?.eventDateEnd)!, fromFormat: fromFormat, toFormat: toFormat)
        
        eventStreet.text = eventRecived?.eventStreet
        eventCity.text = eventRecived?.eventCity
        
        
        if let found = friends.first(where: { $0.key == String(eventRecived?.userIdScan ?? 0) }) {
            friendId = Int(found.key)!
            eventScan.text = String(found.value)
        }
        
        if let imageData = eventRecived?.eventImg{
            ivImageEvent.isHidden = false
            
            let attributedTitle = NSAttributedString(string: "edit_image".localized(), attributes: attributes)
            btnAddImage.setAttributedTitle(attributedTitle, for: .normal)
            btnDelImage.isHidden = false
        
            //ivImageEvent.image = UIImage(data: imageData)
            let url = URL(string: imageData)
            let placeholder = UIImage(named: "ic_event_img")
            
            ivImageEvent.kf.setImage(
                with: url,
                placeholder: placeholder,
                options: [
                    .transition(.fade(0.3)),
                    .cacheOriginalImage
                ])
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
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        if let fecha = formatter.date(from: eventRecived?.eventDateStart ?? "") {
            datePickerStart?.date = fecha
        }

        let currentLocale = Locale.current
        datePickerStart?.locale = Locale(identifier: currentLocale.identifier)
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
        datePickerStart = UIDatePicker()
        datePickerStart?.datePickerMode = .dateAndTime
        datePickerStart?.preferredDatePickerStyle = .wheels
        datePickerStart?.addTarget(self, action: #selector(dateEndChanged(_:)), for: .valueChanged)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        if let fecha = formatter.date(from: eventRecived?.eventDateEnd ?? "") {
            datePickerStart?.date = fecha
        }

        let currentLocale = Locale.current
        datePickerStart?.locale = Locale(identifier: currentLocale.identifier)
        eventDateEnd.inputView = datePickerStart

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
            currentOptions = Array(friends.values)
            
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
                  // print("❌ Error al guardar la imagen editada:", error)
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
    
    func updateEvent() {
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

       
        let eventNameVal = eventName.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let eventDescVal = eventDesc.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let eventTypeVal = eventType.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let eventDateStartVal = eventDateStart.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let eventDateEndVal = eventDateEnd.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let eventStreetVal = eventStreet.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let eventCityVal = eventCity.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let eventScanVal = friendId
        let eventIdVal = eventId
        
        var newEvent = EventDto(
            eventId : Int(eventIdVal),
            eventName : eventNameVal,
            eventDesc : eventDescVal,
            eventType : eventTypeVal,
            eventDateStart : Utils.dateFormatString(date: eventDateStartVal, fromFormat: fromFormat, toFormat: toFormat),
            eventDateEnd : Utils.dateFormatString(date: eventDateEndVal, fromFormat: fromFormat, toFormat: toFormat),
            eventStreet : eventStreetVal,
            eventCity : eventCityVal,
            eventStatus : "A",
            eventImg : URLImage,
            eventCreatedAt : "",
            userId : Int(userId),
            eventSync : 0,
            userIdScan : Int(eventScanVal)
        )
        
    
        
        /*let newEvent = EventEntity(context: context)
            newEvent.eventId = Int16(eventIdVal)
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
            newEvent.userIdScan = Int16(eventScanVal)*/
        
        if(isConnected){
            newEvent.eventSync = 1
            serviceManager.updateEvent(image: ivImageEvent?.image, fileName: "eventImge.jpg", event: newEvent){ result in
                print(result)
                switch result {
                    case .success(let event):
                    if event.eventImg != nil{
                        newEvent.eventImg = Constants.URLs.eventApi + event.eventImg!
                    }else{
                        newEvent.eventImg = event.eventImg
                    }
                        
                        if(DataManager.shared.updateEventDB(eventUpdate: newEvent)){
                            alertLoading.dismiss(animated: true){
                                Utils.Snackbar.snackbarNoAction(message: "event_update_success".localized(), bgColor: Constants.Colors.green!, duration: 5.0)
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
            if(DataManager.shared.updateEventDB(eventUpdate: newEvent)){
                alertLoading.dismiss(animated: true){
                    Utils.Snackbar.snackbarNoAction(message: "event_update_success".localized(), bgColor: Constants.Colors.green!, duration: 5.0)
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
        
        dismiss(animated: true){
            Utils.Snackbar.snackbarNoAction(message: "event_update_success".localized(), bgColor: Constants.Colors.green!, duration: 5.0)
        }
        NotificationCenter.default.post(name: NSNotification.Name("UPDATE_CONTACT"), object:nil)
       
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

extension EditEventViewController: UIPickerViewDataSource, UIPickerViewDelegate {
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
        activeTextField?.text = currentOptions[row]
    }
    @objc func dismissPickers() {
        activeTextField?.resignFirstResponder()
    }

}
