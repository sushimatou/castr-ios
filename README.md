Installation
===================


To build and run CastrApp on iOS, we use CocoaPods to manage packages and dependencies.

----------


Install CocoaPods
-------------

To install CocoaPods, you need Ruby on your computer. Ruby is integrated by default in macOS. You can install Ruby with the next command:

>$ sudo apt-get install ruby-full

After this, just run:

>$ sudo gem install cocoapods

Install Pods in App Workspace
-------------
To run properly the project, you need to install Pods in your Xcode App WorkSpace. Shut down Xcode, open Terminal and go into your project file with:

>$ cd your-project-path/

And run the cocoapods installer:

>$ pod install

Cocoapods will install all the packages declared in the file **Podfile**. After that, you need to reopen your project with the file  **CastrApp.xcodeworkspace**. Build the app using <kbd>Cmd+B</kbd>. That's it !
