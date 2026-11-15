plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.divergia.divergia_app"
    // flutter_secure_storage exige compileSdk 37 — a versão default do
    // Flutter (flutter.compileSdkVersion) ainda aponta para 36.
    compileSdk = 37
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.divergia.divergia_app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        // Build de depuração instala ao lado do app oficial, sem substituí-lo nem apagar a sessão.
        debug {
            applicationIdSuffix = ".dev"
        }
        release {
            // Build de distribuição fora da loja (homologação): DIVERGIA_APP_ID_SUFFIX=.dev instala ao lado
            // do app oficial e reaproveita o cliente Android do Google já autorizado. Vazio = pacote oficial.
            applicationIdSuffix = System.getenv("DIVERGIA_APP_ID_SUFFIX") ?: ""
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
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
