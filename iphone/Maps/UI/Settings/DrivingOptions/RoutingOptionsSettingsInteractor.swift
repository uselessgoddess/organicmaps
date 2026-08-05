final class RoutingOptionsSettingsInteractor {
  var presenter: RoutingOptionsSettingsPresenter?

  private let routingOptionsProvider: () -> RoutingOptions
  private var state: RoutingOptionsSettingsState?
  private var initialRouteSpeedPercentage = RoutingOptions.defaultRouteSpeedPercentage
  private var initialBicycleWindEnabled = false
  private var initialBicycleWindSpeedMpS = RoutingOptions.defaultBicycleWindSpeedMpS
  private var initialBicycleWindDirectionDegrees = 0

  init(routingOptionsProvider: @escaping () -> RoutingOptions = RoutingOptions.init) {
    self.routingOptionsProvider = routingOptionsProvider
  }

  func loadSettings() {
    let options = routingOptionsProvider()
    initialRouteSpeedPercentage = options.routeSpeedPercentage
    initialBicycleWindEnabled = options.bicycleWindEnabled
    initialBicycleWindSpeedMpS = options.bicycleWindSpeedMpS
    initialBicycleWindDirectionDegrees = options.bicycleWindDirectionDegrees
    let state = RoutingOptionsSettingsState(options: options,
                                            routeSpeedPercentage: options.routeSpeedPercentage,
                                            bicycleWindEnabled: options.bicycleWindEnabled,
                                            bicycleWindSpeedMpS: options.bicycleWindSpeedMpS,
                                            bicycleWindDirectionDegrees: options.bicycleWindDirectionDegrees)
    self.state = state
    present(state, animatingDifferences: false)
  }

  private func set(_ option: RoutingOption, enabled: Bool) {
    guard let state else { return }
    option.setEnabled(enabled, in: state.options)
    state.options.save()
    present(state, animatingDifferences: false)
  }

  private func setRouteSpeed(_ value: Float) {
    guard var state, state.options.routeSpeedSettingSupported else { return }
    let step = RoutingOptions.routeSpeedPercentageStep
    let percentage = Int((Double(value) / Double(step)).rounded()) * step
    state.routeSpeedPercentage = min(max(percentage, RoutingOptions.minimumRouteSpeedPercentage),
                                     RoutingOptions.maximumRouteSpeedPercentage)
    self.state = state
    presenter?.present(state, reconfiguredItems: [.routeSpeed], animatingDifferences: false)
  }

  private func setBicycleWindEnabled(_ enabled: Bool) {
    guard var state, state.options.bicycleWindSettingSupported else { return }
    state.bicycleWindEnabled = enabled
    self.state = state
    present(state)
  }

  private func setBicycleWindSpeed(_ value: Float) {
    guard var state, state.options.bicycleWindSettingSupported else { return }
    let step = RoutingOptions.bicycleWindSpeedStepMpS
    let speed = Int((Double(value) / Double(step)).rounded()) * step
    state.bicycleWindSpeedMpS = min(max(speed, RoutingOptions.minimumBicycleWindSpeedMpS),
                                    RoutingOptions.maximumBicycleWindSpeedMpS)
    self.state = state
    presenter?.present(state, reconfiguredItems: [.windSpeed], animatingDifferences: false)
  }

  private func setBicycleWindDirection(_ value: Float) {
    guard var state, state.options.bicycleWindSettingSupported else { return }
    let step = RoutingOptions.bicycleWindDirectionStepDegrees
    let direction = Int((Double(value) / Double(step)).rounded()) * step
    state.bicycleWindDirectionDegrees = min(max(direction, 0), 315)
    self.state = state
    presenter?.present(state, reconfiguredItems: [.windDirection], animatingDifferences: false)
  }

  private func saveRouteSettings() {
    guard let state,
          state.options.routeSpeedSettingSupported,
          state.routeSpeedPercentage != initialRouteSpeedPercentage ||
          state.bicycleWindEnabled != initialBicycleWindEnabled ||
          state.bicycleWindSpeedMpS != initialBicycleWindSpeedMpS ||
          state.bicycleWindDirectionDegrees != initialBicycleWindDirectionDegrees else { return }
    // Replacing the core router resets the active routing session, so remember its state first.
    let shouldRebuild = MWMRouter.isRoutingActive()
    state.options.routeSpeedPercentage = state.routeSpeedPercentage
    state.options.bicycleWindEnabled = state.bicycleWindEnabled
    state.options.bicycleWindSpeedMpS = state.bicycleWindSpeedMpS
    state.options.bicycleWindDirectionDegrees = state.bicycleWindDirectionDegrees
    state.options.save()
    initialRouteSpeedPercentage = state.routeSpeedPercentage
    initialBicycleWindEnabled = state.bicycleWindEnabled
    initialBicycleWindSpeedMpS = state.bicycleWindSpeedMpS
    initialBicycleWindDirectionDegrees = state.bicycleWindDirectionDegrees
    if shouldRebuild {
      MWMRouter.rebuild(withBestRouter: false)
    }
  }

  private func present(_ state: RoutingOptionsSettingsState, animatingDifferences: Bool = true) {
    presenter?.present(state, animatingDifferences: animatingDifferences)
  }
}

extension RoutingOptionsSettingsInteractor: SettingsViewControllerInteractor {
  typealias Section = RoutingOptionsSettingsSection
  typealias Item = RoutingOption

  func handle(_ action: SettingsViewControllerAction<RoutingOption>) {
    switch action {
    case .didLoad:
      loadSettings()
    case .willDisappear:
      saveRouteSettings()
    case .didChangeSwitch(.windEnabled, isOn: let isOn):
      setBicycleWindEnabled(isOn)
    case .didChangeSwitch(let item, isOn: let isOn):
      set(item, enabled: isOn)
    case .didChangeSlider(.routeSpeed, value: let value):
      setRouteSpeed(value)
    case .didChangeSlider(.windSpeed, value: let value):
      setBicycleWindSpeed(value)
    case .didChangeSlider(.windDirection, value: let value):
      setBicycleWindDirection(value)
    default:
      break
    }
  }
}
