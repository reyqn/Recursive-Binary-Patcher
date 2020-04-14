import os, sets, osproc, strutils

let oldDir = paramStr(1)
let newDir = paramStr(2)

var oldSeq: seq[string]
var newSeq: seq[string]

for file in walkDirRec(oldDir, relative = true):
    oldSeq.add(file)

for file in walkDirRec(newDir, relative = true):
    newSeq.add(file)

let
  oldSet = toHashSet(oldSeq)
  newSet = toHashSet(newSeq)

var rmFiles: HashSet[string] = oldSet - newSet
var newFiles: HashSet[string] = newSet - oldSet
var diffFiles: seq[string]

for file in oldSet * newSet:
    if not sameFileContent(joinPath(oldDir, file), joinPath(newDir, file)):
        diffFiles.add(file)
        

echo diffFiles.len
echo rmFiles.len
echo newFiles.len

createDir("diffFiles")
for file in diffFiles:
    let i = file.rfind(DirSep)
    if (i > 0):
        createDir(joinPath("diffFiles", file[0..i]))
    echo execProcess("xdelta3.exe", args=["-s", joinPath(oldDir, file), joinPath(newDir, file), "diffFiles" & DirSep & file & ".patch"], options={poStdErrToStdOut})

createDir("newFiles")
for file in newFiles:
    let i = file.rfind(DirSep)
    if (i > 0):
        createDir(joinPath("newFiles", file[0..i]))
    copyFile(joinPath(newDir, file), joinPath("newFiles", file))

var o = open("rmFiles.txt", fmWrite)
for file in rmFiles:
    o.writeLine(file)
o.close()