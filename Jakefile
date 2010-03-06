
require("./common.jake");

var FILE = require("file"),
    SYSTEM = require("system"),
    OS = require("os"),
    jake = require("jake"),
    stream = require("term").stream;

var subprojects = ["Objective-J", "CommonJS", "Foundation", "AppKit", "Tools"];

["build", "clean", "clobber"].forEach(function(aTaskName)
{
    task (aTaskName, function()
    {
        subjake(subprojects, aTaskName);
    });
});

$BUILD_CJS_OBJECTIVE_J_DEBUG_FRAMEWORKS = FILE.join($BUILD_CJS_OBJECTIVE_J, "Frameworks", "Debug");


filedir ($BUILD_CJS_OBJECTIVE_J_DEBUG_FRAMEWORKS, ["debug", "release"], function()
{
    FILE.mkdirs($BUILD_CJS_OBJECTIVE_J_DEBUG_FRAMEWORKS);

    cp_r(FILE.join($BUILD_DIR, "Debug", "Objective-J"), FILE.join($BUILD_CJS_OBJECTIVE_J_DEBUG_FRAMEWORKS, "Objective-J"));
});

$BUILD_CJS_CAPPUCCINO_DEBUG_FRAMEWORKS = FILE.join($BUILD_CJS_CAPPUCCINO, "Frameworks", "Debug");

filedir ($BUILD_CJS_CAPPUCCINO_DEBUG_FRAMEWORKS, ["debug", "release"], function()
{
    FILE.mkdirs($BUILD_CJS_CAPPUCCINO_DEBUG_FRAMEWORKS);

    cp_r(FILE.join($BUILD_DIR, "Debug", "Foundation"), FILE.join($BUILD_CJS_CAPPUCCINO_DEBUG_FRAMEWORKS, "Foundation"));
    cp_r(FILE.join($BUILD_DIR, "Debug", "AppKit"), FILE.join($BUILD_CJS_CAPPUCCINO_DEBUG_FRAMEWORKS, "AppKit"));
    cp_r(FILE.join($BUILD_DIR, "Debug", "BlendKit"), FILE.join($BUILD_CJS_CAPPUCCINO_DEBUG_FRAMEWORKS, "BlendKit"));
});

task ("CommonJS", [$BUILD_CJS_OBJECTIVE_J_DEBUG_FRAMEWORKS, $BUILD_CJS_CAPPUCCINO_DEBUG_FRAMEWORKS, "debug", "release"]);

task ("install", ["CommonJS"], function()
{
    // FIXME: require("narwhal/tusk/install").install({}, $COMMONJS);
    // Doesn't work due to some weird this.print business.
    if (OS.system(["tusk", "install", "--force", $BUILD_CJS_OBJECTIVE_J, $BUILD_CJS_CAPPUCCINO])) {
        stream.print("\0red(Installation failed, possibly because you do not have permissions.\0)");
        stream.print("\0red(Try re-running using '\0yellow(jake sudo-install\0)'.\0)");
        OS.exit(1); //rake abort if ($? != 0)
    }
});

task ("sudo-install", ["CommonJS"], function()
{
    // FIXME: require("narwhal/tusk/install").install({}, $COMMONJS);
    // Doesn't work due to some weird this.print business.
    if (OS.system(["sudo", "tusk", "install", "--force", $BUILD_CJS_OBJECTIVE_J, $BUILD_CJS_CAPPUCCINO]))
    {
        // Attempt a hackish work-around for sudo compiled with the --with-secure-path option
        if (OS.system("sudo bash -c 'source " + getShellConfigFile() + "; tusk install --force " + $BUILD_CJS_OBJECTIVE_J + " " + $BUILD_CJS_CAPPUCCINO + "'"))
            OS.exit(1); //rake abort if ($? != 0)
    }
});

task ("install-symlinks",  function()
{
    installSymlink($BUILD_CJS_OBJECTIVE_J);
    installSymlink($BUILD_CJS_CAPPUCCINO);
});

function installSymlink(sourcePath) {
    var TUSK = require("narwhal/tusk");
    var INSTALL = require("narwhal/tusk/commands/install");

    var packageName = FILE.basename(sourcePath);
    var packageDir = TUSK.getPackagesDirectory().join(packageName);
    stream.print("Symlinking \0cyan(" + packageDir + "\0) to \0cyan(" + sourcePath + "\0)");

    FILE.symlink(sourcePath, packageDir);
    INSTALL.finishInstall(packageDir);
}

// Documentation

$DOCUMENTATION_BUILD = FILE.join($BUILD_DIR, "Documentation");

task ("docs", ["documentation"]);

task ("documentation", function()
{
    if (executableExists("doxygen"))
    {
        if (OS.system(["ruby", FILE.join("Tools", "Documentation", "make_headers")]))
            OS.exit(1); //rake abort if ($? != 0)

        if (OS.system(["doxygen", FILE.join("Tools", "Documentation", "Cappuccino.doxygen")]))
            OS.exit(1); //rake abort if ($? != 0)

        rm_rf($DOCUMENTATION_BUILD);
        mv("debug.txt", FILE.join("Documentation", "debug.txt"));
        mv("Documentation", $DOCUMENTATION_BUILD);
    }
    else
        print("doxygen not installed. skipping documentation generation.");
});

// Downloads

task ("downloads", ["starter_download", "tools_download"]);

$STARTER_README                 = FILE.join('Tools', 'READMEs', 'STARTER-README');
$STARTER_DOWNLOAD               = FILE.join($BUILD_DIR, 'Cappuccino', 'Starter');
$STARTER_DOWNLOAD_APPLICATION   = FILE.join($STARTER_DOWNLOAD, 'NewApplication');
$STARTER_DOWNLOAD_README        = FILE.join($STARTER_DOWNLOAD, 'README');

task ("starter_download", [$STARTER_DOWNLOAD_APPLICATION, $STARTER_DOWNLOAD_README, "documentation"], function()
{
    if (FILE.exists($DOCUMENTATION_BUILD))
    {
        rm_rf(FILE.join($STARTER_DOWNLOAD, 'Documentation'));
        cp_r(FILE.join($DOCUMENTATION_BUILD, 'html', '.'), FILE.join($STARTER_DOWNLOAD, 'Documentation'));
    }
});

filedir ($STARTER_DOWNLOAD_APPLICATION, ["CommonJS"], function()
{
    rm_rf($STARTER_DOWNLOAD_APPLICATION);
    FILE.mkdirs($STARTER_DOWNLOAD);

    if (OS.system(["capp", "gen", $STARTER_DOWNLOAD_APPLICATION, "-t", "Application", "--noconfig"]))
        // FIXME: uncomment this: we get conversion errors
        //OS.exit(1); // rake abort if ($? != 0)
        {}
    // No tools means no objective-j gem
    // FILE.rm(FILE.join($STARTER_DOWNLOAD_APPLICATION, 'Rakefile'))
});

filedir ($STARTER_DOWNLOAD_README, [$STARTER_README], function()
{
    cp($STARTER_README, $STARTER_DOWNLOAD_README);
});

$TOOLS_README                   = FILE.join('Tools', 'READMEs', 'TOOLS-README');
$TOOLS_EDITORS                  = FILE.join('Tools', 'Editors');
$TOOLS_INSTALLER                = FILE.join('Tools', 'Install', 'install-tools');
$TOOLS_DOWNLOAD                 = FILE.join($BUILD_DIR, 'Cappuccino', 'Tools');
$TOOLS_DOWNLOAD_EDITORS         = FILE.join($TOOLS_DOWNLOAD, 'Editors');
$TOOLS_DOWNLOAD_README          = FILE.join($TOOLS_DOWNLOAD, 'README');
$TOOLS_DOWNLOAD_INSTALLER       = FILE.join($TOOLS_DOWNLOAD, 'install-tools');
$TOOLS_DOWNLOAD_COMMONJS        = FILE.join($BUILD_DIR, "Cappuccino", "Tools", "CommonJS", "objective-j");

task ("tools_download", [$TOOLS_DOWNLOAD_EDITORS, $TOOLS_DOWNLOAD_README, $TOOLS_DOWNLOAD_INSTALLER, $TOOLS_DOWNLOAD_COMMONJS]);

filedir ($TOOLS_DOWNLOAD_EDITORS, [$TOOLS_EDITORS], function()
{
    cp_r(FILE.join($TOOLS_EDITORS, '.'), $TOOLS_DOWNLOAD_EDITORS);
});

filedir ($TOOLS_DOWNLOAD_README, [$TOOLS_README], function()
{
    cp($TOOLS_README, $TOOLS_DOWNLOAD_README);
});

filedir ($TOOLS_DOWNLOAD_INSTALLER, [$TOOLS_INSTALLER], function()
{
    cp($TOOLS_INSTALLER, $TOOLS_DOWNLOAD_INSTALLER);
});

filedir ($TOOLS_DOWNLOAD_COMMONJS, ["CommonJS"], function()
{
    rm_rf($TOOLS_DOWNLOAD_COMMONJS);
    cp_r($COMMONJS_PRODUCT, $TOOLS_DOWNLOAD_COMMONJS);
});

// Deployment

task ("deploy", ["downloads"], function()
{
    var cappuccino_output_path = FILE.join($BUILD_DIR, 'Cappuccino');

    // zip the starter pack
    var starter_zip_output = FILE.join($BUILD_DIR, 'Cappuccino', 'Starter.zip');
    rm_rf(starter_zip_output);

    OS.system("cd " + OS.enquote(cappuccino_output_path) + " && zip -ry -8 Starter.zip Starter");

    // zip the tools pack
    var tools_zip_output = FILE.join($BUILD_DIR, 'Cappuccino', 'Tools.zip')
    rm_rf(tools_zip_output);

    OS.system("cd " + OS.enquote(cappuccino_output_path) + " && zip -ry -8 Tools.zip Tools");
});

// Testing

task("test", ["build", "test-only"]);

task("test-only", function()
{
    var tests = new FileList('Tests/**/*Test.j');
    var cmd = ["ojtest"].concat(tests.items());

    var code = OS.system(serializedENV() + " " + cmd.map(OS.enquote).join(" "));
    if (code !== 0)
        OS.exit(code);
});

task("push-packages", ["push-cappuccino", "push-objective-j"]);

task("push-cappuccino", function() {
    pushPackage(
        $BUILD_CJS_CAPPUCCINO,
        "git@github.com:280north/cappuccino-package.git",
        SYSTEM.env["PACKAGE_BRANCH"]
    );
});

task("push-objective-j", function() {
    pushPackage(
        $BUILD_CJS_OBJECTIVE_J,
        "git@github.com:280north/objective-j-package.git",
        SYSTEM.env["PACKAGE_BRANCH"]
    );
});

function pushPackage(path, remote, branch)
{
    branch = branch || "master";
    
    stream.print("Pushing \0blue(" + path + "\0) to "+branch+" of \0blue(" + remote + "\0)");

    FILE.mkdirs(".push-package");

    var pushPackageDir = FILE.join(".push-package", remote.replace(/[^\w]/g, "_"));

    if (FILE.exists(pushPackageDir))
        OS.system(buildCmd([["cd", pushPackageDir], ["git", "fetch"]]));
    else
        OS.system(["git", "clone", remote, pushPackageDir]);

    if (OS.system(buildCmd([["cd", pushPackageDir], ["git", "checkout", "origin/"+branch]]))) {
        if (OS.system(buildCmd([
            ["cd", pushPackageDir],
            ["git", "symbolic-ref", "HEAD", "refs/heads/"+branch],
            ["rm", ".git/index"],
            ["git", "clean", "-fdx"]
        ])))
            throw "pushPackage failed";
    }

    if (OS.system("cd "+OS.enquote(pushPackageDir)+" && git rm --ignore-unmatch -r * && rm -rf *"))
        throw "pushPackage failed";
    if (OS.system("cp -R "+OS.enquote(path)+"/* "+OS.enquote(pushPackageDir)+"/."))
        throw "pushPackage failed";

    OS.system(buildCmd([
        ["cd", pushPackageDir],
        ["git", "add", "."],
        ["git", "commit", "-m", "Pushed on " + new Date()]
    ]));
    
    if (OS.system(buildCmd([
        ["cd", pushPackageDir],
        ["git", "push", "origin", "HEAD:"+branch]
    ])))
        throw "pushPackage failed";
}

function buildCmd(arrayOfCommands)
{
    return arrayOfCommands.map(function(cmd) {
        return cmd.map(OS.enquote).join(" ");
    }).join(" && ");
}

function getShellConfigFile()
{
    var homeDir = SYSTEM.env["HOME"] + "/";
    // use order outlined by http://hayne.net/MacDev/Notes/unixFAQ.html#shellStartup
    var possibilities = [homeDir + ".bash_profile",
                         homeDir + ".bash_login",
                         homeDir + ".profile",
                         homeDir + ".bashrc"];

    for (var i = 0; i < possibilities.length; i++)
    {
        if (FILE.exists(possibilities[i]))
            return possibilities[i];
    }
}