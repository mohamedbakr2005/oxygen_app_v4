plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
}

import java.util.Properties
import java.io.FileInputStream

val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localProperties.load(localPropertiesFile.reader(Charsets.UTF_8))
}

var flutterVersionCode = localProperties.getProperty("flutter.versionCode") ?: "2"
var flutterVersionName = localProperties.getProperty("flutter.versionName") ?: "2.0"

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.oxygenmart.app"
    compileSdk = 36
    ndkVersion = "29.0.14206865"

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    

    kotlinOptions {
        jvmTarget = "11"
    }

    sourceSets["main"].java.srcDirs("src/main/kotlin")

    defaultConfig {
    applicationId = "com.oxygenmart.app"
    minSdk = flutter.minSdkVersion
    targetSdk = 36
    versionCode = flutterVersionCode.toInt()
    versionName = flutterVersionName
    multiDexEnabled = true

    externalNativeBuild {
        cmake {
            arguments += listOf(
                "-DANDROID_SUPPORT_FLEXIBLE_PAGE_SIZES=ON",
                "-DANDROID_USE_LEGACY_PAGE_SIZE=OFF"
            )
        }
    }
}

    packagingOptions {
      jniLibs {
        useLegacyPackaging = false
      }
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String?
        }
    }

    buildTypes {
    release {
        signingConfig = signingConfigs.getByName("release")

        isMinifyEnabled = true
        isShrinkResources = true

        proguardFiles(
            getDefaultProguardFile("proguard-android-optimize.txt"),
            "proguard-rules.pro"
        )
    }
}

}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    implementation("com.google.firebase:firebase-messaging:23.4.1")
    implementation("com.android.installreferrer:installreferrer:2.2")
    implementation("org.slf4j:slf4j-simple:2.0.9")
}
