@echo off
echo ========================================
echo Shakti AI - Directory Cleanup
echo ========================================
echo.
echo This script will delete the frontend and blockchain directories.
echo.
echo IMPORTANT: Close VS Code and File Explorer before running this.
echo.
pause

echo.
echo Deleting frontend directory...
if exist frontend (
    rmdir /s /q frontend
    if exist frontend (
        echo ERROR: Could not delete frontend directory
        echo Please close any programs that might be using it and try again
    ) else (
        echo SUCCESS: frontend directory deleted
    )
) else (
    echo INFO: frontend directory already deleted
)

echo.
echo Deleting blockchain directory...
if exist blockchain (
    rmdir /s /q blockchain
    if exist blockchain (
        echo ERROR: Could not delete blockchain directory
        echo Please close any programs that might be using it and try again
    ) else (
        echo SUCCESS: blockchain directory deleted
    )
) else (
    echo INFO: blockchain directory already deleted
)

echo.
echo ========================================
echo Cleanup Complete!
echo ========================================
echo.
echo Next steps:
echo 1. Run: pip install -r requirements.txt
echo 2. Start server: python -m uvicorn main:app --reload
echo.
pause
