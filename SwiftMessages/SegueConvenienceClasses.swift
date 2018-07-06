//
//  SegueConvenienceClasses.swift
//  SwiftMessages
//
//  Created by Timothy Moose on 6/18/18.
//  Copyright © 2018 SwiftKick Mobile. All rights reserved.
//

import UIKit

/**
 A convenience class that presents a top message using the standard message view layout.
 This class is intended for use with Interface Builder. Reference as `SwiftMessagesSegue` in code.
 */
public class TopMessageSegue: SwiftMessagesSegue {
    override public  init(identifier: String?, source: UIViewController, destination: UIViewController) {
        super.init(identifier: identifier, source: source, destination: destination)
        configure(layout: .topMessage)
    }
}

/**
 A convenience class that presents a top message using the card-style layout.
 This class is intended for use with Interface Builder. Reference as `SwiftMessagesSegue` in code.
 */
public class TopCardSegue: SwiftMessagesSegue {
    override public  init(identifier: String?, source: UIViewController, destination: UIViewController) {
        super.init(identifier: identifier, source: source, destination: destination)
        configure(layout: .topCard)
    }
}

/**
 A convenience class that presents a bottom message using the standard message view layout.
 This class is intended for use with Interface Builder. Reference as `SwiftMessagesSegue` in code.
 */
public class BottomMessageSegue: SwiftMessagesSegue {
    override public  init(identifier: String?, source: UIViewController, destination: UIViewController) {
        super.init(identifier: identifier, source: source, destination: destination)
        configure(layout: .bottomMessage)
    }
}

/**
 A convenience class that presents a bottom message using the card-style layout.
 This class is intended for use with Interface Builder. Reference as `SwiftMessagesSegue` in code.
 */
public class BottomCardSegue: SwiftMessagesSegue {
    override public  init(identifier: String?, source: UIViewController, destination: UIViewController) {
        super.init(identifier: identifier, source: source, destination: destination)
        configure(layout: .bottomCard)
    }
}

/**
 A convenience class that presents centered message using the card-style layout.
 This class is intended for use with Interface Builder. Reference as `SwiftMessagesSegue` in code.
 */
public class CenteredSegue: SwiftMessagesSegue {
    override public  init(identifier: String?, source: UIViewController, destination: UIViewController) {
        super.init(identifier: identifier, source: source, destination: destination)
        configure(layout: .centered)
    }
}
