start cmd /c sqlcmd -S. -i .\LoadScripts\LoadGeneratorRead.sql  1> NUL  2> NUL
start cmd /c sqlcmd -S. -i .\LoadScripts\LoadGeneratorWrite.sql
