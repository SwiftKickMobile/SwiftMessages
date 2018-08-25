//
//  SegueConvenienceClasses.swift
//  SwiftMessages
//
//  Created by Timothy Moose on 6/18/18.
//  Copyright © 2018 SwiftKick Mobile. All rights reserved.
//

import UIKit
#if canImport(SwiftMessages) && !(COCOAPODS)
import SwiftMessages
#endif

/**
 A convenience class that presents a top message using the standard message view layout.
 This class is intended for use with Interface Builder. Reference as `SwiftMessagesSegue` in code.
 */
public class SwiftMessagesTopSegue: SwiftMessagesSegue {
    override public  init(identifier: String?, source: UIViewController, destination: UIViewController) {
        super.init(identifier: identifier, source: source, destination: destination)
        configure(layout: .topMessage)
    }
}

/**
 A convenience class that presents a top message using the card-style layout.
 This class is intended for use with Interface Builder. Reference as `SwiftMessagesSegue` in code.
 */
public class SwiftMessagesTopCardSegue: SwiftMessagesSegue {
    override public  init(identifier: String?, source: UIViewController, destination: UIViewController) {
        super.init(identifier: identifier, source: source, destination: destination)
        configure(layout: .topCard)
    }
}

/**
 A convenience class that presents a top message using the tab-style layout.
 This class is intended for use with Interface Builder. Reference as `SwiftMessagesSegue` in code.
 */
public class SwiftMessagesTopTabSegue: SwiftMessagesSegue {
    override public  init(identifier: String?, source: UIViewController, destination: UIViewController) {
        super.init(identifier: identifier, source: source, destination: destination)
        configure(layout: .topTab)
    }
}

/**
 A convenience class that presents a bottom message using the standard message view layout.
 This class is intended for use with Interface Builder. Reference as `SwiftMessagesSegue` in code.
 */
public class SwiftMessagesBottomSegue: SwiftMessagesSegue {
    override public  init(identifier: String?, source: UIViewController, destination: UIViewController) {
        super.init(identifier: identifier, source: source, destination: destination)
        configure(layout: .bottomMessage)
    }
}

/**
 A convenience class that presents a bottom message using the card-style layout.
 This class is intended for use with Interface Builder. Reference as `SwiftMessagesSegue` in code.
 */
public class SwiftMessagesBottomCardSegue: SwiftMessagesSegue {
    override public  init(identifier: String?, source: UIViewController, destination: UIViewController) {
        super.init(identifier: identifier, source: source, destination: destination)
        configure(layout: .bottomCard)
    }
}

/**
 A convenience class that presents a bottom message using the tab-style layout.
 This class is intended for use with Interface Builder. Reference as `SwiftMessagesSegue` in code.
 */
public class SwiftMessagesBottomTabSegue: SwiftMessagesSegue {
    override public  init(identifier: String?, source: UIViewController, destination: UIViewController) {
        super.init(identifier: identifier, source: source, destination: destination)
        configure(layout: .bottomTab)
    }
}

/**
 A convenience class that presents centered message using the card-style layout.
 This class is intended for use with Interface Builder. Reference as `SwiftMessagesSegue` in code.
 */
public class SwiftMessagesCenteredSegue: SwiftMessagesSegue {
    override public  init(identifier: String?, source: UIViewController, destination: UIViewController) {
        super.init(identifier: identifier, source: source, destination: destination)
        configure(layout: .centered)
    }
}
