//
//  ViewController.swift
//  MyMap
//
//  Created by 김하은 on 2022/07/01.
//

import UIKit
import MapKit           // 지도를 사용하기 위해 import를 해준다.
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
    
    // 내 위치로 돌아가는 버튼을 생성한다.
    lazy var locationBtn: UIButton = {
        let btn1 = UIButton()                    // 버튼 생성하기 위한 변수 생성
//        btn1.setTitle("내 위치", for: .normal)     // 버튼에 들어갈 글씨
//        btn1.backgroundColor = .systemGray       // 버튼 색상
//        btn1.setTitleColor(.white, for: .normal) // 버튼 글씨 색상
        btn1.setImage(UIImage(systemName: "person"), for: .normal)
        btn1.tintColor = .black
        btn1.addTarget(self, action: #selector(goUserPosition), for: .touchUpInside)   // 버튼이 경계 안에서 터치 됐을때 buttonAction이 작동한다.
        return btn1
    }()
    
    // buttonAction을 설정하기 위한 함수
    @objc func goUserPosition(sender: UIButton!) {
        print("내 위치로 이동")           // 작동되는지 확인하기 위한 print문
        // 설정한 위치로 이동한다.
        self.mapView.setUserTrackingMode(.follow, animated: true)   // 위치에 따라 화면이 바뀐다.
//        DispatchQueue.main.async - 지금은 비동기를 해 줄 필요가 없다.
    }
    
    // 지도 뷰를 바꾸는 버튼을 생성한다.
    lazy var changeMapViewBtn: UIButton = {
        let btn3 = UIButton()                    // 버튼 생성하기 위한 변수 생성
        btn3.setImage(UIImage(systemName: "location.circle"), for: .normal)
        btn3.tintColor = .blue
        btn3.addTarget(self, action: #selector(changeMapView), for: .touchUpInside)   // 버튼이 경계 안에서 터치 됐을때 buttonAction이 작동한다.
        return btn3
    }()
    
    // 지도 뷰를 바꾸기 위해 필요한 변수
    var changing = false
    
    // buttonAction을 설정하기 위한 함수
    @objc func changeMapView(sender: Any) {
        if changing {
            print("기본지도 뷰로 변경")           // 작동되는지 확인하기 위한 print문
            mapView.mapType = MKMapType.standard   // 기본지도
            changing = false
        } else {
            print("위성지도 뷰로 변경")           // 작동되는지 확인하기 위한 print문
            mapView.mapType = MKMapType.satellite    // 위성지도
            changing = true
        }
    }
    
    // 위치를 나타낼 함수
    func createMarker(title: String, subtitle: String, coordinate: CLLocationCoordinate2D) {
        let marker = Marker(title: title, subtitle: subtitle, coordinate: coordinate)
        mapView.addAnnotation(marker)
    }
    
    // 클릭 재스처를 추가하기 위한 함수
    func addGesture() {
        let touch = UITapGestureRecognizer(target: self, action: #selector(didClickMapView(sender:)))
        self.mapView.addGestureRecognizer(touch)
    }
    
    // 핀 생성 버튼
    lazy var createMarkerButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "mappin.and.ellipse"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(createMarkerAction), for: .touchUpInside)
        return button
    }()
    
    let popupView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // title 입력 textfield
    lazy var titleText: UITextField = {
        let title = UITextField()
        title.frame = CGRect(x: 65, y: 60, width: 200, height: 30)
        title.placeholder = "장소 이름"           // textfield 기본 텍스트
        title.borderStyle = .roundedRect
        title.clearButtonMode = .whileEditing   // 입력하기 위해서 clear한 btn상태
        return title
    }()
    
    // subtitle 입력 textfield
    lazy var subtitleText: UITextField = {
        let subtitle = UITextField()
        subtitle.frame = CGRect(x: 65, y: 120, width: 200, height: 30)
        subtitle.placeholder = "장소 설명"           // textfield 기본 텍스트
        subtitle.borderStyle = .roundedRect
        subtitle.clearButtonMode = .whileEditing   // 입력하기 위해서 clear한 btn상태
        return subtitle
    }()
    
    // 확인버튼
    lazy var checkBtn: UIButton = {
        let checkBtn = UIButton()
        checkBtn.setImage(UIImage(systemName: "checkmark.rectangle"), for: .normal)
        checkBtn.translatesAutoresizingMaskIntoConstraints = false
        checkBtn.tintColor = .black
        checkBtn.sizeToFit()
        checkBtn.addTarget(self, action: #selector(confirmAction), for: .touchUpInside)
        return checkBtn
    }()
    
    // popupView에 넣기
    
    // 생성하고자하는 위치
    var willCreateLocation: CLLocationCoordinate2D = CLLocationCoordinate2D()
    
    override func viewDidLoad() {
        // 어떤 함수와 어떤 변수가 있는지 한 번 읽어온다.
        super.viewDidLoad()
        
        getLocationUsagePermission()        // 권한을 요청하기 위한 창
        self.mapView.showsUserLocation = true   // 사용자 위치를 나타낸 것을 보여준다.
        
        // addSubview를 해주고 아래 제약조건을 작성해야 됨.
        self.view.addSubview(mapView)
        // btn을 넣어준다.
        self.view.addSubview(locationBtn)
        self.view.addSubview(changeMapViewBtn)
        self.view.addSubview(createMarkerButton)
        self.view.addSubview(popupView)
        self.popupView.addSubview(titleText)
        self.popupView.addSubview(subtitleText)
        self.popupView.addSubview(checkBtn)
        
        // View 위치 설정(제약조건)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        mapView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        mapView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        
        // btn1 위치 설정(제약 조건)
        locationBtn.translatesAutoresizingMaskIntoConstraints = false
        locationBtn.widthAnchor.constraint(equalToConstant: 50).isActive = true
        locationBtn.heightAnchor.constraint(equalToConstant: 50).isActive = true
        locationBtn.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10).isActive = true
        locationBtn.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        
        // btn2 위치 설정(제약 조건)
        changeMapViewBtn.translatesAutoresizingMaskIntoConstraints = false
        changeMapViewBtn.widthAnchor.constraint(equalToConstant: 50).isActive = true
        changeMapViewBtn.heightAnchor.constraint(equalToConstant: 50).isActive = true
        changeMapViewBtn.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10).isActive = true
        changeMapViewBtn.topAnchor.constraint(equalTo: locationBtn.topAnchor, constant: 50).isActive = true
        
        // button 위치 설정
        createMarkerButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        createMarkerButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        createMarkerButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10).isActive = true
        createMarkerButton.topAnchor.constraint(equalTo: locationBtn.topAnchor, constant: 90).isActive = true
        
        // popupView 위치 설정
        popupView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 200).isActive = true
        popupView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -100).isActive = true
        popupView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 30).isActive = true
        popupView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -30).isActive = true
        
        // popupView Btn 위치 설정
        checkBtn.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 400).isActive = true
        checkBtn.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -100).isActive = true
        checkBtn.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 30).isActive = true
        checkBtn.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -30).isActive = true
        
        createMarker(title: "태마파크", subtitle: "디즈니랜드", coordinate: CLLocationCoordinate2D(latitude: 33.812097, longitude: -117.918969))
        
        addGesture()
    }
    
    func getLocationUsagePermission() {
        self.lovationManager.requestWhenInUseAuthorization()    // 권한을 요청하는 것
    }
}

// MARK: - 오브젝트 함수 모음

extension ViewController {
    // 앱을 클릭하면 실행되는 함수
    @objc func didClickMapView(sender: UITapGestureRecognizer) {
        // popupView 띄우기
        createMarkerAction()
        
        let location: CGPoint = sender.location(in: self.mapView)
//        let mapLocation: CLLocationCoordinate2D = self.mapView.convert(location, toCoordinateFrom: self.mapView)
        willCreateLocation = self.mapView.convert(location, toCoordinateFrom: self.mapView)
        
//        print("위도 : \(mapLoscation.latitude), 경도 : \(mapLocation.longitude)")
        
        // 클릭된 상태에서는 생성되면 안됨.
//        createMarker(title: "Test", subtitle: "Test!!", coordinate: mapLocation)
    }
    
    @objc func createMarkerAction() {
        // 흰색 뷰를 보이게
        print("흰색 popView")
        popupView.isHidden.toggle()
    }
    
    // 확인 버튼 액션
    @objc func confirmAction() {
        print("위도: \(willCreateLocation.latitude), 경도: \(willCreateLocation.longitude)")
        createMarker(title: "\(titleText)", subtitle: "\(subtitleText)", coordinate: willCreateLocation)

        popupView.isHidden = true   // 팝업창 닫기
    }
}

// MARK: - GPS 권한 함수 모음

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

