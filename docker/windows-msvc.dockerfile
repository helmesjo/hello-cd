# escape=`

FROM microsoft/windowsservercore:1803

# Install chocolatey
RUN @"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"

# Install Visual C++ Build Tools, as per: https://chocolatey.org/packages/visualcpp-build-tools
# wait for vs_installer.exe, vs_installerservice.exe
# or vs_installershell.exe because choco doesn't
RUN powershell -NoProfile -InputFormat None -Command `
    choco install `
        visualcpp-build-tools --version 15.0.26228.20170424 `
        -y; `
    Write-Host 'Waiting for Visual C++ Build Tools to finish'; `
    Wait-Process -Name vs_installer

RUN powershell -NoProfile -InputFormat None -Command `
    choco install 7zip --version 18.5.0.20180730 -y; `
    choco install git --version 2.18.0 -y; `
    choco install cmake --version 3.12.1 --installargs '"ADD_CMAKE_TO_PATH=System"' -y; `
    choco install python --version 3.7.0 --force --override --installarguments "'/quiet  InstallAllUsers=1 TargetDir=c:\Python35'" -y;

RUN powershell -NoProfile -InputFormat None -Command `
    pip install conan==1.7.1
# Add msbuild to PATH
RUN setx /M PATH "%PATH%;C:\Program Files (x86)\Microsoft Visual Studio\2017\BuildTools\MSBuild\15.0\Bin"
RUN setx /M PATH "%PATH%;C:\Python35"

# Test msbuild can be accessed without path
RUN     cmake --version && `
        conan --version && `
        git --version && `
        msbuild -version && `
        python --version

CMD [ "powershell.exe" ]