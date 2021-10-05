//
// 🦠 Corona-Warn-App
//

import XCTest

class ENAUITests_03_Settings: CWATestCase {
	var app: XCUIApplication!
	
	override func setUpWithError() throws {
		try super.setUpWithError()
		continueAfterFailure = false
		app = XCUIApplication()
		setupSnapshot(app)
		app.setDefaults()
		app.setLaunchArgument(LaunchArguments.onboarding.isOnboarded, to: true)
		app.setLaunchArgument(LaunchArguments.onboarding.setCurrentOnboardingVersion, to: true)
	}

	func test_0030_SettingsFlow() throws {
		app.launch()
		
		app.swipeUp(velocity: .fast)

		app.cells["AppStrings.Home.settingsCardTitle"].waitAndTap()
		
		XCTAssertTrue(app.cells["AppStrings.Settings.tracingLabel"].waitForExistence(timeout: 5.0))
		XCTAssertTrue(app.cells["AppStrings.Settings.notificationLabel"].waitForExistence(timeout: 5.0))
		XCTAssertTrue(app.cells["AppStrings.Settings.backgroundAppRefreshLabel"].waitForExistence(timeout: 5.0))
		XCTAssertTrue(app.cells["AppStrings.Settings.resetLabel"].waitForExistence(timeout: 5.0))
		XCTAssertTrue(app.cells["AppStrings.Settings.Datadonation.description"].waitForExistence(timeout: 5.0))
	}

	func test_0031_SettingsFlow_BackgroundAppRefresh() throws {
		app.launch()
		
		app.swipeUp(velocity: .fast)

		app.cells["AppStrings.Home.settingsCardTitle"].waitAndTap()
		
		app.cells["AppStrings.Settings.backgroundAppRefreshLabel"].waitAndTap()
		
		XCTAssertTrue(app.images["AppStrings.Settings.backgroundAppRefreshImageDescription"].waitForExistence(timeout: 5.0))
	}
	
	func test_screenshot_SettingsNotificationsOn() throws {
		app.setLaunchArgument(LaunchArguments.notifications.isNotificationsEnabled, to: true)
		app.launch()
				
		// Open settings
		app.cells[AccessibilityIdentifiers.Home.settingsCardTitle].waitAndTap()
		
		// Open Notifications
		app.cells[AccessibilityIdentifiers.Settings.notificationLabel].waitAndTap()
		
		// Check if we are on notifications screen - ON
		XCTAssertTrue(app.tables.images[AccessibilityIdentifiers.NotificationSettings.DeltaOnboarding.imageOn].waitForExistence(timeout: .medium))
		XCTAssertTrue(app.staticTexts[AccessibilityIdentifiers.NotificationSettings.notificationsOn].waitForExistence(timeout: .short))
		XCTAssertTrue(app.staticTexts[AccessibilityIdentifiers.NotificationSettings.bulletDescOn].waitForExistence(timeout: .short))
		XCTAssertTrue(app.staticTexts[AccessibilityIdentifiers.NotificationSettings.bulletPoint1].waitForExistence(timeout: .short))
		XCTAssertTrue(app.staticTexts[AccessibilityIdentifiers.NotificationSettings.bulletPoint2].waitForExistence(timeout: .short))
		XCTAssertTrue(app.staticTexts[AccessibilityIdentifiers.NotificationSettings.bulletPoint3].waitForExistence(timeout: .short))
		XCTAssertTrue(app.textViews[AccessibilityIdentifiers.NotificationSettings.bulletDesc2].waitForExistence(timeout: .short))
		
		var screenshotCounter = 0
		let screenshotLabel = "screenshot_settings_notifications_on"
		
		snapshot("\(screenshotLabel)_\(String(format: "%04d", (screenshotCounter.inc())))")
		app.swipeUp()
		
		snapshot("\(screenshotLabel)_\(String(format: "%04d", (screenshotCounter.inc())))")

		// Jump to system settings.
		app.buttons[AccessibilityIdentifiers.NotificationSettings.openSystemSettings].waitAndTap()
		
		// Ensure we are in the settings.
		let systemSettings = XCUIApplication(bundleIdentifier: "com.apple.Preferences")
		XCTAssertTrue(systemSettings.wait(for: .runningForeground, timeout: .long))
	}
	
	func test_screenshot_SettingsNotificationsOff() throws {
		app.setLaunchArgument(LaunchArguments.notifications.isNotificationsEnabled, to: false)
		app.launch()
				
		// Open settings
		app.cells[AccessibilityIdentifiers.Home.settingsCardTitle].waitAndTap()
		
		// Open Notifications
		app.cells[AccessibilityIdentifiers.Settings.notificationLabel].waitAndTap()
		
		// Check if we are on notifications screen - OFF
		XCTAssertTrue(app.tables.images[AccessibilityIdentifiers.NotificationSettings.DeltaOnboarding.imageOff].waitForExistence(timeout: .short))
		XCTAssertTrue(app.staticTexts[AccessibilityIdentifiers.NotificationSettings.notificationsOff].waitForExistence(timeout: .short))
		XCTAssertTrue(app.staticTexts[AccessibilityIdentifiers.NotificationSettings.bulletDescOff].waitForExistence(timeout: .short))
		
		var screenshotCounter = 0
		let screenshotLabel = "screenshot_settings_notifications_on"
		
		snapshot("\(screenshotLabel)_\(String(format: "%04d", (screenshotCounter.inc())))")
		
		// Jump to system settings.
		app.buttons[AccessibilityIdentifiers.NotificationSettings.openSystemSettings].waitAndTap()
		
		// Ensure we are in the settings.
		let systemSettings = XCUIApplication(bundleIdentifier: "com.apple.Preferences")
		XCTAssertTrue(systemSettings.wait(for: .runningForeground, timeout: .long))
	}
}