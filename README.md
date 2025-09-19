#  Patches  for  Hopmon  2.0

> Polska wersja README dostępna [tutaj](https://github.com/Pieshka/hopmon-patched/blob/main/README.PL.md)

This repository contains patches for the game [Hopmon 2.0](http://saitogames.com/hopmon/index.htm) by Saito Games. Hopmon is an older game from 2001, created mainly for DirectX 7. It uses music composed by T. Kinoshita on Roland SK-88 Pro. Around 2020, James Saito released Hopmon as freeware, so anyone can download and play it. Unfortunately, even though the developer has adapted the game for newer Windows systems, some components still cause problems.

This repository contains binary patches for the Hopmon executable file created using [HDiffPatch](https://github.com/sisong/HDiffPatch). The repository itself only contains files related to the patches. The ready-made patch package and any resources (music and Polish textures) can be found in the [Releases](https://github.com/Pieshka/hopmon-patched/releases) tab.

##  I  was  redirected  here  from  the  XYZ  forum...
Previously,  this  repository  looked  completely  different.  Music  files  were  available  directly  in  the  repository,  which  made  them  very  difficult  to  integrate  with  Git  (additionally,  this  could  result  in  a  copyright  strike  on  the  entire  repository,  rather  than  just  part  of  it). DDrawCompact was also included, as well as binary files with patches made in the proprietary SVF format. To make matters worse, the included patcher in bat format contained a VBScript payload, which was obviously not dangerous, but antivirus programmes strongly disapproved of it. Besides, many people would probably prefer not to run a batch file containing a lot of unreadable bytes.

For this reason, I decided to rework this repo to make it ‘copyright friendly’ and to base the whole thing on open-source external tools. For those who would still prefer to apply the patches manually, I will describe exactly what has been changed in the code. So, without further ado, I invite you to read on.

## Changes to the executable file
There are three (four) sets of patches available:
* `music` - changes the `PlayMidi` function so that it plays MP3 files instead of MIDI sequence files. The files `Music01.mp3`, `Music02.mp3`, `Music03.mp3` and `Music04.mp3` must be present in the directory containing the .exe file - available for download in the Releases tab.
* `resolution` - removes the resolution cap completely. In  addition,  the  basic  game  enforces  16-bit  colour  depth,  which  caused  Hopmon  to  stutter  terribly  on  newer  systems  and  graphics  cards.  DDrawCompact  fixed  this,  but  it  turns  out  that  after  removing  the  limit  and  selecting  32-bit  colour  depth,  everything  works  correctly  without  additional  libraries. So the patch adds the ability to select 32-bit colour depth (actually any colour depth, but for me only 32-bit and 16-bit are displayed).
* `combined` - contains the above patches
* `base` - patch available only in Polish, adds the Polish language based on the 2002 translation by Hopmons' polish publisher - TopWare Interactive, without introducing the above changes.

##  Installation  instructions
1.  Download  [Hopmon  2.0](http://saitogames.com/hopmon/index.htm)  and  install  it  on  your  system.
2. Download the `hopmon-patches.zip` package from the [Releases](https://github.com/Pieshka/hopmon-patched/releases) tab and extract it somewhere on your hard drive.
3. Copy the `Hopmon.exe` file from the installed version of the game to the unzipped package so that the `Hopmon.exe` and `start.bat` files are in the same directory.
4. Run the `start.bat` file (you can check that it does not contain any payloads :>)
5. Follow the instructions on the screen. The package requires that the version of Hopmon be exactly the same as the one I used to generate the patches - it will check this requirement itself.
6. An .exe file with `patched` in its name will be generated. Copy it to the original Hopmon directory and replace the original `Hopmon.exe` with it.
7. If you chose the `music` or `combined` patches, download the `hopmon-music.zip` package from the [Releases](https://github.com/Pieshka/hopmon-patched/releases) tab and extract the MP3 files it contains directly to the game directory so that the `Hopmon.exe` file and the MP3 files are next to each other. At this stage, you can delete the `.mid` files as they will not be needed.
8. All downloaded zip files and packages can be safely deleted.

> **NOTE!** You may need to install additional codecs on your system to support MP3 files. K-Lite Mega Codec Pack has been tested, but any codec pack that provides codecs in Media Foundation Platform format will likely work. Probably reencoding music files to older revision of the MP3 standard would also work.

##  Manual  preparation  method
If  you  don't  want  to  use  my  patches  and  prefer  to  prepare  the  appropriate  executable  file  yourself,  follow  this  section.  However,  it  is  intended  for  people  who  are  familiar  with  reverse  engineering,  so  I  will  assume  that  you  know  what  it  is  about.  I  will  only  point  out  specific  modifications  in  the  code.

### Music patch
By default, the `PlayMidi` function uses `mciSendString` to play music and calls it like this:

![PREV_PLAY_MIDI.png](.github/PREV_PLAY_MIDI.png)

The presence of `type sequencer` forces the input file to be treated as a sequential MIDI type. This should be deleted from the string. The modified function should look like this:

![NEW_PLAY_MIDI.png](.github/NEW_PLAY_MIDI.png)

In addition, in `XApplication::Create()`, change the loading of paths to files and replace `.mid` entries in file names with `.mp3`:

![PREV_MIDI_LIST.png](.github/PREV_MIDI_LIST.png)

After modification, the paths should look like this:

![NEW_MP3_LIST.png](.github/NEW_MP3_LIST.png)

Thanks to this modification, the game will play MP3 files instead of MIDI files. There is also an option to play WAV files. Just change the names from `.mid` to `.wav`.

### Resolution patch
In the `UpdateDialogControls` function, resolutions greater than 1280x960 and bit depths other than 16-bit are ignored when filling in dialogue options.

The assembler code looks like the image below. First, we have operations that check the upper limit of the resolution, followed by operations that check the bit depth.

![PREV_RESOLUTION.png](.github/PREV_RESOLUTION.png)

We can completely remove any resolution and bit depth checks. With the available space, we can write custom format string for `wsprintfA()` to allow showing bit depth in the game launcher. This assembly shows how the patch is implemented and where in the code:
```asm
                             LAB_004052b7                                    XREF[2]:     004052ad(j), 004052b3(j)  
        004052b7 eb 35           JMP        LAB_004052ee
        004052b9 25 6c 64        ds         "%ld x %ld - %ldbit"
                 20 78 20 
                 25 6c 64 
        004052cc 00              ??         00h
        004052cd 73              ??         73h    s
        004052ce 02              ??         02h
        004052cf eb              ??         EBh
        004052d0 a5              ??         A5h
        004052d1 eb              ??         EBh
        004052d2 1b              ??         1Bh
        004052d3 a8              ??         A8h
        004052d4 81              ??         81h
        004052d5 7a              ??         7Ah    z
        004052d6 0c              ??         0Ch
        004052d7 00              ??         00h
        004052d8 10              ??         10h
        004052d9 00              ??         00h
        004052da 00              ??         00h
        004052db 77              ??         77h    w
        004052dc 0c              ??         0Ch
        004052dd 8b              ??         8Bh
        004052de 45              ??         45h    E
        004052df a8              ??         A8h
        004052e0 81              ??         81h
        004052e1 78              ??         78h    x
        004052e2 08              ??         08h
        004052e3 00              ??         00h
        004052e4 10              ??         10h
        004052e5 00              ??         00h
        004052e6 00              ??         00h
        004052e7 76              ??         76h    v
        004052e8 02              ??         02h
        004052e9 eb              ??         EBh
        004052ea 8b              ??         8Bh
        004052eb 90              ??         90h
        004052ec 90              ??         90h
        004052ed 90              ??         90h
                             LAB_004052ee                                    XREF[1]:     004052b7(j)  
        004052ee 8b 55 a8        MOV        EDX,dword ptr [EBP + -0x58]
        004052f1 8b 42 54        MOV        EAX,dword ptr [EDX + 0x54]
        004052f4 67 50           PUSH       EAX
        004052f6 8b 55 a8        MOV        EDX,dword ptr [EBP + dev_mode]
        004052f9 8b 42 08        MOV        EAX,dword ptr [EDX + 0x8]
        004052fc 50              PUSH       EAX
        004052fd 8b 4d a8        MOV        ECX,dword ptr [EBP + dev_mode]
        00405300 8b 51 0c        MOV        EDX,dword ptr [ECX + 0xc]
        00405303 52              PUSH       EDX
        00405304 68 b9 52        PUSH       0x4052b9
                 40 00
        00405309 8d 45 ac        LEA        EAX=>res_text,[EBP + -0x54]
        0040530c 50              PUSH       EAX
        0040530d ff 15 3c        CALL       dword ptr [->USER32.DLL::wsprintfA]              = 00084bf6
                 32 47 00
```

###  Polish base patch
The  translation  of  the  binary  into  Polish  is  based  on  replacing  resources  using  tools  such  as  [Risoh  Editor](https://github.com/katahiromz/RisohEditor).  Image  files  and  dialogue  boxes  in  Polish  are  available  in  the [Releases](https://github.com/Pieshka/hopmon-patched/releases) tab in the `hopmon-polish-resources.zip` file. The files have names that correspond to resource identifiers, so it will be very easy to replace them. Personally, I think the Polish images are ugly (especially the final congratulations).

## Credits
* Special thanks to James Saito for creating my childhood game Hopmon, and to T. Kinoshita for the phenomenal soundtrack!
*  MP3  versions  of  the  original  soundtrack  were  generated  by  [Tech&Music  Extra](https://www.youtube.com/watch?v=G_BOY0J7tlI)
*  Patches  were  prepared  using  [HDiffPatch](https://github.com/sisong/HDiffPatch)  software
* Polish resources were prepared by a team of translators from TopWare Poland for the Polish release of Hopmon in 2002.

## License
All scripts and patches (i.e. the entire repository) are available under the Unlicense, i.e. in the public domain.
This does not apply to the packages available in the [Releases](https://github.com/Pieshka/hopmon-patched/releases) tab, which, in addition to my patches and scripts, also contain resources copyrighted by TopWare Poland and T. Kinoshita.

**Please note that redistribution of modified Hopmon binaries is not permitted under its EULA!**
