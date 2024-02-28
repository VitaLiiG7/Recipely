// Validator.swift
// Copyright © RoadMap. All rights reserved.

import Foundation

/// Валидатор учетных данных пользователя
struct Validator {
    // MARK: - Constants

    enum Constants {
        static let loginRegEx = ##"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,10}"##
        static let passwordRegEx = ##"[a-zA-Z0-9!"#$%&'()*+,-./:;<=>?@\[\]^_`{|}~]{8,32}"##
    }

    // MARK: - Public Properties

    var isHidden = false

    // MARK: - Public Methods

    func isEmailValid(_ email: String) -> Bool {
        email.validateUsing(Constants.loginRegEx)
    }

    func isPasswordValid(_ password: String) -> Bool {
        password.validateUsing(Constants.passwordRegEx)
    }
}
