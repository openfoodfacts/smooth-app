# Changelog

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
