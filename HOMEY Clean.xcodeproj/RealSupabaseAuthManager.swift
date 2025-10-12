func signUp(fullName: String, email: String, password: String, referralCode: String?) {
    var metadata: [String: AnyJSON] = [
        "full_name": .string(fullName),
        "role": .string("client"),
        "app_source": .string("ios")
    ]
    if let referralCode = referralCode {
        metadata["referral_code"] = .string(referralCode)
    }
    // Rest of the signUp implementation remains unchanged
}
