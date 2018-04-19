load(
    "@rules_scala_annex//rules:internal/workspace_internal.bzl",
    "annex_configure_scala_repository_implementation",
)
load("@rules_scala_annex//rules:internal/utils.bzl", "safe_name")
load("//3rdparty:workspace.bzl", "maven_dependencies")
load("//3rdparty:scalafmt_workspace.bzl", scalafmt_maven_dependencies = "maven_dependencies")

annex_configure_scala_repository = repository_rule(
    implementation = annex_configure_scala_repository_implementation,
    attrs = {
        "compiler_bridge": attr.string(),
        "organization": attr.string(),
        "version": attr.string(),
    },
)

def annex_scala_repositories():
    maven_dependencies()
    scalafmt_maven_dependencies()

    BAZEL_JAVA_LAUNCHER_VERSION = "0.11.1"
    java_stub_template_url = (
        "raw.githubusercontent.com/bazelbuild/bazel/" +
        BAZEL_JAVA_LAUNCHER_VERSION +
        "/src/main/java/com/google/devtools/build/lib/bazel/rules/java/" +
        "java_stub_template.txt"
    )

    native.http_file(
        name = "anx_java_stub_template",
        urls = [
            "https://mirror.bazel.build/%s" % java_stub_template_url,
            "https://%s" % java_stub_template_url,
        ],
        sha256 = "2cbba7c512e400df0e7d4376e667724a38d1155db5baaa81b72ad785c6d761d1",
    )

    scala_src_build = """filegroup(name = "src", srcs = glob(["**/*.scala", "**/*.java"]), visibility=["//visibility:public"])"""

    native.new_http_archive(
        name = "compiler_bridge_2_11",
        build_file_content = scala_src_build,
        sha256 = "a3fda3b74ad549e5234ecad73847856607d42f3866890fa8f2b48130eaf303ce",
        url = "http://central.maven.org/maven2/org/scala-sbt/compiler-bridge_2.11/1.1.3/compiler-bridge_2.11-1.1.3-sources.jar",
    )

    native.new_http_archive(
        name = "compiler_bridge_2_12",
        build_file_content = scala_src_build,
        sha256 = "cec8a3423b04c1ac8060a7de21ca14fb0461186aa0256ddf0602f4f8fcb6c6d0",
        url = "http://central.maven.org/maven2/org/scala-sbt/compiler-bridge_2.12/1.1.3/compiler-bridge_2.12-1.1.3-sources.jar",
    )

def annex_scala_repository(name, coordinates, compiler_bridge):
    annex_configure_scala_repository(
        name = name,
        compiler_bridge = compiler_bridge,
        version = coordinates[1],
    )

    organization, version = coordinates

    native.maven_jar(
        name = "{}_scala_compiler".format(name),
        artifact = "%s:scala-compiler:%s" % (organization, version),
    )

    native.maven_jar(
        name = "{}_scala_library".format(name),
        artifact = "%s:scala-library:%s" % (organization, version),
    )

    native.maven_jar(
        name = "{}_scala_reflect".format(name),
        artifact = "%s:scala-reflect:%s" % (organization, version),
    )

def scalafmt_default_config(path = ".scalafmt.conf"):
    build = []
    build.append("filegroup(")
    build.append("    name = \"config\",")
    build.append("    srcs = [\"{}\"],".format(path))
    build.append("    visibility = [\"//visibility:public\"],")
    build.append(")")
    native.new_local_repository(name = "scalafmt_default", build_file_content = "\n".join(build), path = "")
