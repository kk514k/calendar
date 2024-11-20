# Calendar Mobile Application Project for COMPS413F

This document provides a guide for setting up the Calendar mobile application project.

### Set Running Environment

Before running the code, please follow the steps below to set up your environment:

1. **Install Android Studio**
   - Download and install Android Studio 

2. **Install Visual Studio Code**
   - Download and install Visual Studio Code (VS Code) from the [official site](https://code.visualstudio.com/).
   - Install the Flutter extension for VS Code from the Visual Studio Marketplace:  
     [Flutter Extension for VS Code](https://marketplace.visualstudio.com/items?itemName=Dart-Code.flutter).

     https://marketplace.visualstudio.com/items?itemName=Dart-Code.flutter

3. **Create a New Flutter Project**
   - Open VS Code and press `Ctrl + Shift + P`.
   - Type `Flutter: New Project` and select it.
   - Enter the SDK path: `"c://dev"`.

4. **Configure Android Studio SDK**
   - Open Android Studio and navigate to the SDK settings to ensure that command-line tools are installed.

5. **Run Flutter Doctor**
   - Open a terminal and execute:  
     ```bash
     flutter doctor
     ```
   - Follow any prompts to resolve issues.

6. **Accept Android Licenses**
   - In the terminal, run:  
     ```bash
     flutter doctor --android-licenses
     ```

7. **Install Flutter Plugin in Android Studio**
   - Open Android Studio and go to `Plugins`.
   - Search for and install the Flutter plugin.

### Additional Resources

- For a detailed walkthrough on installing Flutter, refer to the YouTube video:  
  [How to install Flutter on Windows 2024 | Setup Android Studio for Flutter Step by Step](https://www.youtube.com/watch?v=mMeQhLGD-og).

   https://www.youtube.com/watch?v=mMeQhLGD-og
