//
//  Log.swift
//  WebRTCTutorial
//
//  Created by 정김기보 on 2021/03/16.
//

#if ENABLE_LOG

import SwiftyBeaver

let Log = SwiftyBeaver.self
extension SwiftyBeaver {
    static func setup() {
        let console = ConsoleDestination()
        setup(destination: console)
        Log.addDestination(console)
        
        let file = FileDestination()
        setup(destination: file)
        //file.format = "$Dyyyy-MM-dd HH:mm:ss.SSSZ$d $C$L$c $N.$F:$l - $M"
        Log.addDestination(file)
    }

    static func setup(destination: BaseDestination) {
        
        destination.minLevel = .debug   //.info
        
        destination.asynchronously = false    // defult is true

        destination.levelString.verbose = ""
        destination.levelString.debug   = ""
        destination.levelString.info    = ""
        destination.levelString.warning = ""
        destination.levelString.error   = ""

        destination.levelColor.verbose = "" //"🟣"
        destination.levelColor.debug   = "" //"🟢"
        destination.levelColor.info    = "" //"🔵"
        destination.levelColor.warning = "🟡warning "
        destination.levelColor.error   = "🔴error "
        
        destination.format = "$Dyyyy-MM-dd HH:mm:ss.SSSZ$d $C$L$c$N.$F:$l - $M"
        //destination.format = "$DHH:mm:ss.SSSZ$d $C$L$c$N.$F:$l - $M"    // AR 드로잉 인식 속도:
    }
    
    /// log something generally unimportant (lowest priority)
    class func v(_ message: @autoclosure () -> Any, _
        file: String = #file, _ function: String = #function, line: Int = #line, context: Any? = nil) {
        #if swift(>=5)
        custom(level: .verbose, message: message(), file: file, function: function, line: line, context: context)
        #else
        custom(level: .verbose, message: message, file: file, function: function, line: line, context: context)
        #endif
    }

    /// log something which help during debugging (low priority)
    class func d(_ message: @autoclosure () -> Any, _
        file: String = #file, _ function: String = #function, line: Int = #line, context: Any? = nil) {
        #if swift(>=5)
        custom(level: .debug, message: message(), file: file, function: function, line: line, context: context)
        #else
        custom(level: .debug, message: message, file: file, function: function, line: line, context: context)
        #endif
    }

    /// log something which you are really interested but which is not an issue or error (normal priority)
    class func i(_ message: @autoclosure () -> Any, _
        file: String = #file, _ function: String = #function, line: Int = #line, context: Any? = nil) {
        #if swift(>=5)
        custom(level: .info, message: message(), file: file, function: function, line: line, context: context)
        #else
        custom(level: .info, message: message, file: file, function: function, line: line, context: context)
        #endif
    }

    /// log something which may cause big trouble soon (high priority)
    class func w(_ message: @autoclosure () -> Any, _
        file: String = #file, _ function: String = #function, line: Int = #line, context: Any? = nil) {
        #if swift(>=5)
        custom(level: .warning, message: message(), file: file, function: function, line: line, context: context)
        #else
        custom(level: .warning, message: message, file: file, function: function, line: line, context: context)
        #endif
    }

    /// log something which will keep you awake at night (highest priority)
    class func e(_ message: @autoclosure () -> Any, _
        file: String = #file, _ function: String = #function, line: Int = #line, context: Any? = nil) {
        #if swift(>=5)
        custom(level: .error, message: message(), file: file, function: function, line: line, context: context)
        #else
        custom(level: .error, message: message, file: file, function: function, line: line, context: context)
        #endif
    }
}

#else

public class Log {
    static func setup() {}
    
    static func v(_ message: Any?) {}
    static func d(_ message: Any?) {}
    static func i(_ message: Any?) {}
    static func w(_ message: Any?) {}
    static func e(_ message: Any?) {}
}

#endif
