<p align="center">
<img src="https://raw.githubusercontent.com/mohakapt/Stringz/master/app_icon.png">
</p>

<h1 align="center">Stringz</h1>
<p align="center"><i>It is Strings but with a Z 😬</i></p>

<p align="center"><i>Loved the project? Please visit give it a ⭐️</i></p>

Stringz is an application for macOS that (in my opinion) will save you a lot of headache while internationalizing your Xcode project.

![Stingz](https://raw.githubusercontent.com/mohakapt/Stringz/master/hero_image.png)

## Features
* Filter strings to show only translated or untranslated strings.
* Search for strings by typing any word of any langauge you remember.
* Easy to use and mac in it's core.
* Fast and doesn't need configuration
* Continuously being improved and updated

## Installation
1. Clone this repository somewhere on your mac.
2. Run the following command in Terminal:

```ruby
pod install
```

3. Open `Stringz.xcworkspace`, Build the project and run it on your mac.
4. That's it.

## Requirements
* Runtime: macOS 10.12 or greater (Yeah! I know, I'll try to pull this down very soon)
* Build: Xcode 8 and 10.12 SDK or greater

## Stuff i'd love to implement -as soon as i get some free time-
* Code spider to analyze the code and extract strings from classes
* Fetch initial translation from Google Translate
* Support for storyboards and xibs
* Support for Android strings
* Ability to enable internationalization on project
* Recent search history
* Support for untranslatable strings
* Ability to catigorize strings in the .strings file

## Dependencies
Stringz uses `XcodeEditor` to open xcode projects and browse their contents

## Important
Stringz still in its **beta versions**. Your app is amazing and i don't want it to get ruined because of me, so please do what any cautious developer would do and make a commit before using Stringz or (if you don't have version control in your app) make a backup of your app.

## Contributions
Stringz is my first macOS project so if you run into some messy code please don't judge instead create a pull request into `development` branch and i will be more than happy to merge it (Explaining what you changed and why would be highly appreciated).

## License
Stringz is available under the MIT license. See the LICENSE file for more information.
