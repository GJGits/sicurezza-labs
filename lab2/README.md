# Laboratorio n.2

## 1 Algoritmi di cifratura simmetrica

### 1.1    Cifratura simmetrica

Provate a cifrare un blocco di dati col comando OpenSSLenc. Scegliete una chiave di 32 cifre esadecimali escrivetela qui

```sh
ex-key=67890987654321234567890987654321
```

Usate AES (con chiave di 128 bit) per cifrare il fileptextcon la chiave da voi scelta. Il messaggio cifrato deveessere salvato in un file chiamato ctext.aes128.Scoprite la stringhe di comando OpenSSL da usare per svolgere l’operazione richiesta e scrivetela sotto.  Fatein modo che il comando visualizzi la chiave e l’IV (se l’algoritmo usa un IV) effettivamente usati:

```sh 
openssl enc -aes128 -e -K 67890987654321234567890987654321 -iv 67890987654321234567890987654312 -in ptext -out ctext.aes128 -p

salt=C32725B9097F0000
key=67890987654321234567890987654321
iv =67890987654321234567890987654312
```

Scoprite la stringhe di comando OpenSSL da usare per cifrareptextcon gli algoritmi DES, RC4 e 3DES conla chiave da voi scelta. Il messaggio cifrato deve essere salvato in un file chiamatoctext.algoritmo.

> Per quanto riguarda DES la chiave deve essere da 64 bit quindi la chiave precedente è stata riadattata. In realtà la chiave effettivamente utilizzata è lunga 56 bit, 8 sono di checksum, tuttavia la libreria richiede una chiave di 64 bit altrimenti effettua un padding di zeri

```sh 
openssl enc -DES -e -K 6789098765432121 -iv 6789098765431221 -in ptext -out ctext.DES -p

salt=C337F9104A7F0000
key=6789098765432121
iv =6789098765431221
```

> RC4 non usa iv quindi viene omesso dal comando

```sh 
openssl enc -RC4 -e -K 67890987654321234567890987654321 -in ptext -out ctext.RC4 -p
salt=C3A73B8EF77F0000
key=67890987654321234567890987654321
```

> Analogamente al DES 3-DES richiede una chiave lunga 192 bit anche se poi effettivamente ne vengono utilizzati solo 168. Il vettore di inizializzazione rimane quello del DES, lungo quindi 64 bit.

```sh
openssl enc -des3 -e -K 678909876543212345678909876543211234567898765432 -iv 6789098765432123 -in ptext -out ctext.de3 -p
salt=00FF4647EA550000
key=678909876543212345678909876543211234567898765432
iv =6789098765432123

```

Quali altre scelte dobbiamo compiere nel caso di DES, 3DES e AES?

```sh
in che senso?
```

Lunghezze dei vari ctext.* e ptext

```sh
stat -c "%s %n" *
48 ctext.aes128
40 ctext.de3
40 ctext.DES
32 ctext.RC4
32 ptext
2638 README.md

```

> ptext ha dimensione 32 byte che nel caso di AES128 equivale a due blocchi, nel caso dei DES corrisponde a quattro blocchi. Avendo il messaggio una dimensione che è esattamente un multiplo dei blocchi ci si trova nel caso più sfavorevole, ovvero quello in cui si deve aggiungere un intero blocco di padding. Nel caso di RC4 non viene aggiunto nulla in quanto questo non è un algoritmo a blocchi.

Potrebbe essere interessante osservare il contenuto dei file per analizzare le tecniche di padding utilizzate.

```sh

od -t x1 ctext.aes128 
0000000 31 d0 56 00 4c 87 18 44 e1 58 ea 04 1d 8b aa ae
0000020 3b 5e 5e 60 68 10 0e 64 d0 84 dc ed 65 3e 13 f0
0000040 39 48 c0 8e 05 7b 67 d3 9c 20 ce 21 a4 0c c8 a1
0000060

-----

od -t x1 ctext.de3
0000000 e3 c4 8f bf 6d 98 40 88 a6 3e dc a1 b1 0a d4 03
0000020 4a 31 3f 2e 65 5c 19 b8 af 0c 13 1c dc 07 d9 a0
0000040 8f c9 83 8c 4b 37 81 80
0000050

-----

od -t x1 ctext.DES 
0000000 ee c3 50 5f 95 3d cd 7e e6 b2 4c 21 29 69 41 f0
0000020 00 4a 0e cc ed 4e 12 ba 09 d4 18 ef 48 e4 45 18
0000040 b0 ae 0e 96 83 0c 8d 5f
0000050


```

Provate adesso cosa succede usando il seguente comando

```sh

openssl enc -e -in ptext -out ctext.aes128.nopad -K 67890987654321234567890987654321 -iv 67890987654321234567890987654312  -aes-128-cbc -nopad -p
salt=00BF77236A550000
key=67890987654321234567890987654321
iv =67890987654321234567890987654312

-----

stat -c "%s %n" *
48 ctext.aes128
32 ctext.aes128.nopad
40 ctext.de3
40 ctext.DES
32 ctext.RC4
32 ptext
3796 README.md

-----

od -t x1 ctext.aes128.nopad 
0000000 31 d0 56 00 4c 87 18 44 e1 58 ea 04 1d 8b aa ae
0000020 3b 5e 5e 60 68 10 0e 64 d0 84 dc ed 65 3e 13 f0
0000040

```
avendo utilizzato l'opzione `nopad` non è stato aggiunto alcun padding. Proviamo ad effettuare la stessa prova dopo aver creato un `ptext2` contenente il seguente messaggio: `messaggio numero due` che non ha una dimensione che è un multiplo del blocco.

```sh

openssl enc -e -in ptext2 -out ctext.aes128.nopad2 -K 67890987654321234567890987654321 -iv 67890987654321234567890987654312  -aes-128-cbc -nopad -p
salt=000FD54F32560000
key=67890987654321234567890987654321
iv =67890987654321234567890987654312
bad decrypt
140300172985472:error:0607F08A:digital envelope routines:EVP_EncryptFinal_ex:data not multiple of block length:../crypto/evp/evp_enc.c:425:

```

Per utilizzare l'algoritmo Chacha20 bisogna utilizzare una chiave di lunghezza pari al messaggio da cifrare altrimenti su questa vengono aggiunti dei byte di padding come nel seguente caso

```sh

openssl enc -e -in ptext -out ctext.chacha20 -K 67890987654321234567890987654321 -iv 67890987654321234567890987654312  -chacha20 -p
hex string is too short, padding with zero bytes to length
salt=00BF7AA985550000
key=6789098765432123456789098765432100000000000000000000000000000000
iv =67890987654321234567890987654312


```

la chiave utilizzata infatti è lunga 128 bit, mentre il messaggio è lungo 256 bit. Passiamo quindi a verificare che i messaggi siano propriamente decifrati utilizzando l'apposita chiave

```sh
openssl enc -aes128 -d -K 67890987654321234567890987654321 -iv 67890987654321234567890987654312 -in ctext.aes128 -out dtext.aes128 -p && cmp ptext dtext.aes128
salt=00CF725C5D550000
key=67890987654321234567890987654321
iv =67890987654321234567890987654312
```

il fatto che il comando `cmp` non restituisca nessun output ci conferma che i due file sono identici e la decifratura è andata a buon fine. Allo stesso modo si possono decifrare gli altri file. Cosa succede quando non si forniscono un valore per la chiave ed il vettore di inizializzazione?

```sh
openssl enc -e -in ptext -out ctext -aes-128-cbc -p
enter aes-128-cbc encryption password:
Verifying - enter aes-128-cbc encryption password:
*** WARNING : deprecated key derivation used.
Using -iter or -pbkdf2 would be better.
salt=CAFC2CB31CD46FFC
key=EBE82D184F7A6722262F433273FFAE70
iv =9051973CA95A7DA03668F1C504230162
```
come si evince dall'output quello che succede è che la funzione ci chiede di inserire una password che verrà utilizzata per ottenere una chiave ed un vettore di inizializzazione.
