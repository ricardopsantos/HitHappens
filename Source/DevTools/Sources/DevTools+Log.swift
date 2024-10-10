//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import UIKit
//
import Common

public extension DevTools {
    struct Log {
        private init() {}
        public static var counterTotal = 0
        public static var counterErrors = 0

        public enum Tag {
            case generic // Misc....
            case view // For Views
            case business // For ViewModels/UseCases/Coordinators/WebAPIs/BackgroundServices, PushNotifications, FireBase...
            case appDelegate // For AppDelegate services
        }

        public enum LogTemplate {
            case log(_ any: Any)
            case viewInit(_ origin: String, function: String = #function)
            case appLifeCycle(_ message: Any)
            case warning(_ message: Any)
            case valueChanged(_ origin: String, _ key: String, _ value: String?)
            case screenIn(_ origin: String)
            case screenOut(_ origin: String)
            case onAppear(_ origin: String)
            case onDisappear(_ origin: String)
            case tapped(_ origin: String, _ message: String)
            var log: String {
                switch self {
                case .warning(let message):
                    return "\n !! WARNING !!\n  \(message)\n !! WARNING !!\n"
                case .log(let any):
                    return "\(any)"
                case .viewInit(let origin, let function):
                    return "👶🏻 \(origin) 👶🏻 \(function)"
                case .appLifeCycle(let message):
                    return "🔀 🔀 App Life Cycle 🔀 🔀: \(message)"
                case .screenIn(let origin):
                    return "➡️ Screen In ➡️ \(origin)"
                case .screenOut(let origin):
                    return "⬅️ Screen Out ⬅️ \(origin)"
                case .onAppear(let origin):
                    return "➡️ onAppear ➡️ \(origin)"
                case .onDisappear(let origin):
                    return "⬅️ onDisappear ⬅️ \(origin)"
                case .tapped(let origin, let message):
                    return "👆 \(origin) 👆 Tapped [\(message)] 👆"
                case .valueChanged(let origin, let key, let value):
                    if value == nil {
                        return "💾 \(origin) 💾 Value of [\(key)] was deleted"
                    }
                    guard let value else {
                        return ""
                    }
                    if value.isEmpty {
                        return "💾 \(origin) 💾 Value of [\(key)] changed"
                    } else {
                        return "💾 \(origin) 💾 Value of [\(key)] changed/updated to [\(value)]"
                    }
                }
            }
        }

        static func canLog(_ any: Any?, _ tag: Tag) -> Bool {
            guard Common_Utils.onDebug else {
                return false
            }
            guard any != nil else {
                return false
            }
            // Log by log type
            return switch tag {
            case .generic: !DevTools.onTargetProduction || Common_Utils.onDebug
            case .view: !DevTools.onTargetProduction || Common_Utils.onDebug
            case .business: !DevTools.onTargetProduction || Common_Utils.onDebug
            case .appDelegate: !DevTools.onTargetProduction || Common_Utils.onDebug
            }
        }

        /// Things that must be fixed and shouldn't happen. This logs will always be printed (unless Prod apps)
        public static func error(
            _ any: any Error,
            _ tag: Tag,
            function: String = #function,
            file: String = #file,
            line: Int = #line
        ) {
            DevTools.Log.error("\(any)", tag, function: function, file: file, line: line)
        }

        public static func error(
            _ any: String,
            _ tag: Tag,
            function: String = #function,
            file: String = #file,
            line: Int = #line
        ) {
            guard canLog(any, tag) else {
                return
            }
            let log = prettyPrinted(log: "\(any)", type: "🟥🟥🟥🟥 Error 🟥🟥🟥🟥", tag: tag, function: function, file: file, line: line)
            counterErrors += 1
            // swiftlint:disable logs_rule_1
            print(log)
            // swiftlint:enable logs_rule_1
            if !DevTools.onTargetProduction {
                store(log: log)
            }
        }

        public static func debug(
            _ string: String,
            _ tag: Tag,
            function: String = #function,
            file: String = #file,
            line: Int = #line
        ) {
            Self.debug(.log(string), tag, function: function, file: file, line: line)
        }

        public static func debug(
            _ any: LogTemplate,
            _ tag: Tag,
            function: String = #function,
            file: String = #file,
            line: Int = #line
        ) {
            guard canLog(any, tag) else {
                return
            }
            counterTotal += 1
            let log = "🟢 Log_\(counterTotal) @ \(Date.utcNow) - \(any.log)\n".replace(" +0000", with: "").replace("Optional", with: "")
            // swiftlint:disable logs_rule_1
            print(log)
            // swiftlint:enable logs_rule_1
            if Common_Utils.false {
                store(log: log)
            }
        }
    }
}

//
// MARK: - Storage
//

public extension DevTools.Log {
    static func deleteLogs() { Common_Logs.Persistence.reset() }
    static func retrieveLogs(full: Bool = true) -> String {
        var logs = ""
        var allLogs = Common_Logs.Persistence.allLogs
        allLogs = allLogs.sorted(by: { a, b in
            if let date1 = Date.with(a.logId), let date2 = Date.with(b.logId) {
                return date1 > date2
            }
            return a.logId > b.logId
        })
        let maxLogsDaysToRetrieve = 10
        if allLogs.count > maxLogsDaysToRetrieve {
            allLogs = Array(allLogs.prefix(upTo: maxLogsDaysToRetrieve))
        }
        if !full, let first = allLogs.first {
            allLogs = [first]
        }
        allLogs.forEach { log in
            logs += "🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨\n"
            logs += "🚨🚨🚨🚨🚨 \(log.logId) 🚨🚨🚨🚨🚨\n"
            logs += log.logContent
            logs += "\n\n"
        }
        if !full {
            let max = 20000
            if logs.count > max {
                logs = String(logs.dropFirst(logs.count - max))
            }
        }
        return logs
    }
}

//
// MARK: - Private
//

fileprivate extension DevTools.Log {
    static func store(log: String) { Common_Logs.Persistence.appendToFileStart(log) }

    static func prettyPrinted(
        log: String,
        type: String,
        tag: Tag,
        function: String = #function,
        file: String = #file,
        line: Int = #line
    ) -> String {
        counterTotal += 1

        let senderCodeId = Common_Utils.senderCodeId(function, file: file, line: line)
        let maxLen = 10000
        let messageToPrint = log.count > maxLen ? log.trim.prefix(maxLen) + "(...)✂️✂️ Truncated @ \(maxLen) chars" : log.trim
        let title = "Log_\(counterTotal) @ \(Date.utcNow)"
        let separator = "##################"
        var logMessage = ""
        logMessage = "\(logMessage)\n\(separator)\(separator)\n"
        logMessage = "\(logMessage)# Title:  \(title)\n"
        logMessage = "\(logMessage)# Type:   \(type) | \(tag)\n"
        logMessage = "\(logMessage)# Sender: \(senderCodeId)\n"
        logMessage = "\(logMessage)# Thread: \(Thread.current.queueName)\n"
        logMessage = "\(logMessage)↓ ↓ ↓ ↓\n"
        if messageToPrint.hasSuffix("\n") {
            logMessage = "\(logMessage)\(messageToPrint)"
        } else {
            logMessage = "\(logMessage)\(messageToPrint)\n"
        }
        logMessage = "\(logMessage)↑ ↑ ↑ ↑\n"
        return logMessage
    }
}
