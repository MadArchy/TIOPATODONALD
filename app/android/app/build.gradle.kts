import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Aplica Google Services automáticamente cuando exista google-services.json
// (generado por `flutterfire configure` para dev/prod).
val tieneGoogleServices = listOf(
    file("google-services.json"),
    file("src/dev/google-services.json"),
    file("src/prod/google-services.json"),
).any { it.exists() }
if (tieneGoogleServices) {
    apply(plugin = "com.google.gms.google-services")
}

// Firma de release desde app/android/key.properties (ignorado en git).
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
val tieneKeystoreRelease = keystorePropertiesFile.exists()
if (tieneKeystoreRelease) {
    FileInputStream(keystorePropertiesFile).use { keystoreProperties.load(it) }
}

android {
    namespace = "co.patodonald.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    buildFeatures {
        resValues = true
    }

    defaultConfig {
        applicationId = "co.patodonald.app"
        minSdk = maxOf(flutter.minSdkVersion, 23)
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    flavorDimensions += "env"
    productFlavors {
        create("dev") {
            dimension = "env"
            applicationIdSuffix = ".dev"
            versionNameSuffix = "-dev"
            resValue("string", "app_name", "PATO DONALD (Dev)")
        }
        create("prod") {
            dimension = "env"
            resValue("string", "app_name", "PATO DONALD")
        }
    }

    signingConfigs {
        if (tieneKeystoreRelease) {
            create("release") {
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                storeFile = file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (tieneKeystoreRelease) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
