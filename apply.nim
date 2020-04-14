import os, osproc, strutils

let patchDir = paramStr(1)

for file in walkDirRec("diffFiles", relative = true):
    let i = file.rfind(DirSep)
    if (i > 0):
        createDir(joinPath("newFiles", file[0..i]))
    echo execProcess("xdelta3.exe", args=["-d", "-s", joinPath(patchDir, file[0..^7]), joinPath("diffFiles", file), joinPath("newFiles", file[0..^7])], options={poStdErrToStdOut})

for file in walkDirRec("newFiles", relative = true):
    let i = file.rfind(DirSep)
    if (i > 0):
        createDir(joinPath(patchDir, file[0..i]))
    copyFile(joinPath("newFiles", file), joinPath(patchDir, file))

var i = open("rmFiles.txt")
for file in i.lines:
    removeFile(joinPath(patchDir, file))
i.close()
