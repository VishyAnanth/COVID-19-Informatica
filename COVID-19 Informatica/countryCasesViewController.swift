import UIKit

class countryCasesViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var backButton: UIView!
    
    typealias CompletionHandler = (_ success:Bool) -> Void
    
    var flagView = UIImageView()
    var countryHistory : [[String:Any]] = []
    var lineChart = LineChart()
    var dataPoints : [PointEntry] = []
    var deathsPoints : [PointEntry] = []
    var recoveredPoints : [PointEntry] = []
    var countrySpecificInfo : [String:Any] = [:]
    var countryMark = ""
    var heroCountry = ""
    var provinceScroll = UIScrollView()
    var yVal = 550
    var timeScroll = Timer()
    var caseLabel1 = UILabel()
    var caseLabel2 = UILabel()
    var caseLabel3 = UILabel()
    var caseLabel4 = UILabel()
    var currentIso2 = UserDefaults.standard.string(forKey: "_CURRENT_ISO2")
    var segControl = UISegmentedControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .dark
        self.countryLabel.alpha = 0.0
        self.backButton.alpha = 0.0
        var country = UserDefaults.standard.string(forKey: "_CURRENT_COUNTRY")!
        self.heroCountry = country
        self.countryLabel.text = country
        
        self.flagView = UIImageView(frame: CGRect(x: self.countryLabel.frame.origin.x + self.countryLabel.frame.width + 10, y: 0, width: 70, height: 70))
        self.flagView.alpha = 0.0
        self.flagView.image = UIImage(data: UserDefaults.standard.data(forKey: "_CURRENT_FlAG")!)
        self.view.addSubview(self.flagView)
        
        let gest = UILongPressGestureRecognizer(target: self, action: #selector(self.backButtonTapped(_:)))
        gest.minimumPressDuration = 0.0
        self.backButton.addGestureRecognizer(gest)
        
        if(country == "Diamond Princess") {
            country = "Cruise Ship"
        } else if(country == "UAE") {
            country = "United Arab Emirates"
        } else if(country == "St. Barth") {
            country = "Saint Barthelemy"
        } else if(country == "St. Vincent Grenadines") {
            country = "Saint Vincent and the Grenadines"
        } else if(country == "S. Korea") {
            country = "Korea, South"
        } else if(country == "Faeroe Islands") {
            country = "Faroe Islands"
        } else if(country == "USA") {
            country = "US"
        } else if(country == "UK") {
            country = "United Kingdom"
        }
        
        self.countryMark = country
        
        self.provinceScroll = UIScrollView(frame: CGRect(x: 0, y: 100, width: self.view.frame.width, height: self.view.frame.height - 90))
        self.provinceScroll.contentSize = CGSize(width: self.provinceScroll.contentSize.width, height: self.provinceScroll.contentSize.height + 550)
        self.view.addSubview(self.provinceScroll)
        self.provinceScroll.delegate = self
        
        let activity = UIActivityIndicatorView(frame: CGRect(x: (self.view.frame.width - 50) / 2, y: self.view.frame.height / 4, width: 50, height: 50))
        self.provinceScroll.addSubview(activity)
        activity.startAnimating()
        
        self.generateGraphPoints { (completed) in
            if(completed) {
                DispatchQueue.main.async {
                    for v in self.provinceScroll.subviews {
                        if(v is UIActivityIndicatorView) {
                            v.removeFromSuperview()
                            break
                        }
                    }
                    if self.dataPoints.count > 0 {
                        self.lineChart = LineChart(frame: CGRect(x: 5, y: 10, width: self.view.frame.width - 10, height: 300))
                        self.lineChart.topColor = .red
                        self.lineChart.lineGap = 20
                        self.lineChart.dataEntries = self.dataPoints
                        self.lineChart.isCurved = false
                        self.provinceScroll.addSubview(self.lineChart)
                    }
                    
                    self.segControl = UISegmentedControl(items: ["Confirmed", "Deaths", "Recovered"])
                    self.segControl.frame = CGRect(x: self.view.frame.width * 0.1, y: 10, width: self.view.frame.width * 0.8, height: 30)
                    self.segControl.selectedSegmentIndex = 0
                    self.segControl.layer.cornerRadius = 5
                    self.segControl.addTarget(self, action: #selector(self.segValueChanged(_:)), for: .valueChanged)
                    self.segControl.clipsToBounds = true
                    self.segControl.layer.zPosition = 100
                    self.provinceScroll.addSubview(self.segControl)
                    
                    for v in self.lineChart.subviews {
                        if(v is UIScrollView) {
                            (v as! UIScrollView).delegate = self
                            let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(self.graphPinched(_:)))
                            v.addGestureRecognizer(pinchGesture)
                            DispatchQueue.main.async {
                                UIView.animate(withDuration: 3, delay: 0, options: [.allowUserInteraction], animations: {
                                    (v as! UIScrollView).setContentOffset(CGPoint(x: (20 * self.dataPoints.count) - (Int(self.view.frame.width) - 10), y: 0), animated: false)
                                }) { _ in
                                    (v as! UIScrollView).layer.removeAllAnimations()
                                }
                            }
                        }
                    }
                }
            }
        }
        
        self.generateCountrySpecificInfo { (completed) in
            if(completed) {
                self.generateProviceData()
                DispatchQueue.main.async {
                    if let casess = self.countrySpecificInfo["cases"] as? Int, let today = self.countrySpecificInfo["todayCases"] as? Int {
                        let label1 = UILabel(frame: CGRect(x: 20, y: 310, width: (self.view.frame.width - 40), height: 50))
                        label1.textAlignment = .center
                        label1.adjustsFontSizeToFitWidth = true
                        label1.minimumScaleFactor = 0.2
                        label1.textColor = .white
                        label1.text = "Cases: \(casess)   |   Today's Increase: \(today)"
                        self.provinceScroll.addSubview(label1)
                    }
                    if let deathss = self.countrySpecificInfo["deaths"] as? Int, let today = self.countrySpecificInfo["todayDeaths"] as? Int {
                        let label1 = UILabel(frame: CGRect(x: 20, y: 350, width: (self.view.frame.width - 40), height: 50))
                        label1.textAlignment = .center
                        label1.adjustsFontSizeToFitWidth = true
                        label1.minimumScaleFactor = 0.2
                        label1.textColor = .white
                        label1.text = "Deaths: \(deathss)   |   Today's Increase: \(today)"
                        self.provinceScroll.addSubview(label1)
                    }
                    if let critical = self.countrySpecificInfo["critical"] as? Int, let active = self.countrySpecificInfo["active"] as? Int {
                        let label1 = UILabel(frame: CGRect(x: 20, y: 390, width: (self.view.frame.width - 40), height: 50))
                        label1.textAlignment = .center
                        label1.adjustsFontSizeToFitWidth = true
                        label1.minimumScaleFactor = 0.2
                        label1.textColor = .white
                        label1.text = "Active: \(active)   |   Critical: \(critical)"
                        self.provinceScroll.addSubview(label1)
                    }
                    if let casesPerOneMillion = self.countrySpecificInfo["casesPerOneMillion"] as? Int, let recov = self.countrySpecificInfo["recovered"] as? Int {
                        let label1 = UILabel(frame: CGRect(x: 20, y: 430, width: (self.view.frame.width - 40), height: 50))
                        label1.textAlignment = .center
                        label1.adjustsFontSizeToFitWidth = true
                        label1.minimumScaleFactor = 0.2
                        label1.textColor = .white
                        label1.text = "Cases Per Million: \(casesPerOneMillion)   |   Recovered: \(recov)"
                        self.provinceScroll.addSubview(label1)
                    }
                }
            }
        }
        
        caseLabel1 = UILabel(frame: CGRect(x: 10, y: 490, width: (self.view.frame.width - 20) * 0.25, height: 50))
        caseLabel1.text = "Province"
        caseLabel1.font = caseLabel1.font.withSize(13)
        caseLabel1.textColor = .white
        caseLabel1.backgroundColor = .black
        caseLabel1.tag = 100
        caseLabel1.layer.addBorder(edge: .top, color: UIColor(red: 1, green: 1, blue: 1, alpha: 0.2), thickness: 1)
        caseLabel1.textAlignment = .center
        caseLabel1.clipsToBounds = true
        caseLabel1.layer.zPosition = 100
        self.provinceScroll.addSubview(caseLabel1)
        
        caseLabel2 = UILabel(frame: CGRect(x: 10 + ((self.view.frame.width - 20) * 0.25), y: 490, width: (self.view.frame.width - 20) * 0.25, height: 50))
        caseLabel2.text = "Cases"
        caseLabel2.font = caseLabel2.font.withSize(13)
        caseLabel2.textColor = .white
        caseLabel2.backgroundColor = .black
        caseLabel2.tag = 100
        caseLabel2.layer.addBorder(edge: .top, color: UIColor(red: 1, green: 1, blue: 1, alpha: 0.2), thickness: 1)
        caseLabel2.layer.addBorder(edge: .left, color: UIColor(red: 1, green: 1, blue: 1, alpha: 0.2), thickness: 1)
        caseLabel2.textAlignment = .center
        caseLabel2.clipsToBounds = true
        caseLabel2.layer.zPosition = 100
        self.provinceScroll.addSubview(caseLabel2)
        
        caseLabel3 = UILabel(frame: CGRect(x: 10 + ((self.view.frame.width - 20) * 0.5), y: 490, width: (self.view.frame.width - 20) * 0.25, height: 50))
        caseLabel3.text = "Deaths"
        caseLabel3.font = caseLabel3.font.withSize(13)
        caseLabel3.textColor = .white
        caseLabel3.backgroundColor = .black
        caseLabel3.tag = 100
        caseLabel3.layer.addBorder(edge: .top, color: UIColor(red: 1, green: 1, blue: 1, alpha: 0.2), thickness: 1)
        caseLabel3.layer.addBorder(edge: .left, color: UIColor(red: 1, green: 1, blue: 1, alpha: 0.2), thickness: 1)
        caseLabel3.textAlignment = .center
        caseLabel3.clipsToBounds = true
        caseLabel3.layer.zPosition = 100
        self.provinceScroll.addSubview(caseLabel3)
        
        caseLabel4 = UILabel(frame: CGRect(x: 10 + ((self.view.frame.width - 20) * 0.75), y: 490, width: (self.view.frame.width - 20) * 0.25, height: 50))
        caseLabel4.text = "Recovered"
        caseLabel4.font = caseLabel4.font.withSize(13)
        caseLabel4.textColor = .white
        caseLabel4.backgroundColor = .black
        caseLabel4.tag = 100
        caseLabel4.layer.addBorder(edge: .top, color: UIColor(red: 1, green: 1, blue: 1, alpha: 0.2), thickness: 1)
        caseLabel4.layer.addBorder(edge: .left, color: UIColor(red: 1, green: 1, blue: 1, alpha: 0.2), thickness: 1)
        caseLabel4.textAlignment = .center
        caseLabel4.clipsToBounds = true
        caseLabel4.layer.zPosition = 100
        self.provinceScroll.addSubview(caseLabel4)
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.countryLabel.alpha = 1.0
        self.backButton.alpha = 1.0
        self.flagView.frame = CGRect(x: self.countryLabel.frame.origin.x + self.countryLabel.frame.width + 30, y: self.countryLabel.frame.origin.y + 15, width: 40, height: 40)
        self.flagView.alpha = 1.0
        self.startTimerForShowScrollIndicator()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if(scrollView.contentOffset.x > 0) {
            self.timeScroll.invalidate()
        }
        if(self.provinceScroll.contentOffset.y > 490) {
            self.caseLabel1.frame = CGRect(x: self.caseLabel1.frame.origin.x, y: self.provinceScroll.contentOffset.y, width: self.caseLabel1.frame.width, height: self.caseLabel1.frame.height)
            self.caseLabel2.frame = CGRect(x: self.caseLabel2.frame.origin.x, y: self.provinceScroll.contentOffset.y, width: self.caseLabel2.frame.width, height: self.caseLabel2.frame.height)
            self.caseLabel3.frame = CGRect(x: self.caseLabel3.frame.origin.x, y: self.provinceScroll.contentOffset.y, width: self.caseLabel3.frame.width, height: self.caseLabel3.frame.height)
            self.caseLabel4.frame = CGRect(x: self.caseLabel4.frame.origin.x, y: self.provinceScroll.contentOffset.y, width: self.caseLabel4.frame.width, height: self.caseLabel4.frame.height)
        } else {
            self.caseLabel1.frame = CGRect(x: self.caseLabel1.frame.origin.x, y: 490, width: self.caseLabel1.frame.width, height: self.caseLabel1.frame.height)
            self.caseLabel2.frame = CGRect(x: self.caseLabel2.frame.origin.x, y: 490, width: self.caseLabel2.frame.width, height: self.caseLabel2.frame.height)
            self.caseLabel3.frame = CGRect(x: self.caseLabel3.frame.origin.x, y: 490, width: self.caseLabel3.frame.width, height: self.caseLabel3.frame.height)
            self.caseLabel4.frame = CGRect(x: self.caseLabel4.frame.origin.x, y: 490, width: self.caseLabel4.frame.width, height: self.caseLabel4.frame.height)
        }
    }
    func startTimerForShowScrollIndicator() {
        self.timeScroll = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.showScrollIndicatorsInContacts), userInfo: nil, repeats: true)
    }
    func generateProviceData() {
        if(self.currentIso2 == nil || self.currentIso2 == "") {
            self.currentIso2 = "1234"
        }
        let urll = "https://wuhan-coronavirus-api.laeyoung.endpoint.ainize.ai/jhu-edu/latest?iso2=\(self.currentIso2!)"
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
                return
            }
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options:[])
                if let proviceArr = json as? NSArray {
                    if proviceArr.count > 1 {
                        for elem in proviceArr {
                            if let province = elem as? [String:Any] {
                                self.generateScrollElement(province, true)
                            }
                        }
                    } else {
                        self.generateScrollElement(["":""], false)
                    }
                }
            } catch {
                print("error")
            }
        })

        dataTask.resume()
    }
    func generateScrollElement(_ data : [String:Any], _ customCase : Bool) {
        DispatchQueue.main.async {
            if(customCase) {
                if let cases = data["confirmed"] as? Int, let deaths = data["deaths"] as? Int, let recovered = data["recovered"] as? Int {
                    if(!(cases == 0 && deaths == 0 && recovered == 0)) {
                        let container = UIView(frame: CGRect(x: 10, y: self.yVal, width: Int(self.view.frame.width) - 20, height: 80))
                        container.backgroundColor = .white
                        container.backgroundColor = UIColor(red: 46/255, green: 46/255, blue: 46/255, alpha: 1.0)
                        container.layer.cornerRadius = 5
                        
                        let proviceLabel = UILabel(frame: CGRect(x: 10, y: 20, width: ((self.view.frame.width - 20) * 0.25) - 15, height: 40))
                        proviceLabel.adjustsFontSizeToFitWidth = true
                        proviceLabel.minimumScaleFactor = 0.2
                        proviceLabel.text = data["provincestate"] as? String
                        if(proviceLabel.text == "") {
                            proviceLabel.text = self.countryMark
                        }
                        container.addSubview(proviceLabel)
                        
                        let casesLabel = UILabel(frame: CGRect(x: (self.view.frame.width - 20) * 0.25, y: 1, width: (self.view.frame.width - 20) * 0.25, height: container.frame.height - 2))
                        casesLabel.textAlignment = .center
                        casesLabel.adjustsFontSizeToFitWidth = true
                        casesLabel.minimumScaleFactor = 0.2
                        casesLabel.text = "\(cases)"
                        casesLabel.layer.addBorder(edge: .left, color: UIColor(red: 1, green: 1, blue: 1, alpha: 0.2), thickness: 1)
                        casesLabel.textColor = .white
                        container.addSubview(casesLabel)
                        let deathLabel = UILabel(frame: CGRect(x: (self.view.frame.width - 20) * 0.5, y: 1, width: (self.view.frame.width - 20) * 0.25, height: container.frame.height - 2))
                        deathLabel.textAlignment = .center
                        deathLabel.text = "\(deaths)"
                        deathLabel.adjustsFontSizeToFitWidth = true
                        deathLabel.minimumScaleFactor = 0.2
                        deathLabel.layer.addBorder(edge: .left, color: UIColor(red: 1, green: 1, blue: 1, alpha: 0.2), thickness: 1)
                        deathLabel.textColor = .white
                        container.addSubview(deathLabel)
                        let recovLabel = UILabel(frame: CGRect(x: (self.view.frame.width - 20) * 0.75, y: 1, width:     (self.view.frame.width - 20) * 0.25, height: container.frame.height - 2))
                        recovLabel.textAlignment = .center
                        recovLabel.text = "\(recovered)"
                        recovLabel.adjustsFontSizeToFitWidth = true
                        recovLabel.minimumScaleFactor = 0.2
                        recovLabel.layer.addBorder(edge: .left, color: UIColor(red: 1, green: 1, blue: 1, alpha: 0.2), thickness: 1)
                        recovLabel.textColor = .white
                        container.addSubview(recovLabel)
                        
                        self.provinceScroll.addSubview(container)
                        self.yVal += 90
                        self.provinceScroll.contentSize = CGSize(width: self.provinceScroll.contentSize.width, height: self.provinceScroll.contentSize.height + 90)
                    }
                }
            } else {
                let container = UIView(frame: CGRect(x: 10, y: self.yVal, width: Int(self.view.frame.width) - 20, height: 80))
                container.backgroundColor = .white
                container.backgroundColor = UIColor(red: 46/255, green: 46/255, blue: 46/255, alpha: 1.0)
                container.layer.cornerRadius = 5
                
                let proviceLabel = UILabel(frame: CGRect(x: 10, y: 20, width: ((self.view.frame.width - 20) * 0.25) - 15, height: 40))
                proviceLabel.adjustsFontSizeToFitWidth = true
                proviceLabel.minimumScaleFactor = 0.2
                proviceLabel.text = self.countryMark
                container.addSubview(proviceLabel)
                
                if let casess = self.countrySpecificInfo["cases"] as? Int {
                    let casesLabel = UILabel(frame: CGRect(x: (self.view.frame.width - 20) * 0.25, y: 1, width: (self.view.frame.width - 20) * 0.25, height: container.frame.height - 2))
                    casesLabel.textAlignment = .center
                    casesLabel.adjustsFontSizeToFitWidth = true
                    casesLabel.minimumScaleFactor = 0.2
                    casesLabel.text = "\(casess)"
                    casesLabel.layer.addBorder(edge: .left, color: UIColor(red: 1, green: 1, blue: 1, alpha: 0.2), thickness: 1)
                    casesLabel.textColor = .white
                    container.addSubview(casesLabel)
                }
                if let deathss = self.countrySpecificInfo["deaths"] as? Int {
                    let deathLabel = UILabel(frame: CGRect(x: (self.view.frame.width - 20) * 0.5, y: 1, width: (self.view.frame.width - 20) * 0.25, height: container.frame.height - 2))
                    deathLabel.textAlignment = .center
                    deathLabel.text = "\(deathss)"
                    deathLabel.adjustsFontSizeToFitWidth = true
                    deathLabel.minimumScaleFactor = 0.2
                    deathLabel.layer.addBorder(edge: .left, color: UIColor(red: 1, green: 1, blue: 1, alpha: 0.2), thickness: 1)
                    deathLabel.textColor = .white
                    container.addSubview(deathLabel)
                }
                if let recov = self.countrySpecificInfo["recovered"] as? Int {
                    let recovLabel = UILabel(frame: CGRect(x: (self.view.frame.width - 20) * 0.75, y: 1, width:     (self.view.frame.width - 20) * 0.25, height: container.frame.height - 2))
                    recovLabel.textAlignment = .center
                    recovLabel.text = "\(recov)"
                    recovLabel.adjustsFontSizeToFitWidth = true
                    recovLabel.minimumScaleFactor = 0.2
                    recovLabel.layer.addBorder(edge: .left, color: UIColor(red: 1, green: 1, blue: 1, alpha: 0.2), thickness: 1)
                    recovLabel.textColor = .white
                    container.addSubview(recovLabel)
                }
                
                self.provinceScroll.addSubview(container)
                self.yVal += 90
                self.provinceScroll.contentSize = CGSize(width: self.provinceScroll.contentSize.width, height: self.provinceScroll.contentSize.height + 90)
            }
        }
    }
    func generateCountrySpecificInfo(_ completionHandler: @escaping CompletionHandler) {
        let urll = "https://coronavirus-19-api.herokuapp.com/countries/\(self.heroCountry)"
        let urlString = urll.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let req = NSMutableURLRequest(url: NSURL(string: urlString!)! as URL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        req.httpMethod = "GET"
        let sess = URLSession.shared
        let dataTasker = sess.dataTask(with: req as URLRequest, completionHandler: { (data, response, error) in
            guard error == nil && data != nil else {
                print(error as Any)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
               
                return
            }
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: [])
                if let dict = json as? [String:Any] {
                    self.countrySpecificInfo = dict
                    completionHandler(true)
                }
            } catch {
                print("error")
            }
        })
        dataTasker.resume()
    }
    func generateGraphPoints(_ completionHandler: @escaping CompletionHandler) {
        let req = NSMutableURLRequest(url: NSURL(string: "https://pomber.github.io/covid19/timeseries.json")! as URL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        req.httpMethod = "GET"
        let sess = URLSession.shared
        let dataTasker = sess.dataTask(with: req as URLRequest, completionHandler: { (data, response, error) in
            guard error == nil && data != nil else {
                print(error as Any)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
               
                return
            }
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: [])
                if let dict = json as? [String:Any] {
                    if let countryGraphData = dict[self.countryMark] as? NSArray {
                        for elem in countryGraphData {
                            if let elemDict = elem as? [String:Any] {
                                if let conf = elemDict["confirmed"] as? Int {
                                    self.dataPoints.append(PointEntry(value: conf, label: elemDict["date"] as! String))
                                }
                                if let dea = elemDict["deaths"] as? Int {
                                    self.deathsPoints.append(PointEntry(value: dea, label: elemDict["date"] as! String))
                                }
                                if let reco = elemDict["recovered"] as? Int {
                                    self.recoveredPoints.append(PointEntry(value: reco, label: elemDict["date"] as! String))
                                }
                            }
                        }
                        completionHandler(true)
                    }
               }
            } catch {
                print("error")
            }
        })
        dataTasker.resume()
    }
    func changeGraph(_ data: [PointEntry], _ color: UIColor, _ selected: Int) {
        self.lineChart.removeFromSuperview()
        self.segControl.removeFromSuperview()
        self.lineChart = LineChart(frame: CGRect(x: 5, y: 10, width: self.view.frame.width - 10, height: 300))
        self.lineChart.topColor = color
        self.lineChart.dataEntries = data
        self.lineChart.isCurved = false
        self.lineChart.lineGap = 20
        self.provinceScroll.addSubview(self.lineChart)
        self.provinceScroll.addSubview(self.segControl)
        self.segControl.selectedSegmentIndex = selected
        for v in self.lineChart.subviews {
            if(v is UIScrollView) {
                (v as! UIScrollView).delegate = self
                (v as! UIScrollView).contentSize = CGSize(width: (v as! UIScrollView).contentSize.width + 300, height: (v as! UIScrollView).contentSize.height)
                let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(self.graphPinched(_:)))
                v.addGestureRecognizer(pinchGesture)
            }
        }
    }
    
    @objc func graphPinched(_ pinch: UIPinchGestureRecognizer) {
        var color:Optional = self.lineChart.topColor
        var data:Optional = self.lineChart.dataEntries
        var selected:Optional = self.segControl.selectedSegmentIndex
        var currentLineGap:Optional = self.lineChart.lineGap
        var currentScroll:Optional = (self.lineChart.subviews.first as! UIScrollView).contentOffset
        self.lineChart.removeFromSuperview()
        self.segControl.removeFromSuperview()
        self.lineChart = LineChart(frame: CGRect(x: 5, y: 10, width: self.view.frame.width - 10, height: 300))
        self.lineChart.topColor = color!
        self.lineChart.dataEntries = data
        var scalar:Optional = CGFloat(0.0)
        if(pinch.scale < 1) {
            scalar = currentLineGap! * pinch.scale * 0.33
        } else {
            scalar = currentLineGap! * pinch.scale * 3
        }
        if(scalar! < CGFloat(5)) {
            scalar = 5
        } else if(scalar! > CGFloat(100)) {
            scalar = 100
        }
        self.lineChart.lineGap = scalar!
        self.lineChart.isCurved = false
        self.provinceScroll.addSubview(self.lineChart)
        self.provinceScroll.addSubview(self.segControl)
        self.segControl.selectedSegmentIndex = selected!
        for v in self.lineChart.subviews {
            if(v is UIScrollView) {
                (v as! UIScrollView).delegate = self
                (v as! UIScrollView).contentOffset = currentScroll!
                (v as! UIScrollView).contentSize = CGSize(width: (v as! UIScrollView).contentSize.width + 300, height: (v as! UIScrollView).contentSize.height)
                let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(self.graphPinched(_:)))
                v.addGestureRecognizer(pinchGesture)
            }
        }
        color = nil
        data = nil
        selected = nil
        currentLineGap = nil
        currentScroll = nil
    }
    @objc func segValueChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            self.changeGraph(self.dataPoints, .red, 0)
        case 1:
            self.changeGraph(self.deathsPoints, .gray, 1)
        case 2:
            self.changeGraph(self.recoveredPoints, .green, 2)
        default:
            self.changeGraph(self.dataPoints, .red, 0)
        }
    }
    @objc func showScrollIndicatorsInContacts() {
        DispatchQueue.main.async {
            for v in self.lineChart.subviews {
                if(v is UIScrollView) {
                    (v as! UIScrollView).flashScrollIndicators()
                }
            }
        }
    }
    @objc func backButtonTapped(_ tap : UILongPressGestureRecognizer) {
        if(tap.state == .began) {
            self.backButton.alpha = 0.0
        } else if(tap.state == .ended) {
            UIView.animate(withDuration: 0.2) {
                self.backButton.alpha = 1.0
            }
            let transition = CATransition()
            transition.duration = 0.4
            transition.type = CATransitionType.push
            transition.subtype = CATransitionSubtype.fromLeft
            transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
            view.window!.layer.add(transition, forKey: kCATransition)
            self.dismiss(animated: false, completion: nil)
        }
    }
}
