//
//  StringExtensionsSpec.swift
//  MarvelAppTests
//
//  Created by Mostafa Abdellateef on 2/19/18.
//  Copyright © 2018 Mostafa Abdellateef. All rights reserved.
//

import Foundation
import Quick
import Nimble


@testable import MarvelApp

class StringExtensionsSpec : QuickSpec {
    override func spec() {
        describe("String Extension") {
            it("should allow any string to be converted to it's MD5 representation") {
                let md5 = "1abcd1234".toMd5()
                expect(md5).to(equal("ffd275c5130566a2916217b101f26150"))
            }
        }
    }
}
