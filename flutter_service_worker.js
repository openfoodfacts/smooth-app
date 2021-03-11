'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';
const RESOURCES = {
  "manifest.json": "6e18fcd91ba6e455502434f850c7841c",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"assets/NOTICES": "a7655260d982db981b59f682346a9b9c",
"assets/assets/data/target.svg": "5c4ddcf64e54ddced0e7f8c05dc2e5fb",
"assets/assets/data/energy.svg": "316f12f39df3f08e00365c78baac667d",
"assets/assets/data/portion.svg": "33ab28358a175db9efb660561cb3d0ca",
"assets/assets/labels/ab_label.svg": "f51067bb93a405e67da314d3967cd66e",
"assets/assets/temp/Logo.png": "8a50b602aa79b19775c22d02a290f51f",
"assets/assets/categories/salty_snacks.svg": "e31d163fba26f23f72ea9d5181f2f3d0",
"assets/assets/categories/fat_and_sauces.svg": "96be5c65a083feb8f8cae27785bf6e24",
"assets/assets/categories/cereals_and_potatoes.svg": "6a7b07d98666dc14f1af287fa5c05ea3",
"assets/assets/categories/fish_meat_and_eggs.svg": "e009e8e9ce8b8c7c6cbfa190ef54ecb6",
"assets/assets/categories/milk_and_dairies.svg": "2b75decaf124657aeecd69de14c99b73",
"assets/assets/categories/beverages.svg": "55568c46041e88431941d75636019097",
"assets/assets/categories/fruits_and_vegetables.svg": "61a372a301f0c4fcc2e2655b11c93008",
"assets/assets/categories/composite_foods.svg": "43658cd985870e2df72f20806fc3dba0",
"assets/assets/categories/sugary_snacks.svg": "59fc16fb246f3aeef57b28ca661e99aa",
"assets/assets/navigation/organize.svg": "5150725a3b0b0cd8a9ca9c37fce3cccd",
"assets/assets/navigation/contribute.svg": "6d094eb62061017ee805f8d4798b705c",
"assets/assets/navigation/search.svg": "d117030916e75287156ff20573b441d1",
"assets/assets/navigation/track.svg": "b12d601915c801ed6b532e8ab0d046f0",
"assets/assets/navigation/user.svg": "5c8032415b662540335e256222e22a7f",
"assets/assets/ikonate_bold/add.svg": "9d8bd775a02e936aca42d781db7adf66",
"assets/assets/ikonate_bold/activity.svg": "b4c4f9aaafe4641fd3ba6ab350cfa99d",
"assets/assets/ikonate_bold/search.svg": "c53a306539187e3ffee33930f2d94e16",
"assets/assets/ikonate_bold/person.svg": "1d71012426330c4d46fc9e39dc6c97d8",
"assets/assets/ikonate_bold/camera.svg": "30b1309e1a39c6a690e95b851da9592c",
"assets/assets/metadata/init_preferences_en.json": "57c34fe43400c25181fa4206fdebb413",
"assets/assets/metadata/init_attribute_groups_en.json": "48b51db9108cb16ed6df24e89ca62448",
"assets/assets/product/product_not_found.svg": "97a08cb1eae014e79a70436b01cf30d2",
"assets/assets/product/missing_image.svg": "0a5281d9f72e4272e0453cc9b7cfc932",
"assets/assets/ikonate_thin/add.svg": "d255ee69c8962bf447b0c03d58a24034",
"assets/assets/ikonate_thin/activity.svg": "8594262e62b54c11adcf2cd9ac1360f2",
"assets/assets/ikonate_thin/search.svg": "788ea985caa946d6cc1e859c68443fae",
"assets/assets/ikonate_thin/person.svg": "f29d4aa584831fc944a50fd7a01446c9",
"assets/assets/ikonate_thin/maximise.svg": "d1882cf49ba9363e50aca9ce505276f8",
"assets/assets/ikonate_thin/camera.svg": "35b362b5acec3f4d0d4765e96dbf34f0",
"assets/assets/actions/preferences.svg": "23db135d9751aa918387801e98886fb0",
"assets/assets/actions/scanner_alt_1.svg": "533063311fc6fcb6cfcd7c5ffe0e5b37",
"assets/assets/actions/qr_code.svg": "59a1aa7ee1c991c744169dd52f49bc55",
"assets/assets/actions/scanner_alt_3.svg": "01942799ad98b2b2811f959cf478bec7",
"assets/assets/actions/scanner.svg": "ee45ec1fef65bd9b3c316b2031ee9b00",
"assets/assets/actions/smoothie.svg": "251f267a5c6a4c7d3deccd080837f541",
"assets/assets/actions/scanner_alt_2.svg": "6af5ea2eb23698ced84269bc023ab2f9",
"assets/assets/actions/food-cog.svg": "d1423b6a3277220b6e61cff8e8329cff",
"assets/assets/actions/camera.svg": "ef8664a97bdacf10829020f9e7f92259",
"assets/assets/misc/checkmark.svg": "31920c1a628d617319042f45bdf595b2",
"assets/assets/misc/work_in_progress_alt.svg": "a44ac910d7920e0a7f541b4d4855548d",
"assets/assets/misc/work_in_progress.svg": "09d9e740b4b184e9e8b0269a84839520",
"assets/assets/misc/right_arrow.svg": "87b33e97487ec9f166d3ec66e40b5c67",
"assets/assets/misc/information.svg": "cd833150b39375bdc164bcd04451195e",
"assets/assets/misc/work_in_progress_alt_3.svg": "dc1ee41a0e40a49533cc35f5c00f7f73",
"assets/assets/misc/work_in_progress_alt_2.svg": "f1301e2cd2dd1541ed6b2645092d38d1",
"assets/assets/cache/nova-group-unknown.svg": "f94a547082069ae740b6bc6a52e60834",
"assets/assets/cache/ecoscore-a.svg": "ed9ecc4d0a03b5acdbd94a1d57b03bb0",
"assets/assets/cache/no-eggs.svg": "879724cee652ff714601327bb258cde3",
"assets/assets/cache/may-contain-milk.svg": "18fe57a2d9d74a946e1ea4bbd9f17527",
"assets/assets/cache/may-contain-molluscs.svg": "157cfc8c7ae743c20866271dec07fcc9",
"assets/assets/cache/no-sesame-seeds.svg": "38c5f28d16ac7cf162213cdfdf40a66b",
"assets/assets/cache/forest-footprint-d.svg": "0cbca5d28d8c83fad1ef0ab3090ad4b3",
"assets/assets/cache/maybe-vegan.svg": "b4bbb1c165cce3d2f474df9431f3a530",
"assets/assets/cache/may-contain-gluten.svg": "c83022eb5b162fd5f5db53b9a182cec7",
"assets/assets/cache/3-additives.svg": "cc2c19061cb6dcb19f50053788c21c90",
"assets/assets/cache/crustaceans-content-unknown.svg": "f96e470e740663ca498efe927d2d5c00",
"assets/assets/cache/contains-fish.svg": "aca840b03d4cb1355e8c8bd82ff3197d",
"assets/assets/cache/forest-footprint-a.svg": "f8e45467458b8793d3d6e6d4d647eef2",
"assets/assets/cache/contains-lupin.svg": "f6bbfbd260e8c188be093adf975cb162",
"assets/assets/cache/molluscs-content-unknown.svg": "9225840b2ba2c0a21e3f66346efd3606",
"assets/assets/cache/contains-molluscs.svg": "cef2379d1d377e172caed8ebaf9ae336",
"assets/assets/cache/ecoscore-unknown.svg": "81d46c2a7d2c2240af7e73793a3d61e0",
"assets/assets/cache/forest-footprint-not-computed.svg": "97979255cb6253f358024f18eb5d20c4",
"assets/assets/cache/no-crustaceans.svg": "e359435b81b1348b1c14faf0335d1a46",
"assets/assets/cache/no-celery.svg": "3cf1558f963b6a000dbe5a0e7ecba7b4",
"assets/assets/cache/no-fish.svg": "8a136b53f73759af64517aaf409e3030",
"assets/assets/cache/may-contain-palm-oil.svg": "ac685961fdf32434f7ce4af1e9243b5d",
"assets/assets/cache/fair-trade.svg": "c99300beb43c7760e0ecbfe33f3a21c5",
"assets/assets/cache/mustard-content-unknown.svg": "c2f20cf68903b2d8ff8ffcf29c7c2f36",
"assets/assets/cache/may-contain-sulphur-dioxide-and-sulphites.svg": "193c3e8dcbeb8f74efa3c09c453ab4e3",
"assets/assets/cache/nova-group-4.svg": "0a4959e3512582da5c6f40c2ce9ad8c4",
"assets/assets/cache/nutrient-level-sugars-low.svg": "f4fdedc9af4e30296afd3e88517da833",
"assets/assets/cache/contains-sesame-seeds.svg": "5548de6fe1ac2d9b642925a9b0a220d4",
"assets/assets/cache/vegan.svg": "65c7d6bdd2209b4eebce615ec773b022",
"assets/assets/cache/nutriscore-c.svg": "d2903f9368538b7f795d5c44d29cfdd2",
"assets/assets/cache/may-contain-soybeans.svg": "fd75cc0d6676e04ad2e39a93acc78645",
"assets/assets/cache/nutrient-level-salt-high.svg": "e7e987ae75a985fae6ce34d9aa576eb2",
"assets/assets/cache/nuts-content-unknown.svg": "0e77219bcd20f4ab970c65cb05a2cacf",
"assets/assets/cache/non-vegan.svg": "28b0fbc347021ce08e540ba706e6d012",
"assets/assets/cache/may-contain-sesame-seeds.svg": "897f82dab886c01ad77e0c9eca304782",
"assets/assets/cache/7-additives.svg": "c4e361ef64e143ba5ae051429493d7df",
"assets/assets/cache/nutriscore-b.svg": "10ca9053129b7d98c791eadeb2ebf8ce",
"assets/assets/cache/organic.svg": "6f14989733ec53b9ad96dda70d5a3826",
"assets/assets/cache/2-additives.svg": "cb02a3b6dacdd243090672978362ca5f",
"assets/assets/cache/1-additives.svg": "a9b1e92cdfeeee4cf57f8436b07cfd6b",
"assets/assets/cache/nutrient-level-saturated-fat-high.svg": "026fa01401d14f465bf1c3f092fda6bb",
"assets/assets/cache/no-nuts.svg": "732c50051eb6029a1c4960e9098e2388",
"assets/assets/cache/celery-content-unknown.svg": "c6b1d7eb8499df8ad08e092f2f1034b8",
"assets/assets/cache/maybe-vegetarian.svg": "449345bdc6e62e09e44dcfe787ba623d",
"assets/assets/cache/nutrient-level-sugars-high.svg": "2ce5c90136f5223ed394d60f1d9a6434",
"assets/assets/cache/vegetarian-status-unknown.svg": "364240b35ecd872768cc64c0ee4865f7",
"assets/assets/cache/sulphur-dioxide-and-sulphites-content-unknown.svg": "819550d6facf6442dbdf258700031490",
"assets/assets/cache/peanuts-content-unknown.svg": "a4aaeef70c43c583f82541e0969849a3",
"assets/assets/cache/no-gluten.svg": "556113b1581d4eb38510314b4814fc86",
"assets/assets/cache/eggs-content-unknown.svg": "43860f0ec9c2a1d8c901764ef0fad056",
"assets/assets/cache/contains-palm-oil.svg": "44724daa0cf1654fda1615ed45222141",
"assets/assets/cache/may-contain-fish.svg": "a300ac7f7f531e5fd6f68b2c23598834",
"assets/assets/cache/contains-gluten.svg": "7fb635dd316820331e2e4199143882a7",
"assets/assets/cache/may-contain-peanuts.svg": "7f622e7e00fcb9cee6c2964b3e46f4f7",
"assets/assets/cache/may-contain-eggs.svg": "1f84a84068156026f459e509a43dc8e6",
"assets/assets/cache/contains-eggs.svg": "7e53d7f2c9688d51afdc6d91b15bfd54",
"assets/assets/cache/palm-oil-content-unknown.svg": "9bf56b8e080e542562e17e7e14ad49f2",
"assets/assets/cache/no-lupin.svg": "93cb6f05715ca2e636368988c615009b",
"assets/assets/cache/10-additives.svg": "4410fde6669c2c191afd561344cf80d5",
"assets/assets/cache/may-contain-nuts.svg": "5c47248db3c3cf4fbe304bfa97abac92",
"assets/assets/cache/nutrient-level-fat-medium.svg": "3ceed34d3a01a5428de824e83fb566f6",
"assets/assets/cache/nutrient-level-salt-low.svg": "6fedb3c72d896232309d4fa6780ffc31",
"assets/assets/cache/organic-unknown.svg": "578164f131d4536abb959fb196aa3829",
"assets/assets/cache/contains-mustard.svg": "67b5c8031b15eda9ba0657c39606e5c5",
"assets/assets/cache/4-additives.svg": "faa03ea279de46b45df1cb0daadbb8b1",
"assets/assets/cache/nutrient-level-sugars-medium.svg": "8618c72045ef5e51e44fe7f108e483dc",
"assets/assets/cache/no-milk.svg": "ce0a3dd71d1aa5f5d27a8ec27d70da00",
"assets/assets/cache/lupin-content-unknown.svg": "95304e7f7e167a94f9e04aad0cdb1fe0",
"assets/assets/cache/may-contain-mustard.svg": "a1138921cf41870b3f3417c8f8c1d6dc",
"assets/assets/cache/palm-oil-free.svg": "d88b823332c6d041f62df03dbdfe5f96",
"assets/assets/cache/may-contain-celery.svg": "d3dc716e70f72e2c5a059317f22d2dea",
"assets/assets/cache/ecoscore-d.svg": "cd29c9603d698c09874d895e2c5b1e6b",
"assets/assets/cache/forest-footprint-e.svg": "840b2e00904a217389f49d73599884aa",
"assets/assets/cache/no-sulphur-dioxide-and-sulphites.svg": "8f50c362a5466e759ae9c19543e90a57",
"assets/assets/cache/nutriscore-d.svg": "2f2ff82230afe2ef0c8b192e5448974d",
"assets/assets/cache/contains-nuts.svg": "aff464919d8b45b7400636dbf01361c4",
"assets/assets/cache/ecoscore-c.svg": "73d2b4355efe3aca6225abc1fefe5353",
"assets/assets/cache/fair-trade-unknown.svg": "62db521c3fc0717103586178b2b454ba",
"assets/assets/cache/contains-celery.svg": "96860eb5d6d6b4f75d925485166b2269",
"assets/assets/cache/8-additives.svg": "c4fd97733d0e4c23aaa63f6305b47b53",
"assets/assets/cache/nutrient-level-saturated-fat-medium.svg": "3be17dd003d529daeec345217019a3d5",
"assets/assets/cache/9-additives.svg": "603a414c5fac3f7f5446605b87fdd38f",
"assets/assets/cache/forest-footprint-unknown.svg": "97979255cb6253f358024f18eb5d20c4",
"assets/assets/cache/soybeans-content-unknown.svg": "f7ce753f568c7fb22b887053815c8ccc",
"assets/assets/cache/0-additives.svg": "a2b1689533a3d2bda9fc872bf1e0ba01",
"assets/assets/cache/nutrient-level-salt-unknown.svg": "9cc507bb71d14f1c1c1016b3595103ad",
"assets/assets/cache/fish-content-unknown.svg": "be86c36ce36da49dabdd96855138bed4",
"assets/assets/cache/not-fair-trade.svg": "1a139119128d6655208cd8c0bee52298",
"assets/assets/cache/ecoscore-b.svg": "ea4a33e49932ea69507bb9213d42d3ba",
"assets/assets/cache/nutrient-level-salt-medium.svg": "9e9aaa012a1549f8c959bce46b6f87ce",
"assets/assets/cache/gluten-content-unknown.svg": "23ef73885d4d6ce015d85e352b4ae24e",
"assets/assets/cache/no-mustard.svg": "aeef50e6bd5a9af1a97559d209eeb2b0",
"assets/assets/cache/ecoscore-e.svg": "61d7a879c798236c015e8cad6134b76b",
"assets/assets/cache/nutrient-level-sugars-unknown.svg": "a401fbe05219bd4b7b6c899a68fcc676",
"assets/assets/cache/nutriscore-a.svg": "b007e87ee40a79d2871d1656d8db46e4",
"assets/assets/cache/nova-group-1.svg": "9d963437c6cd6d81bed02b0796f33dd4",
"assets/assets/cache/6-additives.svg": "e81775e4808ace5cdc7c548921e67eab",
"assets/assets/cache/additives-unknown.svg": "0acec4ab97d4c131c8b21c82fd17385e",
"assets/assets/cache/nutriscore-unknown.svg": "9b230e0328cbeb31541438ce8589a6cb",
"assets/assets/cache/contains-crustaceans.svg": "b65fc0bc64c696739df81ae702af238d",
"assets/assets/cache/nutrient-level-saturated-fat-low.svg": "fe1e3a07372265c04e88dc190fac2e67",
"assets/assets/cache/milk-content-unknown.svg": "2750540fd74038457240700d935ac316",
"assets/assets/cache/no-peanuts.svg": "acd3b0094e9d69b9125d70e7ef25136b",
"assets/assets/cache/forest-footprint-c.svg": "812f54ae853cbf88105f2c6f64f414d6",
"assets/assets/cache/no-soybeans.svg": "c13020ad10ca1ac989903342e0004c14",
"assets/assets/cache/no-molluscs.svg": "6490a956300a2c0f6b8217af271b14db",
"assets/assets/cache/contains-peanuts.svg": "3a7a084136574842f60789d625e306a7",
"assets/assets/cache/nova-group-3.svg": "6bd941b3eadb988aecb31dcc43c0f40f",
"assets/assets/cache/contains-sulphur-dioxide-and-sulphites.svg": "779984452cc43d9cae58489d18ab15e5",
"assets/assets/cache/may-contain-lupin.svg": "58db55d1bce54c75d6e6ace86484628f",
"assets/assets/cache/nova-group-2.svg": "e508d6ec8f9bb3a2797ba32ed43fee20",
"assets/assets/cache/nutrient-level-fat-high.svg": "dcef5f2a921f8b60f3f0f430b424676f",
"assets/assets/cache/5-additives.svg": "8673dfd2e5c90d01fe479b16cdb0db52",
"assets/assets/cache/contains-milk.svg": "86b8c808838dc8bb6cc3263fabd42c3d",
"assets/assets/cache/not-organic.svg": "3622db37eb44350bbd4b5f7b14e27371",
"assets/assets/cache/nutrient-level-fat-unknown.svg": "dee8c61b3a70cb7b9224daa6f301ab8a",
"assets/assets/cache/sesame-seeds-content-unknown.svg": "f3b27e35242b28bee90cc7e0db990323",
"assets/assets/cache/contains-soybeans.svg": "ee9c36bcff6cf4f4c70d7f8d5d30965c",
"assets/assets/cache/nutrient-level-saturated-fat-unknown.svg": "1f6a61a8670722087c399abc8ccfad03",
"assets/assets/cache/nutriscore-e.svg": "0faa62358f3bea75c94ea0a23757548c",
"assets/assets/cache/forest-footprint-b.svg": "eb4642eb54af8351d657531ecf2db865",
"assets/assets/cache/non-vegetarian.svg": "187304338dbc78fbad92ec564598dee4",
"assets/assets/cache/may-contain-crustaceans.svg": "4bf3a07e78205740c45852c33d74445f",
"assets/assets/cache/nutrient-level-fat-low.svg": "a942f519f2e4879737183bdf04c61d7e",
"assets/assets/cache/vegan-status-unknown.svg": "f7594b206e20a3458ad6f850a19906ef",
"assets/assets/cache/vegetarian.svg": "5dccb8fcfefc9413973d339923c85405",
"assets/fonts/MaterialIcons-Regular.otf": "1288c9e28052e028aba623321f7826ac",
"assets/AssetManifest.json": "6cb601e5b38f16440e46c02ef101e144",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "6d342eb68f170c97609e9da345464e5e",
"assets/packages/smooth_ui_library/assets/icons/search.svg": "375983b1e0dad3c0f0d1a4f2f7d6128e",
"assets/packages/smooth_ui_library/assets/product/missing_image.svg": "0a5281d9f72e4272e0453cc9b7cfc932",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"index.html": "ac9f5e9636d2a31bec890d8464b9b5b2",
"/": "ac9f5e9636d2a31bec890d8464b9b5b2",
"main.dart.js": "bcdc38460ece65c339a53d8449544ea5",
"version.json": "e8a19df4cf7dc414b97a48cc551820cc",
"favicon.png": "5dcef449791fa27946b3d35ad8803796"
};

// The application shell files that are downloaded before a service worker can
// start.
const CORE = [
  "/",
"main.dart.js",
"index.html",
"assets/NOTICES",
"assets/AssetManifest.json",
"assets/FontManifest.json"];
// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value + '?revision=' + RESOURCES[value], {'cache': 'reload'})));
    })
  );
});

// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});

// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache.
        return response || fetch(event.request).then((response) => {
          cache.put(event.request, response.clone());
          return response;
        });
      })
    })
  );
});

self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});

// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}

// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
