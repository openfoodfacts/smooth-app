allprojects {
    repositories {
        google()
        mavenCentral()
    }
    subprojects {
        afterEvaluate {
            if (hasProperty("android")) {
                val androidExtension = extensions.findByName("android")
                if (androidExtension != null && androidExtension is com.android.build.gradle.BaseExtension) {
                    if (androidExtension.namespace == null) {
                        androidExtension.namespace = group.toString() // Set namespace as fallback
                    }

                    tasks.whenTaskAdded {
                        if (name.contains("processDebugManifest") || name.contains("processReleaseManifest")) {
                            doFirst {
                                val manifestFile = file("${projectDir}/src/main/AndroidManifest.xml")
                                if (manifestFile.exists()) {
                                    var manifestContent = manifestFile.readText()
                                    if (manifestContent.contains("package=")) {
                                        manifestContent = manifestContent.replace(Regex("package=\"[^\"]*\""), "")
                                        manifestFile.writeText(manifestContent)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
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
