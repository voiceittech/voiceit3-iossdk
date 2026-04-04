import UIKit

/// Main SDK entry point — preserves the VoiceItAPIThree class name for backwards compatibility.
/// Wraps VoiceItAPI for networking and provides encapsulated UI methods.
@objc public class VoiceItAPIThree: NSObject {

    @objc public var apiKey: String
    @objc public var apiToken: String
    @objc public var authHeader: String { api.authHeader }

    private let api: VoiceItAPI
    private weak var masterViewController: UIViewController?

    // MARK: - Init

    @objc public init(_ masterViewController: UIViewController, apiKey: String, apiToken: String) {
        self.masterViewController = masterViewController
        self.apiKey = apiKey
        self.apiToken = apiToken
        self.api = VoiceItAPI(apiKey: apiKey, apiToken: apiToken)
        super.init()
        Theme.set(nil)
    }

    @objc public init(_ masterViewController: UIViewController, apiKey: String, apiToken: String, styles: NSMutableDictionary?) {
        self.masterViewController = masterViewController
        self.apiKey = apiKey
        self.apiToken = apiToken
        self.api = VoiceItAPI(apiKey: apiKey, apiToken: apiToken)
        super.init()
        if let s = styles as? [String: String] {
            Theme.set(s)
        }
    }

    @objc public func setNotificationURL(_ url: String) {
        api.setNotificationURL(url)
    }

    // MARK: - Passthrough API Methods

    @objc public func getPhrases(_ contentLanguage: String, callback: @escaping (String?) -> Void) {
        api.getPhrases(contentLanguage) { callback($0) }
    }
    @objc public func getAllUsers(_ callback: @escaping (String?) -> Void) {
        api.getAllUsers { callback($0) }
    }
    @objc public func createUser(_ callback: @escaping (String?) -> Void) {
        api.createUser { callback($0) }
    }
    @objc public func checkUserExists(_ userId: String, callback: @escaping (String?) -> Void) {
        api.checkUserExists(userId) { callback($0) }
    }
    @objc public func deleteUser(_ userId: String, callback: @escaping (String?) -> Void) {
        api.deleteUser(userId) { callback($0) }
    }
    @objc public func getGroupsForUser(_ userId: String, callback: @escaping (String?) -> Void) {
        api.getGroupsForUser(userId) { callback($0) }
    }
    @objc public func getAllGroups(_ callback: @escaping (String?) -> Void) {
        api.getAllGroups { callback($0) }
    }
    @objc public func getGroup(_ groupId: String, callback: @escaping (String?) -> Void) {
        api.getGroup(groupId) { callback($0) }
    }
    @objc public func groupExists(_ groupId: String, callback: @escaping (String?) -> Void) {
        api.groupExists(groupId) { callback($0) }
    }
    @objc public func createGroup(_ description: String, callback: @escaping (String?) -> Void) {
        api.createGroup(description) { callback($0) }
    }
    @objc public func addUser(toGroup groupId: String, userId: String, callback: @escaping (String?) -> Void) {
        api.addUserToGroup(groupId, userId: userId) { callback($0) }
    }
    @objc public func removeUser(fromGroup groupId: String, userId: String, callback: @escaping (String?) -> Void) {
        api.removeUserFromGroup(groupId, userId: userId) { callback($0) }
    }
    @objc public func deleteGroup(_ groupId: String, callback: @escaping (String?) -> Void) {
        api.deleteGroup(groupId) { callback($0) }
    }
    @objc public func getAllVoiceEnrollments(_ userId: String, callback: @escaping (String?) -> Void) {
        api.getAllVoiceEnrollments(userId) { callback($0) }
    }
    @objc public func getAllFaceEnrollments(_ userId: String, callback: @escaping (String?) -> Void) {
        api.getAllFaceEnrollments(userId) { callback($0) }
    }
    @objc public func getAllVideoEnrollments(_ userId: String, callback: @escaping (String?) -> Void) {
        api.getAllVideoEnrollments(userId) { callback($0) }
    }
    @objc public func deleteAllEnrollments(_ userId: String, callback: @escaping (String?) -> Void) {
        api.deleteAllEnrollments(userId) { callback($0) }
    }
    @objc public func createVoiceEnrollment(_ userId: String, contentLanguage: String, audioPath: String, phrase: String, callback: @escaping (String?) -> Void) {
        api.createVoiceEnrollment(userId, contentLanguage: contentLanguage, phrase: phrase, audioPath: audioPath) { callback($0) }
    }
    @objc public func createFaceEnrollment(_ userId: String, videoPath: String, callback: @escaping (String?) -> Void) {
        api.createFaceEnrollment(userId, videoPath: videoPath) { callback($0) }
    }
    @objc public func createFaceEnrollment(_ userId: String, imageData: Data, callback: @escaping (String?) -> Void) {
        api.createFaceEnrollment(userId, imageData: imageData) { callback($0) }
    }
    @objc public func createVideoEnrollment(_ userId: String, contentLanguage: String, videoPath: String, phrase: String, callback: @escaping (String?) -> Void) {
        api.createVideoEnrollment(userId, contentLanguage: contentLanguage, phrase: phrase, videoPath: videoPath) { callback($0) }
    }
    @objc public func createVideoEnrollment(_ userId: String, contentLanguage: String, imageData: Data, audioPath: String, phrase: String, callback: @escaping (String?) -> Void) {
        api.createVideoEnrollment(userId, contentLanguage: contentLanguage, phrase: phrase, imageData: imageData, audioPath: audioPath) { callback($0) }
    }
    @objc public func voiceVerification(_ userId: String, contentLanguage: String, audioPath: String, phrase: String, callback: @escaping (String?) -> Void) {
        api.voiceVerification(userId, contentLanguage: contentLanguage, phrase: phrase, audioPath: audioPath) { callback($0) }
    }
    @objc public func faceVerification(_ userId: String, videoPath: String, callback: @escaping (String?) -> Void) {
        api.faceVerification(userId, videoPath: videoPath) { callback($0) }
    }
    @objc public func faceVerification(_ userId: String, imageData: Data, callback: @escaping (String?) -> Void) {
        api.faceVerification(userId, imageData: imageData) { callback($0) }
    }
    @objc public func videoVerification(_ userId: String, contentLanguage: String, videoPath: String, phrase: String, callback: @escaping (String?) -> Void) {
        api.videoVerification(userId, contentLanguage: contentLanguage, phrase: phrase, videoPath: videoPath) { callback($0) }
    }
    @objc public func videoVerification(_ userId: String, contentLanguage: String, imageData: Data, audioPath: String, phrase: String, callback: @escaping (String?) -> Void) {
        api.videoVerification(userId, contentLanguage: contentLanguage, phrase: phrase, imageData: imageData, audioPath: audioPath) { callback($0) }
    }
    @objc public func voiceIdentification(_ groupId: String, contentLanguage: String, audioPath: String, phrase: String, callback: @escaping (String?) -> Void) {
        api.voiceIdentification(groupId, contentLanguage: contentLanguage, phrase: phrase, audioPath: audioPath) { callback($0) }
    }
    @objc public func faceIdentification(_ groupId: String, videoPath: String, callback: @escaping (String?) -> Void) {
        api.faceIdentification(groupId, videoPath: videoPath) { callback($0) }
    }
    @objc public func faceIdentification(_ groupId: String, imageData: Data, callback: @escaping (String?) -> Void) {
        api.faceIdentification(groupId, imageData: imageData) { callback($0) }
    }
    @objc public func videoIdentification(_ groupId: String, contentLanguage: String, videoPath: String, phrase: String, callback: @escaping (String?) -> Void) {
        api.videoIdentification(groupId, contentLanguage: contentLanguage, phrase: phrase, videoPath: videoPath) { callback($0) }
    }
    @objc public func videoIdentification(_ groupId: String, contentLanguage: String, imageData: Data, audioPath: String, phrase: String, callback: @escaping (String?) -> Void) {
        api.videoIdentification(groupId, contentLanguage: contentLanguage, phrase: phrase, imageData: imageData, audioPath: audioPath) { callback($0) }
    }

    // MARK: - Encapsulated Enrollment Methods

    @objc public func encapsulatedVoiceEnrollUser(_ userId: String, contentLanguage: String, voicePrintPhrase: String, userEnrollmentsCancelled: @escaping () -> Void, userEnrollmentsPassed: @escaping (String?) -> Void) {
        launchEnrollment(type: .voice, userId: userId, contentLanguage: contentLanguage, voicePrintPhrase: voicePrintPhrase, cancelled: userEnrollmentsCancelled, passed: userEnrollmentsPassed)
    }

    @objc public func encapsulatedFaceEnrollUser(_ userId: String, userEnrollmentsCancelled: @escaping () -> Void, userEnrollmentsPassed: @escaping (String?) -> Void) {
        launchEnrollment(type: .face, userId: userId, contentLanguage: "", voicePrintPhrase: "", cancelled: userEnrollmentsCancelled, passed: userEnrollmentsPassed)
    }

    @objc public func encapsulatedFaceEnrollUser(_ userId: String, contentLanguage: String, userEnrollmentsCancelled: @escaping () -> Void, userEnrollmentsPassed: @escaping (String?) -> Void) {
        launchEnrollment(type: .face, userId: userId, contentLanguage: contentLanguage, voicePrintPhrase: "", cancelled: userEnrollmentsCancelled, passed: userEnrollmentsPassed)
    }

    @objc public func encapsulatedVideoEnrollUser(_ userId: String, contentLanguage: String, voicePrintPhrase: String, userEnrollmentsCancelled: @escaping () -> Void, userEnrollmentsPassed: @escaping (String?) -> Void) {
        launchEnrollment(type: .video, userId: userId, contentLanguage: contentLanguage, voicePrintPhrase: voicePrintPhrase, cancelled: userEnrollmentsCancelled, passed: userEnrollmentsPassed)
    }

    private func launchEnrollment(type: VIMainNavigationController.EnrollmentType, userId: String, contentLanguage: String, voicePrintPhrase: String, cancelled: @escaping () -> Void, passed: @escaping (String?) -> Void) {
        DispatchQueue.main.async { [weak self] in
            guard let self, let vc = self.masterViewController else { return }
            let storyboard = VoiceItUtilities.getVoiceItStoryBoard()
            guard let navVC = storyboard.instantiateViewController(withIdentifier: "mainNavController") as? VIMainNavigationController else { return }
            navVC.myVoiceIt = self
            navVC.uniqueId = userId
            navVC.contentLanguage = contentLanguage
            navVC.voicePrintPhrase = voicePrintPhrase
            navVC.enrollmentType = type
            navVC.userEnrollmentsCancelled = cancelled
            navVC.userEnrollmentsPassed = passed
            navVC.modalPresentationStyle = .overCurrentContext
            vc.present(navVC, animated: true)
        }
    }

    // MARK: - Encapsulated Verification Methods

    @objc public func encapsulatedVoiceVerification(_ userId: String, contentLanguage: String, voicePrintPhrase: String, userVerificationCancelled: @escaping () -> Void, userVerificationSuccessful: @escaping (Float, String?) -> Void, userVerificationFailed: @escaping (Float, String?) -> Void) {
        DispatchQueue.main.async { [weak self] in
            guard let self, let vc = self.masterViewController else { return }
            let storyboard = VoiceItUtilities.getVoiceItStoryBoard()
            guard let verifyVC = storyboard.instantiateViewController(withIdentifier: "verifyVoiceVC") as? VIVoiceVerificationViewController else { return }
            verifyVC.userToVerifyUserId = userId
            verifyVC.contentLanguage = contentLanguage
            verifyVC.thePhrase = voicePrintPhrase
            verifyVC.voiceItMaster = self
            verifyVC.userVerificationCancelled = userVerificationCancelled
            verifyVC.userVerificationSuccessful = userVerificationSuccessful
            verifyVC.userVerificationFailed = userVerificationFailed
            verifyVC.modalPresentationStyle = .overCurrentContext
            vc.present(verifyVC, animated: true)
        }
    }

    @objc public func encapsulatedFaceVerification(_ userId: String, contentLanguage: String, userVerificationCancelled: @escaping () -> Void, userVerificationSuccessful: @escaping (Float, String?) -> Void, userVerificationFailed: @escaping (Float, String?) -> Void) {
        DispatchQueue.main.async { [weak self] in
            guard let self, let vc = self.masterViewController else { return }
            let storyboard = VoiceItUtilities.getVoiceItStoryBoard()
            guard let verifyVC = storyboard.instantiateViewController(withIdentifier: "faceVerificationVC") as? VIFaceVerificationViewController else { return }
            verifyVC.userToVerifyUserId = userId
            verifyVC.contentLanguage = contentLanguage
            verifyVC.voiceItMaster = self
            verifyVC.userVerificationCancelled = userVerificationCancelled
            verifyVC.userVerificationSuccessful = userVerificationSuccessful
            verifyVC.userVerificationFailed = userVerificationFailed
            verifyVC.modalPresentationStyle = .overCurrentContext
            vc.present(verifyVC, animated: true)
        }
    }

    @objc public func encapsulatedVideoVerification(_ userId: String, contentLanguage: String, voicePrintPhrase: String, userVerificationCancelled: @escaping () -> Void, userVerificationSuccessful: @escaping (Float, Float, String?) -> Void, userVerificationFailed: @escaping (Float, Float, String?) -> Void) {
        DispatchQueue.main.async { [weak self] in
            guard let self, let vc = self.masterViewController else { return }
            let storyboard = VoiceItUtilities.getVoiceItStoryBoard()
            guard let verifyVC = storyboard.instantiateViewController(withIdentifier: "videoVerifyVC") as? VIVideoVerificationViewController else { return }
            verifyVC.userToVerifyUserId = userId
            verifyVC.contentLanguage = contentLanguage
            verifyVC.thePhrase = voicePrintPhrase
            verifyVC.voiceItMaster = self
            verifyVC.userVerificationCancelled = userVerificationCancelled
            verifyVC.userVerificationSuccessful = userVerificationSuccessful
            verifyVC.userVerificationFailed = userVerificationFailed
            verifyVC.modalPresentationStyle = .overCurrentContext
            vc.present(verifyVC, animated: true)
        }
    }

    // MARK: - Encapsulated Identification Methods

    @objc public func encapsulatedVoiceIdentification(_ groupId: String, contentLanguage: String, voicePrintPhrase: String, userIdentificationCancelled: @escaping () -> Void, userIdentificationSuccessful: @escaping (Float, String?, String?) -> Void, userIdentificationFailed: @escaping (Float, String?) -> Void) {
        DispatchQueue.main.async { [weak self] in
            guard let self, let vc = self.masterViewController else { return }
            let storyboard = VoiceItUtilities.getVoiceItStoryBoard()
            guard let idVC = storyboard.instantiateViewController(withIdentifier: "identifyVoiceVC") as? VIVoiceIdentificationViewController else { return }
            idVC.groupToIdentifyGroupId = groupId
            idVC.contentLanguage = contentLanguage
            idVC.thePhrase = voicePrintPhrase
            idVC.voiceItMaster = self
            idVC.userIdentificationCancelled = userIdentificationCancelled
            idVC.userIdentificationSuccessful = userIdentificationSuccessful
            idVC.userIdentificationFailed = userIdentificationFailed
            idVC.modalPresentationStyle = .overCurrentContext
            vc.present(idVC, animated: true)
        }
    }
}
