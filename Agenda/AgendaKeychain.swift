//
//  AgendaKeychain.swift
//  Agenda
//
//  Created by Eric Peterson on 12/18/20.
//
//  Largely cribbed from https://developer.apple.com/documentation/security/keychain_services/keychain_items/using_the_keychain_to_manage_user_secrets .

import Foundation

struct Credentials {
    var username: String
    var password: String
}

enum KeychainError: Error {
    case noPassword
    case unexpectedPasswordData
    case unhandledError(status: OSStatus)
}

func getCredentials() -> Credentials? {
    let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                kSecAttrServer as String: server,
                                kSecMatchLimit as String: kSecMatchLimitOne,
                                kSecReturnAttributes as String: true,
                                kSecReturnData as String: true]
    
    var item: CFTypeRef?
    let status = SecItemCopyMatching(query as CFDictionary, &item)
    guard status != errSecItemNotFound else {
        return nil
    }
    guard status == errSecSuccess else {
        return nil
    }

    guard let existingItem = item as? [String : Any],
        let passwordData = existingItem[kSecValueData as String] as? Data,
        let password = String(data: passwordData, encoding: String.Encoding.utf8),
        let account = existingItem[kSecAttrAccount as String] as? String
    else {
        return nil
    }
    
    return Credentials(username: account, password: password)
}

func setCredentials(credentials: Credentials) throws -> () {
    // first, try to update credentials
    let searchQuery: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                      kSecAttrServer as String: server]
    let account = credentials.username
    let password = credentials.password.data(using: String.Encoding.utf8)!
    let attributes: [String: Any] = [kSecAttrAccount as String: account,
                                     kSecValueData as String: password]
    let searchStatus = SecItemUpdate(searchQuery as CFDictionary, attributes as CFDictionary)
    if searchStatus == errSecSuccess { return }
    
    // if none are found, add fresh credentials instead
    let addQuery: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                   kSecAttrAccount as String: account,
                                   kSecAttrServer as String: server,
                                   kSecValueData as String: password]
    
    let addStatus = SecItemAdd(addQuery as CFDictionary, nil)
    guard addStatus == errSecSuccess else {
        throw KeychainError.unhandledError(status: addStatus)
    }
}
