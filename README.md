<h1 align="center">
  PulseText AI
</h1>

<h4 align="center">Flutter Application that recognizes speech and converts it to Text with real time and offline</h4>

<p align="center">
  <a href="#key-features">Key Features</a>
</p>

<center>
<table>
  <tr>
    <td align="center">
      <img src="readme_assets/ios_demo.gif" alt="iosgif" /><br/>
      <b>iOS Demo</b>
    </td>
    <td align="center">
      <img src="readme_assets/android_demo.gif" alt="androidgif" /><br/>
      <b>Android Demo</b>
    </td>
  </tr>
</table>
</center>

## Key Features
* **Core Framework**: Built with Flutter and the Dart programming language.
* **State Management**: Riverpod for managing application state.
* **Audio Recording**: Uses the microphone of the device (tested on iOS & Android)
* **Testing**: Unit & Widget test & basic Integration test
* **Localization**: Implements Internationalization using [Flutter's localization features](https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization) configured in l10n.yaml
* **Flutter Version Management**: Uses FVM (.fvmrc) to manage the Flutter SDK version.
* **Speech Recognition**: Incorporates ONNX models for on-device speech recognition.
* **Onboarding**: Handles first-time user flow, completion state is persisted with shared preferences.

## Architecture
The application is following 'reference architecture' which helps to seperate between UI, business logic and data layer (aka seperation of concerns).
![architecture overview](readme_assets/speechtotext-flow.png)
- **Presentation**: the UI layer (e.g., buttons, text) and its controllers (e.g., updating, displaying). Generally, you will find two types inside it:
  - widget/screen: the actual UI elements
  - controller: manages the widget/screen state (providers). 
- **Domain**: the data model (simple and immutable classes)
- **Data:**: Everything related to receive and manipulating the data. In this application, we mainly have repositories to access the data (microphone/shared preferences) and run the model.
The folders are feature-based structured. Each feature has its own data, domain and presentation layer. 

