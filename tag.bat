@echo off
set projectPath=https://svn2.hosted-projects.com/Amadeus/Npp/WebEdit
set projectName=WebEdit
if "%1" NEQ "" goto start
echo Tag - create a tag of the current branch
echo Usage: "tag <version-to-tag-as>"
echo Example: tag 2.0.2
goto :eof

:start
svn update
::if %errorlevel% NEQ 0 goto :Svnfailed
:: set FileFlags=0 in the version information
:: - in the ANSI build
sed -e "s/^FileFlags=.*/FileFlags=0/" Src\%projectName%Ver > Src\%projectName%Ver.tmp
del Src\%projectName%Ver
ren Src\%projectName%Ver.tmp %projectName%Ver

:: - in the Unicode build
sed -e "s/^FileFlags=.*/FileFlags=0/" Src\%projectName%UVer > Src\%projectName%UVer.tmp
del Src\%projectName%UVer
ren Src\%projectName%UVer.tmp %projectName%UVer

:: make sure the project compiles and passes all tests
make
if %errorlevel% NEQ 0 goto Makefailed
make test
if %errorlevel% NEQ 0 goto Makefailed

:: create distribution package
make dist -C Src
if %errorlevel% NEQ 0 goto Makefailed
move Src\%projectName%.zip Src\%projectName%.%1.zip
sed -e "s/\*%projectName%\.zip/*%projectName%.%1.zip/" Src\%projectName%.zip.md5 > Src\%projectName%.%1.zip.md5
del Src\%projectName%.zip.md5

:: create the tag
svn copy . %projectPath%/tags/%1 -m "Tagged %projectName% v.%1 release."
if %errorlevel% NEQ 0 goto :Svnfailed
svn revert Src\%projectName%Ver
if %errorlevel% NEQ 0 goto :Svnfailed
echo The tag was created successfully.
goto :eof

:Makefailed
echo Make failed - tag was not created
goto :eof

:Svnfailed
echo SVN command failed - see error message above
goto :eof