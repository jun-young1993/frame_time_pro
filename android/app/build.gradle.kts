import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "juny.frame_time_pro"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
        freeCompilerArgs = listOf("-Xlint:-options")
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "juny.frame_time_pro"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            val keyProperties = Properties().apply {
                val file = rootProject.file("key.properties")
                if(file.exists()){
                    load(FileInputStream(file))
                }
            }
            val storeFilePath = keyProperties.getProperty("storeFile")
            val loadedKeyAlias = keyProperties.getProperty("keyAlias")
            val loadedKeyPassword = keyProperties.getProperty("keyPassword")
            val loadedStorePassword = keyProperties.getProperty("storePassword")
            if (storeFilePath.isNullOrEmpty()) {
                throw GradleException("Missing 'storeFile' property in key.properties")
            }

            val storeFileResolved = rootProject.file(storeFilePath)
            if (!storeFileResolved.exists()) {
                throw GradleException("Keystore file specified in 'storeFile' property not found at: ${storeFileResolved.absolutePath}")
            }
            if (loadedKeyAlias.isNullOrEmpty()) {
                throw GradleException("Missing 'keyAlias' property in key.properties")
            }
            if (loadedKeyPassword.isNullOrEmpty()) {
                throw GradleException("Missing 'keyPassword' property in key.properties")
            }
            if (loadedStorePassword.isNullOrEmpty()) {
                throw GradleException("Missing 'storePassword' property in key.properties")
            }

            storeFile = storeFileResolved
            keyAlias = loadedKeyAlias
            keyPassword = loadedKeyPassword
            storePassword = loadedStorePassword
          
        }
    }


    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}
