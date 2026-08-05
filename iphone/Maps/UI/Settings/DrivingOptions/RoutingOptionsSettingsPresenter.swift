final class RoutingOptionsSettingsPresenter {
  private weak var viewController: RoutingOptionsSettingsViewController?

  init(viewController: RoutingOptionsSettingsViewController) {
    self.viewController = viewController
  }

  func present(_ state: RoutingOptionsSettingsState,
               reconfiguredItems: [RoutingOption] = [],
               animatingDifferences: Bool = true) {
    viewController?.display(SettingsViewModel(title: RootSettings.routingOptions.title,
                                              sections: sections(from: state),
                                              reconfiguredItems: reconfiguredItems,
                                              animatingDifferences: animatingDifferences))
  }

  private func sections(from state: RoutingOptionsSettingsState) -> [RoutingOptionsSettingsSectionViewModel] {
    if state.options.routeSpeedSettingSupported {
      var sections = [SettingsSectionViewModel(section: .routeSpeed,
                                               header: RoutingOptionsSettingsSection.routeSpeed.title,
                                               footer: RoutingOptionsSettingsSection.routeSpeed.footer,
                                               items: [routeSpeedItem(state)])]
      if state.options.bicycleWindSettingSupported {
        var windItems = [windEnabledItem(state)]
        if state.bicycleWindEnabled {
          windItems.append(windSpeedItem(state))
          windItems.append(windDirectionItem(state))
        }
        sections.append(SettingsSectionViewModel(section: .wind,
                                                 footer: RoutingOptionsSettingsSection.wind.footer,
                                                 items: windItems))
      }
      return sections
    }
    return [SettingsSectionViewModel(section: .options,
                                     items: [.tollRoads, .unpavedRoads, .ferryCrossings, .motorways].map {
                                       item($0, state: state)
                                     })]
  }

  private func item(_ option: RoutingOption,
                    state: RoutingOptionsSettingsState) -> RoutingOptionsSettingsItemViewModel {
    SettingsItemViewModel(item: option,
                          title: option.title,
                          kind: .switcher(isOn: option.isEnabled(in: state.options), isEnabled: true))
  }

  private func routeSpeedItem(_ state: RoutingOptionsSettingsState) -> RoutingOptionsSettingsItemViewModel {
    let percentage = state.routeSpeedPercentage
    let speedKMpH = state.options.routeDefaultCruisingSpeedKMpH * Double(percentage) / 100.0
    return SettingsItemViewModel(item: .routeSpeed,
                                 kind: .slider(value: Float(percentage),
                                               minimumValue: Float(RoutingOptions.minimumRouteSpeedPercentage),
                                               maximumValue: Float(RoutingOptions.maximumRouteSpeedPercentage),
                                               valueTitle: cruisingSpeedTitle(speedKMpH),
                                               isEnabled: true))
  }

  private func windEnabledItem(_ state: RoutingOptionsSettingsState) -> RoutingOptionsSettingsItemViewModel {
    SettingsItemViewModel(item: .windEnabled,
                          title: RoutingOption.windEnabled.title,
                          kind: .switcher(isOn: state.bicycleWindEnabled, isEnabled: true))
  }

  private func windSpeedItem(_ state: RoutingOptionsSettingsState) -> RoutingOptionsSettingsItemViewModel {
    SettingsItemViewModel(item: .windSpeed,
                          title: RoutingOption.windSpeed.title,
                          kind: .slider(value: Float(state.bicycleWindSpeedMpS),
                                        minimumValue: Float(RoutingOptions.minimumBicycleWindSpeedMpS),
                                        maximumValue: Float(RoutingOptions.maximumBicycleWindSpeedMpS),
                                        valueTitle: windSpeedTitle(state.bicycleWindSpeedMpS),
                                        isEnabled: true))
  }

  private func windDirectionItem(_ state: RoutingOptionsSettingsState) -> RoutingOptionsSettingsItemViewModel {
    let degrees = state.bicycleWindDirectionDegrees
    let labels = ["route_wind_direction_n", "route_wind_direction_ne", "route_wind_direction_e",
                  "route_wind_direction_se", "route_wind_direction_s", "route_wind_direction_sw",
                  "route_wind_direction_w", "route_wind_direction_nw"]
    let label = L(labels[degrees / RoutingOptions.bicycleWindDirectionStepDegrees])
    return SettingsItemViewModel(item: .windDirection,
                                 title: RoutingOption.windDirection.title,
                                 kind: .slider(value: Float(degrees),
                                               minimumValue: 0,
                                               maximumValue: 315,
                                               valueTitle: "\(label) · \(degrees)°",
                                               isEnabled: true))
  }

  private func cruisingSpeedTitle(_ speedKMpH: Double) -> String {
    let value = Settings.measurementUnits() == .imperial ? speedKMpH * 0.621371192 : speedKMpH
    let units = Settings.measurementUnits() == .imperial ? L("miles_per_hour") : L("kilometers_per_hour")
    let formatter = NumberFormatter()
    formatter.maximumFractionDigits = 2
    return "\(formatter.string(from: NSNumber(value: value)) ?? String(value))\u{00a0}\(units)"
  }

  private func windSpeedTitle(_ speedMpS: Int) -> String {
    guard Settings.measurementUnits() == .imperial else { return "\(speedMpS)\u{00a0}m/s" }
    let speedMPH = Int((Double(speedMpS) * 2.236936292).rounded())
    return "\(speedMPH)\u{00a0}\(L("miles_per_hour"))"
  }
}
