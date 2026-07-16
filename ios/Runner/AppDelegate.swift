import Flutter
import UIKit
import HealthKit
import CoreLocation
import MapKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    let registry = engineBridge.pluginRegistry

    if let routeRegistrar = registry.registrar(forPlugin: "HealthRouteChannel") {
      HealthRouteChannel.register(with: routeRegistrar)
    }

    if let mapRegistrar = registry.registrar(forPlugin: "AppleRouteMapView") {
      mapRegistrar.register(
        AppleRouteMapViewFactory(messenger: mapRegistrar.messenger()),
        withId: "kynos/apple_route_map"
      )
    }

    if let thermalRegistrar = registry.registrar(forPlugin: "DeviceThermalChannel") {
      DeviceThermalChannel.register(with: thermalRegistrar)
    }
  }
}

// MARK: - Device Thermal Channel

final class DeviceThermalChannel: NSObject {
  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "kynos/device_thermal",
      binaryMessenger: registrar.messenger()
    )
    let instance = DeviceThermalChannel()
    channel.setMethodCallHandler(instance.handle)
  }

  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "isThermallyThrottled":
      let state = ProcessInfo.processInfo.thermalState
      result(state == .serious || state == .critical)
    case "physicalMemoryBytes":
      result(Int(ProcessInfo.processInfo.physicalMemory))
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}

final class HealthRouteChannel: NSObject {
  private let healthStore = HKHealthStore()

  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "kynos/health_route", binaryMessenger: registrar.messenger())
    let instance = HealthRouteChannel()
    channel.setMethodCallHandler(instance.handle)
  }

  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getWorkoutRoute":
      guard let args = call.arguments as? [String: Any],
            let uuidText = args["workoutUuid"] as? String,
            let uuid = UUID(uuidString: uuidText) else {
        result(FlutterError(code: "bad_args", message: "Missing or invalid workoutUuid", details: nil))
        return
      }

      requestRouteReadPermission { [weak self] granted, error in
        if let error {
          result(FlutterError(code: "auth_error", message: error.localizedDescription, details: nil))
          return
        }

        guard granted else {
          result(FlutterError(code: "auth_denied", message: "HealthKit route permission denied", details: nil))
          return
        }

        self?.fetchWorkoutRoute(workoutUUID: uuid, result: result)
      }

    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func requestRouteReadPermission(completion: @escaping (Bool, Error?) -> Void) {
    guard HKHealthStore.isHealthDataAvailable() else {
      completion(false, nil)
      return
    }

    let routeType = HKSeriesType.workoutRoute()
    let workoutType = HKObjectType.workoutType()
    healthStore.requestAuthorization(toShare: nil, read: [workoutType, routeType]) { granted, error in
      completion(granted, error)
    }
  }

  private func fetchWorkoutRoute(workoutUUID: UUID, result: @escaping FlutterResult) {
    let workoutType = HKObjectType.workoutType()
    let workoutPredicate = HKQuery.predicateForObject(with: workoutUUID)

    let workoutQuery = HKSampleQuery(
      sampleType: workoutType,
      predicate: workoutPredicate,
      limit: 1,
      sortDescriptors: nil
    ) { [weak self] _, samples, error in
      if let error {
        result(FlutterError(code: "workout_query_error", message: error.localizedDescription, details: nil))
        return
      }

      guard let workout = samples?.first as? HKWorkout else {
        result(["points": []])
        return
      }

      self?.fetchRouteSamples(for: workout, result: result)
    }

    healthStore.execute(workoutQuery)
  }

  private func fetchRouteSamples(for workout: HKWorkout, result: @escaping FlutterResult) {
    let routeType = HKSeriesType.workoutRoute()
    let predicate = HKQuery.predicateForObjects(from: workout)
    let routeQuery = HKSampleQuery(
      sampleType: routeType,
      predicate: predicate,
      limit: HKObjectQueryNoLimit,
      sortDescriptors: nil
    ) { [weak self] _, samples, error in
      if let error {
        result(FlutterError(code: "route_query_error", message: error.localizedDescription, details: nil))
        return
      }

      let routes = (samples as? [HKWorkoutRoute]) ?? []
      guard !routes.isEmpty else {
        result(["points": []])
        return
      }

      self?.collectCoordinates(from: routes, result: result)
    }

    healthStore.execute(routeQuery)
  }

  private func collectCoordinates(from routes: [HKWorkoutRoute], result: @escaping FlutterResult) {
    let group = DispatchGroup()
    var collected = [[String: Any]]()
    var queryError: Error?

    for route in routes {
      group.enter()
      let routeQuery = HKWorkoutRouteQuery(route: route) { _, locationsOrNil, done, error in
        if let error {
          queryError = error
        }

        let locations = locationsOrNil ?? []
        for location in locations {
          collected.append([
            "latitude": location.coordinate.latitude,
            "longitude": location.coordinate.longitude,
            "timestamp": ISO8601DateFormatter().string(from: location.timestamp)
          ])
        }

        if done {
          group.leave()
        }
      }
      healthStore.execute(routeQuery)
    }

    group.notify(queue: .main) {
      if let error = queryError {
        result(FlutterError(code: "route_points_error", message: error.localizedDescription, details: nil))
        return
      }

      result(["points": collected])
    }
  }
}

final class AppleRouteMapViewFactory: NSObject, FlutterPlatformViewFactory {
  private let messenger: FlutterBinaryMessenger

  init(messenger: FlutterBinaryMessenger) {
    self.messenger = messenger
    super.init()
  }

  func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
    FlutterStandardMessageCodec.sharedInstance()
  }

  func create(
    withFrame frame: CGRect,
    viewIdentifier viewId: Int64,
    arguments args: Any?
  ) -> FlutterPlatformView {
    AppleRouteMapView(frame: frame, viewId: viewId, args: args)
  }
}

final class AppleRouteMapView: NSObject, FlutterPlatformView, MKMapViewDelegate {
  private let mapView: MKMapView

  init(frame: CGRect, viewId: Int64, args: Any?) {
    self.mapView = MKMapView(frame: frame)
    super.init()

    mapView.delegate = self
    mapView.showsCompass = true
    mapView.showsScale = true

    let points = parsePoints(args)
    renderRoute(points)
  }

  func view() -> UIView {
    mapView
  }

  private func parsePoints(_ args: Any?) -> [CLLocationCoordinate2D] {
    guard let dict = args as? [String: Any],
          let rawPoints = dict["points"] as? [[String: Any]] else {
      return []
    }

    return rawPoints.compactMap { point in
      guard let lat = point["latitude"] as? Double,
            let lng = point["longitude"] as? Double else {
        return nil
      }
      return CLLocationCoordinate2D(latitude: lat, longitude: lng)
    }
  }

  private func renderRoute(_ coords: [CLLocationCoordinate2D]) {
    mapView.removeOverlays(mapView.overlays)
    mapView.removeAnnotations(mapView.annotations)

    guard !coords.isEmpty else { return }

    var mutableCoords = coords
    let polyline = MKPolyline(coordinates: &mutableCoords, count: mutableCoords.count)
    mapView.addOverlay(polyline)

    let start = MKPointAnnotation()
    start.coordinate = coords.first!
    start.title = "Start"
    mapView.addAnnotation(start)

    let end = MKPointAnnotation()
    end.coordinate = coords.last!
    end.title = "Finish"
    mapView.addAnnotation(end)

    mapView.setVisibleMapRect(
      polyline.boundingMapRect,
      edgePadding: UIEdgeInsets(top: 40, left: 24, bottom: 40, right: 24),
      animated: false
    )
  }

  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    guard let polyline = overlay as? MKPolyline else {
      return MKOverlayRenderer(overlay: overlay)
    }

    let renderer = MKPolylineRenderer(polyline: polyline)
    renderer.strokeColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 0.95)
    renderer.lineWidth = 4
    renderer.lineJoin = .round
    renderer.lineCap = .round
    return renderer
  }
}
