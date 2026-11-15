@echo off
echo "DOCS PUSH BAT"
git add .
set now=%date% %time%
echo "Time:" %now%
git commit -m "%now%"
git push
pause