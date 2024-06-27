---
title: Password Cracking - Guide Pratique pour les Compétitions CTF
date: 2024-06-24 19:26:01 -0400
description: Le Password Cracking est une compétence essentielle pour tout membre d'une équipe de Red Team. Que ce soit dans le cadre de compétitions CTF ou dans des scénarios réels, la capacité à récupérer des mots de passe à partir de hachages peut faire la différence entre le succès et l'échec d'une mission. Dans cet article, nous explorerons comment aborder un challenge de cracking de mots de passe avec des outils comme John the Ripper et Hashcat.
categories: [RedTeam]
tags: [cracking, CTFs, hashcat]
image:
    path: https://i.ibb.co/4TNTjMH/passes.jpg
---


- **[The Best Academy to Learn Hacking](https://referral.hackthebox.com/mz6xj5g)**.
- **[Beginner Friendly challenges on TryHackMe](https://tryhackme.com/signup?referrer=61e8a27ddd3f3b00496505d1)**.


<h2 style="color: orange;">Challenges 1</h2>


<strong>Pouvez-vous déchiffrer ces 10 mots de passe à partir de notre fichier de hachage ?</strong>
```console
user1:1013:633c097a37b26c0caad3b435b51404ee:f2477a144dff4f216ab81f2ac3e3207d:::
user2:1014:874ea23df4afd3cf93e28745b8bf4ba6:fb4bf3ddf37cf6494a9905541290cf51:::
user3:1015:598ddce2660d3193aad3b435b51404ee:2d20d252a479f485cdf5e171d93985bf:::
user4:1016:44efce164ab921caaad3b435b51404ee:32ed87bdb5fdc5e9cba88547376818d4:::
user5:1017:5de640a31c34882ff500944b53168930:320a78179516c385e35a93ffa0b1c4ac:::
user6:1018:45bf38fbd873819aaad3b435b51404ee:152efbcfafeb22eabda8fc5e68697a41:::
user7:1019:e52cac67419a9a224a3b108f3fa6cb6d:8846f7eaee8fb117ad06bdd830b7586c:::
user8:1020:87199f718f851325359d3fc755b08c91:d33b15ba0f27dbf0fd56cd54b1db1ade:::
user9:1021:7b6007cf0384ac234dd8ea76ea0efefb:b31c6aa5660d6e87ee046b1bb5d0ff79:::
user10:1022:a7f6fe4d214a8591613e9293942509f0:b963c57010f218edc2cc3c229b5e4d0f:::
```

Dans ce premier challenge, voici les hashes qu'on a été donnés pour cracker. Pour cela, je vais utiliser un outil disponible sur `Kali Linux` qui est `John the Ripper`. Mais pour commencer, j'ai identifié ces hashes et je vais juste prendre les hashes `NT` pour cracker plus rapidement.

<h3 style="color: orange;">Identification des Hashes NT</h3>

Voici les hashes `NT` extraits des données :

![NT Hash](https://i.ibb.co/brZ4NHb/nt.png)

Ensuite, je vais utiliser l'outil `john` tout en spécifiant le format du hash pour être rapide.

```console
└─# john --format=NT hashes.txt --wordlist=/usr/share/wordlists/rockyou.txt
```

Voici un aperçu de l'exécution de la commande :

![John](https://i.ibb.co/6B55cnS/john.png)



<h2 style="color: orange;">Challenges 2</h2>

Dans ce deuxieme challenge voici ce que l'auteur nous dit:

>**Nous disposons des hashes et savons qu'ils suivent le même format que lors d'une précédente intrusion. Ils doivent commencer par ``HACK-ME-`` suivi de quatre chiffres. Par exemple, ``HACK-ME-1111``**
{: .prompt-info }

```console
74f464283a165fb9f47b8451a9bc7dc0
8151c07fc7a11fa33ae9ffea5eba7aa3
9fba0c637e9ff1ce7e14f255e1c8367d
b956ca6aa424e6b19932e0172e8df74a
2e97f889a75b972802b235f9053800e7
```

 D'après ce que l'auteur nous dit, ici nous devons générer notre propre `wordlist` pour pouvoir cracker ces hashes. Pour cela, je vais utiliser un outil très connu sur `Kali Linux` pour créer une custom `wordlist`, qui s'appelle `crunch`.

> L'outil `crunch` nous permet de créer des wordlists basées sur des motifs spécifiques. Voici les options que je vais utiliser sur ce challenge :
{: .prompt-info }

```console
$ man crunch
       -t @,%^
              Specifies a pattern, eg: @@god@@@@ where the only the @'s, ,'s, %'s, and ^'s will change.
              @ will insert lower case characters
              , will insert upper case characters
              % will insert numbers
              ^ will insert symbols
```

comme le dit le challenge, les mots de passe commencent par **HACK-ME-** et sont suivi par 4 chiffre, donc je vais utiliser le `%` pour inserer des nombres a la fin.

```console
└─# crunch 12 12 -t HACK-ME-%%%% -o wordlist.txt
Crunch will now generate the following amount of data: 130000 bytes
0 MB
0 GB
0 TB
0 PB
Crunch will now generate the following number of lines: 10000
crunch: 100% completed generating output
```

Ensuite, je n'ai qu'a lancer `john` toute en specifiant ce wordlist que j'ai generer aussi avec le format des Hashes.

```console
john hashes.txt --format=Raw-MD5 --wordlist=wordlist.txt
```

![John2](https://i.ibb.co/4Ktj7jq/john2.png)



<h2 style="color: orange;">Ressources supplementaires</h2>
<p style="color: white;"> Voici quelques ressources supplémentaires qui pourraient vous être utiles :</p>

- [Crunch wordlist](https://www.hackingarticles.in/a-detailed-guide-on-crunch/)
- [Password Cracking Challenges](https://cybercompaacc.com/challenges/password-cracking-challenges/)
- [Join Us on Discord](https://discord.gg/wBT9wr9ruG).
