---
title: iOS 开发地图常见功能总结（定位、标注大头针、划线、路径规划、导航、地理围栏等）
date: 2020-11-14 19:27:25
tags: 
- iOS
- 地图
categories:
- iOS
- 定位
---

### 前言

最近开发的项目使用了一些第三方地图的功能，主要包括：

- 定位
- POI（附近，模糊）搜索
- 地理编码和逆编码
- 地图展示 
- 标记点（大头针）
- 线段，图形，覆盖物（折线，直线，圆形，不规则图形）
- 导航（内部导航，跳转其他地图 App 导航）
- 地理围栏

> 主要包含了高德地图、谷歌地图等，其他的地图如百度地图，腾讯地图等参考相关文档其实差别也不大。

文章主要记录一下相关代码和一些集成调试踩过的一些坑，防止忘记，归个档。



### 废话不多说，先看效果：

#### <img src="https://image-1254431338.cos.ap-guangzhou.myqcloud.com/2020-11-14-105920201114185932086" style="zoom: 25%;" /><img src="https://image-1254431338.cos.ap-guangzhou.myqcloud.com/2020-11-14-105932.png" alt="image-20201114185932086" style="zoom: 25%;" />

![ezgif.com-gif-makereee](https://image-1254431338.cos.ap-guangzhou.myqcloud.com/2020-11-14-112339.gif)





#### <img src="https://image-1254431338.cos.ap-guangzhou.myqcloud.com/2020-11-14-111311.gif" style="zoom: 50%;" />

<img src="https://image-1254431338.cos.ap-guangzhou.myqcloud.com/2020-11-14-110809.png" alt="image-20201114190809301" style="zoom:25%;" />

<img src="https://image-1254431338.cos.ap-guangzhou.myqcloud.com/2020-11-14-114426.png" alt="image-20201114194426235" style="zoom:33%;" />

### 定位

`CoreLocation 框架`， `CLLocationManager` 类。

#### 定位 - 系统原生

```swift
// 1. 初始化 CLLocationManager 实例
locationManager.delegate = self
locationManager.requestAlwaysAuthorization()
locationManager.desiredAccuracy = kCLLocationAccuracyBest
locationManager.distanceFilter = kCLDistanceFilterNone

// 持续定位上报
locationManager.allowsBackgroundLocationUpdates = true
// 是否允许中断定位功能
locationManager.pausesLocationUpdatesAutomatically = false

locationManager.startUpdatingLocation()

// 权限判断
let status  = CLLocationManager.authorizationStatus()
        
if status == .notDetermined {
    locationManager.requestWhenInUseAuthorization()
}

if status == .denied || status == .restricted {
    let alert = UIAlertController(title: "定位权限未开启", message: "请前往设置允许访问您的定位权限", preferredStyle: .alert)
    let okAction = UIAlertAction(title: "去开启", style: .default, handler: { _ in
        // 打开设置
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
    })

    alert.addAction(okAction)
    let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
    alert.addAction(cancelAction)

    UIApplication.shared.visibleVC().present(alert, animated: true, completion: nil)
    return
}

// 3. 代理回调 CLLocationManagerDelegate
func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    let currentLocation = locations.last
    
    // 得到经纬度
    let currentCoordinate2D = currentLocation?.coordinate
    guard let latitude = currentCoordinate2D?.latitude, let longitude = currentCoordinate2D?.longitude else { return }

    // 定位成功后停止定位
    locationManager.stopUpdatingLocation()
}

// 发生错误
func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    
}

```



#### 定位 - 高德定位

> 1. 在[高德开放平台](https://lbs.amap.com/)注册账号
> 2. 新建应用
> 3. 拿到 key，在 App 启动的时候设置 

```swift
// 设置 key
AMapServices.shared()?.apiKey = "\(appKey)"


// 1. 初始化 AMapLocationManager 实例
private lazy var locationManager : AMapLocationManager = {
    let managner = AMapLocationManager()
    managner.delegate = self
    managner.pausesLocationUpdatesAutomatically = false
    // 定位精度
    managner.desiredAccuracy = kCLLocationAccuracyBest
    // 是否允许后台定位
    managner.allowsBackgroundLocationUpdates = false
    
    // 指定单次定位超时时间,默认为10s。最小值是2s。注意单次定位请求前设置。注意: 单次定位超时时间从确定了定位权限(非kCLAuthorizationStatusNotDetermined状态)后开始计算。
    manager.locationTimeout = 2
    // 指定单次定位逆地理超时时间,默认为5s。最小值是2s。注意单次定位请求前设置。
    manager.reGeocodeTimeout = 2
    
    return managner
}()

// 2. 开始连续定位。调用此方法会cancel掉所有的单次定位请求。
locationManager.startUpdatingLocation()

// 3. 停止连续定位。调用此方法会cancel掉所有的单次定位请求，可以用来取消单次定位。
locationManager.stopUpdatingLocation()

// 4. 单次定位。如果当前正在连续定位，调用此方法将会失败，返回NO。\n该方法将会根据设定的 desiredAccuracy 去获取定位信息。如果获取的定位信息精确度低于 desiredAccuracy ，将会持续的等待定位信息，直到超时后通过completionBlock返回精度最高的定位信息。\n可以通过 stopUpdatingLocation 方法去取消正在进行的单次定位请求。
// withReGeocode: 是否带有逆地理信息(获取逆地理信息需要联网)
locationManager.requestLocation(withReGeocode: true) { (location, regeocode, error) in
    guard error == nil else { return }
    guard let regeocode = regeocode else { return }
    print(regeocode)
}

// 5. 代理回调  AMapLocationManagerDelegate

// 定位成功
func amapLocationManager(_ manager: AMapLocationManager!, didUpdate location: CLLocation!, reGeocode: AMapLocationReGeocode!) {
    	
}

// 定位失败
func amapLocationManager(_ manager: AMapLocationManager!, didFailWithError error: Error!) {
	
}

// 请求定位授权
func amapLocationManager(_ manager: AMapLocationManager!, doRequireLocationAuth locationManager: CLLocationManager!) {
    locationManager.requestAlwaysAuthorization()
}
```



#### 定位 - Google 定位

> 1. 在 https://cloud.google.com/maps-platform/ 平台注册开发者账号
> 2. 申请 API key
> 3. ![image-20201114173121575](https://image-1254431338.cos.ap-guangzhou.myqcloud.com/2020-11-14-094340.png)
>
> 



```swift
// 设置 API key
GMSServices.provideAPIKey("\(Google API key)")
```



### POI（Point of Interest，兴趣点）&& 地理编码、逆编码  &&  路径规划

#### POI（Point of Interest，兴趣点）&& 地理编码、逆编码  &&  路径规划 -  高德地图

> 高德地图 SDK 封装了 AMapSearchObject 基类对象，具体的搜搜请求对象和响应对象都由子类去继承实现。

```swift
// 1、初始化搜索对象，设置代理
private lazy var search: AMapSearchAPI = {
     let object = AMapSearchAPI()!
     object.delegate = self
     return object
}()


//---------  附近 ：构造请求对象 ----------- 
let request = AMapPOIAroundSearchRequest()
// 当地定位经纬度
request.location = AMapGeoPoint.location(withLatitude: currentCoordinate!.latitude.cgFloat, longitude: currentCoordinate!.longitude.cgFloat)
request.sortrule = 0
// 类型，多个类型用“|”分割 可选值:文本分类、分类代码 
// 高德地图的POI类别共20个大类，分别为：汽车服务、汽车销售、汽车维修、摩托车服务、餐饮服务、购物服务、生活服务、体育休闲服务、医疗保健服务、住宿服务、风景名胜、商务住宅、政府机构及社会团体、科教文化服务、交通设施服务、金融保险服务、公司企业、道路附属设施、地名地址信息、公共设施，同时，每个大类别都还有二级以及三级的细小划。
request.types = "风景名胜|商务住宅|政府机构及社会团体|交通设施服务|公司企业|道路附属设施|地名地址信息"
request.requireExtension = true
// 当前页数
request.page = page
request.requireSubPOIs = true

// 发起搜索
search.aMapPOIAroundSearch(request)


// ----------------- 关键词搜索 构造请求对象 ------------------------------
let request = AMapPOIKeywordsSearchRequest()
request.keywords = keywords
// 指定城市
request.city = city
request.sortrule = 0
request.requireExtension = true
request.page = page
request.cityLimit = false
request.requireSubPOIs = true
request.types = "风景名胜|商务住宅|政府机构及社会团体|交通设施服务|公司企业|道路附属设施|地名地址信息"

// 关键词搜索 - 高德： 发起关键词搜索
search.aMapPOIKeywordsSearch(request)


// ----------- 地理编码：地理编码，又称为地址匹配，是从已知的地址描述到对应的经纬度坐标的转换过程。该功能适用于根据用户输入的地址确认用户具体位置的场景，常用于配送人员根据用户输入的具体地址找地点。-----------
let request = AMapGeocodeSearchRequest()
// 位置信息：地理编码是依据当前输入，根据标准化的地址结构（省/市/区或县/乡/村或社区/商圈/街道/门牌号/POI）进行各个地址级别的匹配，以确认输入地址对应的地理坐标，只有返回的地理坐标匹配的级别为POI，才会对应一个具体的地物（POI）。
request.address = address

// 发起地理编码搜索请求
search.aMapGeocodeSearch(request)


// -------------------------------- AMapSearchDelegate --------------------------------------
// POI 搜索回调
func onPOISearchDone(_ request: AMapPOISearchBaseRequest!, response: AMapPOISearchResponse!) {
    
    if response.count == 0 {
        return
    }
    
    //解析response获取POI信息
}

// 地理编码（地址转坐标）回调
func onGeocodeSearchDone(_ request: AMapGeocodeSearchRequest!, response: AMapGeocodeSearchResponse!) {
    // 解析response获取地理信息，
   
}

// 路线规划
func onRouteSearchDone(_ request: AMapRouteSearchBaseRequest!, response: AMapRouteSearchResponse!) {
    if response.count > 0 {
        //解析response获取路径信息
    }
}

// 搜索出现错误    
func aMapSearchRequest(_ request: Any!, didFailWithError error: Error!) {

}
```



#### POI（Point of Interest，兴趣点）&& 地理编码、逆编码  &&  路径规划 -  Google 地图

> Google 地图这些 POI 搜索，导航数据这些，提供的是 HTTP API 请求调用的方式。

```swift
// 谷歌地图 POI 关键词模糊搜索
// https://maps.googleapis.com/maps/api/place/textsearch/json
var params: [String: Any] = [:]
params["key"] = "\(Google API key)"
// 语言 ： 
params["language"] = "en"
params["query"] = "\(关键词文本)"
params["inputType"] = "textQuery"
//  params["region"] =


// 谷歌地图 POI 附近搜索
// https://maps.googleapis.com/maps/api/place/nearbysearch/json
var params: [String: Any] = [:]
params["key"] = "\(Google API key)"
// 语言 ： 
params["language"] = "en"
// 当前位置 字符串: "纬度,经度"
params["location"] = "\(latitude,longitude)"
// 搜索半径 （单位：米）
params["radius"] = "\(1500)"


// 谷歌地理编码
// https://maps.googleapis.com/maps/api/geocode/json
var params: [String: Any] = [:]
params["key"] = "\(Google API key)"
// 地址文本
params["address"] = address


// 谷歌地址逆编码
// https://maps.googleapis.com/maps/api/geocode/json
var params: [String: Any] = [:]
params["key"] = "\(Google API key)"
params["latlng"] = location.googleDisplay

return .requestParameters(parameters: params,
                          encoding: URLEncoding.default)


// 谷歌路线导航，默认驾车
// https://maps.googleapis.com/maps/api/directions/json
var params: [String: Any] = [:]
params["key"] = "\(Google API key)"
// 出发点坐标位置
params["origin"] = "\(latitude,longitude)"
// 目的地坐标位置
params["destination"] = "\(latitude,longitude)"


// 解析相应数据，模型转换框架使用的是 ObjectMapper 
/// 列表容器模型
struct ListContainerModel<T: Mappable>: Mappable {
    var list: [T]?
    var numberOfElements: Int?
    var total: Int?
    var pageNumber: Int?
    var size: Int?
    var hasNextPage: Bool?
    var hasPreviousPage: Bool?

    init?(map: Map) {
      
    }

    mutating func mapping(map: Map) {
        list <- map["list"]
        numberOfElements <- map["numberOfElements"]
        total <- map["total"]
        pageNumber <- map["pageNumber"]
        size <- map["size"]
        hasNextPage <- map["hasNextPage"]
        hasPreviousPage <- map["hasPreviousPage"]
    }
}

/// google POI 附近和关键词地址搜索
struct GoogleSearchAddressContainerModel: Mappable {
    var html_attributions: [Any]?
    
    /// POI 列表
    var results: [SearchAddressModel]?
    
    /// 返回结果状态
    var status: String?
    
    init?(map: Map) {
      
    }

    mutating func mapping(map: Map) {
        html_attributions <- map["html_attributions"]
        results <- map["results"]
        status <- map["status"]
    }
}

/// leg Model
struct GoogleDirectionLegModel: Mappable  {
    var distance: Any?
    var duration: Any?
    var end_address: String?
    var end_location: GeometryLocation?
    var start_address: String?
    var start_location: GeometryLocation?
    
    var steps: [GoogleDirectionAddressModel]?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        steps <- map["steps"]
    }
}

/// 谷歌地图返回结果模型 
struct GoogleDirectionResultModel: Mappable {
    var steps: [GoogleDirectionAddressModel]? {
        get {
            var result = [GoogleDirectionAddressModel]()
            legs?.forEach({ (leg) in
                result.append(contentsOf: leg.steps ?? [])
            })
            
            return result
        }
    }
    
    var legs: [GoogleDirectionLegModel]?
    
    var points: String?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        legs <- map["routes.0.legs"]
        points <- map["routes.0.overview_polyline.points"]
    }
}
```



### 标记点（大头针 annotation || Marker）

#### 标记点（大头针 annotation || Marker）- 高德

```swift
// 1. 创建地图对象
let gaodeMap = MAMapView()
gaodeMap.delegate = self
// 缩放级别
zoomLevel = 17
// 是否显示用户位置
isShowsUserLocation = true

// 自定义地图样式(1. 在高德地图开发者应用后台新建地图样式，下载样式的资源包拖到工程里面去)
guard let url = R.file.styleData(),
    let data = try? Data(contentsOf: url) else { return }

let options = MAMapCustomStyleOptions()
options.styleData = data
setCustomMapStyleOptions(options)
customMapStyleEnabled = true

// 设定当前地图的经纬度范围，该范围可能会被调整为适合地图窗口显示的范围
setRegion(MACoordinateRegion(center:  centerCoordinate, span: MACoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)), animated: false)


// 2. 新建标注
let pointAnnotation = MAPointAnnotation()
// 标注中心点经纬度坐标
pointAnnotation.coordinate = center
// 标注标题
pointAnnotation.title = title
// 标注副标题
pointAnnotation.subtitle = subTitle

// 添加标注 
gaodeMap.addAnnotation(pointAnnotation
// 选中标注数据对应的view。注意：如果annotation对应的annotationView因不在屏幕范围内而被移入复用池，为了完成选中操作，会将对应的annotationView添加到地图上，并将地图中心点移至annotation.coordinate的位置。
gaodeMap.selectAnnotation(pointAnnotation, animated: false)
                       
                       
// 设置标注 的外观样式
// MAMapViewDelegate       
 func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
    if annotation.isKind(of: MAPointAnnotation.self) {
        let pointReuseIndetifier = "pointReuseIndetifier"
        var annotationView: MAPinAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: pointReuseIndetifier) as! MAPinAnnotationView?

        if annotationView == nil {
            annotationView = MAPinAnnotationView(annotation: annotation, reuseIdentifier: pointReuseIndetifier)
        }
		
        // 是否可以点击标注view
        annotationView!.canShowCallout = true
        // 是否有标注添加到地图上的动画效果(从上而下)
        annotationView!.animatesDrop = true
        // 是否可以拖拽
        annotationView!.isDraggable = true
        // 是否有右边的视图
        annotationView!.rightCalloutAccessoryView = nil

        return annotationView!
    }

    return nil
}
                       
// 移除标注
gaodeMap.removeAnnotation(pointAnnotation)             
```



#### 标记点（大头针 annotation || Marker）- Google

```swift
// 创建 Google map
let googleMap = GMSMapView()


// 添加标注 Marker
// 创建 GMSMarker 对象
let marker = GMSMarker()
// 标注位置
marker.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
// 标注标题
marker.title = title
// 标注副标题
marker.snippet = subTitle

// 设置标注的图片
marker.icon = UIImage()

// 设置
let camera = GMSCameraPosition.camera(withLatitude: marker.position.latitude, longitude: marker.position.longitude, zoom: 16.0)
marker.map = googleMap

// 自动显示标题内容
selectedMarker = marker


// 移除标注
marker.map = nil
```



### Overlay && Polyline

#### Overlay && Polyline - 高德

```swift
// 多线段的坐标点数组
var lineCoordinates = [CLLocationCoordinate2D]()
// 多边形
let pol = MAPolygon(coordinates: &lineCoordinates, count: UInt(lineCoordinates.count))
gaodeMap.add(pol)

// 不是多边形
let polyline: MAPolyline = MAPolyline(coordinates: &lineCoordinates, count: UInt(lineCoordinates.count))
gaodeMap.addOverlays([polyline])
// 展示路线
showOverlays([polyline], animated: false)

// 移除
removeOverlays(polyline)
```



#### Overlay && Polyline - Google

```swift
// 多线段的坐标点数组
var lineCoordinates = [CLLocationCoordinate2D]()

// 多边形路径
let gmsPath = GMSMutablePath()
lineCoordinates.forEach { (location) in
    if let latitude = location.latitude, let longitude = location.longitude {
        gmsPath.addLatitude(latitude, longitude: longitude)
    }
}

let polyline = GMSPolyline(path: gmsPath)
// 设置线段颜色
polyline.strokeColor = UIColor._themeColor()
// 设置线段宽度
polyline.strokeWidth = 8.0
// 显示出来
polyline.map = googleMap


// 移除
polyline.map = nil

```



### 地理围栏

- POI 围栏

- 行政区划 围栏

- 自定义圆形围栏

- 自定义多边围栏

  

```swift
// 创建围栏对象
lazy var geoFenceManager: AMapGeoFenceManager = {
    let manager = AMapGeoFenceManager()
    //进入，离开，停留都要进行通知
    manager.activeAction = [AMapGeoFenceActiveAction.inside , AMapGeoFenceActiveAction.outside , AMapGeoFenceActiveAction.stayed]
    manager.allowsBackgroundLocationUpdates = false  // 允许后台定位
    manager.delegate = self

    return manager
}()
    
// 创建行政区域地理围栏
geoFenceManager.addDistrictRegionForMonitoring(withDistrictName: "深圳市", customID: "city")

// 添加圆形围栏
// withCenter: 围栏中心点
//  radius: 围栏半径
geoFenceManager.addCircleRegionForMonitoring(withCenter: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), radius: 500, customID: "123456")

// 移除围栏


// 设置圆形围栏样式
// 渲染多边型 --- MAMapViewDelegate
func mapView(_ mapView: MAMapView!, rendererFor overlay: MAOverlay!) -> MAOverlayRenderer! {
    if overlay.isKind(of: MACircle.self) {
        let renderer: MACircleRenderer = MACircleRenderer(overlay: overlay)
     
        renderer.lineWidth = 1.0
        renderer.strokeColor = UIColor.gxd_themeColor()
        renderer.fillColor = UIColor.gxd_themeColor().withAlphaComponent(0.4)

        return renderer
    }

	return nil
}


// MARK: - AMapGeoFenceManagerDelegate 
// 围栏创建完成
func amapGeoFenceManager(_ manager: AMapGeoFenceManager!, didAddRegionForMonitoringFinished regions: [AMapGeoFenceRegion]!, customID: String!, error: Error!) {
    if let error = error {
        let error = error as NSError
        NSLog("创建失败 %@",error);
    }
    else {
        NSLog("创建成功")
        let circleRegion = regions.first as? AMapGeoFenceCircleRegion

        // 在地图上画一个区域
        guard let center = circleRegion?.center,
            let radius = circleRegion?.radius else { return }
		
        let circle: MACircle = MACircle(center: CLLocationCoordinate2D(latitude: center.latitude, longitude: center.longitude), radius: CLLocationDistance(radius))
        gaodeMap.add(circle)
    }
}

// 围栏状态改变时 用户未知、进入围栏、退出围栏、在围栏内停留
func amapGeoFenceManager(_ manager: AMapGeoFenceManager!, didGeoFencesStatusChangedFor region: AMapGeoFenceRegion!, customID: String!, error: Error!) {
    if error == nil {
        print("status changed \(region.description)")
    } else {
        print("status changed error \(error)")
    }
}

```



### 导航

> 跳转到第三方地图  App 发起导航，先要在 InfoPlist 文件里面配置 QueriesSchemes 字段

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>comgooglemaps</string>
    <string>iosamap</string>
    <string>baidumap</string>
</array>
```



发起导航：

```swift
/// 地图导航模式
enum MapDirectionMode {
    // 驾车
    case driving
    // 步行
    case walking
    // 骑行
    case bicycling
    // 公共交通
    case transit
}

struct DirectionParams {
    /// 源 App 名称
    var sourceApplication: String = U""
    /// 源 App scheme url
    var backScheme: String = "\(appUrlScheme)"

    /// 起始地点
    var origin: Location?
    /// 目的地点
    var destination: Location
    /// 导航模式
    var mode: MapDirectionMode = .driving
}



/// 打开苹果地图导航
/// - Parameter params: 参数
static func openAppleMapDirection(withParams params: DirectionParams) {
    guard let latitude = params.destination.latitude,
        let longitude = params.destination.longitude else { return }

    let currentLocation = MKMapItem.forCurrentLocation()
    let toPlacemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
    let toLocation = MKMapItem(placemark: toPlacemark)
    toLocation.name = params.destination.name
    MKMapItem.openMaps(with: [currentLocation, toLocation], launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
}


/// 打开 google 地图导航
/// - Parameter params: 参数
static func openGoogleMapDirection(withParams params: DirectionParams) {
    if !Keys.MapSchemeUrl.google.isInstalled { return }

    guard var daddr = params.destination.name else {
        return
    }
    daddr = daddr.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)

    let urlString = Keys.MapSchemeUrl.google.rawValue + "?" +  "x-source=\(params.sourceApplication)&x-success=\(params.backScheme)&saddr=&daddr=\(daddr)&directionsmode=driving"

    guard let url = URL(string: urlString) else { return }
    UIApplication.shared.open(url, options: [:], completionHandler: nil)

}


/// 打开 百度 地图导航
/// - Parameter params: 参数
static func openBaiduMapDirection(withParams params: DirectionParams) {
    if !Keys.MapSchemeUrl.baidu.isInstalled { return }

    guard let destinationLatitude = params.destination.latitude,
                let destinationLongitude = params.destination.longitude else { return }
    let destinationName = params.destination.name ?? ""

    let urlString = Keys.MapSchemeUrl.baidu.rawValue + "map/direction?origin=name:{{我的位置}}&destination=name:\(destinationName)|latlng:\(destinationLatitude),\(destinationLongitude)&mode=driving&coord_type=bd09ll&src=ios.Express.\(params.sourceApplication)"

    guard let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") else { return }
    UIApplication.shared.open(url, options: [:], completionHandler: nil)
}


/// 打开 高德 地图导航
/// - Parameter params: 参数
static func openGaodeMapDirection(withParams params: DirectionParams) {
    if !Keys.MapSchemeUrl.gaode.isInstalled { return }

    guard let latitude = params.destination.latitude,
        let longitude = params.destination.longitude else { return }
    let destinationName = params.destination.name ?? ""
    let urlString = Keys.MapSchemeUrl.gaode.rawValue +  "path?sourceApplication=\(params.sourceApplication)&backScheme=\(params.backScheme)&dlat=\(latitude)&dlon=\(longitude)&dname=\(destinationName)&dev=0&t=0"

    guard let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") else { return }
    UIApplication.shared.open(url, options: [:], completionHandler: nil)
}
```



### 参考链接

1. https://lbs.amap.com/api
2. https://developers.google.com/places/ios-sdk/overview



---
分享个人技术学习记录和跑步马拉松训练比赛、读书笔记等内容，感兴趣的朋友可以关注我的公众号「by在水一方」。

<img src="https://image-1254431338.cos.ap-guangzhou.myqcloud.com/qrcode_for_gh_0be790c1f754_258.jpg" alt="by在水一方"  />

