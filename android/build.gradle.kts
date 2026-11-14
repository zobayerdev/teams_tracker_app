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
    project.evaluationDependsOn(":app")
}

subprojects {
    plugins.withId("com.android.library") {
        val android = project.extensions.findByName("android")
        if (android != null) {
            try {
                val getNamespace = android.javaClass.getMethod("getNamespace")
                if (getNamespace.invoke(android) == null) {
                    val setNamespace = android.javaClass.getMethod("setNamespace", String::class.java)
                    setNamespace.invoke(android, "com.example.${project.name.replace('-', '_')}")
                }
            } catch (e: Exception) {
            }
        }
    }

    if (project.name == "fluttertoast") {
        afterEvaluate {
            val android = project.extensions.findByName("android")
            if (android != null) {
                try {
                    val method = android.javaClass.methods.firstOrNull { it.name == "compileSdkVersion" && it.parameterTypes.size == 1 && it.parameterTypes[0] == Integer.TYPE }
                    method?.invoke(android, 34)
                } catch (e: Exception) {}
                try {
                    val method = android.javaClass.methods.firstOrNull { it.name == "setCompileSdkVersion" && it.parameterTypes.size == 1 && it.parameterTypes[0] == Integer.TYPE }
                    method?.invoke(android, 34)
                } catch (e: Exception) {}
                try {
                    val method = android.javaClass.methods.firstOrNull { it.name == "setCompileSdk" && it.parameterTypes.size == 1 }
                    method?.invoke(android, 34)
                } catch (e: Exception) {}
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
