//
// 🦠 Corona-Warn-App
//

import Foundation

extension Locator {

	static func authorizeOtpEls(
		forceApiTokenHeader: Bool = false,
		isFake: Bool
	) -> Locator {
		let fake = String(isFake ? 1 : 0)
		let forceApiHeader = String(forceApiTokenHeader ? 1 : 0)
		return Locator(
			endpoint: .dataDonation,
			paths: ["version", "v1", "ios", "els"],
			method: .post,
			defaultHeaders: [fake: "cwa-fake", forceApiHeader: "cwa-ppac-ios-accept-api-token"],
			// TODO: "application/x-protobuf" as Content Type?
			// TODO: Body (Protobuf) is missing here
			type: .default
		)
	}

}