---
title: Hacking for Beginners - Bandit Levels 6-10 on OverTheWire
date: 2023-09-07 00:00:00 -500
categories: [Hacking for Beginners, OverTheWire]
tags: [Bandit, Linux, CTFs, Hacking]
image:
    path: https://i.ibb.co/8MJXs9H/banditcover.png
---

Welcome back Hackers, **to The Hacking Journey**, In our previous articles, we embarked on an exciting **Hacking Journey** through the Bandit wargame by OverTheWire, specifically focusing on Bandit levels 0 to 5. If you missed those adventures, don't worry; you can catch up on all the action and insights [here](https://blackcybersec.xyz/posts/Bandit0-5/).

### **RECAP** :
We began with the basics, honing our Linux command-line skills and navigating file systems. Now, let's continue our adventure into Bandit levels 6 to 10, where challenges get even more intriguing.

But before we do, we invite you to join our vibrant Hacking Journey community on **Discord!** Connect with like-minded hackers, share your experiences, and get ready for more thrilling challenges.
Whether you're a seasoned pro or just getting started, there's a place for you in our community. **Let's learn, explore, and hack together**. **Join us on Discord [here](https://discord.gg/wBT9wr9ruG)**.

## **Level 6**: Human-readable files, file sizes and non-executable files.

- **GOAL**: 
The password for the next level is stored in a file somewhere under the inhere directory and has all of the following properties:
    human-readable
    1033 bytes in size
    not executable

- **SOLUTION**:
First, we need to access the "inhere" directory where we suspect the password file is located. To do this, we use the `cd` (change directory) command like this:
```terminal
bandit5@bandit:~$ cd inhere/
bandit5@bandit:~/inhere$ ls
maybehere00  maybehere03  maybehere06  maybehere09  maybehere12  maybehere15  maybehere18
maybehere01  maybehere04  maybehere07  maybehere10  maybehere13  maybehere16  maybehere19
maybehere02  maybehere05  maybehere08  maybehere11  maybehere14  maybehere17
```
Now that we're inside the "inhere" directory, we want to see what's inside. The `ls` command lists the contents of the directory, showing us all the files and subdirectories present.
We know that the password file must be 1033 bytes in size. To find it, we use the `find` command with specific criteria. Here's the command:
```terminal
bandit5@bandit:~/inhere$ find . -type f -size 1033c 
./maybehere07/.file2
```
  - `.`: This tells find to start the search in the current directory (which is "inhere").
  -  `-type f`: This option specifies that we're looking for regular files (not directories or other types of files).
  -  `-size 1033c`: We're specifying that we want files exactly 1033 bytes in size.

To view the contents of the file `.file2` we can use a command like cat:
```terminal
bandit5@bandit:~/inhere$ cat ./maybehere07/.file2
P4L4vucdmLnXXXXXXXX
```

## **Level 7**: Find a file with specific user and group ownership.

- **GOAL**: 
The password for the next level is stored somewhere on the server and has all of the following properties:
    owned by user bandit7
    owned by group bandit6
    33 bytes in size

- **SOLUTION**:
We start our quest by using the find command to search the entire server ("/") for files that meet the specified criteria. In this case, we're looking for files that:
    - Are owned by the user "bandit7" (-user bandit7).
    - Are owned by the group "bandit6" (-group bandit6).
    - Are precisely 33 bytes in size (-size 33c).
```terminal
find / -type f -user bandit7 -group bandit6 -size 33c
```
Once the `find` command identifies files that match the criteria, we want to examine the contents of these files to find the password. This is where the `xargs` command comes into play.
`xargs` is a command that can be used to build and execute commands from standard input. In our case, it will help us execute the cat command for each of the matching files.
The full command to achieve this and print out the password is:
```terminal
find / -type f -user bandit7 -group bandit6 -size 33c | xargs cat
find: ‘/sys/fs/pstore’: Permission denied
find: ‘/sys/fs/bpf’: Permission denied
z7WtoNQU2XfjmMtWA8u5rN4vzqu4v99S
```
  `-group` and `-user` are options (or flags) that you provide to the `find` command to specify certain criteria for the files you want to search for.
    `-group bandit6` specifies that you're looking for files that belong to the group "bandit6." In this context, you're interested in files that are owned by this particular group.
    `-user bandit7` specifies that you're looking for files that are owned by the user "bandit7." You want to find files specifically owned by this user.
    `xargs` is a utility that allows you to take the output of one command (in this case, the list of file paths found by `find`) and use it as arguments for another command (in this case, `cat`).
    Essentially, it helps you execute a command for each item (in this case, file path) in a list.   

## **Level 8**: Learning grep.

- **GOAL**: 
The password for the next level is stored in the file data.txt next to the word millionth

- **SOLUTION**:
In this Bandit level 8 challenge, you're tasked with finding the password for the next level, which is stored in a file named `data.txt` next to the word "millionth."
So, I started by using the ls command to list the files in my current directory. When I did that, I saw that there was a file named `data.txt` in the list.
```terminal
bandit7@bandit:~$ ls
data.txt
bandit7@bandit:~$ wc data.txt 
  98567  197133 4184396 data.txt
```
`wc data.txt`: The wc (word count) command is used to count the number of lines, words, and characters in a file. . When you run `wc data.txt`, it provides the following information about `data.txt`:
    - 98,567 lines
    - 197,133 words
    - 4,184,396 characters
Then I read it using the `cat` following by `grep`:
```terminal
bandit7@bandit:~$ cat data.txt | grep "millionth"
millionth TESKZC0XvTetK0S9xNwm25SXXXXXX
```
`cat data.txt | grep "millionth"`: This command performs the following actions:
    - `cat data.txt `reads the contents of the "data.txt" file and displays it in the terminal.
    - The `|` (pipe) operator takes the output of the cat command (the contents of "data.txt") and passes it as input to the grep command.
    - `grep "millionth"` searches for the word "millionth" within the contents of "data.txt."

## **Level 9**: uniq & sort commands, to find line only appearing once.
- **GOAL**: 
The password for the next level is stored in the file data.txt and is the only line of text that occurs only once

- **SOLUTION**:
In this challenge, you're tasked with finding the password for the next level, which is stored in the "data.txt" file. The unique characteristic of this password is that it is the only line of text in the file that occurs only once. 
Like the last challenge we begin by listing all the contents in our current directory by using `ls` command:
```terminal
bandit8@bandit:~$ ls
data.txt
bandit8@bandit:~$ wc data.txt 
 1001  1001 33033 data.txt
```
and when i found a data.txt i used the `wc` as we have seen it before to count the word and the number of lines in our file.
```terminal
bandit8@bandit:~$ cat data.txt | sort | uniq -u
EN632PlfYiZbn3PhVK3XOGSXXXXX
```
`cat data.txt | sort | uniq -u`: This is a series of commands that work together to find the password.
  - `cat data.txt` reads the contents of the "data.txt" file.
  - `sort` sorts the lines of text in alphabetical order.
  - `uniq -u` prints only the lines that occur once (i.e., unique lines).

## **Level 10**: The strings command. Find human-readable strings in a file.
- **GOAL**: 
The password for the next level is stored in the file data.txt in one of the few human-readable strings, preceded by several `==` characters.

- **SOLUTION**:
In this Bandit level 10, your goal is to find the password for the next level, which is stored in the "data.txt" file within a human-readable string that's preceded by several `==` characters.
```terminal
bandit9@bandit:~$ ls
data.txt
bandit9@bandit:~$ wc -l data.txt 
79 data.txt
```
`wc -l data.txt`: The `wc` command is used to count the number of lines, words, and characters in a file. The `-l` option specifically counts the number of lines. When you run `wc -l data.txt`, it provides the following information: There are 79 lines in the "data.txt" file.
```terminal
bandit9@bandit:~$ cat data.txt | strings | grep "=="
4========== the#
========== password
========== is
========== G7w8LIi6J3kTb8A7j9LgrywtEUlyyp6s
```
`cat data.txt | strings | grep "=="`: This is a series of commands that work together to find the password.
    - `cat data.txt` reads the contents of the "data.txt" file.
    - `strings` is a command that extracts human-readable strings from a binary file or input. In this case, it helps extract any human-readable text from the "data.txt" file.
    - `grep "=="` searches for lines containing the == characters. This is the criterion you're using to identify lines that may contain the password.
## CONCLUSION:
In summary, the levels we've covered in OverTheWire's Bandit wargame offer an engaging introduction to the world of ethical hacking. These challenges have equipped us with essential command-line navigation skills, taught us how to locate hidden files, and shown us how to analyze different content types. These foundational skills are crucial for newcomers to the field of cybersecurity. As we progress through the game, we'll build upon this knowledge, moving closer to mastering the abilities that can be applied in real-world scenarios. Join us in the next levels as we continue this exciting journey of learning and discovery.