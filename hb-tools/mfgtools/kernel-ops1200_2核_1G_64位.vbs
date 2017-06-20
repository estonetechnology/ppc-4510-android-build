Set wshShell = CreateObject("WScript.shell")
wshShell.run "mfgtool2.exe -c ""linux"" -l ""eMMC-Android-kernel"" -s ""board=sabresd""  -s ""folder=sabresd"" -s ""mmc=2"" -s ""data_type="""
Set wshShell = Nothing
