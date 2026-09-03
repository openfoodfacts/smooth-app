pluginManagement {
    val flutterSdkPath = run {
        val properties = java.util.Properties()
        file("local.properties").inputStream().use { properties.load(it) }
        val flutterSdkPath = properties.getProperty("flutter.sdk")
        require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
        flutterSdkPath
    }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

// cf. https://docs.flutter.dev/release/breaking-changes/android-java-gradle-migration-guide
// cf. flutter analyze --suggestions
// cf. gradle-wrapper.properties and distributionUrl
// https://kotlinlang.org/docs/gradle-configure-project.html#apply-the-plugin
plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "9.0.0" apply false // AGP
    id("org.jetbrains.kotlin.android") version "2.4.0" apply false // KGP
}

include(":app")
