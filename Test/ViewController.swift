//
//  ViewController.swift
//  Test
//
//  Created by 衡成飞 on 10/21/16.
//  Copyright © 2016 qianwang. All rights reserved.
//

import UIKit
import WebKit
import CoreLocation

class ViewController: UIViewController,CLLocationManagerDelegate,WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler{
    
    @IBOutlet weak var latLabel:UILabel!
    @IBOutlet weak var lngLabel:UILabel!
    @IBOutlet weak var timeLabel:UILabel!
    @IBOutlet weak var speedLabel:UILabel!
    @IBOutlet weak var courseLabel:UILabel!
    
    var webview:WKWebView!
    let locationManager = CLLocationManager()
    fileprivate var marketTimer:Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setupLocation()
        setupWebview()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.marketTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(refresh), userInfo: nil, repeats: true)
        self.marketTimer!.fire()
        
    }
    
    func refresh(){
        locationManager.startUpdatingLocation()
    }
    
    func setupWebview(){
        
        var frame = self.view.frame
        frame.origin.y = 130
        frame.size.height = frame.size.height - 130
        
        let conf = WKWebViewConfiguration()
        webview = WKWebView(frame: frame, configuration: conf)
        
        webview.navigationDelegate = self
        webview.uiDelegate = self
        self.view.addSubview(webview)
 
        let request = URLRequest(url: URL(string: "http://nearby.qbao.com/login?username=syy010&sign=2aae19dc6647913ee87cd08d46cec493")!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 60)
        
        webview.load(request)
    }
    
    func setupLocation(){
        locationManager.delegate = self
        
        //定位进度
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.allowsBackgroundLocationUpdates = true
//        //更新距离
        locationManager.distanceFilter = 10
        
        
        //发送授权申请
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            //允许使用定位服务的话，开启定位服务更新
            locationManager.startUpdatingLocation()
            
            print("定位开始")
        }
    }
    
    
    //MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //获取最新的坐标
        let currentLocation = locations.last!
        

        
        let lat = currentLocation.coordinate.longitude
        let lng = currentLocation.coordinate.latitude
        let alt = currentLocation.altitude//海拔
        let course = currentLocation.course //方向
        let speed = currentLocation.speed//速度
        let time = currentLocation.timestamp//timestamp
        let dict:[String:Any] = ["lat":lat,
                    "lng":lng,
                    "alt":alt,
                    "course":course,
                    "speed":"\(speed)",
                     "time":"\(time)"]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
        let json = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)
        
     
        webview.evaluateJavaScript("callMap(\(json!))") { (v, error) in
            //print(error.debugDescription)
        }
        
        lngLabel.text = "经度：" + "\(lng)"
        latLabel.text = "纬度：" + "\(lat)"
        timeLabel.text = "时间：" + "\(time)"
        speedLabel.text = "速度：" + "\(speed)"
        courseLabel.text = "方向：" + "\(course)"
    }
    
    // MARK: -  WKScriptMessageHandler
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
//        let name = message.name
//        let data = message.body
    }
    

    
    
    deinit{
        webview.navigationDelegate = nil
        webview.uiDelegate = nil
    }
}

