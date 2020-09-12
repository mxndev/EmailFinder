//
//  SharedContainer.swift
//  EmailFinder
//
//  Created by Mikołaj Płachta on 11/09/2020.
//  Copyright © 2020 Mikołaj Płachta. All rights reserved.
//

import Swinject

class SharedContainer {
    static let sharedContainer = Container() { _ in }
}
