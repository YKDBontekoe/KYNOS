import Flutter
import UIKit
import HealthKit
import CoreLocation
import MapKit
import GameKit

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

    if let gameKitRegistrar = registry.registrar(forPlugin: "GameKitChannel") {
      GameKitChannel.register(with: gameKitRegistrar)
    }
  }
}

// MARK: - GameKit Channel

final class GameKitChannel: NSObject {
  private var viewController: UIViewController?

  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "kynos/gamekit", binaryMessenger: registrar.messenger())
    let instance = GameKitChannel()
    channel.setMethodCallHandler(instance.handle)
  }

  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "signIn":
      signIn(result: result)
    case "submitScore":
      guard let args = call.arguments as? [String: Any],
            let leaderboardId = args["leaderboard_id"] as? String,
            let score = args["score"] as? Int else {
        result(FlutterError(code: "bad_args", message: "Missing leaderboard_id or score", details: nil))
        return
      }
      submitScore(leaderboardId: leaderboardId, score: score, result: result)
    case "unlockAchievement":
      guard let args = call.arguments as? [String: Any],
            let achievementId = args["achievement_id"] as? String else {
        result(FlutterError(code: "bad_args", message: "Missing achievement_id", details: nil))
        return
      }
      let percentComplete = args["percent_complete"] as? Double ?? 100.0
      unlockAchievement(achievementId: achievementId, percentComplete: percentComplete, result: result)
    case "showLeaderboard":
      guard let args = call.arguments as? [String: Any],
            let leaderboardId = args["leaderboard_id"] as? String else {
        result(FlutterError(code: "bad_args", message: "Missing leaderboard_id", details: nil))
        return
      }
      showLeaderboard(leaderboardId: leaderboardId, result: result)
    case "showAchievements":
      showAchievements(result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func signIn(result: @escaping FlutterResult) {
    let localPlayer = GKLocalPlayer.local
    localPlayer.authenticateHandler = { [weak self] viewController, error in
      if let vc = viewController {
        self?.viewController = vc
        DispatchQueue.main.async {
          UIApplication.shared.windows.first?.rootViewController?.present(vc, animated: true)
        }
        return
      }
      if let error = error {
        result(FlutterError(code: "auth_error", message: error.localizedDescription, details: nil))
        return
      }
      result(localPlayer.isAuthenticated)
    }
  }

  private func submitScore(leaderboardId: String, score: Int, result: @escaping FlutterResult) {
    guard GKLocalPlayer.local.isAuthenticated else {
      result(nil)
      return
    }
    GKLeaderboard.submitScore(score, context: 0, player: GKLocalPlayer.local,
      leaderboardIDs: [leaderboardId]) { error in
      if let error = error {
        result(FlutterError(code: "submit_error", message: error.localizedDescription, details: nil))
      } else {
        result(nil)
      }
    }
  }

  private func unlockAchievement(achievementId: String, percentComplete: Double, result: @escaping FlutterResult) {
    guard GKLocalPlayer.local.isAuthenticated else {
      result(nil)
      return
    }
    let achievement = GKAchievement(identifier: achievementId)
    achievement.percentComplete = percentComplete
    achievement.showsCompletionBanner = true
    GKAchievement.report([achievement]) { error in
      if let error = error {
        result(FlutterError(code: "achievement_error", message: error.localizedDescription, details: nil))
      } else {
        result(nil)
      }
    }
  }

  private func showLeaderboard(leaderboardId: String, result: @escaping FlutterResult) {
    guard GKLocalPlayer.local.isAuthenticated else {
      result(nil)
      return
    }
    let vc = GKGameCenterViewController(leaderboardID: leaderboardId, playerScope: .global, timeScope: .week)
    vc.gameCenterDelegate = self
    DispatchQueue.main.async {
      UIApplication.shared.windows.first?.rootViewController?.present(vc, animated: true)
    }
    result(nil)
  }

  private func showAchievements(result: @escaping FlutterResult) {
    guard GKLocalPlayer.local.isAuthenticated else {
      result(nil)
      return
    }
    let vc = GKGameCenterViewController(state: .achievements)
    vc.gameCenterDelegate = self
    DispatchQueue.main.async {
      UIApplication.shared.windows.first?.rootViewController?.present(vc, animated: true)
    }
    result(nil)
  }
}

extension GameKitChannel: GKGameCenterControllerDelegate {
  func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
    gameCenterViewController.dismiss(animated: true)
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
