enum RoutingOptionsSettingsSection: String {
  case options
  case routeSpeed
}

extension RoutingOptionsSettingsSection {
  var title: String? {
    switch self {
    case .options: return nil
    case .routeSpeed: return L("route_speed_title")
    }
  }

  var footer: String? {
    switch self {
    case .options: return nil
    case .routeSpeed: return L("route_speed_description")
    }
  }
}

enum RoutingOption: String, CaseIterable {
  case tollRoads
  case unpavedRoads
  case ferryCrossings
  case motorways
  case routeSpeed
}

extension RoutingOption {
  var title: String {
    switch self {
    case .tollRoads: return L("avoid_tolls")
    case .unpavedRoads: return L("avoid_unpaved")
    case .ferryCrossings: return L("avoid_ferry")
    case .motorways: return L("avoid_motorways")
    case .routeSpeed: return L("route_speed_title")
    }
  }

  func isEnabled(in options: RoutingOptions) -> Bool {
    guard let routingOptionsKeyPath else { return false }
    return options[keyPath: routingOptionsKeyPath]
  }

  func setEnabled(_ enabled: Bool, in options: RoutingOptions) {
    guard let routingOptionsKeyPath else { return }
    options[keyPath: routingOptionsKeyPath] = enabled
  }

  private var routingOptionsKeyPath: ReferenceWritableKeyPath<RoutingOptions, Bool>? {
    switch self {
    case .tollRoads: return \.avoidToll
    case .unpavedRoads: return \.avoidDirty
    case .ferryCrossings: return \.avoidFerry
    case .motorways: return \.avoidMotorway
    case .routeSpeed: return nil
    }
  }
}

struct RoutingOptionsSettingsState {
  let options: RoutingOptions
  var routeSpeedPercentage: Int
}

typealias RoutingOptionsSettingsViewController = SettingsViewController<RoutingOptionsSettingsSection, RoutingOption>
typealias RoutingOptionsSettingsSectionViewModel = SettingsSectionViewModel<RoutingOptionsSettingsSection, RoutingOption>
typealias RoutingOptionsSettingsItemViewModel = SettingsItemViewModel<RoutingOption>
