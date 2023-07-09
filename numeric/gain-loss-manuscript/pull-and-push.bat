set /p commitMessage=Commit message:
git pull
git add .
git commit -a -m "%commitMessage%"
git push
cmd /k