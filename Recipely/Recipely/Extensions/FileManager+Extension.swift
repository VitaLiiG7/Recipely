// FileManager+Extension.swift
// Copyright © RoadMap. All rights reserved.

import Foundation

extension FileManager {
    func getDirectory(withName name: String, inUserDomain directory: FileManager.SearchPathDirectory) -> URL? {
        guard let targetURL = FileManager.default
            .urls(for: directory, in: .userDomainMask)
            .first?
            .appendingPathComponent(name)
        else { return nil }

        let targetPath = targetURL.path()
        if !FileManager.default.fileExists(atPath: targetPath) {
            do {
                try FileManager.default.createDirectory(atPath: targetPath, withIntermediateDirectories: true)
                print("Successfully created \"\(name)\"")
            } catch {
                print("Error creating folder: \(error)")
            }
        }
        return targetURL
    }
}
