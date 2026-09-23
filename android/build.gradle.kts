allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Google Services classpath
        classpath("com.google.gms:google-services:4.4.0")
        classpath("com.android.tools.build:gradle:9.0.1")
    }
}

// بدل rootProject.buildDir = '../build'
val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()

rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {

    // مكان buildDir لكل module
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)

    // نفس شرط afterEvaluate بتاع compileSdk
    afterEvaluate {
        if (project.plugins.hasPlugin("com.android.application") ||
            project.plugins.hasPlugin("com.android.library")
        ) {
            project.extensions.configure<com.android.build.gradle.BaseExtension> {
                compileSdkVersion(36)
                buildToolsVersion("34.0.0")
            }
        }

        if (project.extensions.findByName("android") != null) {
            project.extensions.configure<com.android.build.gradle.BaseExtension> {
                if (namespace == null) {
                    namespace = project.group.toString()
                }
            }
        }
    }
}

// نفس السطر
subprojects {
    evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
