allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Patch pour Isar : ajouter le namespace manquant pour AGP 8+
subprojects {
    afterEvaluate {
        if (project.name == "isar_flutter_libs") {
            extensions.findByType<com.android.build.gradle.LibraryExtension>()?.apply {
                namespace = "dev.isar.isar_flutter_libs"
            }
        }
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
