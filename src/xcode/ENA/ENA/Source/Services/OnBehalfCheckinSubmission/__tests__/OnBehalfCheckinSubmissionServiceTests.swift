//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class OnBehalfCheckinSubmissionServiceTests: CWATestCase {

	func testSuccessfulSubmission() {
		let client = ClientMock()

		let getRegistrationTokenExpectation = expectation(description: "getRegistrationTokenExpectation called")
		client.onGetRegistrationToken = { _, _, _, _, completion in
			completion(.success("registrationToken"))
			getRegistrationTokenExpectation.fulfill()
		}

		let getTANForExposureSubmitExpectation = expectation(description: "getTANForExposureSubmit called")
		client.onGetTANForExposureSubmit = { _, _, completion in
			completion(.success("submissionTAN"))
			getTANForExposureSubmitExpectation.fulfill()
		}

		let submitOnBehalfExpectation = expectation(description: "getRegistrationTokenExpectation called")
		client.onSubmitOnBehalf = { _, _, completion in
			completion(.success(()))
			submitOnBehalfExpectation.fulfill()
		}

		let service = OnBehalfCheckinSubmissionService(
			client: client,
			appConfigurationProvider: CachedAppConfigurationMock()
		)

		let completionExpectation = expectation(description: "completion called")
		service.submit(checkin: .mock(), teleTAN: "2222222223") { result in
			guard case .success = result else {
				XCTFail("Expected success")
				return
			}
			completionExpectation.fulfill()
		}

		waitForExpectations(timeout: .short)
	}

	func testSubmissionWithRegistrationTokenRequestErrorTeleTanAlreadyUsed() {
		let client = ClientMock()

		let getRegistrationTokenExpectation = expectation(description: "getRegistrationTokenExpectation called")
		client.onGetRegistrationToken = { _, _, _, _, completion in
			completion(.failure(.teleTanAlreadyUsed))
			getRegistrationTokenExpectation.fulfill()
		}

		let service = OnBehalfCheckinSubmissionService(
			client: client,
			appConfigurationProvider: CachedAppConfigurationMock()
		)

		let completionExpectation = expectation(description: "completion called")
		service.submit(checkin: .mock(), teleTAN: "2222222223") { result in
			switch result {
			case .success:
				XCTFail("Expected failure")
			case .failure(let error):
				XCTAssertEqual(error, .registrationTokenError(.teleTanAlreadyUsed))
				XCTAssertEqual(
					error.localizedDescription,
					"Ungültige TAN. Bitte überprüfen Sie Ihre Eingabe oder kontaktieren Sie die Stelle, die Ihnen die TAN mitgeteilt hat. (REGTOKEN_OB_CLIENT_ERROR)"
				)
			}
			completionExpectation.fulfill()
		}

		waitForExpectations(timeout: .short)
	}

	func testSubmissionWithRegistrationTokenRequestErrorQRAlreadyUsed() {
		let client = ClientMock()

		let getRegistrationTokenExpectation = expectation(description: "getRegistrationTokenExpectation called")
		client.onGetRegistrationToken = { _, _, _, _, completion in
			completion(.failure(.qrAlreadyUsed))
			getRegistrationTokenExpectation.fulfill()
		}

		let service = OnBehalfCheckinSubmissionService(
			client: client,
			appConfigurationProvider: CachedAppConfigurationMock()
		)

		let completionExpectation = expectation(description: "completion called")
		service.submit(checkin: .mock(), teleTAN: "2222222223") { result in
			switch result {
			case .success:
				XCTFail("Expected failure")
			case .failure(let error):
				XCTAssertEqual(error, .registrationTokenError(.qrAlreadyUsed))
				XCTAssertEqual(
					error.localizedDescription,
					"Ungültige TAN. Bitte überprüfen Sie Ihre Eingabe oder kontaktieren Sie die Stelle, die Ihnen die TAN mitgeteilt hat. (REGTOKEN_OB_CLIENT_ERROR)"
				)
			}
			completionExpectation.fulfill()
		}

		waitForExpectations(timeout: .short)
	}

	func testSubmissionWithRegistrationTokenRequestError40x() {
		let client = ClientMock()

		let getRegistrationTokenExpectation = expectation(description: "getRegistrationTokenExpectation called")
		client.onGetRegistrationToken = { _, _, _, _, completion in
			completion(.failure(.serverError(400)))
			getRegistrationTokenExpectation.fulfill()
		}

		let service = OnBehalfCheckinSubmissionService(
			client: client,
			appConfigurationProvider: CachedAppConfigurationMock()
		)

		let completionExpectation = expectation(description: "completion called")
		service.submit(checkin: .mock(), teleTAN: "2222222223") { result in
			switch result {
			case .success:
				XCTFail("Expected failure")
			case .failure(let error):
				XCTAssertEqual(error, .registrationTokenError(.serverError(400)))
				XCTAssertEqual(
					error.localizedDescription,
					"Ungültige TAN. Bitte überprüfen Sie Ihre Eingabe oder kontaktieren Sie die Stelle, die Ihnen die TAN mitgeteilt hat. (REGTOKEN_OB_CLIENT_ERROR)"
				)
			}
			completionExpectation.fulfill()
		}

		waitForExpectations(timeout: .short)
	}

	func testSubmissionWithRegistrationTokenRequestError50x() {
		let client = ClientMock()

		let getRegistrationTokenExpectation = expectation(description: "getRegistrationTokenExpectation called")
		client.onGetRegistrationToken = { _, _, _, _, completion in
			completion(.failure(.serverError(500)))
			getRegistrationTokenExpectation.fulfill()
		}

		let service = OnBehalfCheckinSubmissionService(
			client: client,
			appConfigurationProvider: CachedAppConfigurationMock()
		)

		let completionExpectation = expectation(description: "completion called")
		service.submit(checkin: .mock(), teleTAN: "2222222223") { result in
			switch result {
			case .success:
				XCTFail("Expected failure")
			case .failure(let error):
				XCTAssertEqual(error, .registrationTokenError(.serverError(500)))
				XCTAssertEqual(
					error.localizedDescription,
					"Ein Fehler ist aufgetreten. Bitte versuchen Sie es später noch einmal oder kontaktieren Sie die technische Hotline über App-Informationen -> Technische Hotline. (REGTOKEN_OB_SERVER_ERROR)"
				)
			}
			completionExpectation.fulfill()
		}

		waitForExpectations(timeout: .short)
	}

	func testSubmissionWithRegistrationTokenRequestNoNetworkError() {
		let client = ClientMock()

		let getRegistrationTokenExpectation = expectation(description: "getRegistrationTokenExpectation called")
		client.onGetRegistrationToken = { _, _, _, _, completion in
			completion(.failure(.noNetworkConnection))
			getRegistrationTokenExpectation.fulfill()
		}

		let service = OnBehalfCheckinSubmissionService(
			client: client,
			appConfigurationProvider: CachedAppConfigurationMock()
		)

		let completionExpectation = expectation(description: "completion called")
		service.submit(checkin: .mock(), teleTAN: "2222222223") { result in
			switch result {
			case .success:
				XCTFail("Expected failure")
			case .failure(let error):
				XCTAssertEqual(error, .registrationTokenError(.noNetworkConnection))
				XCTAssertEqual(
					error.localizedDescription,
					"Ihre Internetverbindung wurde unterbrochen. Bitte prüfen Sie die Verbindung und versuchen Sie es erneut. (REGTOKEN_OB_NO_NETWORK)"
				)
			}
			completionExpectation.fulfill()
		}

		waitForExpectations(timeout: .short)
	}

	func testSubmissionWithSubmissionTANRequestError40x() {
		let client = ClientMock()

		let getTANForExposureSubmitExpectation = expectation(description: "getTANForExposureSubmit called")
		client.onGetTANForExposureSubmit = { _, _, completion in
			completion(.failure(.serverError(400)))
			getTANForExposureSubmitExpectation.fulfill()
		}

		let service = OnBehalfCheckinSubmissionService(
			client: client,
			appConfigurationProvider: CachedAppConfigurationMock()
		)

		let completionExpectation = expectation(description: "completion called")
		service.submit(checkin: .mock(), teleTAN: "2222222223") { result in
			switch result {
			case .success:
				XCTFail("Expected failure")
			case .failure(let error):
				XCTAssertEqual(error, .submissionTANError(.serverError(400)))
				XCTAssertEqual(
					error.localizedDescription,
					"Ein Fehler ist aufgetreten. Bitte kontaktieren Sie die technische Hotline über App-Informationen -> Technische Hotline. (TAN_OB_CLIENT_ERROR)"
				)
			}
			completionExpectation.fulfill()
		}

		waitForExpectations(timeout: .short)
	}

	func testSubmissionWithSubmissionTANRequestError50x() {
		let client = ClientMock()

		let getTANForExposureSubmitExpectation = expectation(description: "getTANForExposureSubmit called")
		client.onGetTANForExposureSubmit = { _, _, completion in
			completion(.failure(.serverError(500)))
			getTANForExposureSubmitExpectation.fulfill()
		}

		let service = OnBehalfCheckinSubmissionService(
			client: client,
			appConfigurationProvider: CachedAppConfigurationMock()
		)

		let completionExpectation = expectation(description: "completion called")
		service.submit(checkin: .mock(), teleTAN: "2222222223") { result in
			switch result {
			case .success:
				XCTFail("Expected failure")
			case .failure(let error):
				XCTAssertEqual(error, .submissionTANError(.serverError(500)))
				XCTAssertEqual(
					error.localizedDescription,
					"Ein Fehler ist aufgetreten. Bitte versuchen Sie es später noch einmal oder kontaktieren Sie die technische Hotline über App-Informationen -> Technische Hotline. (TAN_OB_SERVER_ERROR)"
				)
			}
			completionExpectation.fulfill()
		}

		waitForExpectations(timeout: .short)
	}

	func testSubmissionWithSubmissionTANRequestNoNetworkError() {
		let client = ClientMock()

		let getTANForExposureSubmitExpectation = expectation(description: "getTANForExposureSubmit called")
		client.onGetTANForExposureSubmit = { _, _, completion in
			completion(.failure(.noNetworkConnection))
			getTANForExposureSubmitExpectation.fulfill()
		}

		let service = OnBehalfCheckinSubmissionService(
			client: client,
			appConfigurationProvider: CachedAppConfigurationMock()
		)

		let completionExpectation = expectation(description: "completion called")
		service.submit(checkin: .mock(), teleTAN: "2222222223") { result in
			switch result {
			case .success:
				XCTFail("Expected failure")
			case .failure(let error):
				XCTAssertEqual(error, .submissionTANError(.noNetworkConnection))
				XCTAssertEqual(
					error.localizedDescription,
					"Ihre Internetverbindung wurde unterbrochen. Bitte prüfen Sie die Verbindung und versuchen Sie es erneut. (TAN_OB_NO_NETWORK)"
				)
			}
			completionExpectation.fulfill()
		}

		waitForExpectations(timeout: .short)
	}

	func testSubmissionWithSubmissionRequestInvalidPayloadOrHeadersError() {
		let client = ClientMock()

		let submitOnBehalfExpectation = expectation(description: "getRegistrationTokenExpectation called")
		client.onSubmitOnBehalf = { _, _, completion in
			completion(.failure(.invalidPayloadOrHeaders))
			submitOnBehalfExpectation.fulfill()
		}

		let service = OnBehalfCheckinSubmissionService(
			client: client,
			appConfigurationProvider: CachedAppConfigurationMock()
		)

		let completionExpectation = expectation(description: "completion called")
		service.submit(checkin: .mock(), teleTAN: "2222222223") { result in
			switch result {
			case .success:
				XCTFail("Expected failure")
			case .failure(let error):
				XCTAssertEqual(error, .submissionError(.invalidPayloadOrHeaders))
				XCTAssertEqual(
					error.localizedDescription,
					"Ein Fehler ist aufgetreten. Bitte kontaktieren Sie die technische Hotline über App-Informationen -> Technische Hotline. (SUBMISSION_OB_CLIENT_ERROR)"
				)
			}
			completionExpectation.fulfill()
		}

		waitForExpectations(timeout: .short)
	}

	func testSubmissionWithSubmissionRequestInvalidTanError() {
		let client = ClientMock()

		let submitOnBehalfExpectation = expectation(description: "getRegistrationTokenExpectation called")
		client.onSubmitOnBehalf = { _, _, completion in
			completion(.failure(.invalidTan))
			submitOnBehalfExpectation.fulfill()
		}

		let service = OnBehalfCheckinSubmissionService(
			client: client,
			appConfigurationProvider: CachedAppConfigurationMock()
		)

		let completionExpectation = expectation(description: "completion called")
		service.submit(checkin: .mock(), teleTAN: "2222222223") { result in
			switch result {
			case .success:
				XCTFail("Expected failure")
			case .failure(let error):
				XCTAssertEqual(error, .submissionError(.invalidTan))
				XCTAssertEqual(
					error.localizedDescription,
					"Ein Fehler ist aufgetreten. Bitte kontaktieren Sie die technische Hotline über App-Informationen -> Technische Hotline. (SUBMISSION_OB_CLIENT_ERROR)"
				)
			}
			completionExpectation.fulfill()
		}

		waitForExpectations(timeout: .short)
	}

	func testSubmissionWithSubmissionRequestError40x() {
		let client = ClientMock()

		let submitOnBehalfExpectation = expectation(description: "getRegistrationTokenExpectation called")
		client.onSubmitOnBehalf = { _, _, completion in
			completion(.failure(.other(.serverError(400))))
			submitOnBehalfExpectation.fulfill()
		}

		let service = OnBehalfCheckinSubmissionService(
			client: client,
			appConfigurationProvider: CachedAppConfigurationMock()
		)

		let completionExpectation = expectation(description: "completion called")
		service.submit(checkin: .mock(), teleTAN: "2222222223") { result in
			switch result {
			case .success:
				XCTFail("Expected failure")
			case .failure(let error):
				XCTAssertEqual(error, .submissionError(.other(.serverError(400))))
				XCTAssertEqual(
					error.localizedDescription,
					"Ein Fehler ist aufgetreten. Bitte kontaktieren Sie die technische Hotline über App-Informationen -> Technische Hotline. (SUBMISSION_OB_CLIENT_ERROR)"
				)
			}
			completionExpectation.fulfill()
		}

		waitForExpectations(timeout: .short)
	}

	func testSubmissionWithSubmissionRequestError50x() {
		let client = ClientMock()

		let submitOnBehalfExpectation = expectation(description: "getRegistrationTokenExpectation called")
		client.onSubmitOnBehalf = { _, _, completion in
			completion(.failure(.other(.serverError(500))))
			submitOnBehalfExpectation.fulfill()
		}

		let service = OnBehalfCheckinSubmissionService(
			client: client,
			appConfigurationProvider: CachedAppConfigurationMock()
		)

		let completionExpectation = expectation(description: "completion called")
		service.submit(checkin: .mock(), teleTAN: "2222222223") { result in
			switch result {
			case .success:
				XCTFail("Expected failure")
			case .failure(let error):
				XCTAssertEqual(error, .submissionError(.other(.serverError(500))))
				XCTAssertEqual(
					error.localizedDescription,
					"Ein Fehler ist aufgetreten. Bitte versuchen Sie es später noch einmal oder kontaktieren Sie die technische Hotline über App-Informationen -> Technische Hotline. (SUBMISSION_OB_SERVER_ERROR)"
				)
			}
			completionExpectation.fulfill()
		}

		waitForExpectations(timeout: .short)
	}

	func testSubmissionWithSubmissionRequestNoNetworkError() {
		let client = ClientMock()

		let submitOnBehalfExpectation = expectation(description: "getRegistrationTokenExpectation called")
		client.onSubmitOnBehalf = { _, _, completion in
			completion(.failure(.other(.noNetworkConnection)))
			submitOnBehalfExpectation.fulfill()
		}

		let service = OnBehalfCheckinSubmissionService(
			client: client,
			appConfigurationProvider: CachedAppConfigurationMock()
		)

		let completionExpectation = expectation(description: "completion called")
		service.submit(checkin: .mock(), teleTAN: "2222222223") { result in
			switch result {
			case .success:
				XCTFail("Expected failure")
			case .failure(let error):
				XCTAssertEqual(error, .submissionError(.other(.noNetworkConnection)))
				XCTAssertEqual(
					error.localizedDescription,
					"Ihre Internetverbindung wurde unterbrochen. Bitte prüfen Sie die Verbindung und versuchen Sie es erneut. (SUBMISSION_OB_NO_NETWORK)"
				)
			}
			completionExpectation.fulfill()
		}

		waitForExpectations(timeout: .short)
	}

}
