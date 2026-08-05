final class RoutingOptionsSettingsInteractor {
  var presenter: RoutingOptionsSettingsPresenter?

  private let routingOptionsProvider: () -> RoutingOptions
  private var state: RoutingOptionsSettingsState?
  private var initialRouteSpeedPercentage = RoutingOptions.defaultRouteSpeedPercentage

  init(routingOptionsProvider: @escaping () -> RoutingOptions = RoutingOptions.init) {
    self.routingOptionsProvider = routingOptionsProvider
  }

  func loadSettings() {
    let options = routingOptionsProvider()
    initialRouteSpeedPercentage = options.routeSpeedPercentage
    let state = RoutingOptionsSettingsState(options: options,
                                            routeSpeedPercentage: options.routeSpeedPercentage)
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

  private func saveRouteSpeed() {
    guard let state,
          state.options.routeSpeedSettingSupported,
          state.routeSpeedPercentage != initialRouteSpeedPercentage else { return }
    // Replacing the core router resets the active routing session, so remember its state first.
    let shouldRebuild = MWMRouter.isRoutingActive()
    state.options.routeSpeedPercentage = state.routeSpeedPercentage
    initialRouteSpeedPercentage = state.routeSpeedPercentage
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
      saveRouteSpeed()
    case .didChangeSwitch(let item, isOn: let isOn):
      set(item, enabled: isOn)
    case .didChangeSlider(.routeSpeed, value: let value):
      setRouteSpeed(value)
    default:
      break
    }
  }
}
