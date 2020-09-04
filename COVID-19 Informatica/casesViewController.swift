import UIKit

class casesViewController: UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate, UISearchBarDelegate {

    @IBOutlet weak var caseTableView: UIScrollView!
    @IBOutlet weak var casesLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var yVal = 5
    var countryData : [[String:Any]] = []
    var numLoaded = 20
    var caseLabel1 = UILabel()
    var caseLabel2 = UILabel()
    var caseLabel3 = UILabel()
    var caseLabel4 = UILabel()
    var timeLabel = UILabel()
    var worldData : [String:Any] = [:]
    var worldIso2 : [String] = []
    var textChangedFirst = false
    
    typealias CompletionHandler = (_ success:Bool) -> Void
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .dark
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(self.appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        self.searchBar.delegate = self
        self.searchBar.backgroundImage = UIImage()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard(_:)))
        self.view.addGestureRecognizer(tapGesture)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        for view in self.caseTableView.subviews {
            view.alpha = 1.0
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(self.textChangedFirst == false) {
            self.textChangedFirst = true
            DispatchQueue.main.async {
                if self.numLoaded < self.countryData.count {
                    for i in self.numLoaded..<self.countryData.count {
                        self.generateCountryElem(self.countryData[i])
                        self.numLoaded += 1
                    }
                }
            }
        }
        for v in self.caseTableView.subviews {
            if(v.tag == 1000) {
                if let xx = v.subviews.first as? UILabel {
                    if(xx.text!.lowercased().contains(searchText.lowercased())) {
                        self.caseTableView.contentOffset = CGPoint(x: 0, y: v.frame.origin.y)
                        break
                    }
                }
            }
        }
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    func startView() {
        DispatchQueue.main.async {
            self.caseTableView.delegate = self
            self.caseTableView.contentSize = CGSize(width: self.caseTableView.contentSize.width, height: self.caseTableView.contentSize.height + 135)
            let activity = UIActivityIndicatorView(frame: CGRect(x: (self.view.frame.width - 50) / 2, y: self.view.frame.height / 4, width: 50, height: 50))
            self.caseTableView.addSubview(activity)
            activity.startAnimating()
            
            self.receiveWorldData { (completed) in
                if(completed) {
                    DispatchQueue.main.async {
                        let container = UIView(frame: CGRect(x: 10, y: 1, width: Int(self.view.frame.width) - 20, height: 100))
                        container.backgroundColor = .clear
                        container.layer.cornerRadius = 5
                        
                        let imView = UIImageView(frame: CGRect(x: (((self.view.frame.width - 20) * 0.25) - 40) / 2, y: 30, width: 40, height: 40))
                        imView.image = UIImage(systemName: "globe")
                        imView.tintColor = .white
                        container.addSubview(imView)
                        
                        if let cases = self.worldData["cases"] as? Int {
                            UserDefaults.standard.set(cases, forKey: "_WORLD_CASES")
                            let casesLabel = UILabel(frame: CGRect(x: (self.view.frame.width - 20) * 0.25, y: 1, width: (self.view.frame.width - 20) * 0.25, height: 98))
                            casesLabel.textAlignment = .center
                            casesLabel.font = casesLabel.font.withSize(12)
                            casesLabel.text = "\(cases)"
                            casesLabel.layer.addBorder(edge: .left, color: UIColor(red: 1, green: 1, blue: 1, alpha: 0.2), thickness: 1)
                            casesLabel.textColor = .white
                            container.addSubview(casesLabel)
                        }
                        if let deaths = self.worldData["deaths"] as? Int {
                            let deathLabel = UILabel(frame: CGRect(x: (self.view.frame.width - 20) * 0.5, y: 1, width: (self.view.frame.width - 20) * 0.25, height: 98))
                            deathLabel.textAlignment = .center
                            deathLabel.text = "\(deaths)"
                            deathLabel.font = deathLabel.font.withSize(12)
                            deathLabel.layer.addBorder(edge: .left, color: UIColor(red: 1, green: 1, blue: 1, alpha: 0.2), thickness: 1)
                            deathLabel.textColor = .white
                            container.addSubview(deathLabel)
                        }
                        if let recovered = self.worldData["recovered"] as? Int {
                            let recovLabel = UILabel(frame: CGRect(x: (self.view.frame.width - 20) * 0.75, y: 1, width:     (self.view.frame.width - 20) * 0.25, height: 98))
                            recovLabel.textAlignment = .center
                            recovLabel.text = "\(recovered)"
                            recovLabel.font = recovLabel.font.withSize(12)
                            recovLabel.layer.addBorder(edge: .left, color: UIColor(red: 1, green: 1, blue: 1, alpha: 0.2), thickness: 1)
                            recovLabel.textColor = .white
                            container.addSubview(recovLabel)
                        }
                        self.caseTableView.addSubview(container)
                    }
                }
            }
            
            self.yVal += 100
            
            let countryLabell = UILabel(frame: CGRect(x: 10.0, y: CGFloat(self.yVal), width: CGFloat((self.view.frame.width - 20) * 0.25), height: 30.0))
            countryLabell.text = "Country"
            countryLabell.textAlignment = .center
            countryLabell.font = countryLabell.font.withSize(13)
            countryLabell.layer.addBorder(edge: .top, color: UIColor(red: 1, green: 1, blue: 1, alpha: 0.2), thickness: 1)
            countryLabell.textColor = .white
            self.caseTableView.addSubview(countryLabell)
            
            self.timeLabel = UILabel(frame: CGRect(x: 10.0, y: self.searchBar.frame.origin.y + self.searchBar.frame.height - 12, width: CGFloat(self.view.frame.width - 20), height: 30.0))
            self.timeLabel.text = "Data as of: \(Date().description(with: .current))"
            self.timeLabel.textAlignment = .center
            self.timeLabel.font = self.timeLabel.font.withSize(6)
            self.timeLabel.textColor = .white
            self.view.addSubview(self.timeLabel)
            
            self.yVal += 30
            
            self.caseLabel1 = UILabel(frame: CGRect(x: 10, y: self.casesLabel.frame.origin.y + self.casesLabel.frame.height, width: (self.view.frame.width - 20) * 0.25, height: 50))
            self.caseLabel1.text = "World"
            self.caseLabel1.font = self.caseLabel1.font.withSize(13)
            self.caseLabel1.textColor = .white
            self.caseLabel1.layer.addBorder(edge: .top, color: UIColor(red: 1, green: 1, blue: 1, alpha: 0.2), thickness: 1)
            self.caseLabel1.textAlignment = .center
            self.caseLabel1.clipsToBounds = true
            self.view.addSubview(self.caseLabel1)
            
            self.caseLabel2 = UILabel(frame: CGRect(x: 10 + ((self.view.frame.width - 20) * 0.25), y: self.casesLabel.frame.origin.y + self.casesLabel.frame.height , width: (self.view.frame.width - 20) * 0.25, height: 50))
            self.caseLabel2.text = "Cases"
            self.caseLabel2.font = self.caseLabel2.font.withSize(13)
            self.caseLabel2.textColor = .white
            self.caseLabel2.layer.addBorder(edge: .top, color: UIColor(red: 1, green: 1, blue: 1, alpha: 0.2), thickness: 1)
            self.caseLabel2.layer.addBorder(edge: .left, color: UIColor(red: 1, green: 1, blue: 1, alpha: 0.2), thickness: 1)
            self.caseLabel2.textAlignment = .center
            self.caseLabel2.clipsToBounds = true
            self.view.addSubview(self.caseLabel2)
            
            self.caseLabel3 = UILabel(frame: CGRect(x: 10 + ((self.view.frame.width - 20) * 0.5), y: self.casesLabel.frame.origin.y + self.casesLabel.frame.height , width: (self.view.frame.width - 20) * 0.25, height: 50))
            self.caseLabel3.text = "Deaths"
            self.caseLabel3.font = self.caseLabel3.font.withSize(13)
            self.caseLabel3.textColor = .white
            self.caseLabel3.layer.addBorder(edge: .top, color: UIColor(red: 1, green: 1, blue: 1, alpha: 0.2), thickness: 1)
            self.caseLabel3.layer.addBorder(edge: .left, color: UIColor(red: 1, green: 1, blue: 1, alpha: 0.2), thickness: 1)
            self.caseLabel3.textAlignment = .center
            self.caseLabel3.clipsToBounds = true
            self.view.addSubview(self.caseLabel3)
            
            self.caseLabel4 = UILabel(frame: CGRect(x: 10 + ((self.view.frame.width - 20) * 0.75), y: self.casesLabel.frame.origin.y + self.casesLabel.frame.height , width: (self.view.frame.width - 20) * 0.25, height: 50))
            self.caseLabel4.text = "Recovered"
            self.caseLabel4.font = self.caseLabel4.font.withSize(13)
            self.caseLabel4.textColor = .white
            self.caseLabel4.layer.addBorder(edge: .top, color: UIColor(red: 1, green: 1, blue: 1, alpha: 0.2), thickness: 1)
            self.caseLabel4.layer.addBorder(edge: .left, color: UIColor(red: 1, green: 1, blue: 1, alpha: 0.2), thickness: 1)
            self.caseLabel4.textAlignment = .center
            self.caseLabel4.clipsToBounds = true
            self.view.addSubview(self.caseLabel4)
            
            self.receiveDataCountries { (completed) in
                if(completed) {
                    DispatchQueue.main.async {
                        for v in self.caseTableView.subviews {
                            if( v is UIActivityIndicatorView) {
                               v.removeFromSuperview()
                               break
                            }
                        }
                    }
                    //UserDefaults.standard.set(self.countryData, forKey: "_WORLD_DATA")
                    UserDefaults.standard.set(Date(), forKey: "_LAST_UPDATE")
                    
                    for j in 0..<self.countryData.count {
                        self.generateISO2(self.countryData[j])
                    }
                    
                    for i in self.numLoaded - 20..<self.numLoaded {
                        self.generateCountryElem(self.countryData[i])
                    }
                }
            }
        }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if(scrollView.contentOffset.y >= 120) {
            self.caseLabel1.text = "Country"
        } else {
            self.caseLabel1.text = "World"
        }
        
        let height = self.caseTableView.frame.size.height
        let contentYoffset = self.caseTableView.contentOffset.y
        let distanceFromBottom = self.caseTableView.contentSize.height - contentYoffset
        if distanceFromBottom < height {
            DispatchQueue.main.async {
                for i in self.numLoaded - 20..<self.numLoaded {
                    if(i < self.countryData.count) {
                        self.generateCountryElem(self.countryData[i])
                    } else {
                        break
                    }
                }
            }
            self.numLoaded += 20
        }
    }
    func receiveWorldData(_ completionHandler: @escaping CompletionHandler) {
        let request = NSMutableURLRequest(url: NSURL(string: "https://coronavirus-19-api.herokuapp.com/all")! as URL,
                                                cachePolicy: .useProtocolCachePolicy,
                                            timeoutInterval: 10.0)
        request.httpMethod = "GET"
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            guard error == nil && data != nil else {
                print(error as Any)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("http error")
                return
            }
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options:[])
                if let dict = json as? [String:Any] {
                    self.worldData = dict
                    completionHandler(true)
                }
            } catch let parseError as NSError {
                print("Error with Json: \(parseError)")
            }
        })

        dataTask.resume()
    }
    func receiveDataCountries(_ completionHandler: @escaping CompletionHandler) {
        let request = NSMutableURLRequest(url: NSURL(string: "https://coronavirus-19-api.herokuapp.com/countries")! as URL,
                                                cachePolicy: .useProtocolCachePolicy,
                                            timeoutInterval: 10.0)
        request.httpMethod = "GET"
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            guard error == nil && data != nil else {
                print(error as Any)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("http error")
                return
            }
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options:[])
                if let dict = json as? NSArray {
                    for elem in dict {
                        if let countryD = elem as? [String:Any] {
                            self.countryData.append(countryD)
                        }
                    }
                    completionHandler(true)
                }
            } catch let parseError as NSError {
                print("Error with Json: \(parseError)")
            }
        })

        dataTask.resume()
    }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if(otherGestureRecognizer is UIPanGestureRecognizer) {
            return true
        } else {
            return false
        }
    }
    func generateISO2(_ data:[String:Any]) {
        DispatchQueue.main.async {
            var country : String = ""
            if(data["country"] as! String == "S. Korea") {
                country = "Korea (Republic of)"
            } else if(data["country"] as! String == "Iran") {
                country = "Iran (Islamic Republic of)"
            } else if(data["country"] as! String == "Czechia") {
                country = "Czech Republic"
            } else if(data["country"] as! String == "Russia") {
                country = "Russian Federation"
            } else if(data["country"] as! String == "Vietnam") {
                country = "Socialist Republic of Vietnam"
            } else if(data["country"] as! String == "North Macedonia") {
                country = "Macedonia (the former Yugoslav Republic of)"
            } else if(data["country"] as! String == "Brunei") {
                country = "Brunei Darussalam"
            } else if(data["country"] as! String == "Moldova") {
                country = "Moldova (Republic of)"
            } else if(data["country"] as! String == "Venezuela") {
                country = "Venezuela (Bolivarian Republic of)"
            } else if(data["country"] as! String == "Faeroe Islands") {
                country = "Faroe Islands"
            } else if(data["country"] as! String == "Palestine") {
                country = "Palestine, State of"
            } else if(data["country"] as! String == "Bolivia") {
                country = "Bolivia (Plurinational State of)"
            } else if(data["country"] as! String == "Tanzania") {
                country = "Tanzania, United Republic of"
            } else if(data["country"] as! String == "Saint Martin") {
                country = "Saint Martin (French part)"
            } else if(data["country"] as! String == "Eswatini") {
                country = "Swaziland"
            } else if(data["country"] as! String == "St. Barth") {
                country = "Saint Barthélemy"
            } else if(data["country"] as! String == "Vatican City") {
                country = "Holy See"
            } else if(data["country"] as! String == "St. Vincent Grenadines") {
                country = "Saint Vincent and the Grenadines"
            } else if(data["country"] as! String == "Sint Maarten") {
                country = "Sint Maarten (Dutch part)"
            } else if(data["country"] as! String == "Syria") {
                country = "Syrian Arab Republic"
            } else {
                country = data["country"] as! String
            }
            
            let urll = "https://restcountries.eu/rest/v2/name/\(country)?fullText=true"
            let urlString = urll.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            let request = NSMutableURLRequest(url: NSURL(string: urlString!)! as URL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
            request.httpMethod = "GET"
                        
            let session = URLSession.shared
            let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                guard error == nil && data != nil else {
                    print(error as Any)
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    print("http error")
                    return
                }
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options:[])
                    if let arr = json as? NSArray {
                        if let dict = arr[0] as? [String:Any] {
                            self.worldIso2.append(dict["alpha2Code"] as! String)
                            UserDefaults.standard.set(self.worldIso2, forKey: "_WORLD_ISO2")
                        }
                    }
                } catch let parseError as NSError {
                    print("Error with Json: \(parseError)")
                }
            })
            dataTask.resume()
        }
    }
    func generateCountryElem(_ data:[String:Any]) {
        DispatchQueue.main.async {
            let container = UIView(frame: CGRect(x: 10, y: self.yVal, width: Int(self.view.frame.width) - 20, height: 80))
            container.tag = 1000
            container.backgroundColor = UIColor(red: 46/255, green: 46/255, blue: 46/255, alpha: 1.0)
            container.layer.cornerRadius = 5
            
            let countryLabel = UILabel(frame: CGRect(x: 10, y: 35, width: ((self.view.frame.width - 20) * 0.25) - 20, height: 40))
            countryLabel.adjustsFontSizeToFitWidth = true
            countryLabel.accessibilityIdentifier = "countryLabel"
            countryLabel.minimumScaleFactor = 0.2
            countryLabel.textAlignment = .center
            countryLabel.text = data["country"] as? String
            if(data["country"] as! String == "CAR") {
                countryLabel.text = "Caribbean"
            }
            countryLabel.font = countryLabel.font.withSize(13)
            container.addSubview(countryLabel)
            
            if let cases = data["cases"] as? Int {
                let casesLabel = UILabel(frame: CGRect(x: (self.view.frame.width - 20) * 0.25, y: 1, width: (self.view.frame.width - 20) * 0.25, height: container.frame.height - 2))
                casesLabel.textAlignment = .center
                casesLabel.font = casesLabel.font.withSize(12)
                casesLabel.text = "\(cases)"
                casesLabel.layer.addBorder(edge: .left, color: UIColor(red: 1, green: 1, blue: 1, alpha: 0.2), thickness: 1)
                casesLabel.textColor = .white
                container.addSubview(casesLabel)
            }
            if let deaths = data["deaths"] as? Int {
                let deathLabel = UILabel(frame: CGRect(x: (self.view.frame.width - 20) * 0.5, y: 1, width: (self.view.frame.width - 20) * 0.25, height: container.frame.height - 2))
                deathLabel.textAlignment = .center
                deathLabel.text = "\(deaths)"
                deathLabel.font = deathLabel.font.withSize(12)
                deathLabel.layer.addBorder(edge: .left, color: UIColor(red: 1, green: 1, blue: 1, alpha: 0.2), thickness: 1)
                deathLabel.textColor = .white
                container.addSubview(deathLabel)
            }
            if let recovered = data["recovered"] as? Int {
                let recovLabel = UILabel(frame: CGRect(x: (self.view.frame.width - 20) * 0.75, y: 1, width:     (self.view.frame.width - 20) * 0.25, height: container.frame.height - 2))
                recovLabel.textAlignment = .center
                recovLabel.text = "\(recovered)"
                recovLabel.font = recovLabel.font.withSize(12)
                recovLabel.layer.addBorder(edge: .left, color: UIColor(red: 1, green: 1, blue: 1, alpha: 0.2), thickness: 1)
                recovLabel.textColor = .white
                container.addSubview(recovLabel)
            }
            
            let rightArrow = UIImageView(frame: CGRect(x: container.frame.width - 10, y: container.frame.height / 3, width: 10, height: container.frame.height / 3))
            rightArrow.image = UIImage(systemName: "chevron.compact.right")
            rightArrow.tintColor = .white
            container.addSubview(rightArrow)
            
            container.accessibilityIdentifier = data["country"] as? String
            
            let countryClicked = UILongPressGestureRecognizer(target: self, action: #selector(self.countryClicked(_:)))
            countryClicked.minimumPressDuration = 0.0
            countryClicked.delegate = self
            countryClicked.cancelsTouchesInView = true
            container.addGestureRecognizer(countryClicked)
                        
            self.caseTableView.addSubview(container)
            self.yVal += 90
            self.caseTableView.contentSize = CGSize(width: self.caseTableView.contentSize.width, height: self.caseTableView.contentSize.height + 90)
            
            var country : String = ""
            
            if(data["country"] as! String == "S. Korea") {
                country = "Korea (Republic of)"
            } else if(data["country"] as! String == "Iran") {
                country = "Iran (Islamic Republic of)"
            } else if(data["country"] as! String == "Czechia") {
                country = "Czech Republic"
            } else if(data["country"] as! String == "Russia") {
                country = "Russian Federation"
            } else if(data["country"] as! String == "Vietnam") {
                country = "Socialist Republic of Vietnam"
            } else if(data["country"] as! String == "North Macedonia") {
                country = "Macedonia (the former Yugoslav Republic of)"
            } else if(data["country"] as! String == "Brunei") {
                country = "Brunei Darussalam"
            } else if(data["country"] as! String == "Moldova") {
                country = "Moldova (Republic of)"
            } else if(data["country"] as! String == "Venezuela") {
                country = "Venezuela (Bolivarian Republic of)"
            } else if(data["country"] as! String == "Faeroe Islands") {
                country = "Faroe Islands"
            } else if(data["country"] as! String == "Palestine") {
                country = "Palestine, State of"
            } else if(data["country"] as! String == "Bolivia") {
                country = "Bolivia (Plurinational State of)"
            } else if(data["country"] as! String == "Tanzania") {
                country = "Tanzania, United Republic of"
            } else if(data["country"] as! String == "Saint Martin") {
                country = "Saint Martin (French part)"
            } else if(data["country"] as! String == "Eswatini") {
                country = "Swaziland"
            } else if(data["country"] as! String == "St. Barth") {
                country = "Saint Barthélemy"
            } else if(data["country"] as! String == "Vatican City") {
                country = "Holy See"
            } else if(data["country"] as! String == "St. Vincent Grenadines") {
                country = "Saint Vincent and the Grenadines"
            } else if(data["country"] as! String == "Sint Maarten") {
                country = "Sint Maarten (Dutch part)"
            } else if(data["country"] as! String == "Syria") {
                country = "Syrian Arab Republic"
            } else {
                country = data["country"] as! String
            }
            
            let urll = "https://restcountries.eu/rest/v2/name/\(country)?fullText=true"
            let urlString = urll.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            let request = NSMutableURLRequest(url: NSURL(string: urlString!)! as URL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
            request.httpMethod = "GET"
                        
            let session = URLSession.shared
            let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                guard error == nil && data != nil else {
                    print(error as Any)
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    print("http error")
                    return
                }
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options:[])
                    if let arr = json as? NSArray {
                        if let dict = arr[0] as? [String:Any] {
                            let request2 = NSMutableURLRequest(url: NSURL(string: "https://www.countryflags.io/\(dict["alpha2Code"] as! String)/flat/64.png")! as URL,
                                cachePolicy: .useProtocolCachePolicy,
                            timeoutInterval: 10.0)
                            request2.httpMethod = "GET"
                            
                            let session2 = URLSession.shared
                            let dataTask2 = session2.dataTask(with: request2 as URLRequest, completionHandler: { (data2, response2, error2) -> Void in
                                guard error2 == nil && data2 != nil else {
                                    print(error2 as Any)
                                    return
                                }
                                guard let httpResponse = response2 as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                                    print("http error")
                                    return
                                }
                                DispatchQueue.main.async {
                                    let imView = UIImageView(frame: CGRect(x: (((self.view.frame.width - 20) * 0.25) - 40) / 2, y: 5, width: 40, height: 40))
                                    imView.image = UIImage(data: data2!)
                                    imView.accessibilityIdentifier = (dict["alpha2Code"] as! String)
                                    container.addSubview(imView)
                                }
                            })
                            dataTask2.resume()
                        }
                    }
                    
                } catch let parseError as NSError {
                    print("Error with Json: \(parseError)")
                }
            })
            dataTask.resume()
        }
    }
    
    @objc func countryClicked(_ tap : UILongPressGestureRecognizer) {
        tap.view?.alpha = 0.2
        for view in tap.view!.subviews {
            if(view is UIImageView) {
                UserDefaults.standard.set((view as! UIImageView).image?.pngData(), forKey: "_CURRENT_FlAG")
                UserDefaults.standard.set(view.accessibilityIdentifier, forKey: "_CURRENT_ISO2")
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            UIView.animateKeyframes(withDuration: 0.5, delay: 10, options: [], animations: {
                UserDefaults.standard.set(tap.view!.accessibilityIdentifier, forKey: "_CURRENT_COUNTRY")
                let transition = CATransition()
                transition.duration = 0.4
                transition.type = CATransitionType.push
                transition.subtype = CATransitionSubtype.fromRight
                transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
                self.view.window!.layer.add(transition, forKey: kCATransition)
                self.performSegue(withIdentifier: "casesToCountry", sender: self)
            }, completion: nil)
        })
    }
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
       self.searchBar.resignFirstResponder()
    }
    @objc func appMovedToForeground() {
        for v in self.caseTableView.subviews {
            v.removeFromSuperview()
        }
        self.caseLabel1.removeFromSuperview()
        self.caseLabel2.removeFromSuperview()
        self.caseLabel3.removeFromSuperview()
        self.caseLabel4.removeFromSuperview()
        self.numLoaded = 20
        self.countryData = []
        self.worldIso2 = []
        self.yVal = 5
        self.caseTableView.contentSize = CGSize(width: self.caseTableView.contentSize.width, height: 5)
        self.startView()
    }
}
extension CALayer {

    func addBorder(edge: UIRectEdge, color: UIColor, thickness: CGFloat) {

        let border = CALayer()

        switch edge {
        case .top:
            border.frame = CGRect(x: 0, y: 0, width: frame.width, height: thickness)
        case .bottom:
            border.frame = CGRect(x: 0, y: frame.height - thickness, width: frame.width, height: thickness)
        case .left:
            border.frame = CGRect(x: 0, y: 0, width: thickness, height: frame.height)
        case .right:
            border.frame = CGRect(x: frame.width - thickness, y: 0, width: thickness, height: frame.height)
        default:
            break
        }

        border.backgroundColor = color.cgColor;

        addSublayer(border)
    }
}
