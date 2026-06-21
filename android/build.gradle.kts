allprojects {
    repositories {
        google()
        mavenCentral()
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
    afterEvaluate {
        if (extensions.findByName("android") != null) {
            configure<com.android.build.gradle.BaseExtension> {
                if (namespace == null) {
                    namespace = "com.example.${project.name.replace("-", "_").replace(".", "_")}"
                }
            }

            // Automatically strip package attribute from third-party plugins' AndroidManifest.xml to comply with AGP 8+
            if (project.name != "app") {
                val manifestFile = file("src/main/AndroidManifest.xml")
                if (manifestFile.exists()) {
                    try {
                        var content = manifestFile.readText()
                        if (content.contains("package=")) {
                            content = content.replace(Regex("""\s+package="[^"]*""""), "")
                            manifestFile.writeText(content)
                            project.logger.lifecycle("Stripped package attribute from ${project.name}'s AndroidManifest.xml")
                        }
                    } catch (e: Exception) {
                        project.logger.warn("Failed to strip package attribute from ${project.name}: ${e.message}")
                    }
                }
            }
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
