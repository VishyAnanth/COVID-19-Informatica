import UIKit
import MapKit

class mapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var pointAnnotation:MKPointAnnotation!
    var iso2Arr = [String:[Any]]()
    
    typealias CompletionHandler = (_ success:Bool) -> Void
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .dark
        self.mapView.delegate = self
        if let isoArr = UserDefaults.standard.value(forKey: "_WORLD_ISO2") as? [String] {
            for iso in isoArr {
                let urll = "https://wuhan-coronavirus-api.laeyoung.endpoint.ainize.ai/jhu-edu/latest?iso2=\(iso)"
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
                            for elem in proviceArr {
                                if let province = elem as? [String:Any] {
                                    self.generateMapElement(province, iso)
                                }
                            }
                        }
                    } catch {
                        print("error")
                    }
                })
                dataTask.resume()
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            let region = MKCoordinateRegion( center: CLLocationCoordinate2D(latitude: 54.5260, longitude: -105.2551), latitudinalMeters: CLLocationDistance(exactly: 9000000)!, longitudinalMeters: CLLocationDistance(exactly: 9000000)!)
            self.mapView.setRegion(self.mapView.regionThatFits(region), animated: true)
        })
    }
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        UserDefaults.standard.set(UIImage(named: "Clear.png")!.pngData(), forKey: "_CURRENT_FlAG")
        UserDefaults.standard.set(self.iso2Arr[(view.annotation as! MKPointAnnotation).accessibilityLabel!]![1], forKey: "_CURRENT_ISO2")
        UserDefaults.standard.set(self.iso2Arr[(view.annotation as! MKPointAnnotation).accessibilityLabel!]![2], forKey: "_CURRENT_COUNTRY")
        self.performSegue(withIdentifier: "mapToCountry", sender: self)
    }
    func generateMapElement(_ data: [String:Any], _ iso2: String) {
        if let casess = data["confirmed"] as? Int, casess > 0 {
            if let location = data["location"] as? [String:Any], let country = data["countryregion"] as? String {
                if let lat = location["lat"] as? CGFloat, let lon = location["lng"] as? CGFloat {
                    let randomStr = self.randomString(length: 10)
                    let location = CLLocationCoordinate2D(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(lon))
                    self.iso2Arr[randomStr] = [casess, iso2, country]
                    let annotation = MKPointAnnotation()
                    annotation.accessibilityLabel = randomStr
                    annotation.coordinate = location
                    annotation.title = (data["confirmed"] as? Int)?.description
                    let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: randomStr)
                    annotation.title = casess.description
                    self.mapView.addAnnotation(annotationView.annotation!)
                }
            }
        }
    }
    func randomString(length: Int) -> String {
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)

        var randomString = ""

        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }

        return randomString
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationIdentifier = (annotation as! MKPointAnnotation).accessibilityLabel!
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier)
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            annotationView!.canShowCallout = true
        }
        else {
            annotationView!.annotation = annotation
        }
        
        let circleView = UIView(frame: CGRect(x: -20, y: -20, width: 40, height: 40))
        circleView.layer.cornerRadius = circleView.frame.width / 2
        circleView.backgroundColor = .red
        
        let label = UILabel(frame: CGRect(x: 5, y: 5, width: 30, height: 30))
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.2
        label.textAlignment = .center
        label.text = (self.iso2Arr[annotationIdentifier]![0] as? Int)?.description
        label.textColor = .white
        
        circleView.addSubview(label)
        annotationView?.addSubview(circleView)
        return annotationView
    }
}
