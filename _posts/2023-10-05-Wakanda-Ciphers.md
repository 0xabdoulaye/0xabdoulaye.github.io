---
title: Crypto for Beginners - The Wakanda Ciphers
date: 2023-10-05 00:00:00 -500
categories: [Hacking for Beginners, Crypto CTFs]
tags: [Crypto, cipher, CTFs, Hacking]
image:
    path: https://i.ibb.co/SvfnMWN/wakanda.jpg
---

Welcome back Hackers, I've created a CTF room on TryHackMe specifically tailored for crypto beginners. In this blog post, I will just share a resolution writeup for the CTFs.
But before we start, we invite you to join our vibrant Hacking Journey community on **Discord!** Connect with like-minded hackers, share your experiences, and get ready for more thrilling challenges.
Whether you're a seasoned pro or just getting started, there's a place for you in our community. **Let's learn, explore, and hack together**. **Join us on Discord [here](https://discord.gg/wBT9wr9ruG)**.

- **The Best Academy to Learn Hacking is [Here](https://affiliate.hackthebox.com/nenandjabhata)**.
- **Beginner Friendly challenges on TryHackMe [Here](https://tryhackme.com/signup?referrer=61e8a27ddd3f3b00496505d1)**.
- **The Room [Here](https://tryhackme.com/room/wakanda)**.

## FromHex
You are provided with a hexadecimal string. Your task is to convert this hexadecimal string into its base64 equivalent. The flag is the value in base64 of the given hexadecimal string.
### Solution
```python
>>> import base64
>>> hexa = "72bca9b68fc16ac7beeb8f849dca1d8a783e8acf9679bf9269f7bf"
>>> var = bytes.fromhex(hexa)
>>> flag = base64.b64encode(var)
>>> print(flag)
b'crypto/Base+64+Encoding+is+XXX+XXXX/'
>>> 
```
- We convert the hexadecimal string hexa into a sequence of bytes using the `bytes.fromhex()` method. This step is essential because Base64 encoding operates on binary data.
- Next, we encode the binary data `(var)` into `Base64` format using the `base64.b64encode()` method. This process converts the binary data into a text-based representation that is safe for use in various contexts, such as in URLs.
- Finally, we print the encoded result, which is the Base64 representation of the original hexadecimal data.

## Reversed
You have been given an encoded message that has been reversed. Your task is to reverse the message back to its original form to reveal the flag.

Cipher: `}r3hp1C_v3R_yb4B{MHT`
###  Solution
```python3
>>> flag = "}r3hp1C_v3R_yb4B{MHT"
>>> reversed = flag[::-1]
>>> print(reversed)
THM{B4by_R3v_XXXXX}
>>> 
```
- To solve it, First we define a variable `flag`.The line `reversed = flag[::-1]` is used to reverse the characters in the flag string. This is achieved by using Python's slicing notation with a step value of `-1 ([::-1])`. This effectively reverses the order of characters in the string.

## Wakanda Atbash
Welcome to this cryptography challenge! 🕵️‍♂️ You've stumbled upon a mysterious string: `EVsMv0U0BnUazU8cx180J2odzWMbuJl=`. But beware, it's not just any cipher. 🤫 Explore it carefully to uncover the type of cipher used and decrypt it to reveal the hidden message.

### Solution
As we heard that, this `EVsMv0U0BnUazU8cx180J2odzWMbuJl=` is an atbash cipher. We Have Just to google it and we will find Online Tools to decode That for US.
Online tools [Here](https://www.dcode.fr/chiffre-atbash)
 Now you have just to Google  it and then find an online decoder to decode it.
Then after Decoding it, We got `VEhNe0F0YmFzaF8xc180Q2lwaDNyfQo=` it's seems like an `base64` Cipher.
```python3
┌──(root㉿1337)-[/home/bloman/Blog]
└─# base=VEhNe0F0YmFzaF8xc180Q2lwaDNyfQo=
                                                                             
┌──(root㉿1337)-[/home/bloman/Blog]
└─# echo $base | base64 -d               
THM{Atbash_1s_XXXXXX}
```

## Two Hex Cipher
🤯 It's like discovering a hidden treasure chest in your own backyard. Your mission, should you choose to accept it, is to decipher the encrypted message and uncover the hidden gem within!

### Solution
This `3vs3ej3f46hr4a76cf5m61934qf5ck6876731rr5gu2z76l9` is a `TwinHex Cipher`. 
To decode it Google can Help to find other online tools.
You Can use this : [Decode Twin Hex](https://www.calcresult.com/misc/cyphers/twin-hex.html)
Then found : `THM{N0w_You_kn0w_wh4tX_XXXX}`

## Rot in 13
In this challenge, you'll encounter a message that has been encoded using the ROT13 cipher, a simple letter substitution technique. Your task is to decode the message and reveal the hidden information.
cipher : `R1Vae0UwZ18xM19zMGVfTzN0dmFhcmV9Cg==`
### Solution
First the cipher is a `base64` cipher. we will convert it
```shell
┌──(root㉿1337)-[/home/bloman/Blog]
└─# base=R1Vae0UwZ18xM19zMGVfTzN0dmFhcmV9Cg==
                                                                             
┌──(root㉿1337)-[/home/bloman/Blog]
└─# echo $base | base64 -d
GUZ{E0g_13_s0e_O3tvaare}
```
Now we got `GUZ{E0g_13_s0e_O3tvaare}`. a rot13 Cipher. 
- To decode it you can use Online tools, or Command line.
```terminal
┌──(root㉿1337)-[/home/bloman/Blog]
└─# rot=GUZ{E0g_13_s0e_O3tvaare}
                                                                             
┌──(root㉿1337)-[/home/bloman/Blog]
└─# echo $rot | rot13 
THM{R0t_13_f0r_B3XXXX}
```

## The World of M0rs3 C0de 
In the world of Morse Code, a classic method of communication through dots and dashes! In this challenge, you'll encounter a secret message that has been encoded using Morse Code. Your mission is to decipher the Morse Code and reveal the hidden message.
`-- ----- .-. ... ..... ..--.- ..-. ----- .-. ..--.- -- ----- ... -`

### Solution
Morse code is a communication system that uses a series of dots and dashes (or short and long signals) to represent letters, numbers, and symbols. 
To solve it You can improve your coding skills on it, or use online tools:
flag is not in THM format
`M0RS5_F0R_XXXX`
**Best online Tools for Crypto:**
CyberChef
Cryptii
Dcode
Multi Decoder Sleuth

### Join Us
Thanks for reading. **Let's learn, explore, and hack together**. **Join us on Discord [here](https://discord.gg/wBT9wr9ruG)**. 
