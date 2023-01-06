# Changelog

## [4.2.1](https://github.com/openfoodfacts/smooth-app/compare/v4.2.0...v4.2.1) (2023-01-06)


### 🛠 Miscellaneous

* New Crowdin translations ([#3531](https://github.com/openfoodfacts/smooth-app/issues/3531)) ([984fa73](https://github.com/openfoodfacts/smooth-app/commit/984fa7343526e6fc87f4ad7f5af5557cd1720f7e))


### 🤖 Automation

* fix failing CI ([62f7769](https://github.com/openfoodfacts/smooth-app/commit/62f7769a36e87cc62979dc01ddd408ea0877d6db))


### 🐛 Bug Fixes

* [#3536](https://github.com/openfoodfacts/smooth-app/issues/3536) don't force entry into edit screen on card tap ([#3540](https://github.com/openfoodfacts/smooth-app/issues/3540)) ([f39de2a](https://github.com/openfoodfacts/smooth-app/commit/f39de2aac37c60a133ec8d098e0e06f01c41ddac))
* 3533 - using a not temporary directory for images to be uploaded ([#3539](https://github.com/openfoodfacts/smooth-app/issues/3539)) ([1190474](https://github.com/openfoodfacts/smooth-app/commit/1190474c9b28a995047c12e2465de75c19d02019))

## [4.2.0](https://github.com/openfoodfacts/smooth-app/compare/v4.1.0...v4.2.0) (2023-01-05)


### 📖 Documentation

* figma link in README ([#3406](https://github.com/openfoodfacts/smooth-app/issues/3406)) ([100ef0c](https://github.com/openfoodfacts/smooth-app/commit/100ef0ce3225c4d9b3afe135c2df36e080f013ef))
* finish refactoring README ([#3407](https://github.com/openfoodfacts/smooth-app/issues/3407)) ([b4c391f](https://github.com/openfoodfacts/smooth-app/commit/b4c391fac407980385e1f33b335677b9f1bfc691))
* update iOS release and re-add code documentation ([#3384](https://github.com/openfoodfacts/smooth-app/issues/3384)) ([64ebf44](https://github.com/openfoodfacts/smooth-app/commit/64ebf44feef9861fc8fd19e235d3ea6ad838c0ea))


### 🤖 Automation

* add issues to packaging GitHub Project ([#3476](https://github.com/openfoodfacts/smooth-app/issues/3476)) ([83fee90](https://github.com/openfoodfacts/smooth-app/commit/83fee900a44eb2ae829d03bdbd0dd019178f7341))
* dependabot everywhere ([9ab9f0a](https://github.com/openfoodfacts/smooth-app/commit/9ab9f0a8baea4afca86a81cb3a8670cb1fe6f878))
* fix: release please ([#3421](https://github.com/openfoodfacts/smooth-app/issues/3421)) ([bc9eb99](https://github.com/openfoodfacts/smooth-app/commit/bc9eb9953cee456140ada5bd1f95669588726ed0))
* product scan carousel labeler fix ([#3432](https://github.com/openfoodfacts/smooth-app/issues/3432)) ([c5f69f4](https://github.com/openfoodfacts/smooth-app/commit/c5f69f41721cb274fcb8bd80db267c0b369668af))
* Show flavour in about this app and sentry ([#3429](https://github.com/openfoodfacts/smooth-app/issues/3429)) ([a35b7db](https://github.com/openfoodfacts/smooth-app/commit/a35b7db371a824cff573a792a1ebecda21b50b3b))
* Upgrade ruby + bundler ([#3485](https://github.com/openfoodfacts/smooth-app/issues/3485)) ([fb1ae97](https://github.com/openfoodfacts/smooth-app/commit/fb1ae97585a358c8add232ddc061ab4523cd9fa1))


### 👷 Refactoring

* integrating off-dart 1.30.1 ([#3471](https://github.com/openfoodfacts/smooth-app/issues/3471)) ([390f859](https://github.com/openfoodfacts/smooth-app/commit/390f859782d542a2c8d0ad4079731fcd643be5f5))
* upgrade to off-dart 2.0.0 ([#3495](https://github.com/openfoodfacts/smooth-app/issues/3495)) ([7e861f5](https://github.com/openfoodfacts/smooth-app/commit/7e861f569ebe91d5580b794566c25b81e0a0e513))


### 🚀 Features

* 3332 - refactored the new crop page UI and added a camera ([#3402](https://github.com/openfoodfacts/smooth-app/issues/3402)) ([d3aea55](https://github.com/openfoodfacts/smooth-app/commit/d3aea55ce281da32fde8e83cd2236e098ed7e64b))
* 3418 - 7 new KP action handled ([#3510](https://github.com/openfoodfacts/smooth-app/issues/3510)) ([6321df0](https://github.com/openfoodfacts/smooth-app/commit/6321df0ce92f1a5512f1988b81c6465e3be427f4))
* 3430 - new packagings edit page based on api v3 ([#3475](https://github.com/openfoodfacts/smooth-app/issues/3475)) ([09a982a](https://github.com/openfoodfacts/smooth-app/commit/09a982a1f17798577e96fbbb7ead8e1e79ea6a10))
* 3493 - structured packagings +quantity +weight and localized ([#3500](https://github.com/openfoodfacts/smooth-app/issues/3500)) ([9631da6](https://github.com/openfoodfacts/smooth-app/commit/9631da6426d0d5dbd2d9fc1893e6393e5c37dd31))
* 3505 - packagingsComplete toggle and packagings edit bug fixes ([#3513](https://github.com/openfoodfacts/smooth-app/issues/3513)) ([994078b](https://github.com/openfoodfacts/smooth-app/commit/994078bef15b79eccdea5854631321f858132bc9))
* 3507 - added mandatory icons and optional hints to packagings ([#3514](https://github.com/openfoodfacts/smooth-app/issues/3514)) ([3cf4534](https://github.com/openfoodfacts/smooth-app/commit/3cf45349605972bae9bcb5f026f3c7f765c3ffbf))
* 3507 - full-line text fields ([#3515](https://github.com/openfoodfacts/smooth-app/issues/3515)) ([01348a3](https://github.com/openfoodfacts/smooth-app/commit/01348a3cd59343c97fdb1871a97e5fafe8343396))
* Add all scanned products to list ([#3401](https://github.com/openfoodfacts/smooth-app/issues/3401)) ([1cce8cc](https://github.com/openfoodfacts/smooth-app/commit/1cce8cce073642e11451709a714d1b9aa274a74f))
* Added compare floating button ([#3497](https://github.com/openfoodfacts/smooth-app/issues/3497)) ([8ea6ff3](https://github.com/openfoodfacts/smooth-app/commit/8ea6ff347a57628bbe1f6bb0c2edb7471874ed02))
* improved app rating flow ([#3439](https://github.com/openfoodfacts/smooth-app/issues/3439)) ([9c9b93b](https://github.com/openfoodfacts/smooth-app/commit/9c9b93bfdb830b96d9a2ccceb1ee06ea5349b92d))
* web account deletion ([#3416](https://github.com/openfoodfacts/smooth-app/issues/3416)) ([61d9f39](https://github.com/openfoodfacts/smooth-app/commit/61d9f39ae0dc2bf8cf972d68ae025ecaf0019cc3))


### 🛠 Miscellaneous

* Add dev mode setting to add cards to the scanner ([#3400](https://github.com/openfoodfacts/smooth-app/issues/3400)) ([4a3b1a9](https://github.com/openfoodfacts/smooth-app/commit/4a3b1a90b4f50e0bf0b8bf34a9db331ccd5d843a))
* **deps:** bump actions/setup-java from 3.6.0 to 3.7.0 ([#3396](https://github.com/openfoodfacts/smooth-app/issues/3396)) ([89e0292](https://github.com/openfoodfacts/smooth-app/commit/89e029298e48ef98e6fc895db990976bf448f601))
* **deps:** bump crowdin/github-action from 1.5.1 to 1.5.2 ([#3437](https://github.com/openfoodfacts/smooth-app/issues/3437)) ([d0bbf63](https://github.com/openfoodfacts/smooth-app/commit/d0bbf6363fad4c90bb5631a1254f557ddc92810d))
* **deps:** bump toshimaru/auto-author-assign from 1.6.1 to 1.6.2 ([#3508](https://github.com/openfoodfacts/smooth-app/issues/3508)) ([bd3f7b8](https://github.com/openfoodfacts/smooth-app/commit/bd3f7b8ee50e29f8a223fa40d1ef6c1238ef6ac4))
* Dev mode cleanup ([#3452](https://github.com/openfoodfacts/smooth-app/issues/3452)) ([48745c8](https://github.com/openfoodfacts/smooth-app/commit/48745c8afda178a901c243eba57cce04aa191157))
* New Crowdin translations ([#3379](https://github.com/openfoodfacts/smooth-app/issues/3379)) ([80b7d33](https://github.com/openfoodfacts/smooth-app/commit/80b7d33e1fe7427a526cf11bcb39a5db484d5807))
* New Crowdin translations ([#3408](https://github.com/openfoodfacts/smooth-app/issues/3408)) ([282884a](https://github.com/openfoodfacts/smooth-app/commit/282884a6a6d1707c950ff4e1ee4210e4588620dc))
* New Crowdin translations ([#3425](https://github.com/openfoodfacts/smooth-app/issues/3425)) ([fbab382](https://github.com/openfoodfacts/smooth-app/commit/fbab382c5e1ac25453741b69419006a602a80d30))
* New Crowdin translations ([#3428](https://github.com/openfoodfacts/smooth-app/issues/3428)) ([3aace41](https://github.com/openfoodfacts/smooth-app/commit/3aace41a01b61bbe09632f2bb93e4b0c012bc78a))
* New Crowdin translations ([#3433](https://github.com/openfoodfacts/smooth-app/issues/3433)) ([69f902e](https://github.com/openfoodfacts/smooth-app/commit/69f902e3f15b63fd95abcb8100297f95030806bc))
* New Crowdin translations ([#3434](https://github.com/openfoodfacts/smooth-app/issues/3434)) ([623bdf6](https://github.com/openfoodfacts/smooth-app/commit/623bdf6d8fa74f4050e9da377ed41415b7ae7fd3))
* New Crowdin translations ([#3438](https://github.com/openfoodfacts/smooth-app/issues/3438)) ([a0b2e46](https://github.com/openfoodfacts/smooth-app/commit/a0b2e4626223ce2011aaa5af3821feb316857e0e))
* New Crowdin translations ([#3440](https://github.com/openfoodfacts/smooth-app/issues/3440)) ([d7b65ec](https://github.com/openfoodfacts/smooth-app/commit/d7b65ecf0f92d0193c4afaee13a51830129787ae))
* New Crowdin translations ([#3442](https://github.com/openfoodfacts/smooth-app/issues/3442)) ([7b79612](https://github.com/openfoodfacts/smooth-app/commit/7b796125997283151cd8082c9f24842aca6ab05d))
* New Crowdin translations ([#3443](https://github.com/openfoodfacts/smooth-app/issues/3443)) ([7b2930f](https://github.com/openfoodfacts/smooth-app/commit/7b2930fe321ae680ab728354962a2f341a2826cc))
* New Crowdin translations ([#3444](https://github.com/openfoodfacts/smooth-app/issues/3444)) ([c7034d7](https://github.com/openfoodfacts/smooth-app/commit/c7034d713908b842d47ffdbbd21778b5e516b106))
* New Crowdin translations ([#3463](https://github.com/openfoodfacts/smooth-app/issues/3463)) ([cdac439](https://github.com/openfoodfacts/smooth-app/commit/cdac439af4b64bfb6f5811295bc12b4d18aa5b17))
* New Crowdin translations ([#3463](https://github.com/openfoodfacts/smooth-app/issues/3463)) ([22dbc4c](https://github.com/openfoodfacts/smooth-app/commit/22dbc4c17bddc965f04dadb9ac128d529e4ec6d6))
* New Crowdin translations ([#3467](https://github.com/openfoodfacts/smooth-app/issues/3467)) ([aafd4a1](https://github.com/openfoodfacts/smooth-app/commit/aafd4a11cfd733e4bc42498117263efbacbc0c5f))
* New Crowdin translations ([#3468](https://github.com/openfoodfacts/smooth-app/issues/3468)) ([9631bf6](https://github.com/openfoodfacts/smooth-app/commit/9631bf6d3604047690ce4a796641cf650e00b644))
* New Crowdin translations ([#3472](https://github.com/openfoodfacts/smooth-app/issues/3472)) ([2ffe6f8](https://github.com/openfoodfacts/smooth-app/commit/2ffe6f8c31e6a004c565f6f7d3d76f929faa65b5))
* New Crowdin translations ([#3492](https://github.com/openfoodfacts/smooth-app/issues/3492)) ([36dfa32](https://github.com/openfoodfacts/smooth-app/commit/36dfa322b6b2bba955a3f4b693bbeb2dcb659109))
* New Crowdin translations ([#3501](https://github.com/openfoodfacts/smooth-app/issues/3501)) ([d6933ce](https://github.com/openfoodfacts/smooth-app/commit/d6933cec4c98cec18ad504831f6db699c7fd073c))
* New Crowdin translations ([#3518](https://github.com/openfoodfacts/smooth-app/issues/3518)) ([fb4980d](https://github.com/openfoodfacts/smooth-app/commit/fb4980dcca01c2e31ad342faa3a5d75acccd0864))
* New Crowdin translations to review and merge ([#3511](https://github.com/openfoodfacts/smooth-app/issues/3511)) ([d54c0e8](https://github.com/openfoodfacts/smooth-app/commit/d54c0e8326ec72c72b52927208f3b3b259cb8f81))
* Update assets ([#3382](https://github.com/openfoodfacts/smooth-app/issues/3382)) ([cf3ce7f](https://github.com/openfoodfacts/smooth-app/commit/cf3ce7fed17819b304b2f9e75ff6d42e4fd3ba04))


### 🐛 Bug Fixes

* 3387 - energy and energyKJ confusion fix ([#3399](https://github.com/openfoodfacts/smooth-app/issues/3399)) ([eb2a6aa](https://github.com/openfoodfacts/smooth-app/commit/eb2a6aa6da637ff42e6d22ee615c146c8657e7fa))
* 3393 [Image cropper] The AppBar title is weirdly centered ([#3405](https://github.com/openfoodfacts/smooth-app/issues/3405)) ([0c247f4](https://github.com/openfoodfacts/smooth-app/commit/0c247f452f8e2c6729f860c6d7bfa4fc1f4cce50))
* 3394 The cross to close product wrong alignment ([#3409](https://github.com/openfoodfacts/smooth-app/issues/3409)) ([98b5fab](https://github.com/openfoodfacts/smooth-app/commit/98b5fab8bc7c4f84d98ae4878fef7a08798423cd))
* 3417 The tagline blinks in the app language, then goes back to English ([#3426](https://github.com/openfoodfacts/smooth-app/issues/3426)) ([1301896](https://github.com/openfoodfacts/smooth-app/commit/1301896fbaad2157d7fd84419e96f4ddd8df5f17))
* 3490 - check the Status of picture uploads ([#3517](https://github.com/openfoodfacts/smooth-app/issues/3517)) ([01b4fbf](https://github.com/openfoodfacts/smooth-app/commit/01b4fbf25b18c6101f1f9c2208165be25b29e670))
* 3490 - now accepting not cropped new pictures ([#3524](https://github.com/openfoodfacts/smooth-app/issues/3524)) ([fac9afe](https://github.com/openfoodfacts/smooth-app/commit/fac9afe7154776c17c4bbb63eaffe4d583e56ed7))
* 3490 - verbose debug when cropping and saving a pic ([#3519](https://github.com/openfoodfacts/smooth-app/issues/3519)) ([bdca5d4](https://github.com/openfoodfacts/smooth-app/commit/bdca5d4cf45858d4b800c37d69f31e65569816bd))
* 3504 - different colors for dark/light in structured packagings page ([#3509](https://github.com/openfoodfacts/smooth-app/issues/3509)) ([aa20516](https://github.com/openfoodfacts/smooth-app/commit/aa205169787ddce3f1434c55f1e54ffe23df7a9e))
* 3516 - standardized the "do you want to save" dialog? ([#3520](https://github.com/openfoodfacts/smooth-app/issues/3520)) ([d61ca4b](https://github.com/openfoodfacts/smooth-app/commit/d61ca4b646acd461403f8701afa2d7711ae041be))
* Edit page not accessible on hebrew ([#3453](https://github.com/openfoodfacts/smooth-app/issues/3453)) ([5f824c6](https://github.com/openfoodfacts/smooth-app/commit/5f824c6127b2e288ca13cf833b980a55a23cc724))
* fix-release-please ([#3525](https://github.com/openfoodfacts/smooth-app/issues/3525)) ([4c806f0](https://github.com/openfoodfacts/smooth-app/commit/4c806f0fe408c5c0b08bf3d3d97cb67ea0518a59))
* fixing a few strings ([#3502](https://github.com/openfoodfacts/smooth-app/issues/3502)) ([c6a471d](https://github.com/openfoodfacts/smooth-app/commit/c6a471d3f9ac0b6e7be31eaccd88bb43a6777b59))
* French translations hotfix ([f528b31](https://github.com/openfoodfacts/smooth-app/commit/f528b3154092fa9f471bff4a924fe7e2462c7f87))
* java-360 after dependabot upgrade ([#3413](https://github.com/openfoodfacts/smooth-app/issues/3413)) ([7f0b0d3](https://github.com/openfoodfacts/smooth-app/commit/7f0b0d3d0eb9ce7b9351ab25a26be5f28da911bd))
* Language code usage ([#3450](https://github.com/openfoodfacts/smooth-app/issues/3450)) ([d6dc91d](https://github.com/openfoodfacts/smooth-app/commit/d6dc91d0b71f0e3da3d78143cb6f4fee9aa025c8))
* New product added to history ([#3446](https://github.com/openfoodfacts/smooth-app/issues/3446)) ([07d1f87](https://github.com/openfoodfacts/smooth-app/commit/07d1f87fd0ab3fc203a8da5adece7d63bc071544))
* Prevent edit of perfect product on onboarding ([#3489](https://github.com/openfoodfacts/smooth-app/issues/3489)) ([6d05366](https://github.com/openfoodfacts/smooth-app/commit/6d053667a0189b76a82a91cb8f3987694e5e1cb8))
* Provider used after beeing disposed in multi edit page ([#3454](https://github.com/openfoodfacts/smooth-app/issues/3454)) ([9989120](https://github.com/openfoodfacts/smooth-app/commit/9989120597591701d202dd89c72d87157fd19e92))
* Save userId insted of user email ([#3499](https://github.com/openfoodfacts/smooth-app/issues/3499)) ([b60ce32](https://github.com/openfoodfacts/smooth-app/commit/b60ce3253748e85a61a24aee141641cae8ffe1f6))
* wording fixes ([#3512](https://github.com/openfoodfacts/smooth-app/issues/3512)) ([9f00072](https://github.com/openfoodfacts/smooth-app/commit/9f000726f9e48d3a42775ab1c2680883fe13a802))

## [4.1.0](https://github.com/openfoodfacts/smooth-app/compare/v4.0.0...v4.1.0) (2022-11-26)


### 🤖 Automation

* Upload ml kit apk to github release ([#3330](https://github.com/openfoodfacts/smooth-app/issues/3330)) ([b0b52c5](https://github.com/openfoodfacts/smooth-app/commit/b0b52c5fdc210a761454cc1eee87c0d53578c210))


### 🐛 Bug Fixes

* [#3018](https://github.com/openfoodfacts/smooth-app/issues/3018) - minor step for background tasks ([#3302](https://github.com/openfoodfacts/smooth-app/issues/3302)) ([316272e](https://github.com/openfoodfacts/smooth-app/commit/316272e2f7431d97e4ca343bdac4ef03954b1b43))
* 2255 - safer setState call after async code ([#3345](https://github.com/openfoodfacts/smooth-app/issues/3345)) ([dd65222](https://github.com/openfoodfacts/smooth-app/commit/dd65222664f3306e2126bfd633ed0536d9552d48))
* 3018 - immediate local and server refresh for details (temporary) ([#3308](https://github.com/openfoodfacts/smooth-app/issues/3308)) ([4553468](https://github.com/openfoodfacts/smooth-app/commit/4553468989e1d365730bc23456795d34cff33f4c))
* 3018 - instant upload of images ([#3329](https://github.com/openfoodfacts/smooth-app/issues/3329)) ([fba2851](https://github.com/openfoodfacts/smooth-app/commit/fba2851809d1b295386f6aa16568b594e4dda0f6))
* 3018 - now there's only one place where we upload pictures from ([#3323](https://github.com/openfoodfacts/smooth-app/issues/3323)) ([3d944bb](https://github.com/openfoodfacts/smooth-app/commit/3d944bbed1fccd0254e148cd2ef22526372fd8b8))
* 3249 - refresh of product after each Robotoff answer ([#3336](https://github.com/openfoodfacts/smooth-app/issues/3336)) ([cead249](https://github.com/openfoodfacts/smooth-app/commit/cead249fd520bc6dc74d134afe4106c0b0aadf3d))
* 3291 Question "Continue" button doesn't work ([#3314](https://github.com/openfoodfacts/smooth-app/issues/3314)) ([8614a3f](https://github.com/openfoodfacts/smooth-app/commit/8614a3fed058333d5852496e7f770a9a51bdbbcf))
* account removal reason issue [#2585](https://github.com/openfoodfacts/smooth-app/issues/2585) ([#3258](https://github.com/openfoodfacts/smooth-app/issues/3258)) ([7e4822e](https://github.com/openfoodfacts/smooth-app/commit/7e4822e19101441c31042530e9a4a36d7fa9487d))
* fast scroll in back to top ([#3344](https://github.com/openfoodfacts/smooth-app/issues/3344)) ([f718ffc](https://github.com/openfoodfacts/smooth-app/commit/f718ffcdfa5020f3ece8cc6803191132ca4d76c9))
* rewording-account-deletion ([#3324](https://github.com/openfoodfacts/smooth-app/issues/3324)) ([8b7df79](https://github.com/openfoodfacts/smooth-app/commit/8b7df79dba53c3fc3c63fbd37f6e090f5e86366b))


### 🛠 Miscellaneous

* **deps:** bump actions/dependency-review-action from 2 to 3 ([#3313](https://github.com/openfoodfacts/smooth-app/issues/3313)) ([636c459](https://github.com/openfoodfacts/smooth-app/commit/636c459eead2f808e7eefc2e14dde5e65289a3b9))
* **deps:** bump crowdin/github-action from 1.5.0 to 1.5.1 ([#3327](https://github.com/openfoodfacts/smooth-app/issues/3327)) ([e4df98c](https://github.com/openfoodfacts/smooth-app/commit/e4df98c0d0d38617381dadce74c0e3e1f6c4435d))
* New Crowdin translations ([#3304](https://github.com/openfoodfacts/smooth-app/issues/3304)) ([97d43d2](https://github.com/openfoodfacts/smooth-app/commit/97d43d26c136c0c0fc2a8b84c1ccec6ddb5ded0f))
* New Crowdin translations ([#3315](https://github.com/openfoodfacts/smooth-app/issues/3315)) ([4dadf3f](https://github.com/openfoodfacts/smooth-app/commit/4dadf3f1b854afeda46412a8e13f6516a9d01001))
* New Crowdin translations ([#3320](https://github.com/openfoodfacts/smooth-app/issues/3320)) ([9a42ff9](https://github.com/openfoodfacts/smooth-app/commit/9a42ff9eb6abf03ef73a7b19d13d0246915f0603))
* New Crowdin translations ([#3335](https://github.com/openfoodfacts/smooth-app/issues/3335)) ([efe5cef](https://github.com/openfoodfacts/smooth-app/commit/efe5cef1bf9b6886229b9e26d85ca5ab23200e1e))
* New Crowdin translations ([#3343](https://github.com/openfoodfacts/smooth-app/issues/3343)) ([f5ce272](https://github.com/openfoodfacts/smooth-app/commit/f5ce272cab985afc00c33dbaf1abe7224a8b144b))
* Update assets ([#3342](https://github.com/openfoodfacts/smooth-app/issues/3342)) ([b13794e](https://github.com/openfoodfacts/smooth-app/commit/b13794efa1b33f5935add36b53577d494d151764))


### 🚀 Features

* 3263 - new BackgroundTaskManager that always works ([#3339](https://github.com/openfoodfacts/smooth-app/issues/3339)) ([5304614](https://github.com/openfoodfacts/smooth-app/commit/5304614c993514f5d11f2d7fe02e286574891e78))
* In app review ([#3333](https://github.com/openfoodfacts/smooth-app/issues/3333)) ([80fde53](https://github.com/openfoodfacts/smooth-app/commit/80fde5335b2652cc187c460c428377d76f21f4dd))

## [4.0.0](https://github.com/openfoodfacts/smooth-app/compare/v3.23.0...v4.0.0) (2022-11-10)


### ⚠ BREAKING CHANGES

* hunger games (#3102)

### 📖 Documentation

* Make the guide how to run the app more visible ([#3180](https://github.com/openfoodfacts/smooth-app/issues/3180)) ([1a891e0](https://github.com/openfoodfacts/smooth-app/commit/1a891e09aac6ebc0c486ff69a005cbde4a2ead0c))


### 🚀 Features

* [#3065](https://github.com/openfoodfacts/smooth-app/issues/3065) - using Robotoff question imageUrl if available ([#3178](https://github.com/openfoodfacts/smooth-app/issues/3178)) ([086ff45](https://github.com/openfoodfacts/smooth-app/commit/086ff45017e7fd7670b11c5a2fd6f179ee01d0b1))
* [#3237](https://github.com/openfoodfacts/smooth-app/issues/3237) - improved gallery/camera choice ([#3239](https://github.com/openfoodfacts/smooth-app/issues/3239)) ([cd288cd](https://github.com/openfoodfacts/smooth-app/commit/cd288cdf805b234919bc40eba442bfbd68ab88f1))
* adding contribution count ([#3267](https://github.com/openfoodfacts/smooth-app/issues/3267)) ([52f04ee](https://github.com/openfoodfacts/smooth-app/commit/52f04ee4af6145381f03fb9f6e8365b7d2a6cce4))
* Desktop support for dev (only tested on macOS) ([#3251](https://github.com/openfoodfacts/smooth-app/issues/3251)) ([32784c6](https://github.com/openfoodfacts/smooth-app/commit/32784c61855e0821536537134f1338d7e0dde07f))
* Downgrade to Flutter 3.0 ([#3244](https://github.com/openfoodfacts/smooth-app/issues/3244)) ([c52073d](https://github.com/openfoodfacts/smooth-app/commit/c52073d2c769056cde7c8df9ccc249cfaca61ddc))
* hunger games ([#3102](https://github.com/openfoodfacts/smooth-app/issues/3102)) ([b2885af](https://github.com/openfoodfacts/smooth-app/commit/b2885af8fd1fe57a896bd7da4994f889e114577b))
* MLKit as a dependency ([#3193](https://github.com/openfoodfacts/smooth-app/issues/3193)) ([c27767d](https://github.com/openfoodfacts/smooth-app/commit/c27767df4e06a3216d591c22f7d28e613fe0902d))
* Zxing implementation ([#3252](https://github.com/openfoodfacts/smooth-app/issues/3252)) ([c72242a](https://github.com/openfoodfacts/smooth-app/commit/c72242aa6efbae2e41698ffb255ab8b0c37e8eea))


### 🤖 Automation

* add a list of current tests ([#3223](https://github.com/openfoodfacts/smooth-app/issues/3223)) ([26293c3](https://github.com/openfoodfacts/smooth-app/commit/26293c3505f9607942345a45e25a613c770630e2))
* add support to label goldens ([#3235](https://github.com/openfoodfacts/smooth-app/issues/3235)) ([44350b5](https://github.com/openfoodfacts/smooth-app/commit/44350b57b2ca2f82eacf79bc0613667a3000e1fb))
* allow to run script ([#3222](https://github.com/openfoodfacts/smooth-app/issues/3222)) ([db245c1](https://github.com/openfoodfacts/smooth-app/commit/db245c12501fc5a4307efb53c2c63abad38cdce1))
* fix hunger games labelling ([fe2d8db](https://github.com/openfoodfacts/smooth-app/commit/fe2d8dbbaade380b723a2ab8e86836652213caba))
* fix: iOS release itc_provider ([#3284](https://github.com/openfoodfacts/smooth-app/issues/3284)) ([051de66](https://github.com/openfoodfacts/smooth-app/commit/051de66d1245b3cb7e13a8199c671f7f81b40001))
* fix: unexpected token ([#3165](https://github.com/openfoodfacts/smooth-app/issues/3165)) ([adb7716](https://github.com/openfoodfacts/smooth-app/commit/adb771650b977e6841d6a42f26eba4d4a8d6f6f8))
* Github upload fix ([#3154](https://github.com/openfoodfacts/smooth-app/issues/3154)) ([0d106bd](https://github.com/openfoodfacts/smooth-app/commit/0d106bd6ffe119de4346ba53f48bb6114afd6c22))
* labeler for flavors and zxing ([#3253](https://github.com/openfoodfacts/smooth-app/issues/3253)) ([f739340](https://github.com/openfoodfacts/smooth-app/commit/f73934051f33110d5aaf31a355bedb5b048718d7))
* test labeling for forks ([fb9dc87](https://github.com/openfoodfacts/smooth-app/commit/fb9dc8783ed2ab6e24ceac3786ee01d11eac4a73))
* update the PR template with semantic prefixes ([#3183](https://github.com/openfoodfacts/smooth-app/issues/3183)) ([d5338cf](https://github.com/openfoodfacts/smooth-app/commit/d5338cf179fd9ae0fe01e04b9579ab1ffeb21d12))


### 🛠 Miscellaneous

* add golden tests and files for dialogs ([#3190](https://github.com/openfoodfacts/smooth-app/issues/3190)) ([bc8a6fe](https://github.com/openfoodfacts/smooth-app/commit/bc8a6fe7d944e4ef1599abc7e9a464f64b41aa75))
* add launch.json for vscode ([#3166](https://github.com/openfoodfacts/smooth-app/issues/3166)) ([3b2a12f](https://github.com/openfoodfacts/smooth-app/commit/3b2a12f98df170e2eac9215a8e6f129978343c95))
* Bump flutter_isolate dependency ([#3215](https://github.com/openfoodfacts/smooth-app/issues/3215)) possible scanner fix ([d09fbf7](https://github.com/openfoodfacts/smooth-app/commit/d09fbf7a342c20247752fa6abae66627bd26b1d0))
* **deps:** bump actions/setup-java from 3.5.1 to 3.6.0 ([#3175](https://github.com/openfoodfacts/smooth-app/issues/3175)) ([192a6d9](https://github.com/openfoodfacts/smooth-app/commit/192a6d981cdf1c870cd1252c059b10473e767340))
* **deps:** bump crowdin/github-action from 1.4.14 to 1.4.15 ([#3169](https://github.com/openfoodfacts/smooth-app/issues/3169)) ([b2aacd7](https://github.com/openfoodfacts/smooth-app/commit/b2aacd77b6139ade72a50fc526d10927a0c02cd7))
* **deps:** bump crowdin/github-action from 1.4.15 to 1.4.16 ([#3184](https://github.com/openfoodfacts/smooth-app/issues/3184)) ([1a8f53a](https://github.com/openfoodfacts/smooth-app/commit/1a8f53a07d847227cf950411934f26cf4ae0dec5))
* **deps:** bump crowdin/github-action from 1.4.16 to 1.5.0 ([#3256](https://github.com/openfoodfacts/smooth-app/issues/3256)) ([dadac4c](https://github.com/openfoodfacts/smooth-app/commit/dadac4cbb1eaf7fceb385790a057353091ad70ca))
* Matomo refactor ([#3273](https://github.com/openfoodfacts/smooth-app/issues/3273)) ([1996907](https://github.com/openfoodfacts/smooth-app/commit/1996907f7497df9a3105a9d238a66c8e4f4b80f9))
* migrate to OFF SDK 1.26.0 ([#3153](https://github.com/openfoodfacts/smooth-app/issues/3153)) ([cd8aaaf](https://github.com/openfoodfacts/smooth-app/commit/cd8aaafc82c8bce35a4fe79052d4be934282b9a6))
* New Crowdin translations ([#3147](https://github.com/openfoodfacts/smooth-app/issues/3147)) ([670da44](https://github.com/openfoodfacts/smooth-app/commit/670da44a7df8e093318e4c378a703d1959fae4d1))
* New Crowdin translations ([#3167](https://github.com/openfoodfacts/smooth-app/issues/3167)) ([24514c3](https://github.com/openfoodfacts/smooth-app/commit/24514c38fb73cd9ab6de800617abdf1f04be0d6a))
* New Crowdin translations ([#3173](https://github.com/openfoodfacts/smooth-app/issues/3173)) ([5f41dc3](https://github.com/openfoodfacts/smooth-app/commit/5f41dc39ca173aa0250c8079df0da7156dfca4b4))
* New Crowdin translations ([#3186](https://github.com/openfoodfacts/smooth-app/issues/3186)) ([d3383e5](https://github.com/openfoodfacts/smooth-app/commit/d3383e544888e764e35e2b7e164c6c7527b1081a))
* New Crowdin translations ([#3198](https://github.com/openfoodfacts/smooth-app/issues/3198)) ([b205606](https://github.com/openfoodfacts/smooth-app/commit/b2056066a1be3702fa4b281bb24c5b4b0a6b4c1e))
* New Crowdin translations ([#3213](https://github.com/openfoodfacts/smooth-app/issues/3213)) ([a3066e7](https://github.com/openfoodfacts/smooth-app/commit/a3066e7057a305be6fa46c4baae7c13f30e3ebd4))
* New Crowdin translations ([#3218](https://github.com/openfoodfacts/smooth-app/issues/3218)) ([510104d](https://github.com/openfoodfacts/smooth-app/commit/510104db7692a46b684594e97ec05a7e44e94078))
* New Crowdin translations ([#3228](https://github.com/openfoodfacts/smooth-app/issues/3228)) ([d7fa70d](https://github.com/openfoodfacts/smooth-app/commit/d7fa70dbea2ef970c0f08201665c8f00d05b395a))
* New Crowdin translations ([#3242](https://github.com/openfoodfacts/smooth-app/issues/3242)) ([4b945eb](https://github.com/openfoodfacts/smooth-app/commit/4b945ebd523b8dceac657581909304612f73e91c))
* New Crowdin translations ([#3254](https://github.com/openfoodfacts/smooth-app/issues/3254)) ([134ab47](https://github.com/openfoodfacts/smooth-app/commit/134ab474acb3b7edf81a501a5f1267bf1204ab23))
* New Crowdin translations ([#3257](https://github.com/openfoodfacts/smooth-app/issues/3257)) ([86be3ac](https://github.com/openfoodfacts/smooth-app/commit/86be3ac6c609d203ca684bc73472f956c7de0c8b))
* New Crowdin translations ([#3269](https://github.com/openfoodfacts/smooth-app/issues/3269)) ([b29c075](https://github.com/openfoodfacts/smooth-app/commit/b29c075e3368d4afe306c3d64b38f5e5e1c95c79))
* New Crowdin translations ([#3293](https://github.com/openfoodfacts/smooth-app/issues/3293)) ([f433d4e](https://github.com/openfoodfacts/smooth-app/commit/f433d4ee1f2b4ed716a4a28dc71b5ff4251cd2a3))
* Update assets ([#3185](https://github.com/openfoodfacts/smooth-app/issues/3185)) ([f8444b7](https://github.com/openfoodfacts/smooth-app/commit/f8444b78a8955dd05806b6ed4be413106744f34f))
* user authentication page testing ([#3233](https://github.com/openfoodfacts/smooth-app/issues/3233)) ([45aa97f](https://github.com/openfoodfacts/smooth-app/commit/45aa97f671a2f5a73c0e7ab7df97a395926ef91c))


### 🐛 Bug Fixes

* "Terms of use" not clickable on the Sign up form ([#3205](https://github.com/openfoodfacts/smooth-app/issues/3205)) ([78740d3](https://github.com/openfoodfacts/smooth-app/commit/78740d3e5d067cd2115295afefe4746dd8cef61a))
* [#3018](https://github.com/openfoodfacts/smooth-app/issues/3018) - after review ([#3232](https://github.com/openfoodfacts/smooth-app/issues/3232)) ([14cfed4](https://github.com/openfoodfacts/smooth-app/commit/14cfed46ecb05fe111cd766f824ebf948c7373a6))
* [#3018](https://github.com/openfoodfacts/smooth-app/issues/3018) - new "interesting barcode" and "latest download" features ([#3227](https://github.com/openfoodfacts/smooth-app/issues/3227)) ([24c1579](https://github.com/openfoodfacts/smooth-app/commit/24c15790386a71172df7adf8405f1274af8ee7b5))
* [#3018](https://github.com/openfoodfacts/smooth-app/issues/3018) - UpToDateProductProvider now field of LocalDatabase ([#3220](https://github.com/openfoodfacts/smooth-app/issues/3220)) ([222eb6e](https://github.com/openfoodfacts/smooth-app/commit/222eb6e69e734531f1aaf8e353442b7ae777679b))
* [#3046](https://github.com/openfoodfacts/smooth-app/issues/3046) - refactored NutritionPage around Nutrient ([#3194](https://github.com/openfoodfacts/smooth-app/issues/3194)) ([c608459](https://github.com/openfoodfacts/smooth-app/commit/c608459c7daed865e540c694044f18a83323ed72))
* [#3188](https://github.com/openfoodfacts/smooth-app/issues/3188) - colored button for "ignore" in hunger games ([#3195](https://github.com/openfoodfacts/smooth-app/issues/3195)) ([bf30f3e](https://github.com/openfoodfacts/smooth-app/commit/bf30f3e422b9b374f29b7e8289b51445f76247d4))
* [#3238](https://github.com/openfoodfacts/smooth-app/issues/3238) - removed "other" pictures in gallery (keep just the main 4) ([#3241](https://github.com/openfoodfacts/smooth-app/issues/3241)) ([f65c169](https://github.com/openfoodfacts/smooth-app/commit/f65c169c1a1221bd5812cb6d6cd12d135363ef6d))
* [#3260](https://github.com/openfoodfacts/smooth-app/issues/3260) ([#3261](https://github.com/openfoodfacts/smooth-app/issues/3261)) ([c80f0c2](https://github.com/openfoodfacts/smooth-app/commit/c80f0c20cb2198c7b11ab63397442fb7bd2cc4e0))
* [#3266](https://github.com/openfoodfacts/smooth-app/issues/3266) - centered world map ([#3268](https://github.com/openfoodfacts/smooth-app/issues/3268)) ([12a47b7](https://github.com/openfoodfacts/smooth-app/commit/12a47b74ff44223caff4382c78e7653666d2f797))
* add ITMS fix ([df5c18f](https://github.com/openfoodfacts/smooth-app/commit/df5c18f326244b08ef610c84011e9a337c18476a))
* added auto complete text field for origins  [#3209](https://github.com/openfoodfacts/smooth-app/issues/3209) ([#3230](https://github.com/openfoodfacts/smooth-app/issues/3230)) ([a3608be](https://github.com/openfoodfacts/smooth-app/commit/a3608bef9fc1953eb3ee19685fa3b2a14efd45b0))
* appbar now differentiable issue [#2635](https://github.com/openfoodfacts/smooth-app/issues/2635) ([#3172](https://github.com/openfoodfacts/smooth-app/issues/3172)) ([76cf380](https://github.com/openfoodfacts/smooth-app/commit/76cf380bf11eb270bb7efde8d896dd47bf4c64f0))
* backbutton now visible ([#3170](https://github.com/openfoodfacts/smooth-app/issues/3170)) ([d43c02b](https://github.com/openfoodfacts/smooth-app/commit/d43c02bb9820aad350b38dc9ccdb87295b4646da))
* bottom overflow rendering issue ([#3221](https://github.com/openfoodfacts/smooth-app/issues/3221)) ([e06fdf1](https://github.com/openfoodfacts/smooth-app/commit/e06fdf1214a229952bf01a1d270427f878003bd2))
* bottom padding on login & signup ([#3206](https://github.com/openfoodfacts/smooth-app/issues/3206)) ([e230641](https://github.com/openfoodfacts/smooth-app/commit/e230641f94b46d7216ebcafe7a64e0f511004fbd))
* Darkmode back button ([#3264](https://github.com/openfoodfacts/smooth-app/issues/3264)) ([b807c20](https://github.com/openfoodfacts/smooth-app/commit/b807c20b28c0a1d6590e69129afb664aa1a30853))
* duplicate entries in search query ([#3289](https://github.com/openfoodfacts/smooth-app/issues/3289)) ([768a04a](https://github.com/openfoodfacts/smooth-app/commit/768a04a8ac5e7b206146da3db17dd216bbc025d8))
* empty product addition ([#3265](https://github.com/openfoodfacts/smooth-app/issues/3265)) ([bf27a72](https://github.com/openfoodfacts/smooth-app/commit/bf27a72567e2d1e23f8a07a50a508459ef9f76b3))
* Ensure the auto-suggestion popup is never below the keyboard ([#3282](https://github.com/openfoodfacts/smooth-app/issues/3282)) ([10c3247](https://github.com/openfoodfacts/smooth-app/commit/10c3247a751b8bf724c42da02444715e0feb274b))
* Finish button replaced with FAB ([#3219](https://github.com/openfoodfacts/smooth-app/issues/3219)) ([796257f](https://github.com/openfoodfacts/smooth-app/commit/796257f4779a948df7287693b45c56bdd7fc2e4a))
* Handle the case where the camera controller is disposed, while calling resumePreview() ([#3200](https://github.com/openfoodfacts/smooth-app/issues/3200)) ([3087460](https://github.com/openfoodfacts/smooth-app/commit/3087460d84ab4aa9da041d939902f244bb4eb364))
* Improve weird wordings ([#3277](https://github.com/openfoodfacts/smooth-app/issues/3277)) ([3119fb2](https://github.com/openfoodfacts/smooth-app/commit/3119fb23325f218ab42bf46a5133516d42399253))
* iOS camera permission not working ([#3191](https://github.com/openfoodfacts/smooth-app/issues/3191)) ([6c5be7e](https://github.com/openfoodfacts/smooth-app/commit/6c5be7e416a15e29cc2426d669286e0cae722691))
* Non clickable tag line ([#3300](https://github.com/openfoodfacts/smooth-app/issues/3300)) ([6200325](https://github.com/openfoodfacts/smooth-app/commit/6200325eceeccd8ec7bb7afcea1ab702c6d917eb))
* pull to refresh in product query page ([#3276](https://github.com/openfoodfacts/smooth-app/issues/3276)) ([f12a470](https://github.com/openfoodfacts/smooth-app/commit/f12a470c91c1df4cf68bef4290612e476f8d5cf0))
* secondary button now differentiable issue [#2988](https://github.com/openfoodfacts/smooth-app/issues/2988) ([#3171](https://github.com/openfoodfacts/smooth-app/issues/3171)) ([cfb5137](https://github.com/openfoodfacts/smooth-app/commit/cfb5137cf9519e1cdeadd8d19af43c634c94cd87))
* SignUp Issue ([#3288](https://github.com/openfoodfacts/smooth-app/issues/3288)) ([115c791](https://github.com/openfoodfacts/smooth-app/commit/115c79141062405d687d3bb9a4902ec86b0d390f))
* Signup: the password confirmation should show a submit button on the keyboard ([#3201](https://github.com/openfoodfacts/smooth-app/issues/3201)) ([1693e40](https://github.com/openfoodfacts/smooth-app/commit/1693e409063422055cf3da37b3ac01ffcc7f7fa5))
* unable to load 'sample_product_data.json' ([#3199](https://github.com/openfoodfacts/smooth-app/issues/3199)) ([451f9b1](https://github.com/openfoodfacts/smooth-app/commit/451f9b1bf362742c492745b1e755c82e6a8c49fa))

## [3.23.0](https://github.com/openfoodfacts/smooth-app/compare/v3.22.0...v3.23.0) (2022-10-14)


### 🚀 Features

* Improvement for adding a product to lists ([#3126](https://github.com/openfoodfacts/smooth-app/issues/3126)) ([1700322](https://github.com/openfoodfacts/smooth-app/commit/1700322bba446272b7e1b3f96a5f553e24499468))
* Nutrition page improvements ([#3121](https://github.com/openfoodfacts/smooth-app/issues/3121)) ([33d5b3c](https://github.com/openfoodfacts/smooth-app/commit/33d5b3c646cb2488018ead72a4d3b930257402f4))
* Product edition - animation for the AppBar title ([#3120](https://github.com/openfoodfacts/smooth-app/issues/3120)) ([6058346](https://github.com/openfoodfacts/smooth-app/commit/60583463fe354aff02db070fbcc99e7a8d6cf2b0))


### 🐛 Bug Fixes

* building for realz ([3fa0c1e](https://github.com/openfoodfacts/smooth-app/commit/3fa0c1ebb357df07835ba8452298a67bae102e65))
* Change iOS bundle id ([#3148](https://github.com/openfoodfacts/smooth-app/issues/3148)) ([72599fb](https://github.com/openfoodfacts/smooth-app/commit/72599fbaa2648a3e7c9a5b2d5ea0468233c65f39))
* Fix folders in GitHub Actions ([#3144](https://github.com/openfoodfacts/smooth-app/issues/3144)) ([c149915](https://github.com/openfoodfacts/smooth-app/commit/c14991556140fbba3501300c1fa20ba50f3aced8))
* Fix postsubmit action ([#3141](https://github.com/openfoodfacts/smooth-app/issues/3141)) ([50163e4](https://github.com/openfoodfacts/smooth-app/commit/50163e47085fd301de00bebe617718027738e5ad))
* Migration to Flutter 3.3.x ([#3151](https://github.com/openfoodfacts/smooth-app/issues/3151)) ([2929176](https://github.com/openfoodfacts/smooth-app/commit/2929176c33ebf0081ff1a67090ca0f748d3682cc))


### 🤖 Automation

* Update assets ([#3146](https://github.com/openfoodfacts/smooth-app/issues/3146)) ([95f3660](https://github.com/openfoodfacts/smooth-app/commit/95f36606f724b16b934601de7f51a6f39e7e9824))


### 🛠 Miscellaneous

* **deps:** bump maierj/fastlane-action from 2.2.1 to 2.3.0 ([#3145](https://github.com/openfoodfacts/smooth-app/issues/3145)) ([3dd9d2f](https://github.com/openfoodfacts/smooth-app/commit/3dd9d2f791db2f000f45fd3beac32f6a03e32f20))
* **deps:** bump path from 1.8.0 to 1.8.2 in /packages/smooth_app ([#3152](https://github.com/openfoodfacts/smooth-app/issues/3152)) ([be5725f](https://github.com/openfoodfacts/smooth-app/commit/be5725f5e12d66675ebb93ba081092c14b33ceb7))

## [3.22.0](https://github.com/openfoodfacts/smooth-app/compare/v3.21.0...v3.22.0) (2022-10-13)


### 🐛 Bug Fixes

* Pull to refresh exception ([#3124](https://github.com/openfoodfacts/smooth-app/issues/3124)) ([012a67f](https://github.com/openfoodfacts/smooth-app/commit/012a67f9239310570c8d5312daf4fdfe160a912d))
* Template card size ([#3113](https://github.com/openfoodfacts/smooth-app/issues/3113)) ([3ccf20d](https://github.com/openfoodfacts/smooth-app/commit/3ccf20db0d50a2d9732724b3c7966788152e13f6))


### 🚀 Features

* Products list improvements ([#3122](https://github.com/openfoodfacts/smooth-app/issues/3122)) ([dca2f30](https://github.com/openfoodfacts/smooth-app/commit/dca2f3090a3b3bed014e00fbfd485a08c4dcc3bd))


### 🛠 Miscellaneous

* **deps:** bump amannn/action-semantic-pull-request from 4 to 5 ([#3127](https://github.com/openfoodfacts/smooth-app/issues/3127)) ([61a649e](https://github.com/openfoodfacts/smooth-app/commit/61a649e7981fc057529f7a0088090d01935e3555))
* New Crowdin translations ([#3117](https://github.com/openfoodfacts/smooth-app/issues/3117)) ([8a61468](https://github.com/openfoodfacts/smooth-app/commit/8a61468b9a6bab040cd839b105700dba44f8b17c))
* New Crowdin translations ([#3128](https://github.com/openfoodfacts/smooth-app/issues/3128)) ([4244426](https://github.com/openfoodfacts/smooth-app/commit/4244426d5a2b24ee8e6393b80f6eac28c6b4fde6))
* New Crowdin translations ([#3134](https://github.com/openfoodfacts/smooth-app/issues/3134)) ([d49c2bc](https://github.com/openfoodfacts/smooth-app/commit/d49c2bc203c09024d1983a8092cb7fedca4e726a))


### 🤖 Automation

* fix: dont release on forks ([#3138](https://github.com/openfoodfacts/smooth-app/issues/3138)) ([7411da5](https://github.com/openfoodfacts/smooth-app/commit/7411da5a3876ef5d095972b109e7a4ca512a00dc))
* fix: GitHub actions input env ([#3140](https://github.com/openfoodfacts/smooth-app/issues/3140)) ([7a3eb41](https://github.com/openfoodfacts/smooth-app/commit/7a3eb41b27d74bf740f2ca0bda4be8e80ecf620b))


### 👷 Refactoring

* Make smooth_app a module (also called step 1) ([#3101](https://github.com/openfoodfacts/smooth-app/issues/3101)) ([e3564e5](https://github.com/openfoodfacts/smooth-app/commit/e3564e53a40d2a052dedca98c1b4a984f3bc0550))
* ProductImageData to contain all image links ([#3088](https://github.com/openfoodfacts/smooth-app/issues/3088)) ([41bbf32](https://github.com/openfoodfacts/smooth-app/commit/41bbf32c6679779ce4644f58b9cf7e3277ba478c))

## [3.21.0](https://github.com/openfoodfacts/smooth-app/compare/v3.20.0...v3.21.0) (2022-10-05)


### 🚀 Features

* Add checkmarks on 'add new product' screen ([#3080](https://github.com/openfoodfacts/smooth-app/issues/3080)) ([8b08a85](https://github.com/openfoodfacts/smooth-app/commit/8b08a857c335e52b700f81a9a0e61cd085887191))
* Remove 'empty list' from product query page ([#3081](https://github.com/openfoodfacts/smooth-app/issues/3081)) ([dde3f44](https://github.com/openfoodfacts/smooth-app/commit/dde3f44a2dff671f800c2ee79a059cee2415e000))


### 🤖 Automation

* Auto perfect product update ([#3050](https://github.com/openfoodfacts/smooth-app/issues/3050)) ([a122473](https://github.com/openfoodfacts/smooth-app/commit/a12247354edfe2fb01a56ba15709b9b8a000f9b3))
* Create internal release on every commit ([#2983](https://github.com/openfoodfacts/smooth-app/issues/2983)) ([1a0776a](https://github.com/openfoodfacts/smooth-app/commit/1a0776a2a529dc497f4c1abbb0ffb4f078ce5f97))
* fix: Internal release not working ([#3071](https://github.com/openfoodfacts/smooth-app/issues/3071)) ([b9d5843](https://github.com/openfoodfacts/smooth-app/commit/b9d5843baa903fba418ee9fa8057b4ced261f8c1))
* fix: removed values from traceName ([#3092](https://github.com/openfoodfacts/smooth-app/issues/3092)) ([5bb3ab0](https://github.com/openfoodfacts/smooth-app/commit/5bb3ab03ff88a32c63a44e9dc160782454ae6e1c))
* icons for release please ([#3062](https://github.com/openfoodfacts/smooth-app/issues/3062)) ([ebb6b33](https://github.com/openfoodfacts/smooth-app/commit/ebb6b3359651c360a815c8fce2dc361b05afc9af))
* Make the tagging future-proof ([#3087](https://github.com/openfoodfacts/smooth-app/issues/3087)) ([45a7f32](https://github.com/openfoodfacts/smooth-app/commit/45a7f32887770f36da38d760b188161a098477d8))
* try fixing internal release ([70afce7](https://github.com/openfoodfacts/smooth-app/commit/70afce7c6de95e82fb3ffd12f6e8fbb34be3a0f4))


### 🛠 Miscellaneous

* **deps:** bump actions/checkout from 2 to 3 ([#3078](https://github.com/openfoodfacts/smooth-app/issues/3078)) ([e96e7e4](https://github.com/openfoodfacts/smooth-app/commit/e96e7e4f2612604baa11b08b1ba328f4369948f7))
* **deps:** bump actions/setup-java from 3.5.0 to 3.5.1 ([#3072](https://github.com/openfoodfacts/smooth-app/issues/3072)) ([76da083](https://github.com/openfoodfacts/smooth-app/commit/76da083d314e32feed1f255827a7b6db9ffc7fa4))
* **deps:** bump crowdin/github-action from 1.4.13 to 1.4.14 ([#3061](https://github.com/openfoodfacts/smooth-app/issues/3061)) ([e427d9d](https://github.com/openfoodfacts/smooth-app/commit/e427d9d9d4f78d590ae7131b6d3dfb4f01190a52))
* **deps:** bump fastlane in /packages/smooth_app/android ([#3055](https://github.com/openfoodfacts/smooth-app/issues/3055)) ([708badb](https://github.com/openfoodfacts/smooth-app/commit/708badb004eddd58f50e4dfcfa7875081dc86566))
* **deps:** bump fastlane in /packages/smooth_app/ios ([#3056](https://github.com/openfoodfacts/smooth-app/issues/3056)) ([27f05e3](https://github.com/openfoodfacts/smooth-app/commit/27f05e33f5a405dadb99423efb51dda2bf66d46e))
* New Crowdin translations ([#3036](https://github.com/openfoodfacts/smooth-app/issues/3036)) ([2e55736](https://github.com/openfoodfacts/smooth-app/commit/2e55736c8eb4a310b42c473b833fd281e2d4c33d))
* New Crowdin translations ([#3067](https://github.com/openfoodfacts/smooth-app/issues/3067)) ([6baef2b](https://github.com/openfoodfacts/smooth-app/commit/6baef2bdc2014231e57094d23f461e54c9c3c95e))
* New Crowdin translations ([#3073](https://github.com/openfoodfacts/smooth-app/issues/3073)) ([a02243e](https://github.com/openfoodfacts/smooth-app/commit/a02243e457c21dc40132d3769267f57906589e79))
* New Crowdin translations ([#3079](https://github.com/openfoodfacts/smooth-app/issues/3079)) ([3974b75](https://github.com/openfoodfacts/smooth-app/commit/3974b750a7df1d8bf176007728e605000efd3671))
* New Crowdin translations ([#3090](https://github.com/openfoodfacts/smooth-app/issues/3090)) ([65d4122](https://github.com/openfoodfacts/smooth-app/commit/65d41220a1c5bc06a827317115c2f4066faf6a3d))
* New Crowdin translations ([#3095](https://github.com/openfoodfacts/smooth-app/issues/3095)) ([aa753ca](https://github.com/openfoodfacts/smooth-app/commit/aa753ca13c369ec98a8d41de967e87a62e41098e))
* Update assets ([#3057](https://github.com/openfoodfacts/smooth-app/issues/3057)) ([a3d9e0b](https://github.com/openfoodfacts/smooth-app/commit/a3d9e0b7241479a2f73de151db32fb3a58c22c86))


### 🐛 Bug Fixes

* [#1239](https://github.com/openfoodfacts/smooth-app/issues/1239) Create a test for registration and login ([#3069](https://github.com/openfoodfacts/smooth-app/issues/3069)) ([6644d59](https://github.com/openfoodfacts/smooth-app/commit/6644d59185a0a2ac8acf0c5f368386669eac79ae))
* Add a nudge in home for people still using org.openfoodfact.app fixes [#2979](https://github.com/openfoodfacts/smooth-app/issues/2979) ([#3030](https://github.com/openfoodfacts/smooth-app/issues/3030)) ([74cb804](https://github.com/openfoodfacts/smooth-app/commit/74cb8047fd68c7c71f22bdad1981fc116899fc00))
* Better product_query_page (Search) ([#3093](https://github.com/openfoodfacts/smooth-app/issues/3093)) ([bbf7ffc](https://github.com/openfoodfacts/smooth-app/commit/bbf7ffc04f74e48d78675e2f8404c5289b825338))
* Check if user credential still holds ([#3077](https://github.com/openfoodfacts/smooth-app/issues/3077)) ([0400c18](https://github.com/openfoodfacts/smooth-app/commit/0400c188743e898e25d163e536f6f87dbbdd62ad))
* harmonize search modals ([#3085](https://github.com/openfoodfacts/smooth-app/issues/3085)) ([f277e3e](https://github.com/openfoodfacts/smooth-app/commit/f277e3e855bb4d2c02d8f62a2bc92dafe32ac49a))
* Sentry stopping build ([#3070](https://github.com/openfoodfacts/smooth-app/issues/3070)) ([602b659](https://github.com/openfoodfacts/smooth-app/commit/602b659f86bcc78fe7281423774d000b9b2a0325))
* Tagline always showing deprecated warning ([#3091](https://github.com/openfoodfacts/smooth-app/issues/3091)) ([b8e1f82](https://github.com/openfoodfacts/smooth-app/commit/b8e1f8260a66e7a26a18798a8cfc27c8d80f4259))

## [3.20.0](https://github.com/openfoodfacts/smooth-app/compare/v3.19.0...v3.20.0) (2022-09-20)


### Features

* add paginated top issue parser ([#3041](https://github.com/openfoodfacts/smooth-app/issues/3041)) ([455b304](https://github.com/openfoodfacts/smooth-app/commit/455b3048302da4f29fb0f45e9e483034048f749e))


### Bug Fixes

* [#3038](https://github.com/openfoodfacts/smooth-app/issues/3038) - applied (colored) style for CupertinoPicker ([#3039](https://github.com/openfoodfacts/smooth-app/issues/3039)) ([a47041f](https://github.com/openfoodfacts/smooth-app/commit/a47041f5513b8223af5af4a82ad8ad7ff5447832))
* typo in app_fr.arb ([1865609](https://github.com/openfoodfacts/smooth-app/commit/1865609759f9b51b3f5261db7b72b40c4756f312))
* Upgrade matomo version (+ needed other deps) ([#3034](https://github.com/openfoodfacts/smooth-app/issues/3034)) ([359b362](https://github.com/openfoodfacts/smooth-app/commit/359b3626121db5b3fa8341c43ad8aa5200c159b0))


### Miscellaneous

* New Crowdin translations to review and merge ([#3033](https://github.com/openfoodfacts/smooth-app/issues/3033)) ([420d77b](https://github.com/openfoodfacts/smooth-app/commit/420d77bfcb11b44bf959089bc6aab3792080526b))


### Automation

* update PR labeler ([#2794](https://github.com/openfoodfacts/smooth-app/issues/2794)) ([a6cf19d](https://github.com/openfoodfacts/smooth-app/commit/a6cf19dd01435fd4cedd6cb552555e30ac2e99e8))


### Documentation

* mark portion calculator as done ([d24d991](https://github.com/openfoodfacts/smooth-app/commit/d24d991fdcc80e226ab014a611b0713de6e3149b))

## [3.19.0](https://github.com/openfoodfacts/smooth-app/compare/v3.18.0...v3.19.0) (2022-09-17)


### Features

* [#2354](https://github.com/openfoodfacts/smooth-app/issues/2354) - "portion calculator" added to detailed nutrient page ([#3027](https://github.com/openfoodfacts/smooth-app/issues/3027)) ([3b223ff](https://github.com/openfoodfacts/smooth-app/commit/3b223ffade8bb89737374e35267bc2cfd841060b))

## [3.18.0](https://github.com/openfoodfacts/smooth-app/compare/v3.17.0...v3.18.0) (2022-09-17)


### Features

* [#3013](https://github.com/openfoodfacts/smooth-app/issues/3013) - asset file utz-certified.90x90.svg ([#3015](https://github.com/openfoodfacts/smooth-app/issues/3015)) ([6a11349](https://github.com/openfoodfacts/smooth-app/commit/6a1134908e302f48c97cd2d763f3139647a2e9a8))
* Allow to change the camera mode without restarting ([#3008](https://github.com/openfoodfacts/smooth-app/issues/3008)) ([acb5fac](https://github.com/openfoodfacts/smooth-app/commit/acb5fac58111b1f26b08be3b5ed6514fa5577e9e))


### Bug Fixes

* fixes 1286 ([#3025](https://github.com/openfoodfacts/smooth-app/issues/3025)) ([e60f6b8](https://github.com/openfoodfacts/smooth-app/commit/e60f6b8f776fc816bcc3cd6f9ef41d50ddaf000a))
* Goldens update darkmode status ([#3016](https://github.com/openfoodfacts/smooth-app/issues/3016)) ([1d5abac](https://github.com/openfoodfacts/smooth-app/commit/1d5abac606497f2ffad87f1d420142ee76fa9552))
* handling of back tap in select products list screen ([#3019](https://github.com/openfoodfacts/smooth-app/issues/3019)) ([c459397](https://github.com/openfoodfacts/smooth-app/commit/c459397185b8785f707114cf522c8bb96856496b))
* Image extraction screen ([#3026](https://github.com/openfoodfacts/smooth-app/issues/3026)) ([f893237](https://github.com/openfoodfacts/smooth-app/commit/f8932379db4ee10e0618ff109274a9261cd2156f))
* refresh images from gallery screen ([#3023](https://github.com/openfoodfacts/smooth-app/issues/3023)) ([58dbd43](https://github.com/openfoodfacts/smooth-app/commit/58dbd439e58761968750474191ee924d8a4ec8ba))


### Refactoring

* backgroundTasks - around the new "upload" method ([#3028](https://github.com/openfoodfacts/smooth-app/issues/3028)) ([2ca03cd](https://github.com/openfoodfacts/smooth-app/commit/2ca03cd5dac0f3c9ce1179c3ea8b6722652626fd))
* Removed unnecessary assets ([#3010](https://github.com/openfoodfacts/smooth-app/issues/3010)) ([6ba475b](https://github.com/openfoodfacts/smooth-app/commit/6ba475b0349543f2952983fb692d082febbbc8e3))


### Miscellaneous

* **deps:** bump crowdin/github-action from 1.4.12 to 1.4.13 ([#3014](https://github.com/openfoodfacts/smooth-app/issues/3014)) ([eb66aad](https://github.com/openfoodfacts/smooth-app/commit/eb66aad274dda48e197514d8fe58a5f3863754f5))
* **deps:** bump fastlane in /packages/smooth_app/android ([#3021](https://github.com/openfoodfacts/smooth-app/issues/3021)) ([8e98ecd](https://github.com/openfoodfacts/smooth-app/commit/8e98ecd8109ff66c3131e87f08ae30d1da36122b))
* **deps:** bump fastlane in /packages/smooth_app/ios ([#3020](https://github.com/openfoodfacts/smooth-app/issues/3020)) ([a6714e8](https://github.com/openfoodfacts/smooth-app/commit/a6714e886a2c5541555ace047ca402416959754a))
* New Crowdin translations ([#3000](https://github.com/openfoodfacts/smooth-app/issues/3000)) ([d61596e](https://github.com/openfoodfacts/smooth-app/commit/d61596ea990014d2e8c9cd260c585cd994af602d))
* New Crowdin translations ([#3007](https://github.com/openfoodfacts/smooth-app/issues/3007)) ([706247f](https://github.com/openfoodfacts/smooth-app/commit/706247f0d20edee8c96b8a12aff6efa40d59fc36))
* New Crowdin translations ([#3012](https://github.com/openfoodfacts/smooth-app/issues/3012)) ([c62b3f9](https://github.com/openfoodfacts/smooth-app/commit/c62b3f9eae65fc5393e759b79febd6859d863f52))
* New Crowdin translations ([#3029](https://github.com/openfoodfacts/smooth-app/issues/3029)) ([f8c6635](https://github.com/openfoodfacts/smooth-app/commit/f8c6635c55a6a62dd4f6fb4e9792961bf125e99d))

## [3.17.0](https://github.com/openfoodfacts/smooth-app/compare/v3.16.0...v3.17.0) (2022-09-11)


### Features

* menu to manage offline data ([#2971](https://github.com/openfoodfacts/smooth-app/issues/2971)) ([d2f8077](https://github.com/openfoodfacts/smooth-app/commit/d2f8077812ad3f7bfd2ec9a12e15274c3b7a41c0))


### Refactoring

* background tasks with classes ([#2994](https://github.com/openfoodfacts/smooth-app/issues/2994)) ([68b6939](https://github.com/openfoodfacts/smooth-app/commit/68b693990254cd2413ad78aff9b9270c7739171d))


### Miscellaneous

* **deps:** bump actions/setup-java from 3.4.1 to 3.5.0 ([#2980](https://github.com/openfoodfacts/smooth-app/issues/2980)) ([dc901aa](https://github.com/openfoodfacts/smooth-app/commit/dc901aa581a3aa1a64a8c4bf9d0530f8d0fc9891))
* New Crowdin translations ([#2996](https://github.com/openfoodfacts/smooth-app/issues/2996)) ([7f20d39](https://github.com/openfoodfacts/smooth-app/commit/7f20d39b2dd144431a65d80290cb7abacff83870))

## [3.16.0](https://github.com/openfoodfacts/smooth-app/compare/v3.15.0...v3.16.0) (2022-09-10)


### Features

* Helper for haptic feedback + improved delete product button ([#2957](https://github.com/openfoodfacts/smooth-app/issues/2957)) ([1073972](https://github.com/openfoodfacts/smooth-app/commit/10739723cedf55775e846b05d65db455d89d1d13))


### Bug Fixes

* miniature of ingredients blocks the text ([#2964](https://github.com/openfoodfacts/smooth-app/issues/2964)) ([c30e109](https://github.com/openfoodfacts/smooth-app/commit/c30e109372440ed9ef695525f061efb5f5951465))


### Miscellaneous

* New Crowdin translations ([#2981](https://github.com/openfoodfacts/smooth-app/issues/2981)) ([8f1cd29](https://github.com/openfoodfacts/smooth-app/commit/8f1cd2972f7cd6b3da651042ec673e4fa439ae47))
* New Crowdin translations ([#2990](https://github.com/openfoodfacts/smooth-app/issues/2990)) ([16b0434](https://github.com/openfoodfacts/smooth-app/commit/16b0434a823cb5999bc4b28ad0678497f22c7c58))

## [3.15.0](https://github.com/openfoodfacts/smooth-app/compare/v3.14.0...v3.15.0) (2022-09-07)


### Features

* Finalizer for MLKitScanDecoder ([#2937](https://github.com/openfoodfacts/smooth-app/issues/2937)) ([aefd743](https://github.com/openfoodfacts/smooth-app/commit/aefd7437196026c2a424a6da3b7c84f0cf14704e))

## [3.14.0](https://github.com/openfoodfacts/smooth-app/compare/v3.13.1...v3.14.0) (2022-09-07)


### Features

* Alternative mode for camera (Android only feature) ([#2953](https://github.com/openfoodfacts/smooth-app/issues/2953)) ([15e1f57](https://github.com/openfoodfacts/smooth-app/commit/15e1f57f4f174c30e802a3af40c52f809b075a70))
* Common layout for welcome / product not found / error cards ([#2955](https://github.com/openfoodfacts/smooth-app/issues/2955)) ([77569bf](https://github.com/openfoodfacts/smooth-app/commit/77569bfb13f952b38830dc196c912251bc3c4e6a))


### Bug Fixes

* [#1538](https://github.com/openfoodfacts/smooth-app/issues/1538) - new crop tool (cf. dev mode) ([#2872](https://github.com/openfoodfacts/smooth-app/issues/2872)) ([535cddc](https://github.com/openfoodfacts/smooth-app/commit/535cddc2a9982d89d3ebcca9dfbba814931d860b))
* [#2833](https://github.com/openfoodfacts/smooth-app/issues/2833) - KP page refreshed by product (refactoring was needed) ([#2861](https://github.com/openfoodfacts/smooth-app/issues/2861)) ([e57cc0f](https://github.com/openfoodfacts/smooth-app/commit/e57cc0f042b6eaee8641e6425520dccf7a648d1c))


### Miscellaneous

* add flutter extension to devcontainer.json ([#2939](https://github.com/openfoodfacts/smooth-app/issues/2939)) ([b102b42](https://github.com/openfoodfacts/smooth-app/commit/b102b42fc2647b07ff3155a990ab5dc3011e1f2f))
* New Crowdin translations ([#2952](https://github.com/openfoodfacts/smooth-app/issues/2952)) ([3222912](https://github.com/openfoodfacts/smooth-app/commit/3222912b160788061cadbab83683b14b6002159d))
* New Crowdin translations ([#2966](https://github.com/openfoodfacts/smooth-app/issues/2966)) ([337fad6](https://github.com/openfoodfacts/smooth-app/commit/337fad6e0bbf45d0a676eedd49f0ea9f56d2e1b2))

## [3.13.1](https://github.com/openfoodfacts/smooth-app/compare/v3.13.0...v3.13.1) (2022-09-06)


### Bug Fixes

* [#2863](https://github.com/openfoodfacts/smooth-app/issues/2863) - onboarding black tooltip now bottom positioned ([#2889](https://github.com/openfoodfacts/smooth-app/issues/2889)) ([b163db9](https://github.com/openfoodfacts/smooth-app/commit/b163db93974e9b8847c309e798d0c086bf0610d7))
* Conflicting task names for ingredients and packaging ([#2950](https://github.com/openfoodfacts/smooth-app/issues/2950)) ([5f575a3](https://github.com/openfoodfacts/smooth-app/commit/5f575a3d6602e96e7a43745d185f1e26479b4b60))


### Documentation

* expand thanks ([ebf7ec1](https://github.com/openfoodfacts/smooth-app/commit/ebf7ec15ad7b4ec7225b2a98abed08085cac3a3d))
* extend thanks ([acc32c0](https://github.com/openfoodfacts/smooth-app/commit/acc32c023be3d110a923b7c29ea42af9967487f7))

## [3.13.0](https://github.com/openfoodfacts/smooth-app/compare/v3.12.0...v3.13.0) (2022-09-06)


### Features

* Instant refresh views ([#2901](https://github.com/openfoodfacts/smooth-app/issues/2901)) ([0d2be11](https://github.com/openfoodfacts/smooth-app/commit/0d2be113fc3fd79a1f16db72437843d702c6d2ab))


### Bug Fixes

* fixed package versions ([#2936](https://github.com/openfoodfacts/smooth-app/issues/2936)) ([d7ed371](https://github.com/openfoodfacts/smooth-app/commit/d7ed37133e4fc31f7ee588c4912c2e225fb93871))

## [3.12.0](https://github.com/openfoodfacts/smooth-app/compare/v3.11.0...v3.12.0) (2022-09-06)


### Features

* Improve the Feature request template ([#2931](https://github.com/openfoodfacts/smooth-app/issues/2931)) ([47bbf89](https://github.com/openfoodfacts/smooth-app/commit/47bbf89a421718f4dcf1c6e2e04ab0198d9b0514))


### Bug Fixes

* [#2846](https://github.com/openfoodfacts/smooth-app/issues/2846) horizontal layout buttons ([#2899](https://github.com/openfoodfacts/smooth-app/issues/2899)) ([91aa457](https://github.com/openfoodfacts/smooth-app/commit/91aa45782793d9e1f78c5201053c599d08314260))
* back to flutter 3.0.5 ([#2923](https://github.com/openfoodfacts/smooth-app/issues/2923)) ([513af0e](https://github.com/openfoodfacts/smooth-app/commit/513af0e22df0939ba4a59994c1b26f84447af9e4))
* Dark status bar for onboarding ([#2864](https://github.com/openfoodfacts/smooth-app/issues/2864)) ([e8c97e4](https://github.com/openfoodfacts/smooth-app/commit/e8c97e479b408e745a7e8e26eb3cc38a9a637881))
* Improve the issue template for better issues ([#2930](https://github.com/openfoodfacts/smooth-app/issues/2930)) ([90f9d9e](https://github.com/openfoodfacts/smooth-app/commit/90f9d9edc772f0369403c298fb8bc925876f31fd))
* improve the PR template ([#2933](https://github.com/openfoodfacts/smooth-app/issues/2933)) ([23b1dd4](https://github.com/openfoodfacts/smooth-app/commit/23b1dd4a4ff56108fbc07e71c7382e1d05d04853))
* remove the epic horse ([b42ddb7](https://github.com/openfoodfacts/smooth-app/commit/b42ddb7d160661af5ba5823fdbf3d2065dcec10a))


### Miscellaneous

* New Crowdin translations ([#2920](https://github.com/openfoodfacts/smooth-app/issues/2920)) ([a5f5343](https://github.com/openfoodfacts/smooth-app/commit/a5f53430a5164ba198b6269867a20d1a1db8fdd2))

## [3.11.0](https://github.com/openfoodfacts/smooth-app/compare/v3.10.3...v3.11.0) (2022-09-04)


### Features

* Add a gallery of the images selected and uploaded for a product ([#2801](https://github.com/openfoodfacts/smooth-app/issues/2801)) ([c706839](https://github.com/openfoodfacts/smooth-app/commit/c70683939db4324f3299f0c91e103e3eb7368584))


### Miscellaneous

* **deps:** bump flutter_launcher_icons in /packages/smooth_app ([#2873](https://github.com/openfoodfacts/smooth-app/issues/2873)) ([242ec9d](https://github.com/openfoodfacts/smooth-app/commit/242ec9d91868a1c0e46f2991f58b1c2ce6366951))
* New Crowdin translations ([#2914](https://github.com/openfoodfacts/smooth-app/issues/2914)) ([d1b9020](https://github.com/openfoodfacts/smooth-app/commit/d1b902084b538407575e616169d5bd66d1770982))

## [3.10.3](https://github.com/openfoodfacts/smooth-app/compare/v3.10.2...v3.10.3) (2022-09-03)


### Bug Fixes

* Revert MLKit library to 0.3.0 ([#2907](https://github.com/openfoodfacts/smooth-app/issues/2907)) ([c35b0a2](https://github.com/openfoodfacts/smooth-app/commit/c35b0a2768975330277edbd6b59b8ca66de25d03))


### Miscellaneous

* **deps:** bump path from 1.8.0 to 1.8.2 in /packages/smooth_app ([#2894](https://github.com/openfoodfacts/smooth-app/issues/2894)) ([2fdeda4](https://github.com/openfoodfacts/smooth-app/commit/2fdeda41e1922611df89e76bcd200a8bc39b4f58))
* New Crowdin translations ([#2908](https://github.com/openfoodfacts/smooth-app/issues/2908)) ([eff3886](https://github.com/openfoodfacts/smooth-app/commit/eff388657828f7895364de6f55a3fa0ac3b04009))

## [3.10.2](https://github.com/openfoodfacts/smooth-app/compare/v3.10.1...v3.10.2) (2022-09-02)


### Miscellaneous

* New Crowdin translations ([#2900](https://github.com/openfoodfacts/smooth-app/issues/2900)) ([0167d9d](https://github.com/openfoodfacts/smooth-app/commit/0167d9dccc6bc20a5a6ba0e297ec08f0c6b17f7c))

## [3.10.1](https://github.com/openfoodfacts/smooth-app/compare/v3.10.0...v3.10.1) (2022-09-01)


### Bug Fixes

* Fixes for Flutter version 3.3 ([#2884](https://github.com/openfoodfacts/smooth-app/issues/2884)) ([254a9b7](https://github.com/openfoodfacts/smooth-app/commit/254a9b725eb1ad5df4ddbc147b6d5a8c5f8cc587))


### Automation

* fix PR ([#2888](https://github.com/openfoodfacts/smooth-app/issues/2888)) ([bfeedeb](https://github.com/openfoodfacts/smooth-app/commit/bfeedeb699b56195f317ef90e440dd391a1762cd))


### Miscellaneous

* **deps:** bump google_mlkit_barcode_scanning in /packages/smooth_app ([#2881](https://github.com/openfoodfacts/smooth-app/issues/2881)) ([46c4f36](https://github.com/openfoodfacts/smooth-app/commit/46c4f36342ca6090f2e63bbf7076b2b1f5d0d794))

## [3.10.0](https://github.com/openfoodfacts/smooth-app/compare/v3.9.0...v3.10.0) (2022-09-01)


### Features

* Bring back the quick setting tile on Android ([#2870](https://github.com/openfoodfacts/smooth-app/issues/2870)) ([0c7e236](https://github.com/openfoodfacts/smooth-app/commit/0c7e236a381a3237d0d524077b4779846dd93e1f))


### Bug Fixes

* Background image upload ([#2433](https://github.com/openfoodfacts/smooth-app/issues/2433)) ([cf4fa6a](https://github.com/openfoodfacts/smooth-app/commit/cf4fa6aebe30a769a57ce2c71bc23d4473a7a8e4))


### Automation

* disabling run for dependabot PRs ([4296daf](https://github.com/openfoodfacts/smooth-app/commit/4296dafb0a9748bbed640dddf19d6eb4667dcb89))


### Miscellaneous

* **deps:** bump barcode_widget in /packages/smooth_app ([#2875](https://github.com/openfoodfacts/smooth-app/issues/2875)) ([2fa796e](https://github.com/openfoodfacts/smooth-app/commit/2fa796e868554117510dea6c3fef9e5b8a8eb742))
* **deps:** bump flutter_svg in /packages/smooth_app ([#2874](https://github.com/openfoodfacts/smooth-app/issues/2874)) ([c1e3651](https://github.com/openfoodfacts/smooth-app/commit/c1e36513ad3aa3db054b14b39e3ac9d80646bb96))
* **deps:** bump sentry_flutter in /packages/smooth_app ([#2877](https://github.com/openfoodfacts/smooth-app/issues/2877)) ([94d85c9](https://github.com/openfoodfacts/smooth-app/commit/94d85c98ab254dd546033d0afd8e57ebcf3aae03))
* New Crowdin translations ([#2878](https://github.com/openfoodfacts/smooth-app/issues/2878)) ([2b969e9](https://github.com/openfoodfacts/smooth-app/commit/2b969e921a79ba0924894749e9b101ba2ba0d3b3))
* New Crowdin translations ([#2886](https://github.com/openfoodfacts/smooth-app/issues/2886)) ([fc9711b](https://github.com/openfoodfacts/smooth-app/commit/fc9711bd9ca41d8486e6c35ba8b5354d1671c4ad))

## [3.9.0](https://github.com/openfoodfacts/smooth-app/compare/v3.8.1...v3.9.0) (2022-08-30)


### Features

* [#2852](https://github.com/openfoodfacts/smooth-app/issues/2852) - Matomo message when barcode is not found ([#2854](https://github.com/openfoodfacts/smooth-app/issues/2854)) ([3dca648](https://github.com/openfoodfacts/smooth-app/commit/3dca6488006f9dc043a600522ef16c2fcd5b50e6))
* Add to list horizontal buttons ([#2871](https://github.com/openfoodfacts/smooth-app/issues/2871)) ([1f72ce6](https://github.com/openfoodfacts/smooth-app/commit/1f72ce62ce23316dbd9caedc643416eb2eee55a8))


### Bug Fixes

* [#1538](https://github.com/openfoodfacts/smooth-app/issues/1538) - refactoring of image cropper ([#2858](https://github.com/openfoodfacts/smooth-app/issues/2858)) ([394cf4c](https://github.com/openfoodfacts/smooth-app/commit/394cf4cf1831c2009f18bed0ae172767a419b7e3))
* [#2841](https://github.com/openfoodfacts/smooth-app/issues/2841) - from "AddNewProductPage", no need to be logged in to add data ([#2844](https://github.com/openfoodfacts/smooth-app/issues/2844)) ([474b3d8](https://github.com/openfoodfacts/smooth-app/commit/474b3d8eb67c3b71dd138e169c895b1f41e0e568))
* improve ios launch screen on notch devices ([#2810](https://github.com/openfoodfacts/smooth-app/issues/2810)) ([903d3fc](https://github.com/openfoodfacts/smooth-app/commit/903d3fce18c4a32cdfdbf4c4a70c50d2097fa794))
* Placeholder image in case of image not loading ([#2857](https://github.com/openfoodfacts/smooth-app/issues/2857)) ([4187014](https://github.com/openfoodfacts/smooth-app/commit/418701472bb5c2dbd2a09b76f9fb5374d4ed6928))


### Automation

* fix: Running workflows on pr's from forks ([#2847](https://github.com/openfoodfacts/smooth-app/issues/2847)) ([36443f7](https://github.com/openfoodfacts/smooth-app/commit/36443f7a905f98b76a4f9f26bce138883c2c455a))


### Miscellaneous

* New Crowdin translations ([#2850](https://github.com/openfoodfacts/smooth-app/issues/2850)) ([7526a4c](https://github.com/openfoodfacts/smooth-app/commit/7526a4c78cb44f9981b7ab34a4ac04472aa12652))
* New Crowdin translations to review and merge ([#2838](https://github.com/openfoodfacts/smooth-app/issues/2838)) ([98576d6](https://github.com/openfoodfacts/smooth-app/commit/98576d63d55aafcad86cc264e1bd1e5fc84fb683))
* New Crowdin translations to review and merge ([#2842](https://github.com/openfoodfacts/smooth-app/issues/2842)) ([45764d9](https://github.com/openfoodfacts/smooth-app/commit/45764d910fa761f8ff6b7e95cd5a55d5dd799b56))
* New Crowdin translations to review and merge ([#2848](https://github.com/openfoodfacts/smooth-app/issues/2848)) ([85f491b](https://github.com/openfoodfacts/smooth-app/commit/85f491b4e7af4a9d44383760db2ee39ed291db70))

## [3.8.1](https://github.com/openfoodfacts/smooth-app/compare/v3.8.0...v3.8.1) (2022-08-25)


### Miscellaneous

* New Crowdin translations ([#2743](https://github.com/openfoodfacts/smooth-app/issues/2743)) ([43ab9cf](https://github.com/openfoodfacts/smooth-app/commit/43ab9cf3c0d962f7e67771062d19a1573697cdc3))

## [3.8.0](https://github.com/openfoodfacts/smooth-app/compare/v3.7.4...v3.8.0) (2022-08-24)


### Features

* Improvements for the decoding process (1/3) ([#2835](https://github.com/openfoodfacts/smooth-app/issues/2835)) ([9598b25](https://github.com/openfoodfacts/smooth-app/commit/9598b254f3b04f5a4e91c8428abed1be34eef575))


### Bug Fixes

* Splash on Android 24 ([#2832](https://github.com/openfoodfacts/smooth-app/issues/2832)) ([ab068ed](https://github.com/openfoodfacts/smooth-app/commit/ab068edd412711e3655dd7191d79d4f067e53d8a))


### Automation

* Finalize new pipline ([#2824](https://github.com/openfoodfacts/smooth-app/issues/2824)) ([cbe7677](https://github.com/openfoodfacts/smooth-app/commit/cbe7677c52e924da3faaef39e38b22daf5468086))


### Miscellaneous

* **deps:** bump fastlane in /packages/smooth_app/android ([#2828](https://github.com/openfoodfacts/smooth-app/issues/2828)) ([6f1823e](https://github.com/openfoodfacts/smooth-app/commit/6f1823e96b798bbd0acfb1e66e84d431723c2d2a))
* **deps:** bump fastlane in /packages/smooth_app/ios ([#2827](https://github.com/openfoodfacts/smooth-app/issues/2827)) ([a73fa69](https://github.com/openfoodfacts/smooth-app/commit/a73fa69aca78b02259e53f9db6f50b8407bbd36b))


### Documentation

* Start cleaning the roadmap ([#2815](https://github.com/openfoodfacts/smooth-app/issues/2815)) ([d506209](https://github.com/openfoodfacts/smooth-app/commit/d5062099110dde7428d218d3cde44c6d2037771e))

## [3.7.4](https://github.com/openfoodfacts/smooth-app/compare/v3.7.3...v3.7.4) (2022-08-21)


### Automation

* Fix use inputs not env ([#2822](https://github.com/openfoodfacts/smooth-app/issues/2822)) ([47df2b5](https://github.com/openfoodfacts/smooth-app/commit/47df2b59f69a634a109d3c0ee7c1ab7d2e1ddcf7))

## [3.7.3](https://github.com/openfoodfacts/smooth-app/compare/v3.7.2...v3.7.3) (2022-08-21)


### Automation

* Fix secret naming ([#2820](https://github.com/openfoodfacts/smooth-app/issues/2820)) ([28d41e6](https://github.com/openfoodfacts/smooth-app/commit/28d41e6e307336ef6e7ed7792c9007947090670e))

## [3.7.2](https://github.com/openfoodfacts/smooth-app/compare/v3.7.1...v3.7.2) (2022-08-21)


### Automation

* Fix wrong env name ([#2818](https://github.com/openfoodfacts/smooth-app/issues/2818)) ([5399834](https://github.com/openfoodfacts/smooth-app/commit/5399834a1cecdd5a76cca08c0dde08ff567ca394))

## [3.7.1](https://github.com/openfoodfacts/smooth-app/compare/v3.7.0...v3.7.1) (2022-08-21)


### Automation

* Fix not outputting values from release-please ([#2816](https://github.com/openfoodfacts/smooth-app/issues/2816)) ([903f78e](https://github.com/openfoodfacts/smooth-app/commit/903f78ec01711e5f6ce399d87f057ccc313da603))

## [3.7.0](https://github.com/openfoodfacts/smooth-app/compare/v3.6.0...v3.7.0) (2022-08-20)


### Features

* [#2174](https://github.com/openfoodfacts/smooth-app/issues/2174) - doomscrolling instead of "download more" button ([#2770](https://github.com/openfoodfacts/smooth-app/issues/2770)) ([c821f6d](https://github.com/openfoodfacts/smooth-app/commit/c821f6d2fecb4ce7c529f7ff9931707aded60ba3))
* [#2785](https://github.com/openfoodfacts/smooth-app/issues/2785) - async access to dao product list ([#2788](https://github.com/openfoodfacts/smooth-app/issues/2788)) ([d922511](https://github.com/openfoodfacts/smooth-app/commit/d922511a32903332eb07e0a3b23f371155ebda17))
* Edit product page UI improvements ([#2754](https://github.com/openfoodfacts/smooth-app/issues/2754)) ([8ed337b](https://github.com/openfoodfacts/smooth-app/commit/8ed337bfdeffa81d78363cc9b8d63e0daffdfc13))
* Horizontal buttons for Dialogs ([#2626](https://github.com/openfoodfacts/smooth-app/issues/2626)) ([ddb8bea](https://github.com/openfoodfacts/smooth-app/commit/ddb8bea405ea6401600bc437baed9921d56f8059))
* Show osm attribution + removed matomo_tracker fork ([#2740](https://github.com/openfoodfacts/smooth-app/issues/2740)) ([f6f8511](https://github.com/openfoodfacts/smooth-app/commit/f6f851179cb8d59519d68679f2b75189be8153a6))
* Sign up form: try to highlight the issue ([#2535](https://github.com/openfoodfacts/smooth-app/issues/2535)) ([d08b1bd](https://github.com/openfoodfacts/smooth-app/commit/d08b1bd3772838fee3747d7f174a9396100358bd))
* use modals for navigating to editing screens ([#2797](https://github.com/openfoodfacts/smooth-app/issues/2797)) ([3431933](https://github.com/openfoodfacts/smooth-app/commit/3431933907228745316f418b4a5964e22a9ded94))


### Bug Fixes

* [#2553](https://github.com/openfoodfacts/smooth-app/issues/2553) - upgrade to off-dart 1.24.0 + categories not completed ([#2795](https://github.com/openfoodfacts/smooth-app/issues/2795)) ([133071d](https://github.com/openfoodfacts/smooth-app/commit/133071dea9c2ab398f51ae23e38e2c36a39a5d4d))
* [#2729](https://github.com/openfoodfacts/smooth-app/issues/2729) - product query page - simplified top messages and buttons ([#2736](https://github.com/openfoodfacts/smooth-app/issues/2736)) ([dee9be3](https://github.com/openfoodfacts/smooth-app/commit/dee9be35a3efde29302de2c1cecb0bea98f5b8ed))
* [#2730](https://github.com/openfoodfacts/smooth-app/issues/2730) - removed $ in "contact" translations ([#2734](https://github.com/openfoodfacts/smooth-app/issues/2734)) ([462e73f](https://github.com/openfoodfacts/smooth-app/commit/462e73ff3f0df72b40d50911cf9b4ad00a704e22))
* [#2773](https://github.com/openfoodfacts/smooth-app/issues/2773) - appropriate "clear?" and "delete?" messages for user lists ([#2778](https://github.com/openfoodfacts/smooth-app/issues/2778)) ([3deb4cb](https://github.com/openfoodfacts/smooth-app/commit/3deb4cbeb535c10446b36af3215725acc40e507b))
* [#2774](https://github.com/openfoodfacts/smooth-app/issues/2774) - moved items in EditProductPage ([#2779](https://github.com/openfoodfacts/smooth-app/issues/2779)) ([9e11f50](https://github.com/openfoodfacts/smooth-app/commit/9e11f50dbe2fb91104d6e18ca2e298b2c622ebd7))
* [#2776](https://github.com/openfoodfacts/smooth-app/issues/2776) - more standard user preferences app bar ([#2780](https://github.com/openfoodfacts/smooth-app/issues/2780)) ([4abe9fe](https://github.com/openfoodfacts/smooth-app/commit/4abe9fe832f43a38beaa02df29c3c91cc4278cc0))
* back button invisible for some preferences ([#2760](https://github.com/openfoodfacts/smooth-app/issues/2760)) ([e58db02](https://github.com/openfoodfacts/smooth-app/commit/e58db0284619bdf6126e568d1ac26f0fb1a5def4))
* Offline product knowledge panel issue ([#2693](https://github.com/openfoodfacts/smooth-app/issues/2693)) ([4052a84](https://github.com/openfoodfacts/smooth-app/commit/4052a848d178164962f302c8ff76c0aabd6c2435))
* screenshot - different Key for different screens ([#2798](https://github.com/openfoodfacts/smooth-app/issues/2798)) ([e798376](https://github.com/openfoodfacts/smooth-app/commit/e798376f1c2d4aa44c62ac3830ccc334c89699dd))
* support back swipe on iOS product page ([#2792](https://github.com/openfoodfacts/smooth-app/issues/2792)) ([f2bb63f](https://github.com/openfoodfacts/smooth-app/commit/f2bb63f1381d9f7b3cb1796462b41e40261261ae))
* text alignment in attribute chips ([#2786](https://github.com/openfoodfacts/smooth-app/issues/2786)) ([c5e5ef8](https://github.com/openfoodfacts/smooth-app/commit/c5e5ef8866d79bd8d25fb6743484a12d01a3f87d))
* unsupported-locale-update ([#2766](https://github.com/openfoodfacts/smooth-app/issues/2766)) ([6fe4f22](https://github.com/openfoodfacts/smooth-app/commit/6fe4f22ed981610ce3fd489316e5a93fb4688b1d))


### Miscellaneous

* **deps:** bump crowdin/github-action from 1.4.10 to 1.4.11 ([#2733](https://github.com/openfoodfacts/smooth-app/issues/2733)) ([22cea90](https://github.com/openfoodfacts/smooth-app/commit/22cea90c7997b6e3ce12eca19276291614a66f0e))
* **deps:** bump crowdin/github-action from 1.4.11 to 1.4.12 ([#2789](https://github.com/openfoodfacts/smooth-app/issues/2789)) ([c52327e](https://github.com/openfoodfacts/smooth-app/commit/c52327e4dbcbf4a127b8c459086951e902f56c61))
* **deps:** bump fastlane in /packages/smooth_app/android ([#2782](https://github.com/openfoodfacts/smooth-app/issues/2782)) ([9502be8](https://github.com/openfoodfacts/smooth-app/commit/9502be83ceffa27afb3598f6d3a28b23bae70876))
* **deps:** bump fastlane in /packages/smooth_app/ios ([#2783](https://github.com/openfoodfacts/smooth-app/issues/2783)) ([7da8530](https://github.com/openfoodfacts/smooth-app/commit/7da85303a3c4f42a50532d0b92a6462429452c16))
* New Crowdin translations to review and merge ([#2677](https://github.com/openfoodfacts/smooth-app/issues/2677)) ([08f6e48](https://github.com/openfoodfacts/smooth-app/commit/08f6e487860c14d5b28efb81f0ae81a5a4c285c3))
* productQueryPage - refactored without ScaffoldMessenger ([#2769](https://github.com/openfoodfacts/smooth-app/issues/2769)) ([04d311e](https://github.com/openfoodfacts/smooth-app/commit/04d311e04da1cc3cc7044a5f153be238c429eb39))


### Documentation

* add Weekly meeting ([#2803](https://github.com/openfoodfacts/smooth-app/issues/2803)) ([eb32eaf](https://github.com/openfoodfacts/smooth-app/commit/eb32eaf4957859f1b0ff33865ad66d71f898459f))
* document the forks we depend on ([#2717](https://github.com/openfoodfacts/smooth-app/issues/2717)) ([f6d7e08](https://github.com/openfoodfacts/smooth-app/commit/f6d7e081f88dc2403ec8f1e46208b6beb8d09cb8))


### Refactoring

* [#920](https://github.com/openfoodfacts/smooth-app/issues/920) - when relevant, switched to `Navigator.push<void>` ([#2799](https://github.com/openfoodfacts/smooth-app/issues/2799)) ([18ce300](https://github.com/openfoodfacts/smooth-app/commit/18ce3004e868e3cd14ba6799afdb555972c2daff))


### Automation

* extra security ([#2791](https://github.com/openfoodfacts/smooth-app/issues/2791)) ([6ee068c](https://github.com/openfoodfacts/smooth-app/commit/6ee068c80ede5691627476191ecb9124673c1861))
* extra security, prevent the intruction of vulnerable deps ([6ee068c](https://github.com/openfoodfacts/smooth-app/commit/6ee068c80ede5691627476191ecb9124673c1861))
* Final release fix ([aa35277](https://github.com/openfoodfacts/smooth-app/commit/aa352779c1b8b756054752aed9ad96819831ca4b))
* Major release update ([#2777](https://github.com/openfoodfacts/smooth-app/issues/2777)) ([c4ccd79](https://github.com/openfoodfacts/smooth-app/commit/c4ccd79b5f74aab5251e9ce08f9bceea34fae326))
* Major release update fix ([#2811](https://github.com/openfoodfacts/smooth-app/issues/2811)) ([bbe5635](https://github.com/openfoodfacts/smooth-app/commit/bbe56359f5df1aed4a0b273c378e2c17087bcf47))

## [3.6.0](https://github.com/openfoodfacts/smooth-app/compare/v3.5.1...v3.6.0) (2022-08-04)


### Features

* [#1343](https://github.com/openfoodfacts/smooth-app/issues/1343) - "world" queries and faster cached result display ([#2718](https://github.com/openfoodfacts/smooth-app/issues/2718)) ([8599d10](https://github.com/openfoodfacts/smooth-app/commit/8599d10f94779957ae372dd8d086864155f015fb))
* [#2396](https://github.com/openfoodfacts/smooth-app/issues/2396) - better memory management - load products only when needed ([#2609](https://github.com/openfoodfacts/smooth-app/issues/2609)) ([115722b](https://github.com/openfoodfacts/smooth-app/commit/115722b6136ab4218b3ddfae1a6e666c65325525))
* [#2503](https://github.com/openfoodfacts/smooth-app/issues/2503) - language selector now in "App Settings" (for all users) ([#2658](https://github.com/openfoodfacts/smooth-app/issues/2658)) ([0c5fab5](https://github.com/openfoodfacts/smooth-app/commit/0c5fab5c8d21a833d77d49fc6371a15c48c20c46))
* [#2647](https://github.com/openfoodfacts/smooth-app/issues/2647) - added a refresh gesture to edit product page ([#2649](https://github.com/openfoodfacts/smooth-app/issues/2649)) ([e163167](https://github.com/openfoodfacts/smooth-app/commit/e1631679bd3cb6b17f12f13114f5fdb9da2957d7))
* [#2653](https://github.com/openfoodfacts/smooth-app/issues/2653) - added asset haute-valeur-environnementale.90x90.svg ([#2654](https://github.com/openfoodfacts/smooth-app/issues/2654)) ([96f7b86](https://github.com/openfoodfacts/smooth-app/commit/96f7b8618ae12e12f7a010891ba76d6cf8672712))
* [#2671](https://github.com/openfoodfacts/smooth-app/issues/2671) - product lists - downloads products when not in local database ([#2673](https://github.com/openfoodfacts/smooth-app/issues/2673)) ([b08dc60](https://github.com/openfoodfacts/smooth-app/commit/b08dc608fe9aea6f53b2d6258644e2cec26c4f72))
* [#2705](https://github.com/openfoodfacts/smooth-app/issues/2705) - barcode copy from product edit page ([#2709](https://github.com/openfoodfacts/smooth-app/issues/2709)) ([a713ccd](https://github.com/openfoodfacts/smooth-app/commit/a713ccdda0b729abb4ae1eb1a9d581d3163cc665))
* added feat in dev mode to preload 1k products ([#2661](https://github.com/openfoodfacts/smooth-app/issues/2661)) ([37e5b75](https://github.com/openfoodfacts/smooth-app/commit/37e5b75f64e59d96fa47f9495d464c9f1eae7c5a))
* make text fields design use less space ([#2725](https://github.com/openfoodfacts/smooth-app/issues/2725)) ([bff9e92](https://github.com/openfoodfacts/smooth-app/commit/bff9e92e040438121683ecf7f439aa891817546c))


### Bug Fixes

* [#2291](https://github.com/openfoodfacts/smooth-app/issues/2291) - removed flawed specific font (back to default fonts) ([#2657](https://github.com/openfoodfacts/smooth-app/issues/2657)) ([180c817](https://github.com/openfoodfacts/smooth-app/commit/180c8175622766276cf1ea41c7a1899769f85868))
* [#2682](https://github.com/openfoodfacts/smooth-app/issues/2682) - no more trying to display null panels ([#2684](https://github.com/openfoodfacts/smooth-app/issues/2684)) ([00a717e](https://github.com/openfoodfacts/smooth-app/commit/00a717ee4b59b3e2319f6f11a6893cb53d364d19))
* [#2706](https://github.com/openfoodfacts/smooth-app/issues/2706) - now we display the "LOGIN!" button only if not logged in ([#2714](https://github.com/openfoodfacts/smooth-app/issues/2714)) ([a845721](https://github.com/openfoodfacts/smooth-app/commit/a845721b0206d1b2f1f5bd25249f11115dcb1aef))
* added loading indicator while sign-in in process ([#2727](https://github.com/openfoodfacts/smooth-app/issues/2727)) ([5af58b9](https://github.com/openfoodfacts/smooth-app/commit/5af58b9396c93e1c6caafa6eef84337fa2f3aed8))
* AutocompleteWidget: Scrollbar + dividers + correct width ([#2704](https://github.com/openfoodfacts/smooth-app/issues/2704)) ([1618781](https://github.com/openfoodfacts/smooth-app/commit/1618781d6e74c8d296d659aa1bfe82b20e63a7e1))
* in dark mode, the barcode should be white ([#2702](https://github.com/openfoodfacts/smooth-app/issues/2702)) ([c58ab1b](https://github.com/openfoodfacts/smooth-app/commit/c58ab1b68427a00f988feb4e2e5776dfbecdcd9e))
* in gallery view the dots are not synchronize with the position of the photo, when the screen is launched ([#2700](https://github.com/openfoodfacts/smooth-app/issues/2700)) ([8bd4e9f](https://github.com/openfoodfacts/smooth-app/commit/8bd4e9ff4dfca10afc42d7976a3828616f6bc95f))
* localized title for email ([#2691](https://github.com/openfoodfacts/smooth-app/issues/2691)) ([aa294b4](https://github.com/openfoodfacts/smooth-app/commit/aa294b4e6ed20a373c3831e014fac285a73f7f1a))
* Login button whole width centre ([#2668](https://github.com/openfoodfacts/smooth-app/issues/2668)) ([9acaddf](https://github.com/openfoodfacts/smooth-app/commit/9acaddf1cfe89a2d29b262b89fdf233b26a23d3d))
* new svg asset ([#2688](https://github.com/openfoodfacts/smooth-app/issues/2688)) ([7f12148](https://github.com/openfoodfacts/smooth-app/commit/7f121482d6140e6cb902db0c935b22604a738cd2))
* Padding in language section ([#2690](https://github.com/openfoodfacts/smooth-app/issues/2690)) ([9057659](https://github.com/openfoodfacts/smooth-app/commit/905765919fc81efa6b97729284a8bf70ce60d02c))
* Rounded the load more products in search button [#1900](https://github.com/openfoodfacts/smooth-app/issues/1900) ([#2663](https://github.com/openfoodfacts/smooth-app/issues/2663)) ([dd9c9c6](https://github.com/openfoodfacts/smooth-app/commit/dd9c9c6d6fda874963cfbd1392a7bee2e016f2cb))
* svg asset ([#2710](https://github.com/openfoodfacts/smooth-app/issues/2710)) ([89ffd1e](https://github.com/openfoodfacts/smooth-app/commit/89ffd1ef9386227ab3380a6474ec433538567f06))
* svg asset nature et progres + bleu blanc coeur ([#2722](https://github.com/openfoodfacts/smooth-app/issues/2722)) ([ef639b3](https://github.com/openfoodfacts/smooth-app/commit/ef639b325c820c4a01f3c20bbde707adec8a3377))
* svgAsset - additional svg assets ([#2686](https://github.com/openfoodfacts/smooth-app/issues/2686)) ([6a0ef19](https://github.com/openfoodfacts/smooth-app/commit/6a0ef198ec7e426399fd5585b8b2a426d6df9fd6))
* The virtual keyboard is sometimes visible after clicking on the Search field on the homepage ([#2712](https://github.com/openfoodfacts/smooth-app/issues/2712)) ([16ca53b](https://github.com/openfoodfacts/smooth-app/commit/16ca53bd030e3558a090994c9bb6455f30c36d74))
* use smoothcard in edit_product_page ([#2723](https://github.com/openfoodfacts/smooth-app/issues/2723)) ([af1a45f](https://github.com/openfoodfacts/smooth-app/commit/af1a45f973987905e2cc8a380d4694979b2ce9c0))

## [3.5.1](https://github.com/openfoodfacts/smooth-app/compare/3.4.6...v3.5.1) (2022-07-23)


### Features

* [#2337](https://github.com/openfoodfacts/smooth-app/issues/2337) - additional "power user" product edit page ([#2617](https://github.com/openfoodfacts/smooth-app/issues/2617)) ([d5017b4](https://github.com/openfoodfacts/smooth-app/commit/d5017b4f94db1cac53694eb45dfc9e6839043d7a))
* [#2364](https://github.com/openfoodfacts/smooth-app/issues/2364) - new preferences toggles for ingredients / nutrition expand mode ([#2634](https://github.com/openfoodfacts/smooth-app/issues/2634)) ([cc7c062](https://github.com/openfoodfacts/smooth-app/commit/cc7c062e555a63739708df5bd337316b5b10df42))
* [#2396](https://github.com/openfoodfacts/smooth-app/issues/2396) - preparatory step with simple refactoring ([#2593](https://github.com/openfoodfacts/smooth-app/issues/2593)) ([27681d1](https://github.com/openfoodfacts/smooth-app/commit/27681d101e6f6ebdc82a016aa5d032a0f74662a4))
* [#2475](https://github.com/openfoodfacts/smooth-app/issues/2475) - "contribute" now links to "in app" to-be-completed page ([#2623](https://github.com/openfoodfacts/smooth-app/issues/2623)) ([9b52190](https://github.com/openfoodfacts/smooth-app/commit/9b52190d3065758ab50b7f50ae12ec8f433318a4))
* [#2501](https://github.com/openfoodfacts/smooth-app/issues/2501) - added "origins" in edit product page ([#2571](https://github.com/openfoodfacts/smooth-app/issues/2571)) ([2b60cb5](https://github.com/openfoodfacts/smooth-app/commit/2b60cb5fd05639b100f844e7424cba6bb7113140))
* [#2513](https://github.com/openfoodfacts/smooth-app/issues/2513) - product page - moved higher the action bar ([#2615](https://github.com/openfoodfacts/smooth-app/issues/2615)) ([5816934](https://github.com/openfoodfacts/smooth-app/commit/581693420dc0ad8e9a0e584e88e401e4666b5bb8))
* [#2563](https://github.com/openfoodfacts/smooth-app/issues/2563) - edit product page - added top barcode display and leading/trailing icons ([#2567](https://github.com/openfoodfacts/smooth-app/issues/2567)) ([b16d6d6](https://github.com/openfoodfacts/smooth-app/commit/b16d6d67cbee1b27396e9d7edce99b186f78a5ae))
* [#2572](https://github.com/openfoodfacts/smooth-app/issues/2572) - added icons for ingredients and nutrition in edit product page ([#2577](https://github.com/openfoodfacts/smooth-app/issues/2577)) ([168d468](https://github.com/openfoodfacts/smooth-app/commit/168d4688f4859a498843067475d7b34cd86902c2))
* [#2573](https://github.com/openfoodfacts/smooth-app/issues/2573) - KP cells are expanded on detail pages ([#2581](https://github.com/openfoodfacts/smooth-app/issues/2581)) ([1eb6712](https://github.com/openfoodfacts/smooth-app/commit/1eb6712ffb0820c677ad503c3e62c56b3a49bcec))
* [#2574](https://github.com/openfoodfacts/smooth-app/issues/2574) - added explanations for origins, categories and packaging ([#2580](https://github.com/openfoodfacts/smooth-app/issues/2580)) ([bbcfd87](https://github.com/openfoodfacts/smooth-app/commit/bbcfd87f2620cf6d52ee0437bcdc2844173d4271))
* Language filter ([#2539](https://github.com/openfoodfacts/smooth-app/issues/2539)) ([d856b35](https://github.com/openfoodfacts/smooth-app/commit/d856b350356c10a941954125cee21d3e079c4198))
* Remove a maximum of hardcoded sizes and move Padding to Directional ones ([#2534](https://github.com/openfoodfacts/smooth-app/issues/2534)) ([9ebe5c8](https://github.com/openfoodfacts/smooth-app/commit/9ebe5c849c9967289e861c57ad9f7c45b58ad788))
* Smooth Dialog with an axis for buttons ([#2587](https://github.com/openfoodfacts/smooth-app/issues/2587)) ([4255a5f](https://github.com/openfoodfacts/smooth-app/commit/4255a5faef1f611adfc299c56b0b033f096d9e38))


### Bug Fixes

* [#2009](https://github.com/openfoodfacts/smooth-app/issues/2009) - product page will always pull down - and refresh ([#2618](https://github.com/openfoodfacts/smooth-app/issues/2618)) ([ca960ed](https://github.com/openfoodfacts/smooth-app/commit/ca960ed4d98d95a5971c69723dfc0bd8c900cf79))
* [#2530](https://github.com/openfoodfacts/smooth-app/issues/2530) - replaced the score colors with a score emoji ([#2569](https://github.com/openfoodfacts/smooth-app/issues/2569)) ([a1e096c](https://github.com/openfoodfacts/smooth-app/commit/a1e096c044e8eaf3bd189d34b97ff20ed24c717f))
* [#2561](https://github.com/openfoodfacts/smooth-app/issues/2561) - fixed value+unit management in nutrient page ([#2568](https://github.com/openfoodfacts/smooth-app/issues/2568)) ([750f429](https://github.com/openfoodfacts/smooth-app/commit/750f429d2679e02e5525eab1aed2f9d31bba217f))
* [#2575](https://github.com/openfoodfacts/smooth-app/issues/2575) - fixed brightness check for app icon ([#2579](https://github.com/openfoodfacts/smooth-app/issues/2579)) ([8446b30](https://github.com/openfoodfacts/smooth-app/commit/8446b3082a391b29843a72a2c742152835038952))
* better place holder when no internet connection ([#2560](https://github.com/openfoodfacts/smooth-app/issues/2560)) ([e4ea159](https://github.com/openfoodfacts/smooth-app/commit/e4ea159685342a92dc148793dbadf9a46d662647))
* double-response mechanism in the scan screen ([#2632](https://github.com/openfoodfacts/smooth-app/issues/2632)) ([68d7c54](https://github.com/openfoodfacts/smooth-app/commit/68d7c5484d267cfd53849b8e9cdf96b3c4855ff8))
* ean - now we display ean8 (and not just ean13) ([#2596](https://github.com/openfoodfacts/smooth-app/issues/2596)) ([390ea3c](https://github.com/openfoodfacts/smooth-app/commit/390ea3cc4d144b814d78c1d3927dc9577464ea32))
* Ensure all text inputs have coherent cursors + heights ([#2578](https://github.com/openfoodfacts/smooth-app/issues/2578)) ([6ad23ae](https://github.com/openfoodfacts/smooth-app/commit/6ad23aefb277061f8c7706a2afb1ec5b25bf0918))

## [0.1.0](https://www.github.com/openfoodfacts/smooth-app/compare/v0.0.2...v0.1.0) (2021-11-27)


### Features

* [#657](https://www.github.com/openfoodfacts/smooth-app/issues/657) - nutriscore+ecoscore, then mandatory attributes, then groups and important attributes ([#658](https://www.github.com/openfoodfacts/smooth-app/issues/658)) ([09a21c3](https://www.github.com/openfoodfacts/smooth-app/commit/09a21c3b050180a32e361cf7583bb97ec2f45a7b))
* [#657](https://www.github.com/openfoodfacts/smooth-app/issues/657) (2) - same behavior for label attribute when mandatory or not ([#665](https://www.github.com/openfoodfacts/smooth-app/issues/665)) ([2f6a38d](https://www.github.com/openfoodfacts/smooth-app/commit/2f6a38d8236c65e8ad015f3a87287e32435c49e5))
* [#671](https://www.github.com/openfoodfacts/smooth-app/issues/671) - github magic trick ([da31f5c](https://www.github.com/openfoodfacts/smooth-app/commit/da31f5c74c07a5ff867cdfc6a9cc6931f803ab2b))
* [#671](https://www.github.com/openfoodfacts/smooth-app/issues/671) - removed the "very important" attribute importance ([814cb23](https://www.github.com/openfoodfacts/smooth-app/commit/814cb236ff3b000b7bbecdc3f1aa119a6aaf5b12))
* [#671](https://www.github.com/openfoodfacts/smooth-app/issues/671) - removed the "very important" attribute importance ([#672](https://www.github.com/openfoodfacts/smooth-app/issues/672)) ([69bdefb](https://www.github.com/openfoodfacts/smooth-app/commit/69bdefbaab9b9379c16ef94ec038d51df70f27d5))
* [#678](https://www.github.com/openfoodfacts/smooth-app/issues/678) - added bottom navigation bar to product page ([#679](https://www.github.com/openfoodfacts/smooth-app/issues/679)) ([212dd31](https://www.github.com/openfoodfacts/smooth-app/commit/212dd31d9171af22a412287091a920db2bba271a))
* [#682](https://www.github.com/openfoodfacts/smooth-app/issues/682) - add a "Clear all" menu item in the product history page ([#683](https://www.github.com/openfoodfacts/smooth-app/issues/683)) ([b672d2a](https://www.github.com/openfoodfacts/smooth-app/commit/b672d2a1108cb1966c21498df7b3c61475825e40))


### Bug Fixes

* [#684](https://www.github.com/openfoodfacts/smooth-app/issues/684) - writing in white when in dark mode for score card ([#688](https://www.github.com/openfoodfacts/smooth-app/issues/688)) ([aec0df6](https://www.github.com/openfoodfacts/smooth-app/commit/aec0df6ba979b2b81f3ae697d91b3a690a7bd6ad))
* [#687](https://www.github.com/openfoodfacts/smooth-app/issues/687) - safer product list load ([#689](https://www.github.com/openfoodfacts/smooth-app/issues/689)) ([3ebed5c](https://www.github.com/openfoodfacts/smooth-app/commit/3ebed5c49c4d2638bd94b680713490c07646454b))
* [#687](https://www.github.com/openfoodfacts/smooth-app/issues/687) (2) - product lists loaded from db now only display actual products ([#696](https://www.github.com/openfoodfacts/smooth-app/issues/696)) ([a1012c1](https://www.github.com/openfoodfacts/smooth-app/commit/a1012c190b705f31a00bf69d3fc9a03e02a2b690))
* [#691](https://www.github.com/openfoodfacts/smooth-app/issues/691) - regenerated golden screenshots for profile with bottom bar ([#692](https://www.github.com/openfoodfacts/smooth-app/issues/692)) ([85970d9](https://www.github.com/openfoodfacts/smooth-app/commit/85970d92ae8b4c7d2d457c2566eec97996d4a90c))
* contributors dialog ([#641](https://www.github.com/openfoodfacts/smooth-app/issues/641)) ([b7b7983](https://www.github.com/openfoodfacts/smooth-app/commit/b7b798342559abfaab6824227fd1aea586023b9c))
* deprecated share package + analyzer warnings ([#656](https://www.github.com/openfoodfacts/smooth-app/issues/656)) ([61576de](https://www.github.com/openfoodfacts/smooth-app/commit/61576ded7128aa34b8ac5283532cced4872c8226))
* null crash in new product page with knowledge panels builder ([#675](https://www.github.com/openfoodfacts/smooth-app/issues/675)) ([76222ac](https://www.github.com/openfoodfacts/smooth-app/commit/76222ac7c106873ef233b42c82b823172305837a))
