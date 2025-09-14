# Łatki do Hopmona 2.0
Te repozytorium zawiera łatki do gry [Hopmon 2.0](http://saitogames.com/hopmon/index.htm) autorstwa Saito Games. Hopmon to starsza gra z 2001 roku, stworzona głównie z myślą DirectX 7. Wykorzystuje muzykę skomponowaną przez T.Kinoshita na Roland SK-88 Pro. Około roku 2020 James Saito udostępnił Hopmona jako freeware, więc każdy może pobrać i zagrać w niego. Niestety mimo, że twórca dostosował grę dla nowszych systemów Windows, to jednak część komponentów nadal sprawia problemy.

Te repozytorium zawiera binarne łatki do pliku wykonywanego Hopmona wykonanie przy użyciu [HDiffPatch](https://github.com/sisong/HDiffPatch). Samo repo zawiera jedynie pliki związane z łatkami. Gotowa paczka łatająca oraz ewentualnie zasoby (muzyka i polskie tekstury) znajdują się w zakładce [Releases](https://github.com/Pieshka/hopmon-patched/releases).

## Przekierowano mnie tutaj z forum XYZ...
Poprzednio te repozytorium wyglądało zupełnie inaczej. Pliki muzyczne dostępne były bezpośrednio w repozytorium przez co bardzo kiepsko integrowały się z gitem (dodatkowo mógł z tego powodu nastąpić copyright strike na całe repo, a nie na jego część). Dołączony był również DDrawCompact, a także binarne pliki z łatkami wykonanymi we własnościowym formacie SVF. Na domiar złego dołączony patcher w formacie bat zawierał payload VBScript, który oczywiście nie był niebezpieczny, ale antywirusy mocno kręciły nosem na niego. Poza tym prawdopodobnie wiele osób wolało by nie uruchamiać pliku batch zawierającego mnóstwo nieczytelnych bajtów.

Z tego powodu postanowiłem przerobić to repo, aby było "copyright friendly", a także żeby całość opierała na otwarto-źródłowych narzędziach zewnętrznych. Dla osób, które wolały by mimo wszystko ręcznie zastosować łatki, opiszę co dokładnie w kodzie zostało zmienione. Zatem bez zbędnego przedłużania, zapraszam do czytania.

## Zmiany w pliku wykonywalnym
Dostępne są trzy (cztery) zestawy łatek:
* `music` - zmienia funkcję `PlayMidi`, żeby zamiast plików sekwencyjnych MIDI, odtwarzała pliki MP3. Wymagane jest aby w katalogu z plikiem .exe znajdowały się pliki `Music01.mp3`, `Music02.mp3`, `Music03.mp3` oraz `Music04.mp3` - dostępne do pobrania w zakładce Releases.
* `resolution` - usuwa całkowicie limit rozdzielczości. Dodatkowo podstawowa gra wymusza 16-bitową głębię kolorów przez co na nowszych systemach i kartach graficznych Hopmon okropnie klatkował. DDrawCompact to naprawiał ale okazuje się, że po zdjęciu limitu i wybraniu 32-bitowej głębi kolorów, wszystko poprawnie działa bez dodatkowych bibliotek. Zatem patch dodaje możliwość wybrania 32-bitowej głębi kolorów (właściwie to dowolnej głębi kolorów, ale u mnie się wyświetlają tylko 32-bitowa i 16-bitowa).
* `combined` - zawiera powyższe patche w sobie
* `base` - łatka dostępna jedynie w języku polskim, dodaje sam język polski na bazie tłumaczenia wydawnictwa TopWare Interactive z 2002 roku, bez wprowadzania powyższych zmian.

## Sposób instalacji
1. Pobierz [Hopmon 2.0](http://saitogames.com/hopmon/index.htm) i zainstaluj w systemie.
2. Pobierz paczkę `hopmon-patches.zip` z zakładki [Releases](https://github.com/Pieshka/hopmon-patched/releases) i wypakuj gdzieś u siebie na dysku.
3. Skopiuj plik `Hopmon.exe` z zainstalowanej wersji gry do rozpakowanej paczki, tak aby plik `Hopmon.exe` i `start.bat` znajdowały się w jednym katalogu.
4. Uruchom plik `start.bat` (możesz sprawdzić, że nie zawiera żadnych payloadów :>)
5. Postępuj zgodnie z instrukcjami na ekranie. Paczka wymaga aby wersja Hopmona była dokładnie taka sama na jakiej ja generowałem patche - sprawdzi ona ten wymóg samodzielnie.
6. Zostanie wygenerowany plik .exe z `patched` w nazwie. Przekopiuj go do oryginalnego katalogu z Hopmonem i zastąp nim oryginalny `Hopmon.exe`.
7. Jeżeli wybrałeś łatki `music` lub `combined` to pobierz z zakładki [Releases](https://github.com/Pieshka/hopmon-patched/releases) paczkę `hopmon-music.zip` i wypakuj znajdujące się w niej pliki MP3 bezpośrednio do katalogu z grą, tak żeby plik `Hopmon.exe` oraz pliki MP3 były obok siebie. Na tym etapie możesz usunąć pliki `.mid` ponieważ nie będą potrzebne.
8. Wszystkie pobrane pliki zip i paczki można bezpiecznie usunąć.

## Sposób ręcznego przygotowania
Jeżeli nie chcesz korzystać z moich łatek i wolisz przygotować sobie samemu odpowiedni plik wykonywalny, to podążaj za tą sekcją. Jest ona jednak przeznaczona dla osób, które się znają na reverse engineering, więc będę zakładał, że wiesz o co chodzi. Ja tylko wskażę konkretne modyfikacji w kodzie.

### Patch music
Domyślnie funkcja `PlayMidi` korzysta z `mciSendString` do odtwarzania muzyki i wywołuje ją w taki sposób:

![PREV_PLAY_MIDI.png](.github/PREV_PLAY_MIDI.png)

Obecność `type sequencer` wymusza traktowanie pliku wejściowego jako sekwencyjnego typu MIDI. Należy wykasować to ze stringa. Zmodyfikowana funkcja powinna wyglądać tak:

![NEW_PLAY_MIDI.png](.github/NEW_PLAY_MIDI.png)

Ponadto w `XApplication::Create()` należy zmienić ładowanie ścieżek do plików i podmienić wpisy `.mid` w nazwach plików na `.mp3`:

![PREV_MIDI_LIST.png](.github/PREV_MIDI_LIST.png)

Po zmodyfikowaniu ścieżki powinny wyglądać tak:

![NEW_MP3_LIST.png](.github/NEW_MP3_LIST.png)

Dzięki tej modyfikacji gra zamiast plików MIDI, będzie odtwarzać pliki MP3. Istnieje również opcja odtwarzania plików WAV. Wystarczy zmienić nazwy z `.mid` na `.wav`.

### Patch resolution
W funkcji `UpdateDialogControls` podczas wypełniania opcji dialogowych pomijane są rozdzielczości większe od 1280x960 oraz głębie bitowe inne niż 16-bit. 

Kod assemblera wygląda jak na poniższym obrazku. Najpierw mamy operacje sprawdzające górną granicę rozdzielczości, a potem operacje sprawdzające głębię bitową.

![PREV_RESOLUTION.png](.github/PREV_RESOLUTION.png)

Możemy całkowicie usunąć wszelkie weryfikacje rozdzielczości i głębi bitowej. Z dostępną przestrzenią, możemy napisać własny format stringa dla funkcji `wsprintfA()`, aby móc wyświetlać głębię bitową w lanuncherze gry. Poniżej znajduje się kod assemblera, który pokazuje jak ta łatka została zaimplementowana w kodzie:
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

### Patch PL base
Tłumaczenie binarki na język polski opiera się na podmianie zasobów za pomocą narzędzi typu [Risoh Editor](https://github.com/katahiromz/RisohEditor). Pliki graficzne i okna dialogowe w języku polskim są dostępne w zakładce [Releases](https://github.com/Pieshka/hopmon-patched/releases) w pliku `hopmon-polish-resources.zip`. Pliki mają nazwy, które odpowiadają identyfikatorom zasobów, więc będzie bardzo łatwo je podmienić. Osobiście uważam, że polskie grafiki są brzydkie (szczególnie gratulacje końcowe).

## Credits
* Szczególne podziękowania dla James Saito za stworzenie mojej gry dzieciństwa czyli Hopmona oraz T.Kinoshita za fenomenalny soundtrack!
* Wersje MP3 oryginalnej ścieżki dźwiękowej zostały wygenerowane przez [Tech&Music Extra](https://www.youtube.com/watch?v=G_BOY0J7tlI)
* Patche zostały przygotowane za pomocą oprogramowania [HDiffPatch](https://github.com/sisong/HDiffPatch)
* Polskie zasoby zostały przygotowane przez zespół tłumaczy z wydawnictwa TopWare Poland dla polskiego wydania Hopmona z 2002 roku.

## License
Wszystkie skrypty i łatki (czyli efektycznie całe repozytorium) są dostępne na licencji Unlicense, czyli w domenie publicznej.
Nie dotyczy to paczek udostępnianych w zakładce [Releases](https://github.com/Pieshka/hopmon-patched/releases), które poza moimi łatkami i skryptami, zawierają też zasoby, których prawa autorskie należą do TopWare Poland oraz T.Kinoshita.

**Pamiętaj, że redystrybucja zmodyfikowanych plików binarnych Hopmona jest niezgodne z jego EULA!**
