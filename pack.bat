@echo off
@chcp 65001
setlocal enabledelayedexpansion

rem 如果提供了参数，将第一个参数作为仓库路径，否则设置为当前工作目录
if "%~1"=="" (
    set "repo_path=%cd%"
) else (
    set "repo_path=%~1"
)
echo 仓库路径：%repo_path%
rem 检查仓库路径是否存在
if not exist "%repo_path%" (
    echo 指定的路径不存在：%repo_path%
    exit /b 1
)

rem 检查是否为 Git 仓库
for /f "delims=" %%i in ('git -C %repo_path% status --porcelain 2^>nul') do (
    set "has_git=1"
    goto check_status
)
set "has_git=0"

:check_status
if "%has_git%"=="0" (
    echo "%repo_path%"不是一个有效的 Git 仓库。
    exit /b 1
)

:check_status
if "%has_git%"=="0" (
    echo "%repo_path%"不是一个有效的 Git 仓库。
    exit /b 1
)

rem 检查是否在 merge 或 rebase 状态
set "in_merge_or_rebase=0"
for /f "delims=" %%i in ('git -C %repo_path% status --porcelain') do (
    set "line=%%i"
    if "!line:~0,9!"=="MERGE_HEAD" (
        set "in_merge_or_rebase=1"
        goto report_status
    ) else if "!line:~0,10!"=="REBASE_HEAD" (
        set "in_merge_or_rebase=1"
        goto report_status
    )
)

:report_status
if "%in_merge_or_rebase%"=="1" (
    echo 当前仓库处于 merge 或 rebase 状态，无法进行操作。
    exit /b 1
)

rem 检查暂存区是否为空
for /f "delims=" %%i in ('git -C %repo_path% status --porcelain') do (
    set "line=%%i"
    if "!line:~1,1!" neq " " (
        echo 暂存区不为空，无法继续操作 %line%。
        exit /b 1
    )
)

rem 报告文件状态
for /f "delims=" %%i in ('git -C %repo_path% status --porcelain') do (
    set "line=%%i"
    set "status=!line:~0,1!"
    set "file_path=%repo_path%!line:~3!"
    if "!status!"=="A" (
        echo Added file:!file_path!
    ) else if "!status!"=="D" (
        echo Deleted file:!file_path!
    ) else if "!status!"=="M" (
        echo Modified file:!file_path!
    ) else (
        echo Unrecognized status:!status! for file!file_path!
        exit /b 1
    )
)

