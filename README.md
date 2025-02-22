<p align="center">
   <img src="https://img.shields.io/badge/status-active-brightgreen">
<img src="https://img.shields.io/badge/Swift-5.10-orange.svg?style=flat">

<img src="https://img.shields.io/badge/Xcode-15.4-blue.svg">
   <a href="https://twitter.com/ricardo_psantos/">
      <img src="https://img.shields.io/badge/Twitter-@ricardo_psantos-blue.svg?style=flat" alt="Twitter">
   </a>
</p>


# Index

* __About__: _Into_
* __Architecture I__: _Overview_ | _Additional Modules_ | _Dependencies Manager_ 
* __Architecture II__: _Application_ | _Domain_ | _Core_ | _Common_ | _DesignSystem_ | _DevTools_
* __Tests__: _UI Tests_ | _Unit Tests_
* __Misc__: _Design Language_ | _XcodeGen_ | _SwiftLint and SwiftFormat_  | _Profiling_ | _CI/CD (Bitrise)_ | _Install_
	
# About 

___Hit Happens___ is an open [source app](https://en.wikipedia.org/wiki/Open_source), built using SwiftUI and available on __[AppStore](https://apps.apple.com/pt/app/hit-happens/id6670711255)__.

<center>
<img src=Source/_Documents/images/PreviewOnboarding.jpg width=800/>
</center>

## Intro 

_Hit Happens_ is built with __SwiftUI__ using __MVVM__, and was mainly designed to integrate various frameworks and features in a well-organized structure with support for __Unit Testing__, __UI Testing__. Also makes use of other tools like __[XcodeGen](https://github.com/yonaskolb/XcodeGen)__, __[SwiftLint](https://github.com/realm/SwiftLint)__ and __[SwiftFormat](https://github.com/nicklockwood/SwiftFormat)__

__SwiftUI__ because is Apple's current standart and offers several advantages like including a declarative syntax that simplifies UI design, real-time previews for faster iteration, and seamless integration with Swift for a unified coding experience while also enabling cross-platform development with a single codebase, significantly reducing development time and effort.

__MVVM__ (Model-View-ViewModel) because separates concerns by dividing code into _Model_, _View_, and _ViewModel_, making maintenance easier. Also improves testability by isolating the _ViewModel_ for _unit tests_, enhancing code reliability. It also boosts reusability, allowing _ViewModels_ and _Views_ to be used across different contexts. Additionally, _MVVM_ simplifies data binding, integrating smoothly with _SwiftUI_ and _Combine_ for reactive and responsive user interfaces.

The navigation was inspired by [Modular Navigation in SwiftUI: A Comprehensive Guide](https://medium.com/gitconnected/modular-navigation-in-swiftui-a-comprehensive-guide-5eeb8a511583).

## Architecture I


<center>
<img src=Source/_Documents/Graph_prety.viz.png width=800/>
</center>


### Overview

The app is built using _Clean Architecture_ principles and separation of concerns, ensuring a maintainable and scalable codebase. It leverages dependency injection and interfaces for easy testing and seamless implementation changes.

* __App (Hit Happens):__ The main application containing _Views_, _ViewModels_, _Managers_ (e.g., Analytics), _Assets_, and handling the app's life cycle.

* __Domain:__ Defines the app's _Models_ and _Interfaces_.

* __Core:__ Implements the business logic, such as storage, caching and API requests, defined in the _Domain_.

* __DesignSystem:__ Houses definitions for the app's Fonts, Colors, and Designables (reusable UI components).


### Additional Modules

There are 2 other modules not displayed for simplicity. 

* __Common:__ A utility toolbox containing helper extensions, property wrappers, and other utilities. It has its own unit tests and can be used in any project as it has no dependencies. More info at [https://github.com/ricardopsantos/Common](https://github.com/ricardopsantos/Common)
 
* __DevTools:__ Manages essencialy app logs, is its a module know across all other modules to facilitate logging.

This modular structure ensures each component is focused on a specific responsibility, promoting clean, efficient, and easily testable code.

### Dependencies Manager 

As package dependencies manager was choosen [__Swift Package Manager__](https://www.swift.org/documentation/package-manager/), as it simplifies dependency management and project organization for Swift developers. Also, enables you to easily add, update, and manage third-party libraries and frameworks. Integrated seamlessly with Xcode, Swift Package Manager promotes modularity, improves build performance, and ensures that your dependencies are up-to-date, making it an essential tool for modern Swift development.

The app philosophy emphasizes avoiding the addition of large dependencies for simple tasks (e.g., using Alamofire for a basic REST GET method). Instead, we carefully selected only three essential dependencies to handle complex or time-consuming (to implement) tasks:

* [__KeychainAccess__](https://github.com/kishikawakatsumi/KeychainAccess): _"KeychainAccess is a simple Swift wrapper for Keychain that works on iOS and macOS. Makes using Keychain APIs extremely easy and much more palatable to use in Swift."_
* [__TinyConstraints__](https://github.com/roberthein/TinyConstraints): _"TinyConstraints is the syntactic sugar that makes Auto Layout sweeter for human use."_
* [__Nimble__](https://github.com/Quick/Nimble): _"A matcher framework that enables writing expressive and readable tests."_

# Architecture II

The project is organized into several key directories/targets, each serving a specific purpose: __Application (Hit Happens)__, __Domain__, __Core__, __Common__, __DesignSystem__, __DevTools__, __UnitTests__ and __UITests__ 

## Application

<center>
<img src=Source/_Documents/images/Application.png width=800/>
</center>

It's the main application target. Contains the `Views` (scenes), `ViewModels` (glue betweeen _Views_ and Logic), `Coordinators` (routing logic). 

## Domain

<center>
<img src=Source/_Documents/images/Domain.png width=800/>
</center>

This target encapsulates the interface functionality of the application. Providing the _Models_ and _Protocols_ it define what the app can do and the data structures to do it.

- __Repositories__: Local data storage protocols.
- __Services__: Bigde betweens _ViewModels_ and _Network_ and where we can have more logic associated (eg. caching)

## Core

<center>
<img src=Source/_Documents/images/Core.png width=800/>
</center>

This target implements the _Domain_ functionalities, providing essential components such as:

- __Network__: Remote communication implementations.
- __Repositories__: Local data storage implementations.
- __Services__: Bigde betweens _ViewModels_ and _Network_ and where we can have more logic associated (eg. caching)

Notably, `Services`, `Repositories` and `Network` are defined and implemented via _protocols_. The actual implementation is determined in the main app target, which is crucial for testing and ensuring scalable, maintainable code.

## Common

<center>
<img src=Source/_Documents/images/Common.png width=800/>
</center>

A shared framework that includes extensions and utility functions used across multiple targets, promoting code reuse and modularity. Should not depend on any target, and should seamless work on any project. 

## DesignSystem

This target houses design-related components, ensuring a consistent and reusable visual style throughout the application. Also houses the applications _Colors_ and _Fonts_

<center>
<img src=Source/_Documents/images/DesignSystem.png width=800/>
</center>

## DevTools

Includes various development tools and utilities such as logging, facilitating smoother development and debugging processes.

<center>
<img src=Source/_Documents/images/DevTools.png width=800/>
</center>

# Tests 

The app includes comprehensive testing coverage with both UI Tests and Unit Tests. These tests are designed to cover a wide range of daily development scenarios, ensuring the app's reliability and performance. Additionally, we have incorporated measure/performance tests to monitor and optimize the app's efficiency.

This revision aims to clearly communicate the purpose and scope of the tests while emphasizing their importance in maintaining app quality and performance.

<img src=Source/_Documents/images/UnitTests_2.png width=800/> 

### UITesting

The app includes UI Tests for views and routing logic

<img src=Source/_Documents/images/UITests.png width=800/>

    
### Unit Testing (ViewModels & Services)

The app _ViewModels_ are built on a way that can be tested.

<img src=Source/_Documents/images/UnitTests.vm.png width=800/>

The app _Services_ are built on a way that can be tested.

<img src=Source/_Documents/images/UnitTests.services.png width=800/>

# Misc

## iClould Sync

<table>
<tr>
<td>
<center>
<img src=Source/_Documents/images/iCloud_sync1.png width=200/>
</center>

</td>
<td>
<center>
<img src=Source/_Documents/images/iCloud_sync2.png width=200/>
</center>
</td>
</tr>
</table>

## Ligth / Dark mode support 

<center>
<img src=Source/_Documents/images/PreviewDark.jpg width=800/>
</center>

<center>
<img src=Source/_Documents/images/PreviewLight.jpg width=800/>
</center>

## Design Language 

Design language in mobile apps refers to a set of guidelines and principles that define the visual and interactive style of an application. It includes elements like color schemes, typography, iconography, and spacing to ensure a cohesive and intuitive user experience. A well-defined design language helps maintain consistency, improve usability, and strengthen brand identity across different platforms and devices.

More about at [Adding a Design Language to your Xcode project.](https://medium.com/@ricardojpsantos/adding-a-design-language-to-your-xcode-project-fef5be39bef7)

### Custom Colors (for Ligth/Dark mode)

<img src=Source/_Documents/images/Colors.png width=800/>

### Custom Fonts 

<img src=Source/_Documents/images/Fonts.png width=800/>

### Custom Designables 

<img src=Source/_Documents/images/Designables.png width=800/>

##  XcodeGen

__XcodeGen__ treamlines project management by allowing you to generate Xcode project files from a simple YAML or JSON specification. This approach reduces merge conflicts, ensures consistency across teams, and makes it easier to version control project settings. By automating project setup, XcodeGen enhances productivity and maintains a cleaner, more organized codebase.


## SwiftLint and SwiftFormat

[SwiftLint](https://github.com/realm/SwiftLint) and [SwiftFormat](https://github.com/nicklockwood/SwiftFormat) are essential tools for maintaining code quality in Swift projects. SwiftLint enforces coding style and conventions by analyzing your code for potential issues and inconsistencies, ensuring adherence to best practices. SwiftFormat, on the other hand, automatically formats your Swift code to conform to a consistent style, making it more readable and maintainable. Together, they help streamline development workflows and uphold code standards across teams.

## Profiling

As of today, the project is free from memory [leaks](https://developer.apple.com/documentation/xcode/diagnosing-memory-thread-and-crash-issues-early), ensuring stable performance even with extended use.

<img src=Source/_Documents/images/Leaks.png width=800/>

The app maintains a minimal memory footprint, consistently staying around 50-60 MB after adding 50 new events and navigating through various screens.

<img src=Source/_Documents/images/MemoryPrint.png width=800/>

## CI/CD (Bitrise)

Bitrise, a mobile-focused CI/CD platform, automates build, test, and deployment workflows to streamline development and accelerate quality app delivery—making it the chosen platform for this project.

<center>
<img src=Source/_Documents/images/Bitrise_1.png width=800/>
</center>

<center>
<img src=Source/_Documents/images/Bitrise_2.png width=800/>
</center>

## Install 

No need to install anything, as all app dependencies are managed via [Swift Package Manager](https://www.swift.org/documentation/package-manager/).

However, the project can be fully rebuilt with `./makefile.sh` (for a total cleanup and conflict fixing) using [XcodeGen](https://github.com/yonaskolb/XcodeGen). If you are not familiar with XcodeGen, please check [Avoiding merge conflicts with XcodeGen](https://medium.com/@ricardojpsantos/avoiding-merge-conflicts-with-xcodegen-a0e2a1647bcb).

The scripts can be found at `Source/XcodeGen`

<img src=Source/_Documents/images/Install.png width=800/>