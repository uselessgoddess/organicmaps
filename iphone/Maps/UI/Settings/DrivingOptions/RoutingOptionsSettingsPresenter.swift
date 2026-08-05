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
      return [SettingsSectionViewModel(section: .routeSpeed,
                                       header: RoutingOptionsSettingsSection.routeSpeed.title,
                                       footer: RoutingOptionsSettingsSection.routeSpeed.footer,
                                       items: [routeSpeedItem(state)])]
    }
    return [SettingsSectionViewModel(section: .options,
                                     items: RoutingOption.allCases.filter { $0 != .routeSpeed }.map {
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
    let valueTitle = NumberFormatter.localizedString(from: NSNumber(value: Double(percentage) / 100.0),
                                                     number: .percent)
    return SettingsItemViewModel(item: .routeSpeed,
                                 kind: .slider(value: Float(percentage),
                                               minimumValue: Float(RoutingOptions.minimumRouteSpeedPercentage),
                                               maximumValue: Float(RoutingOptions.maximumRouteSpeedPercentage),
                                               valueTitle: valueTitle,
                                               isEnabled: true))
  }
}
