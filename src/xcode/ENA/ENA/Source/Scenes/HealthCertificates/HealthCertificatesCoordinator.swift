////
// 🦠 Corona-Warn-App
//

import UIKit

final class HealthCertificatesCoordinator {
	
	// MARK: - Init
	
	init(
		store: HealthCertificateStoring,
		healthCertificateService: HealthCertificateServiceProviding,
		vaccinationValueSetsProvider: VaccinationValueSetsProvider
	) {
		self.store = store
		self.healthCertificateService = healthCertificateService
		self.vaccinationValueSetsProvider = vaccinationValueSetsProvider

		#if DEBUG
		if isUITesting {
			store.healthCertificateInfoScreenShown = LaunchArguments.infoScreen.healthCertificateInfoScreenShown.boolValue
		}
		#endif
	}
	
	// MARK: - Internal
	
	lazy var viewController: UINavigationController = {
		if !infoScreenShown {
			return UINavigationController(
				rootViewController: infoScreen(
					hidesCloseButton: true,
					dismissAction: { [weak self] in
						guard let self = self else { return }

						self.viewController.pushViewController(self.overviewScreen, animated: true)
						// Set Overview as the only Controller on the navigation stack to avoid back gesture etc.
						self.viewController.setViewControllers([self.overviewScreen], animated: false)

						self.infoScreenShown = true
					},
					showDetail: { detailViewController in
						self.viewController.pushViewController(detailViewController, animated: true)
					}
				)
			)
		} else {
			return UINavigationController(rootViewController: overviewScreen)
		}
	}()
	
	// MARK: - Private
	
	private let store: HealthCertificateStoring
	private let healthCertificateService: HealthCertificateServiceProviding
	private let vaccinationValueSetsProvider: VaccinationValueSetsProvider

	private var modalNavigationController: UINavigationController!

	private var infoScreenShown: Bool {
		get { store.healthCertificateInfoScreenShown }
		set { store.healthCertificateInfoScreenShown = newValue }
	}

	// MARK: Show Screens

	private lazy var overviewScreen: HealthCertificateOverviewViewController = {
		return HealthCertificateOverviewViewController(
			viewModel: HealthCertificateOverviewViewModel(
				healthCertificateService: healthCertificateService
			),
			onInfoBarButtonItemTap: { [weak self] in
				self?.presentInfoScreen()
			},
			onCreateHealthCertificateTap: { [weak self] in
				guard let self = self else { return }

				self.showQRCodeScanner(from: self.viewController)
			},
			onCertifiedPersonTap: { [weak self] healthCertifiedPerson in
				self?.showHealthCertifiedPerson(healthCertifiedPerson)
			}
		)
	}()

	private func infoScreen(
		hidesCloseButton: Bool = false,
		dismissAction: @escaping (() -> Void),
		showDetail: @escaping ((UIViewController) -> Void)
	) -> TopBottomContainerViewController<HealthCertificateInfoViewController, FooterViewController> {
		let consentScreen = HealthCertificateInfoViewController(
			viewModel: HealthCertificateInfoViewModel(
				hidesCloseButton: hidesCloseButton,
				didTapDataPrivacy: {
					let detailViewController = HTMLViewController(model: AppInformationModel.privacyModel)
					detailViewController.title = AppStrings.AppInformation.privacyTitle
					detailViewController.isDismissable = false

					if #available(iOS 13.0, *) {
						detailViewController.isModalInPresentation = true
					}

					showDetail(detailViewController)
				}
			),
			dismiss: dismissAction
		)

		let footerViewController = FooterViewController(
			FooterViewModel(
				primaryButtonName: AppStrings.HealthCertificate.Info.primaryButton,
				isPrimaryButtonEnabled: true,
				isSecondaryButtonEnabled: false,
				isSecondaryButtonHidden: true,
				backgroundColor: .enaColor(for: .background)
			)
		)

		let topBottomContainerViewController = TopBottomContainerViewController(
			topController: consentScreen,
			bottomController: footerViewController
		)

		return topBottomContainerViewController
	}

	private func presentInfoScreen() {
		// Promise the navigation view controller will be available,
		// this is needed to resolve an inset issue with large titles
		var navigationController: UINavigationController!
		let infoVC = infoScreen(
			dismissAction: {
				navigationController.dismiss(animated: true)
			},
			showDetail: { detailViewController in
				navigationController.pushViewController(detailViewController, animated: true)
			}
		)

		// We need to use UINavigationController(rootViewController: UIViewController) here,
		// otherwise the inset of the navigation title is wrong
		navigationController = UINavigationController(rootViewController: infoVC)
		viewController.present(navigationController, animated: true)
	}
	
	private func showQRCodeScanner(from presentingViewController: UIViewController) {
		let qrCodeScannerViewController = HealthCertificateQRCodeScannerViewController(
			healthCertificateService: healthCertificateService,
			didScanCertificate: { [weak self] healthCertifiedPerson in
				presentingViewController.dismiss(animated: true) {
					if presentingViewController == self?.viewController {
						self?.showHealthCertifiedPerson(healthCertifiedPerson)
					}
				}
			},
			dismiss: {
				presentingViewController.dismiss(animated: true)
			}
		)

		qrCodeScannerViewController.definesPresentationContext = true

		let qrCodeNavigationController = UINavigationController(rootViewController: qrCodeScannerViewController)
		qrCodeNavigationController.modalPresentationStyle = .fullScreen

		presentingViewController.present(qrCodeNavigationController, animated: true)
	}
	
	private func showHealthCertifiedPerson(_ healthCertifiedPerson: HealthCertifiedPerson) {
		let healthCertificatePersonViewController = HealthCertifiedPersonViewController(
			healthCertificateService: healthCertificateService,
			healthCertifiedPerson: healthCertifiedPerson,
			vaccinationValueSetsProvider: vaccinationValueSetsProvider,
			dismiss: { [weak self] in
				self?.viewController.dismiss(animated: true)
			},
			didTapHealthCertificate: { [weak self] healthCertificate in
				self?.showHealthCertificate(
					healthCertifiedPerson: healthCertifiedPerson,
					healthCertificate: healthCertificate
				)
			},
			didTapRegisterAnotherHealthCertificate: { [weak self] in
				guard let self = self else { return }

				self.showQRCodeScanner(from: self.modalNavigationController)
			},
			didSwipeToDelete: { [weak self] healthCertificate, confirmDeletion in
				self?.showDeleteAlert(
					submitAction: UIAlertAction(
						title: AppStrings.HealthCertificate.Alert.deleteButton,
						style: .default,
						handler: { _ in
							self?.healthCertificateService.removeHealthCertificate(healthCertificate)
							confirmDeletion()
						}
					)
				)
			}
		)
		
		let footerViewController = FooterViewController(
			FooterViewModel(
				primaryButtonName: AppStrings.HealthCertificate.Person.primaryButton,
				isPrimaryButtonEnabled: true,
				isSecondaryButtonEnabled: false,
				isSecondaryButtonHidden: true,
				backgroundColor: .enaColor(for: .backgroundLightGray)
			)
		)
		
		let topBottomContainerViewController = TopBottomContainerViewController(
			topController: healthCertificatePersonViewController,
			bottomController: footerViewController
		)
		
		modalNavigationController = UINavigationController(rootViewController: topBottomContainerViewController)
		viewController.present(self.modalNavigationController, animated: true)
	}
	
	private func showHealthCertificate(
		healthCertifiedPerson: HealthCertifiedPerson,
		healthCertificate: HealthCertificate
	) {
		let healthCertificateViewController = HealthCertificateViewController(
			healthCertifiedPerson: healthCertifiedPerson,
			healthCertificate: healthCertificate,
			vaccinationValueSetsProvider: vaccinationValueSetsProvider,
			dismiss: { [weak self] in
				self?.viewController.dismiss(animated: true)
			},
			didTapDelete: { [weak self] in
				self?.showDeleteAlert(
					submitAction: UIAlertAction(
						title: AppStrings.HealthCertificate.Alert.deleteButton,
						style: .default,
						handler: { _ in
							self?.healthCertificateService.removeHealthCertificate(healthCertificate)
							self?.modalNavigationController.popToRootViewController(animated: true)
						}
					)
				)
			}
		)
		
		let footerViewController = FooterViewController(
			FooterViewModel(
				primaryButtonName: AppStrings.HealthCertificate.Details.primaryButton,
				isPrimaryButtonEnabled: true,
				isSecondaryButtonEnabled: false,
				isSecondaryButtonHidden: true,
				primaryButtonInverted: true,
				backgroundColor: .enaColor(for: .backgroundLightGray)
			)
		)
		
		let topBottomContainerViewController = TopBottomContainerViewController(
			topController: healthCertificateViewController,
			bottomController: footerViewController
		)
		modalNavigationController.pushViewController(topBottomContainerViewController, animated: true)
	}
	
	private func showDeleteAlert(submitAction: UIAlertAction) {
		let alert = UIAlertController(
			title: AppStrings.HealthCertificate.Alert.title,
			message: AppStrings.HealthCertificate.Alert.message,
			preferredStyle: .alert
		)
		alert.addAction(
			UIAlertAction(
				title: AppStrings.HealthCertificate.Alert.cancelButton,
				style: .cancel,
				handler: nil
			)
		)
		alert.addAction(submitAction)
		modalNavigationController.present(alert, animated: true)
	}
	
}