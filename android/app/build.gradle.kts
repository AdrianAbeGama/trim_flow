import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Lee la API key de Google Maps desde local.properties (no versionado).
val mapsApiKey: String = run {
    val props = Properties()
    val f = rootProject.file("local.properties")
    if (f.exists()) props.load(FileInputStream(f))
    props.getProperty("MAPS_API_KEY") ?: ""
}

android {
    namespace = "com.example.trim_flow"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.trim_flow"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        resValue("string", "app_name", "TrimFlow")
        manifestPlaceholders["MAPS_API_KEY"] = mapsApiKey
    }

    flavorDimensions += "edition"

    productFlavors {
        create("client") {
            dimension = "edition"
            applicationId = "com.trimflow.app"
            resValue("string", "app_name", "TrimFlow")
            manifestPlaceholders["deepLinkScheme"] = "io.supabase.trimflow"
        }
        create("business") {
            dimension = "edition"
            applicationId = "com.trimflow.business"
            resValue("string", "app_name", "TrimFlow Business")
            manifestPlaceholders["deepLinkScheme"] = "io.supabase.trimflowbusiness"
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}
