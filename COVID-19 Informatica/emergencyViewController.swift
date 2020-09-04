import UIKit

class emergencyViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var yVal = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .dark
        
        let infoLabel = UILabel(frame: CGRect(x: 20, y: self.yVal, width: Int(self.view.frame.width - 40), height: 50))
        infoLabel.text = "About COVID-19"
        infoLabel.textColor = .white
        infoLabel.font = infoLabel.font.withSize(25)
        self.scrollView.addSubview(infoLabel)
        self.yVal += 40
        
        self.scrollView.contentSize = CGSize(width: self.scrollView.contentSize.width, height: self.scrollView.contentSize.height + 50)
                
        let covidLabel = UILabel(frame: CGRect(x: 20, y: self.yVal, width: Int(self.view.frame.width - 40), height: 300))
        covidLabel.text = "Coronavirus disease (COVID-19) is an infectious disease caused by a newly discovered coronavirus. \nMost people infected with the COVID-19 virus will experience mild to moderate respiratory illness and recover without requiring special treatment.  Older people, and those with underlying medical problems like cardiovascular disease, diabetes, chronic respiratory disease, and cancer are more likely to develop serious illness."
        covidLabel.numberOfLines = 0
        covidLabel.adjustsFontSizeToFitWidth = true
        covidLabel.minimumScaleFactor = 0.2
        covidLabel.textColor = .white
        self.scrollView.addSubview(covidLabel)
        self.yVal += 300
        
        self.scrollView.contentSize = CGSize(width: self.scrollView.contentSize.width, height: self.scrollView.contentSize.height + 300)
        
        let whoButton = UIButton(frame: CGRect(x: 20, y: self.yVal, width: Int(self.view.frame.width - 40), height: 50))
        whoButton.setTitle("Visit WHO website to continue reading >", for: .normal)
        whoButton.setTitleColor(.red, for: .normal)
        whoButton.addTarget(self, action: #selector(self.whoButtonClicked(_:)), for: .touchUpInside)
        self.scrollView.addSubview(whoButton)
        self.yVal += 60
        
        self.scrollView.contentSize = CGSize(width: self.scrollView.contentSize.width, height: self.scrollView.contentSize.height + 60)
        
        let sickLabel = UILabel(frame: CGRect(x: 20, y: self.yVal, width: Int(self.view.frame.width - 40), height: 50))
        sickLabel.text = "What to do if You are Sick"
        sickLabel.textColor = .white
        sickLabel.font = infoLabel.font.withSize(25)
        self.scrollView.addSubview(sickLabel)
        self.yVal += 40
        
        self.scrollView.contentSize = CGSize(width: self.scrollView.contentSize.width, height: self.scrollView.contentSize.height + 50)
        
        let sickLabelStep1 = UILabel(frame: CGRect(x: 20, y: self.yVal, width: Int(self.view.frame.width - 40), height: 50))
        sickLabelStep1.text = "Stay home except to get medical care"
        sickLabelStep1.numberOfLines = 0
        sickLabelStep1.textColor = .white
        self.scrollView.addSubview(sickLabelStep1)
        self.yVal += 40
        
        let sickLabelStep11 = UILabel(frame: CGRect(x: 40, y: self.yVal, width: Int(self.view.frame.width - 40), height: 200))
        sickLabelStep11.text = "-Stay home: People who are mildly ill with COVID-19 are able to recover at home. Do not leave, except to get medical care. Do not visit public areas. \n-Stay in touch with your doctor. Call before you get medical care. Be sure to get care if you feel worse or you think it is an emergency. \n-Avoid public transportation: Avoid using public transportation, ride-sharing, or taxis."
        sickLabelStep11.numberOfLines = 0
        sickLabelStep11.adjustsFontSizeToFitWidth = true
        sickLabelStep11.minimumScaleFactor = 0.2
        sickLabelStep11.textColor = .white
        self.scrollView.addSubview(sickLabelStep11)
        self.yVal += 210
        
        self.scrollView.contentSize = CGSize(width: self.scrollView.contentSize.width, height: self.scrollView.contentSize.height + 210)
        
        let sickLabelStep2 = UILabel(frame: CGRect(x: 20, y: self.yVal, width: Int(self.view.frame.width - 40), height: 50))
        sickLabelStep2.text = "Separate yourself from other people in your home, this is known as home isolation"
        sickLabelStep2.numberOfLines = 0
        sickLabelStep2.textColor = .white
        self.scrollView.addSubview(sickLabelStep2)
        self.yVal += 40
        
        self.scrollView.contentSize = CGSize(width: self.scrollView.contentSize.width, height: self.scrollView.contentSize.height + 50)
        
        let sickLabelStep21 = UILabel(frame: CGRect(x: 40, y: self.yVal, width: Int(self.view.frame.width - 40), height: 200))
        sickLabelStep21.text = "-Stay away from others: As much as possible, you should stay in a specific “sick room” and away from other people in your home. Use a separate bathroom, if available. \n-Limit contact with pets & animals: You should restrict contact with pets and other animals, just like you would around other people."
        sickLabelStep21.numberOfLines = 0
        sickLabelStep21.adjustsFontSizeToFitWidth = true
        sickLabelStep21.minimumScaleFactor = 0.2
        sickLabelStep21.textColor = .white
        self.scrollView.addSubview(sickLabelStep21)
        self.yVal += 200
        
        self.scrollView.contentSize = CGSize(width: self.scrollView.contentSize.width, height: self.scrollView.contentSize.height + 210)
        
        let sickLabelStep3 = UILabel(frame: CGRect(x: 20, y: self.yVal, width: Int(self.view.frame.width - 40), height: 50))
        sickLabelStep3.text = "Call ahead before visiting your doctor"
        sickLabelStep3.numberOfLines = 0
        sickLabelStep3.textColor = .white
        self.scrollView.addSubview(sickLabelStep3)
        self.yVal += 40
        
        self.scrollView.contentSize = CGSize(width: self.scrollView.contentSize.width, height: self.scrollView.contentSize.height + 50)
        
        let sickLabelStep31 = UILabel(frame: CGRect(x: 40, y: self.yVal, width: Int(self.view.frame.width - 40), height: 100))
        sickLabelStep31.text = "-Call ahead: If you have a medical appointment, call your doctor’s office or emergency department, and tell them you have or may have COVID-19. This will help the office protect themselves and other patients."
        sickLabelStep31.numberOfLines = 0
        sickLabelStep31.adjustsFontSizeToFitWidth = true
        sickLabelStep31.minimumScaleFactor = 0.2
        sickLabelStep31.textColor = .white
        self.scrollView.addSubview(sickLabelStep31)
        self.yVal += 100
        
        self.scrollView.contentSize = CGSize(width: self.scrollView.contentSize.width, height: self.scrollView.contentSize.height + 110)
        
        let cdcButton = UIButton(frame: CGRect(x: 20, y: self.yVal, width: Int(self.view.frame.width - 40), height: 50))
        cdcButton.setTitle("Visit CDC website to continue reading >", for: .normal)
        cdcButton.setTitleColor(.red, for: .normal)
        cdcButton.addTarget(self, action: #selector(self.cdcButtonClicked(_:)), for: .touchUpInside)
        self.scrollView.addSubview(cdcButton)
        self.yVal += 60
        
        self.scrollView.contentSize = CGSize(width: self.scrollView.contentSize.width, height: self.scrollView.contentSize.height + 60)
        // Do any additional setup after loading the view.
    }
    
    @objc func whoButtonClicked(_ tap: UITapGestureRecognizer) {
        UIApplication.shared.open(URL(string: "https://www.who.int/health-topics/coronavirus#tab=tab_1")!, options: [:], completionHandler: nil)
    }
    @objc func cdcButtonClicked(_ tap: UITapGestureRecognizer) {
        UIApplication.shared.open(URL(string: "https://www.cdc.gov/coronavirus/2019-ncov/if-you-are-sick/steps-when-sick.html")!, options: [:], completionHandler: nil)
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
