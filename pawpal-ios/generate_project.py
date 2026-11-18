#!/usr/bin/env python3
"""生成 Summer 的 Xcode 项目文件（无需 xcodegen）。"""
import os, uuid

ROOT = os.path.dirname(os.path.abspath(__file__))
SRC = os.path.join(ROOT, "Summer")
PROJ = os.path.join(ROOT, "Summer.xcodeproj")
os.makedirs(PROJ, exist_ok=True)

def uid(s):
    # 稳定的 24 位十六进制 ID
    import hashlib
    return hashlib.md5(s.encode()).hexdigest().upper()[:24]

swift_files = []
for dirpath, _, files in os.walk(SRC):
    for f in sorted(files):
        if f.endswith(".swift"):
            swift_files.append(os.path.relpath(os.path.join(dirpath, f), ROOT))
swift_files.sort()
# 资源使用 Asset Catalog（Image("hero") 等通过它解析）
asset_catalog = "Summer/Resources/Assets.xcassets"
resource_paths = [asset_catalog]

all_files = swift_files + resource_paths

# --- 对象定义 ---
objects = {}

def add(oid, isa, fields):
    lines = [f"\t\t{oid} /* {fields.pop('_name', isa)} */ = {{"]
    lines.append(f"\t\t\tisa = {isa};")
    for k, v in fields.items():
        lines.append(f"\t\t\t{k} = {v};")
    lines.append("\t\t};")
    objects[oid] = "\n".join(lines)

# 文件引用
file_refs = {}
for path in all_files:
    oid = uid("file:" + path)
    name = os.path.basename(path)
    ftype = "sourcecode.swift" if path.endswith(".swift") else "folder.assetcatalog"
    add(oid, "PBXFileReference", {
        "_name": name,
        "lastKnownFileType": ftype,
        "name": f'"{name}"',
        "path": f'"{name}"',
        "sourceTree": '"<group>"',
    })
    file_refs[path] = oid

# 构建文件
build_files = {}
for path in all_files:
    oid = uid("build:" + path)
    add(oid, "PBXBuildFile", {"_name": os.path.basename(path), "fileRef": f"{file_refs[path]} /* {os.path.basename(path)} */"})
    build_files[path] = oid

src_build = " ".join(f"{build_files[p]} /* {os.path.basename(p)} in Sources */," for p in swift_files)
res_build = "\n\t\t\t".join(f"{build_files[p]} /* {os.path.basename(p)} in Resources */," for p in resource_paths)

# 分组
main_group = uid("group:main")
src_group = uid("group:src")
res_group = uid("group:res")
products = uid("group:products")

src_children = "\n\t\t\t".join(f"{file_refs[p]} /* {os.path.basename(p)} */," for p in swift_files)
res_children = "\n\t\t\t".join(f"{file_refs[p]} /* {os.path.basename(p)} */," for p in resource_paths)

def arr(items):
    return "(\n\t\t\t" + items + "\n\t\t)"

add(main_group, "PBXGroup", {
    "_name": "Main Group",
    "children": arr(f"{src_group} /* Summer */,\n\t\t\t{products} /* Products */,"),
    "sourceTree": '"<group>"',
})
add(src_group, "PBXGroup", {
    "_name": "Summer",
    "children": arr(f"{src_children}\n\t\t\t{res_group} /* Resources */,"),
    "path": '"Summer"',
    "sourceTree": '"<group>"',
})
add(res_group, "PBXGroup", {
    "_name": "Resources",
    "children": arr(res_children),
    "path": '"Resources"',
    "sourceTree": '"<group>"',
})
add(products, "PBXGroup", {
    "_name": "Products",
    "children": arr(f"{uid('file:product')} /* Summer.app */,"),
    "sourceTree": '"<group>"',
})

product_ref = uid("file:product")
add(product_ref, "PBXFileReference", {
    "_name": "Summer.app",
    "explicitFileType": '"wrapper.application"',
    "includeInIndex": "0",
    "path": '"Summer.app"',
    "sourceTree": '"BUILT_PRODUCTS_DIR"',
})

# 构建阶段
sources_phase = uid("phase:sources")
frameworks_phase = uid("phase:frameworks")
resources_phase = uid("phase:resources")
add(sources_phase, "PBXSourcesBuildPhase", {
    "_name": "Sources",
    "buildActionMask": "2147483647",
    "files": arr(src_build),
    "runOnlyForDeploymentPostprocessing": "0",
})
add(frameworks_phase, "PBXFrameworksBuildPhase", {
    "_name": "Frameworks",
    "buildActionMask": "2147483647",
    "files": "(\n\t\t)",
    "runOnlyForDeploymentPostprocessing": "0",
})
add(resources_phase, "PBXResourcesBuildPhase", {
    "_name": "Resources",
    "buildActionMask": "2147483647",
    "files": arr(res_build),
    "runOnlyForDeploymentPostprocessing": "0",
})

# Target
target = uid("target:summer")
add(target, "PBXNativeTarget", {
    "_name": "Summer",
    "buildConfigurationList": f"{uid('conf:list:target')} /* Build configuration list for PBXNativeTarget \"Summer\" */",
    "buildPhases": arr(f"{sources_phase} /* Sources */,\n\t\t\t{frameworks_phase} /* Frameworks */,\n\t\t\t{resources_phase} /* Resources */,"),
    "buildRules": "(\n\t\t)",
    "dependencies": "(\n\t\t)",
    "name": '"Summer"',
    "productName": '"Summer"',
    "productReference": f"{product_ref} /* Summer.app */",
    "productType": '"com.apple.product-type.application"',
})

project = uid("project")
add(project, "PBXProject", {
    "_name": "Project object",
    "attributes": "{\n\t\t\tBuildIndependentTargetsInParallel = 1;\n\t\t\tLastUpgradeCheck = 2700;\n\t\t\tTargetAttributes = {\n\t\t\t\t" + target + " = {\n\t\t\t\t\tCreatedOnToolsVersion = 27.0;\n\t\t\t\t};\n\t\t\t};\n\t\t}",
    "buildConfigurationList": f"{uid('conf:list:project')} /* Build configuration list for PBXProject \"Summer\" */",
    "compatibilityVersion": '"Xcode 16.0"',
    "developmentRegion": '"en"',
    "hasScannedForEncodings": "0",
    "knownRegions": "(\n\t\t\ten,\n\t\t\tBase,\n\t\t\t\"zh-Hans\",\n\t\t)",
    "mainGroup": f"{main_group} /* Main Group */",
    "productRefGroup": f"{products} /* Products */",
    "projectDirPath": '""',
    "projectRoot": '""',
    "targets": arr(f"{target} /* Summer */,"),
})

def add_config(oid, name, is_target, is_debug):
    common = {
        "_name": name,
        "buildSettings": "{\n" + build_settings(is_target, is_debug) + "\n\t\t\t}",
    }
    add(oid, "XCBuildConfiguration", common)

def build_settings(is_target, is_debug):
    s = [
        ('ASSETCATALOG_COMPILER_APPICON_NAME', '"AppIcon"'),
        ('CODE_SIGN_STYLE', '"Automatic"'),
        ('CURRENT_PROJECT_VERSION', '"1"'),
        ('GENERATE_INFOPLIST_FILE', 'YES'),
        ('INFOPLIST_KEY_UIApplicationSceneManifest_Generation', 'YES'),
        ('INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents', 'YES'),
        ('INFOPLIST_KEY_UILaunchScreen_Generation', 'YES'),
        ('INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad', '"UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight"'),
        ('INFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone', '"UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight"'),
        ('INFOPLIST_KEY_Localization', '"en"'),
        ('PRODUCT_BUNDLE_IDENTIFIER', '"com.summer.walkdog"'),
        ('PRODUCT_NAME', '"$(TARGET_NAME)"'),
        ('SWIFT_EMIT_LOC_STRINGS', 'YES'),
        ('SWIFT_VERSION', '"5.0"'),
        ('TARGETED_DEVICE_FAMILY', '"1,2"'),
        ('IPHONEOS_DEPLOYMENT_TARGET', '"17.0"'),
        ('SDKROOT', '"iphoneos"'),
    ]
    if is_debug:
        s += [('DEBUG_INFORMATION_FORMAT', '"dwarf"'),
              ('ENABLE_TESTABILITY', 'YES'),
              ('GCC_OPTIMIZATION_LEVEL', '0'),
              ('ONLY_ACTIVE_ARCH', 'YES'),
              ('SWIFT_OPTIMIZATION_LEVEL', '"-Onone"')]
    else:
        s += [('DEBUG_INFORMATION_FORMAT', '"dwarf-with-dsym"'),
              ('SWIFT_COMPILATION_MODE', '"wholemodule"'),
              ('SWIFT_OPTIMIZATION_LEVEL', '"-O"'),
              ('VALIDATE_PRODUCT', 'YES')]
    if is_target:
        s.append(('INFOPLIST_KEY_CFBundleDisplayName', '"Summer"'))
    return "\n".join(f"\t\t\t\t{k} = {v};" for k, v in s)

for suffix, dbg in [("Debug", True), ("Release", False)]:
    add_config(uid(f"conf:project:{suffix}"), suffix, False, dbg)
    add_config(uid(f"conf:target:{suffix}"), suffix, True, dbg)

add(uid("conf:list:project"), "XCConfigurationList", {
    "_name": 'Build configuration list for PBXProject "Summer"',
    "buildConfigurations": arr(f"{uid('conf:project:Debug')} /* Debug */,\n\t\t\t{uid('conf:project:Release')} /* Release */,"),
    "defaultConfigurationIsVisible": "0",
    "defaultConfigurationName": '"Release"',
})
add(uid("conf:list:target"), "XCConfigurationList", {
    "_name": 'Build configuration list for PBXNativeTarget "Summer"',
    "buildConfigurations": arr(f"{uid('conf:target:Debug')} /* Debug */,\n\t\t\t{uid('conf:target:Release')} /* Release */,"),
    "defaultConfigurationIsVisible": "0",
    "defaultConfigurationName": '"Release"',
})

header = """// !$*UTF8*$!
{
\tarchiveVersion = 1;
\tclasses = {
\t};
\tobjectVersion = 56;
\tobjects = {

"""
footer = "\t};\n\trootObject = " + project + " /* Project object */;\n}\n"

with open(os.path.join(PROJ, "project.pbxproj"), "w") as f:
    f.write(header)
    for oid in sorted(objects):
        f.write(objects[oid] + "\n")
    f.write(footer)

print("Generated:", os.path.join(PROJ, "project.pbxproj"))
print("Swift files:", len(swift_files))
print("Asset catalogs:", len(resource_paths))
