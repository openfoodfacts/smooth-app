import java.io.FileInputStream
import java.util.Properties
import org.jetbrains.kotlin.gradle.dsl.JvmTarget
import org.jetbrains.kotlin.gradle.dsl.KotlinVersion

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

kotlin {
    compilerOptions {
        jvmTarget = JvmTarget.fromTarget("17")
    }
}

android {
    namespace = "org.openfoodfacts.app"
    compileSdk = maxOf(flutter.compileSdkVersion, 37)
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        applicationId = "org.openfoodfacts.scanner"
        // sentry_flutter 10+ requires Android API 26+ (Android 8.0) for both debug and release builds.
        val minSdkOverride = project.findProperty("minSdk")?.toString()?.toIntOrNull()
        minSdk = minSdkOverride ?: maxOf(flutter.minSdkVersion, 26)
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
        // Custom scheme for the Keycloak OIDC redirect
        // (must match KeycloakAuthService.redirectUrl).
        manifestPlaceholders["appAuthRedirectScheme"] = "org.openfoodfacts.app"
    }

    signingConfigs {
        create("release") {
            storeFile = System.getenv("SIGN_STORE_PATH")?.let { file(it) }
            storePassword = System.getenv("SIGN_STORE_PASSWORD")
            keyAlias = System.getenv("SIGN_KEY_ALIAS")
            keyPassword = System.getenv("SIGN_KEY_PASSWORD")
        }
    }

    buildTypes {
        debug {
            signingConfig = signingConfigs.getByName("debug")
        }
        release {
            signingConfig = if (System.getenv("SIGN_STORE_PATH") != null) {
                signingConfigs.getByName("release")
            } else {
                null
            }
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}
