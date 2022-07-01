//
//  ViewController.swift
//  MyMap
//
//  Created by 김하은 on 2022/07/01.
//

import UIKit
import MapKit   // 지도를 사용하기 위해 import를 해준다.
import CoreLocation     // GPS를 사용하기 위해 import를 해준다.

class ViewController: UIViewController {

    // View를 변수에 넣어 생성한다.
    let mapView: MKMapView = {
        let map = MKMapView()
        map.overrideUserInterfaceStyle = .light // 다크모드, 라이트모드 설정
        return map
    }()
    
    // GPS를 사용하기 위한 변수를 생성한다.
    lazy var lovationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.startUpdatingLocation()     // startUpdate를 해야 didUpdateLocation 메서드가 호출된다.
        manager.delegate = self
        
        return manager
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getLocationUsagePermission()        // 권한을 요청하기 위한 창
        self.mapView.showsUserLocation = true   // 사용자 위치를 나타낸 것을 보여준다.
        
        // addSubview를 해주고 아래 제약조건을 작성해야 됨.
        self.view.addSubview(mapView)
        
        // View 위치 설정(제약조건)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        mapView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        mapView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        
    }
    
    func getLocationUsagePermission() {
        self.lovationManager.requestWhenInUseAuthorization()    // 권한을 요청하는 것
    }
}

extension ViewController: CLLocationManagerDelegate {   // 기능 별로 분리해서 상속으로 표현하는 것이 좋다.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:   // 권한 동의를 누른 상태
            print("GPS 권한 설정됨.")
            DispatchQueue.main.async {
                self.mapView.setUserTrackingMode(.follow, animated: true)   // 위치에 따라 화면이 바뀐다.
            }
        case .restricted, .notDetermined:               // 권한 동의 버튼 자체를 누르지 않은 상태
            print("GPS 권한 설정되지 않음.")
            DispatchQueue.main.async {                  // 권한 요청을 비동기로 보냄. (팝업으로 띄워야되기 때문이다. 만약 비동기를 사용하지 않으면 권한 설정이 될 때까지 작동하지 않음.)
                self.getLocationUsagePermission()
            }
        case .denied:                                   // 권한 거부를 누른 상태
            print("GPS 권한 요청 거부됨.")
            DispatchQueue.main.async {
                self.getLocationUsagePermission()
            }
        default:
            print("GPS: Default")
        }
    }
}

