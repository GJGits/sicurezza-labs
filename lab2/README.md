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

### 1.2 Attacco a forza bruta

Avendo creato diverse macchine virtuali e settato la virtual network procederò con lo scambio file che utilizza ssh piuttosto che creare due utenti sulla stessa macchina. Dopo aver verificato che le due macchine riescono a comunicare tra di loro lanciare `ssh` sulla macchina di Bob.

```sh
systemctl start ssh
```

A questo punto creare una cartella `shared` e e generare il file cifrato richiesto all'interno di questa cartella.

```sh
mkdir shared && openssl enc -e -in ptext -out shared/ctext_alice -K 7 -rc4
hex string is too short, padding with zero bytes to length
```

A questo punto è possibile copiare su Bob il file con il seguente comando

```sh
scp -r shared/ <IP Bob>:/home/Desktop/
```

il file ora si dovrebbe trovare sul Desktop di Bob, tuttavia potrebbe non essere visibile, lanciare il comando `ls` sul desktop di Bob per verificare il buon esito dell'operazione. Per provare ora a decifrare il messaggio posizionarsi sulla macchina di Bob e specificatamente sul Desktop di Bob ed eseguire il seguente comando

```sh
openssl enc -d -in ctext_alice -out ptext -K 1 -rc4 && nano ptext
hex string is too short, padding with zero bytes to length
```

Verificare ad ogni tentativo il messaggio decifrato. Inviamo ora il file `bruteforce_enc` a Bob e ripetiamo la stessa procedura di prima

```sh
scp lab02_support/bruteforce_enc <IP Bob>:/home/Desktop/
```

e su Bob provare a lanciare il comando proposto

```sh
scp lab02_support/bruteforce_enc <IP Bob>:/home/Desktop/
```

Seguendo la procedura prima proposta non sono riuscito a decifrare il messaggio.
Per verificare le prestazioni in termini di tempo impiegato a svolgere le operazioni, è stato creato un apposito script chiamato `testSpeed`, tale comando svolge le seguenti operazioni

- crea dei file di plaintext con dimensione pari a quelle richieste
- cifra i file eseguendo il comando `time` ed il comando `speed`
- decifra i file
- pulisce la cartella eliminando i file di plaintext ed i file cifrati

il comando `time` inoltre stampa i seguenti output:

- **real**: è il time che intercorre da quando viene preso in carica il comando a quando la chiamata termina.
- **user**: quantità di tempo di CPU speso in user mode
- **system**: quantità di tempo di CPU speso in kernel mode

## 2. Algoritmi di cifratura asimmetrica

### 2.1 Generazione di chiavi RSA

La riga di comando per generare una coppia di chiavi RSA a 2048 bit è la seguente:

```sh
openssl genrsa -out rsa.key.alice 2048
```

lanciando il comando proposto viene mostrato il seguente output

```
openssl rsa -in rsa.key.alice -text
RSA Private-Key: (2048 bit, 2 primes)
modulus:
    00:9d:95:1d:1b:56:9c:e6:54:1b:c1:ac:b7:4e:b8:
    c4:62:4b:56:d8:00:38:ed:50:ff:66:7f:a3:2b:26:
    1e:63:83:86:71:cc:25:32:e0:70:0f:41:cf:ec:21:
    30:4f:4c:88:65:e4:3d:e8:71:0a:64:92:da:2f:60:
    a8:2b:4c:96:66:c6:b7:54:b3:11:cc:ea:60:41:79:
    43:47:bb:01:a5:da:b5:26:8b:8b:c5:c2:38:dd:89:
    de:a4:68:b3:51:5e:0b:23:7e:1e:46:8a:29:d9:05:
    3f:76:03:69:8b:5c:d5:14:68:07:73:09:81:7e:8b:
    b0:b9:85:d6:7c:7b:e9:5c:b9:1d:31:a8:96:c3:bc:
    bc:f7:0f:8c:81:b7:05:b2:64:a4:0f:d9:01:de:8f:
    18:6c:ee:0c:a1:80:53:3b:8e:c2:0d:84:35:2c:05:
    95:d9:48:29:41:bc:dd:85:e7:f9:0d:8b:1b:8e:82:
    cf:60:d2:0b:54:c2:d9:b0:e4:d0:e7:34:3a:a0:51:
    9b:99:d1:ab:49:c6:30:a7:7d:4c:b0:bc:5c:18:92:
    6d:5a:a3:77:ae:b3:a4:15:6b:71:a1:bf:96:6e:48:
    f9:ed:af:ca:55:6c:f8:33:70:0d:98:fc:7a:20:8f:
    80:b9:1e:a8:c6:dc:af:d3:41:70:f2:61:5f:e6:0a:
    b0:93
publicExponent: 65537 (0x10001)
privateExponent:
    40:34:57:0d:a2:76:7e:e9:d9:fd:49:2f:ce:a5:3d:
    6e:87:1f:b5:16:32:1b:8f:1a:e0:5a:34:d3:09:ce:
    eb:e0:d4:d0:5c:ca:f3:35:ba:b2:9c:af:e8:97:85:
    25:6a:1b:50:d8:73:d8:d6:e5:d3:20:7a:41:3f:72:
    85:61:c9:0d:ca:fd:3b:47:52:83:59:23:2a:ca:0b:
    7d:98:56:0d:8b:54:af:85:bf:c7:2d:61:19:f2:68:
    82:38:1e:87:92:77:9b:58:71:61:70:3d:a8:ac:98:
    b4:ae:a3:3c:22:f0:b6:45:c4:73:3c:76:44:67:09:
    f4:2c:f1:bc:fa:87:94:3d:3c:3a:ca:b4:63:73:cd:
    6c:ee:38:14:24:de:8b:b2:1e:e0:bc:b6:89:50:e7:
    32:0a:97:93:4f:34:d6:21:35:e9:2c:0f:02:18:1f:
    a6:76:d9:65:30:fc:b8:5b:36:d0:54:53:67:8e:6d:
    e5:d3:61:3a:89:4a:7e:b5:7f:48:17:3e:ea:16:7e:
    00:95:4c:36:29:9b:8a:9d:f6:bd:0e:60:34:3b:75:
    bf:ff:b0:f3:9a:20:8c:e6:b1:d0:9f:59:23:e0:f5:
    d9:34:56:b3:6e:3d:41:34:fd:20:ce:e1:c2:4f:e7:
    93:5c:02:15:ba:da:53:01:e5:31:91:7e:64:2f:dc:
    e1
prime1:
    00:d0:cf:75:5a:36:c4:c7:32:32:fa:ac:fb:73:c6:
    0f:f4:49:02:9d:0f:ff:aa:d9:9b:42:ee:37:4c:f2:
    ba:d6:08:1e:95:95:15:8c:f2:44:41:2b:1b:65:57:
    bd:ea:8d:50:66:41:44:1b:fa:90:27:f8:7a:07:e9:
    47:4d:f4:09:87:ac:64:cd:24:0d:31:ae:ce:81:b3:
    8d:9b:d6:e2:ff:2a:d4:c6:a8:92:60:ad:3f:03:d6:
    51:39:ce:d4:63:c1:91:87:f1:19:ec:81:3e:cc:89:
    57:09:20:6d:2d:91:3d:9a:12:59:de:db:67:8e:10:
    80:68:19:46:cc:77:56:bb:29
prime2:
    00:c1:31:e8:d8:d2:74:9b:0c:05:9c:df:40:1e:0b:
    b1:ad:8b:52:ce:35:97:3a:28:ca:98:2c:5d:85:52:
    91:6c:90:5b:04:a3:63:e8:c7:81:b1:7a:90:a7:78:
    9e:af:3a:0a:15:80:76:3c:52:a1:28:15:41:bb:f0:
    9c:52:a2:43:9d:ca:5c:35:c3:2e:99:49:75:42:ba:
    b4:72:8f:e6:b2:49:c3:4e:cd:ee:cb:ec:bc:96:35:
    54:a2:dc:ef:97:59:44:8d:bf:f9:04:ed:93:e2:9d:
    53:3a:73:09:91:ec:0d:2e:29:1a:37:86:34:ea:67:
    b1:19:3a:72:56:a2:03:01:5b
exponent1:
    00:b2:73:19:8f:67:8e:f3:cd:6a:d3:e0:51:64:b7:
    b7:9a:c5:6a:7e:5f:d5:d7:64:f0:d3:5a:51:d8:68:
    f8:53:41:cd:21:78:af:5a:2d:11:37:c0:67:41:4c:
    a2:f9:78:9b:65:48:11:b4:f7:85:8b:23:46:e6:cb:
    ee:2c:28:8a:9c:70:30:15:40:e2:25:bb:86:b0:41:
    8a:9b:cc:21:62:80:70:26:f6:99:62:15:ac:ec:d2:
    93:c8:1b:82:57:5e:6d:c9:07:bb:67:eb:6c:87:d0:
    37:99:8d:24:c0:f4:86:f8:cd:06:10:f6:e0:a1:00:
    69:3c:8d:9d:7b:cf:e1:47:41
exponent2:
    16:ac:d0:f3:81:e0:05:c2:a7:75:fe:0d:fc:78:ca:
    e5:df:90:5c:7b:95:c0:51:c1:55:92:ff:77:02:75:
    e7:14:1a:5a:b5:02:a8:f3:a1:99:3f:15:73:52:88:
    ed:70:16:76:e7:98:f9:03:89:be:b6:9f:fc:7b:05:
    1d:fd:c5:89:e3:92:67:0c:fd:8f:28:3c:07:14:fa:
    d0:e7:6a:e0:4a:20:0e:43:c5:5f:51:ed:e0:83:69:
    e7:a3:9e:cb:58:c2:df:10:45:1d:fa:f4:7c:88:92:
    98:2d:a0:55:ec:2a:af:dc:4b:23:71:31:0c:c2:16:
    db:2b:2c:f8:56:13:9c:39
coefficient:
    18:4c:9b:e4:d0:3d:91:af:5d:85:7c:7b:c0:e4:fd:
    d6:fe:21:84:ac:52:0e:d3:4d:81:24:6f:9a:b4:b3:
    67:06:ce:52:21:06:c0:ca:aa:58:83:29:98:f2:53:
    13:fb:4b:2b:07:af:ce:bb:82:a0:dc:a7:d6:bc:7f:
    30:a2:d8:3b:db:f9:51:9d:85:5b:63:4d:3f:fb:cd:
    e1:24:1c:0e:2c:ed:84:f2:e0:c7:e0:cd:1e:c9:d4:
    a1:81:cc:c5:12:78:ff:38:55:c1:ab:82:ab:32:a9:
    ed:7b:01:d4:d3:87:5a:67:43:38:23:19:12:6a:00:
    bf:35:98:aa:33:e5:7e:67
writing RSA key
-----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEAnZUdG1ac5lQbway3TrjEYktW2AA47VD/Zn+jKyYeY4OGccwl
MuBwD0HP7CEwT0yIZeQ96HEKZJLaL2CoK0yWZsa3VLMRzOpgQXlDR7sBpdq1JouL
xcI43YnepGizUV4LI34eRoop2QU/dgNpi1zVFGgHcwmBfouwuYXWfHvpXLkdMaiW
w7y89w+MgbcFsmSkD9kB3o8YbO4MoYBTO47CDYQ1LAWV2UgpQbzdhef5DYsbjoLP
YNILVMLZsOTQ5zQ6oFGbmdGrScYwp31MsLxcGJJtWqN3rrOkFWtxob+Wbkj57a/K
VWz4M3ANmPx6II+AuR6oxtyv00Fw8mFf5gqwkwIDAQABAoIBAEA0Vw2idn7p2f1J
L86lPW6HH7UWMhuPGuBaNNMJzuvg1NBcyvM1urKcr+iXhSVqG1DYc9jW5dMgekE/
coVhyQ3K/TtHUoNZIyrKC32YVg2LVK+Fv8ctYRnyaII4HoeSd5tYcWFwPaismLSu
ozwi8LZFxHM8dkRnCfQs8bz6h5Q9PDrKtGNzzWzuOBQk3ouyHuC8tolQ5zIKl5NP
NNYhNeksDwIYH6Z22WUw/LhbNtBUU2eObeXTYTqJSn61f0gXPuoWfgCVTDYpm4qd
9r0OYDQ7db//sPOaIIzmsdCfWSPg9dk0VrNuPUE0/SDO4cJP55NcAhW62lMB5TGR
fmQv3OECgYEA0M91WjbExzIy+qz7c8YP9EkCnQ//qtmbQu43TPK61ggelZUVjPJE
QSsbZVe96o1QZkFEG/qQJ/h6B+lHTfQJh6xkzSQNMa7OgbONm9bi/yrUxqiSYK0/
A9ZROc7UY8GRh/EZ7IE+zIlXCSBtLZE9mhJZ3ttnjhCAaBlGzHdWuykCgYEAwTHo
2NJ0mwwFnN9AHguxrYtSzjWXOijKmCxdhVKRbJBbBKNj6MeBsXqQp3ierzoKFYB2
PFKhKBVBu/CcUqJDncpcNcMumUl1Qrq0co/msknDTs3uy+y8ljVUotzvl1lEjb/5
BO2T4p1TOnMJkewNLikaN4Y06mexGTpyVqIDAVsCgYEAsnMZj2eO881q0+BRZLe3
msVqfl/V12Tw01pR2Gj4U0HNIXivWi0RN8BnQUyi+XibZUgRtPeFiyNG5svuLCiK
nHAwFUDiJbuGsEGKm8whYoBwJvaZYhWs7NKTyBuCV15tyQe7Z+tsh9A3mY0kwPSG
+M0GEPbgoQBpPI2de8/hR0ECgYAWrNDzgeAFwqd1/g38eMrl35Bce5XAUcFVkv93
AnXnFBpatQKo86GZPxVzUojtcBZ255j5A4m+tp/8ewUd/cWJ45JnDP2PKDwHFPrQ
52rgSiAOQ8VfUe3gg2nno57LWMLfEEUd+vR8iJKYLaBV7Cqv3EsjcTEMwhbbKyz4
VhOcOQKBgBhMm+TQPZGvXYV8e8Dk/db+IYSsUg7TTYEkb5q0s2cGzlIhBsDKqliD
KZjyUxP7SysHr867gqDcp9a8fzCi2Dvb+VGdhVtjTT/7zeEkHA4s7YTy4MfgzR7J
1KGBzMUSeP84VcGrgqsyqe17AdTTh1pnQzgjGRJqAL81mKoz5X5n
-----END RSA PRIVATE KEY-----

```
- **modulus**: è il modulo pubblico, quello che nelle slide viene chiamato N
- **publicExponent**: è l'esponente pubblico che generalmente è 65537, nelle slide si chiama E
- **privateExponent**: è l'esponente privato quello che nelle slide viene chiamato D
- **prime1**: è il primo numero primo che viene utilizzato per il calcolo del modulo, quello che nelle slide viene chiamato P
- **prime2**: è il secondo numero primo che viene utilizzato per il calcolo del modulo, quello che nelle slide viene chiamato Q

chiave pubblica=(N,E), mentre la chiave privata è formata da (N,D). Proviamo ora a generare una coppia di chiavi per Bob e visualizziamone il contenuto.

```
openssl rsa -in rsa.key.bob -text
RSA Private-Key: (2048 bit, 2 primes)
modulus:
    00:f6:53:6e:24:d2:9a:08:a0:4b:d7:2d:08:d6:cc:
    b6:d7:f2:d0:23:c3:cb:f7:84:53:c5:05:7d:97:ea:
    aa:f6:b5:d3:44:84:1f:3e:4f:8c:ad:c2:1d:1e:47:
    cc:43:f4:3d:d4:ed:2c:f3:69:7f:42:1f:70:f3:65:
    ec:60:a9:76:88:b7:a4:92:a5:8a:2a:54:bd:94:91:
    c9:9d:50:e4:f1:01:7c:1a:9c:fa:77:e1:09:66:bf:
    e4:fd:23:95:6c:9e:3c:ff:f8:9f:57:8b:ca:8d:fb:
    f3:dc:f4:98:9d:d8:0a:a1:0e:5e:ad:7a:b0:cc:bc:
    04:93:59:a6:c9:f4:f4:da:8a:c2:31:6b:e1:b2:17:
    39:fc:61:6e:2e:14:24:f5:2a:e4:2c:91:d2:41:35:
    2e:59:af:46:f1:91:a0:39:29:42:8d:7f:72:5d:48:
    f2:1b:85:2d:81:8a:d9:ab:69:72:96:f7:c5:4b:b5:
    50:17:d7:16:19:b3:82:a9:23:61:d2:6b:0e:4f:0f:
    cd:11:89:43:d3:ee:fe:2f:94:34:65:f3:82:d5:60:
    28:90:c7:d9:d7:c0:28:b6:4a:b6:fc:3c:17:5e:ef:
    3a:c1:eb:ad:34:03:b6:69:8b:d3:b4:4b:4c:d7:64:
    b6:5f:dc:b0:ac:c1:57:58:a6:1e:31:c9:f6:83:23:
    1a:2b
publicExponent: 65537 (0x10001)
privateExponent:
    00:eb:9f:18:af:ce:68:1b:32:41:f9:7d:11:84:6e:
    63:c4:23:76:a7:8f:65:ee:c8:bc:5c:ad:08:db:25:
    55:0e:13:15:18:e8:0c:fe:cc:97:33:aa:87:b1:ec:
    59:de:f2:a5:a6:a4:8c:a7:f5:d5:0e:0a:07:40:3b:
    d1:a5:10:d4:da:a8:57:9b:13:10:1b:b7:dd:74:5d:
    13:ef:10:6f:3e:7d:fe:19:72:e9:3f:7c:9a:42:97:
    f2:51:96:15:1b:c6:2d:71:68:7f:fa:fd:33:ef:26:
    ff:b8:ee:9b:81:f9:23:09:b6:36:28:59:40:ff:46:
    26:56:50:9e:73:76:86:34:f8:3f:a9:3d:32:1e:80:
    af:30:8d:ad:30:e5:70:ac:bf:9a:a4:03:2a:42:d2:
    0c:5e:8b:5d:de:68:90:ff:5a:20:34:06:45:a7:91:
    5e:59:67:3a:ec:f7:91:98:cf:22:40:74:9a:d2:3e:
    c1:cc:91:1f:22:4d:2f:78:12:b0:d7:c0:96:1c:eb:
    67:26:c4:ad:f6:f2:ca:ff:cb:02:2a:cc:86:9a:e2:
    b3:12:6b:53:b0:23:6f:35:9e:49:5c:bb:c8:50:d2:
    dd:99:a4:bc:fd:22:5a:95:dc:65:be:63:a4:31:fa:
    d6:6b:83:29:c6:58:ea:2c:e6:f0:1e:c9:dd:54:bb:
    4f:69
prime1:
    00:fb:6c:41:9b:86:84:b6:23:44:dc:e3:4a:09:49:
    3b:57:6a:fb:cc:37:b5:46:a2:1c:b0:98:49:09:85:
    b9:d2:c5:27:eb:50:47:5e:a8:c1:c6:b5:b4:2f:77:
    ec:0d:a5:ce:ea:31:49:a1:38:44:94:c9:47:e7:29:
    51:c9:b7:5f:38:8b:66:32:9d:a6:21:9e:0a:f4:16:
    f6:d8:5a:a0:42:87:18:22:00:3f:79:d5:f8:84:56:
    bc:5b:52:0b:44:81:51:d2:05:ee:72:2c:ed:70:3b:
    28:84:43:7f:a7:97:a7:71:5d:1b:3a:3c:81:a3:e5:
    bf:03:4a:86:47:d7:40:6a:bd
prime2:
    00:fa:cf:6b:75:c0:03:8b:28:27:c0:f3:39:aa:c2:
    05:e7:fe:a4:38:a8:79:93:20:3b:cb:b8:0a:fb:26:
    a1:68:fc:9d:62:3f:e5:82:66:65:47:bc:35:58:98:
    92:d3:36:eb:d3:17:79:55:a5:f7:f7:ff:e8:ec:61:
    08:0b:c0:b9:f3:40:12:aa:ce:98:0f:96:24:b7:6d:
    ac:4b:2a:d3:e6:a0:8b:95:f3:02:21:fa:7d:72:ea:
    7b:e4:51:ed:14:6e:28:b7:91:2f:e2:bc:4f:53:f6:
    70:1a:17:b8:a8:81:54:af:85:f0:cc:95:c8:6e:85:
    8a:42:55:07:66:22:9b:5b:07
exponent1:
    37:86:03:c3:1d:e4:e6:f8:48:f7:e2:f5:f1:b1:0b:
    7a:d5:b4:7f:b7:f9:bf:7c:83:8b:78:46:00:e5:58:
    51:34:9b:09:3b:74:57:72:3b:40:ef:d5:b7:f9:ea:
    d6:64:bc:9a:39:82:42:29:53:f3:eb:b3:86:58:38:
    a8:ac:67:49:ec:77:08:4c:8a:68:b8:27:41:1a:65:
    2f:08:6c:85:e4:a1:ae:b8:91:4c:0d:b5:d1:3b:fa:
    62:cc:6e:92:95:60:85:5a:2b:fb:68:f2:92:ab:6d:
    da:2f:b1:dc:48:00:81:67:87:60:c8:05:f5:35:02:
    86:ee:89:53:0a:35:3e:9d
exponent2:
    00:96:9c:96:20:48:a5:18:1c:8d:fa:cd:54:54:d9:
    5c:68:9b:3e:8c:93:87:26:35:96:12:d8:bb:27:64:
    64:4b:42:5f:54:4f:a0:87:f4:eb:5e:ef:83:6d:67:
    79:cc:02:50:0d:1c:2c:8d:a5:33:ca:26:4f:fe:1a:
    aa:95:3c:2f:ae:06:4c:ef:6b:4e:5f:15:bf:88:b3:
    00:62:c7:1e:26:81:44:31:50:93:78:4a:0e:a9:42:
    6c:11:88:ad:00:b6:c2:16:b1:c5:fa:b7:30:3f:f0:
    5e:13:1d:29:93:6e:ce:a6:f4:9c:cc:8e:29:a5:4c:
    e5:e0:bd:64:cb:0d:7f:13:63
coefficient:
    05:0c:96:a8:4c:7a:20:b4:ef:4b:2b:38:73:86:b6:
    2d:e7:40:b2:0d:63:cb:0f:33:96:86:56:af:cf:2b:
    a1:a4:7f:c2:49:ee:75:a4:ac:15:72:b7:a2:90:33:
    ad:da:97:56:55:59:b7:09:27:25:0d:63:08:bc:d3:
    d0:df:34:e6:63:1f:9a:ad:e3:1b:88:fb:d0:d5:d9:
    90:28:b2:4f:9c:9a:ed:69:ca:1f:62:87:73:bf:e4:
    d0:07:0a:7f:1f:d1:1f:f9:9e:8a:d8:2e:c1:ec:7f:
    9d:38:fd:d5:03:0c:6f:f4:18:0a:59:09:42:16:d1:
    21:68:5d:da:3c:2d:94:af
writing RSA key
-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEA9lNuJNKaCKBL1y0I1sy21/LQI8PL94RTxQV9l+qq9rXTRIQf
Pk+MrcIdHkfMQ/Q91O0s82l/Qh9w82XsYKl2iLekkqWKKlS9lJHJnVDk8QF8Gpz6
d+EJZr/k/SOVbJ48//ifV4vKjfvz3PSYndgKoQ5erXqwzLwEk1mmyfT02orCMWvh
shc5/GFuLhQk9SrkLJHSQTUuWa9G8ZGgOSlCjX9yXUjyG4UtgYrZq2lylvfFS7VQ
F9cWGbOCqSNh0msOTw/NEYlD0+7+L5Q0ZfOC1WAokMfZ18Aotkq2/DwXXu86weut
NAO2aYvTtEtM12S2X9ywrMFXWKYeMcn2gyMaKwIDAQABAoIBAQDrnxivzmgbMkH5
fRGEbmPEI3anj2XuyLxcrQjbJVUOExUY6Az+zJczqoex7Fne8qWmpIyn9dUOCgdA
O9GlENTaqFebExAbt910XRPvEG8+ff4Zcuk/fJpCl/JRlhUbxi1xaH/6/TPvJv+4
7puB+SMJtjYoWUD/RiZWUJ5zdoY0+D+pPTIegK8wja0w5XCsv5qkAypC0gxei13e
aJD/WiA0BkWnkV5ZZzrs95GYzyJAdJrSPsHMkR8iTS94ErDXwJYc62cmxK328sr/
ywIqzIaa4rMSa1OwI281nklcu8hQ0t2ZpLz9IlqV3GW+Y6Qx+tZrgynGWOos5vAe
yd1Uu09pAoGBAPtsQZuGhLYjRNzjSglJO1dq+8w3tUaiHLCYSQmFudLFJ+tQR16o
wca1tC937A2lzuoxSaE4RJTJR+cpUcm3XziLZjKdpiGeCvQW9thaoEKHGCIAP3nV
+IRWvFtSC0SBUdIF7nIs7XA7KIRDf6eXp3FdGzo8gaPlvwNKhkfXQGq9AoGBAPrP
a3XAA4soJ8DzOarCBef+pDioeZMgO8u4CvsmoWj8nWI/5YJmZUe8NViYktM269MX
eVWl9/f/6OxhCAvAufNAEqrOmA+WJLdtrEsq0+agi5XzAiH6fXLqe+RR7RRuKLeR
L+K8T1P2cBoXuKiBVK+F8MyVyG6FikJVB2Yim1sHAoGAN4YDwx3k5vhI9+L18bEL
etW0f7f5v3yDi3hGAOVYUTSbCTt0V3I7QO/Vt/nq1mS8mjmCQilT8+uzhlg4qKxn
Sex3CEyKaLgnQRplLwhsheShrriRTA210Tv6YsxukpVghVor+2jykqtt2i+x3EgA
gWeHYMgF9TUChu6JUwo1Pp0CgYEAlpyWIEilGByN+s1UVNlcaJs+jJOHJjWWEti7
J2RkS0JfVE+gh/TrXu+DbWd5zAJQDRwsjaUzyiZP/hqqlTwvrgZM72tOXxW/iLMA
YsceJoFEMVCTeEoOqUJsEYitALbCFrHF+rcwP/BeEx0pk27OpvSczI4ppUzl4L1k
yw1/E2MCgYAFDJaoTHogtO9LKzhzhrYt50CyDWPLDzOWhlavzyuhpH/CSe51pKwV
creikDOt2pdWVVm3CSclDWMIvNPQ3zTmYx+areMbiPvQ1dmQKLJPnJrtacofYodz
v+TQBwp/H9Ef+Z6K2C7B7H+dOP3VAwxv9BgKWQlCFtEhaF3aPC2Urw==
-----END RSA PRIVATE KEY-----

```

come già preventivato il publicExponent rimane lo stesso. Per estrarre la chiave pubblica è possibile lanciare il seguente comando:

```sh
openssl rsa -in rsa.key.alice -out rsa.pubkey -pubout
```

è possibile anche visualizzare il contenuto del file come fatto prima

```sh
openssl rsa -in rsa.pubkey -pubin -text

RSA Public-Key: (2048 bit)
Modulus:
    00:9d:95:1d:1b:56:9c:e6:54:1b:c1:ac:b7:4e:b8:
    c4:62:4b:56:d8:00:38:ed:50:ff:66:7f:a3:2b:26:
    1e:63:83:86:71:cc:25:32:e0:70:0f:41:cf:ec:21:
    30:4f:4c:88:65:e4:3d:e8:71:0a:64:92:da:2f:60:
    a8:2b:4c:96:66:c6:b7:54:b3:11:cc:ea:60:41:79:
    43:47:bb:01:a5:da:b5:26:8b:8b:c5:c2:38:dd:89:
    de:a4:68:b3:51:5e:0b:23:7e:1e:46:8a:29:d9:05:
    3f:76:03:69:8b:5c:d5:14:68:07:73:09:81:7e:8b:
    b0:b9:85:d6:7c:7b:e9:5c:b9:1d:31:a8:96:c3:bc:
    bc:f7:0f:8c:81:b7:05:b2:64:a4:0f:d9:01:de:8f:
    18:6c:ee:0c:a1:80:53:3b:8e:c2:0d:84:35:2c:05:
    95:d9:48:29:41:bc:dd:85:e7:f9:0d:8b:1b:8e:82:
    cf:60:d2:0b:54:c2:d9:b0:e4:d0:e7:34:3a:a0:51:
    9b:99:d1:ab:49:c6:30:a7:7d:4c:b0:bc:5c:18:92:
    6d:5a:a3:77:ae:b3:a4:15:6b:71:a1:bf:96:6e:48:
    f9:ed:af:ca:55:6c:f8:33:70:0d:98:fc:7a:20:8f:
    80:b9:1e:a8:c6:dc:af:d3:41:70:f2:61:5f:e6:0a:
    b0:93
Exponent: 65537 (0x10001)
writing RSA key
-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAnZUdG1ac5lQbway3TrjE
YktW2AA47VD/Zn+jKyYeY4OGccwlMuBwD0HP7CEwT0yIZeQ96HEKZJLaL2CoK0yW
Zsa3VLMRzOpgQXlDR7sBpdq1JouLxcI43YnepGizUV4LI34eRoop2QU/dgNpi1zV
FGgHcwmBfouwuYXWfHvpXLkdMaiWw7y89w+MgbcFsmSkD9kB3o8YbO4MoYBTO47C
DYQ1LAWV2UgpQbzdhef5DYsbjoLPYNILVMLZsOTQ5zQ6oFGbmdGrScYwp31MsLxc
GJJtWqN3rrOkFWtxob+Wbkj57a/KVWz4M3ANmPx6II+AuR6oxtyv00Fw8mFf5gqw
kwIDAQAB
-----END PUBLIC KEY-----

```

### 2.2 Operazioni di cifratura e decifratura asimmetrica con algoritmo RSA

Supponendo di dover inviare il messaggio in maniera confidenziale, dobbiamo cifrare il messaggio con la chiave pubblica in modo tale che il ricevente lo possa decifrare con la chiave privata che è tenuta segreta dal ricevente del messaggio.

```sh
openssl pkeyutl -encrypt -in plain -out encRSA -inkey rsa.pubkey -pubin
```

Il comando proposta cifra il file plain e salva il contenuto in plain.enc.RSA.for.name, la chiave utilizzata è la chiave privata. Supponiamo di voler decifrare il messaggio sopra cifrato in un file decRSA, il comando da utilizzare è il seguente:

```sh
openssl pkeyutl -decrypt -in encRSA -out decRSA -inkey rsa.key.alice
```

lanciando il comando `diff` si può constatare che il contenuto di `plain` è identico al contenuto di `decRSA`. Dopo aver scaricato il pdf, provando a cifrarlo in cui è stato cifrato precedentemente il file `plain` in precedenza otteniamo il seguente risultato.

```sh
openssl pkeyutl -encrypt -in chap8.pdf -out ciph_chap8.pdf -inkey rsa.pubkey -pubin
Public Key operation error
139965432771712:error:0406D06E:rsa routines:RSA_padding_add_PKCS1_type_2:data too large for key size:../crypto/rsa/rsa_pk1.c:125:
```

Il motivo del messaggio d'errore è stato spiegato nella nota dell'esercizio.

### 2.3 Operazioni di firma e verifica con l'algoritmo RSA

Il comando `pkeyutl` offre una serie di comandi che servono sia a cifrare/decifrare che a firmare/verificare. Nel processo di cifratura/decifratura si:

- cifra con la funzione `-encrypt` al quale si passa la chiave pubblica (privata)
- decifra con la funzione `-decrypt` al quale si passa la chiave privata (pubblica)

La firma digitale di un documento invece consiste nel calcolare un hash del file e cifrarlo con la chiave privata del mittente. A questo punto il ricevente può decifrare il digest utilizzando la chiave pubblica del mittente e confrontarlo con l'hash calcolato sul documento ricevuto, che a sua volta può essere in chiaro o meno. Per effettuare la firma di un documento il comando `pkeyutl` fornisce degli appositi flag.

```sh

# 1. generare la firma da memorizzare in sign
openssl pkeyutl -sign -in plain -out sign -inkey rsa.key.alice

# 2 verifico la firma
openssl pkeyutl -verify -in plain -inkey rsa.key.alice -sigfile sign
Signature Verified Successfully
```

### Generazione di chiavi EC

Per informazioni sul comando `ecparam` è possibile visualizzare il link [ecparam](https://wiki.openssl.org/index.php/Command_Line_Elliptic_Curve_Operations), in particolare risulta utile eseguire un comando per prendere visione degli algoritmi implementati.

```sh
openssl ecparam -list_curves
```
il comando che ci viene richiesto è quindi `secp192k1`.

```sh

# 1. generare la curva
openssl ecparam -name secp192k1 -out ec.key.alice -genkey -noout

# 2. mostrare i parametri associati alla curva
openssl ecparam -in ec.key.alice -text -param_enc explicit -noout
Field Type: prime-field
Prime:
    00:ff:ff:ff:ff:ff:ff:ff:ff:ff:ff:ff:ff:ff:ff:
    ff:ff:ff:ff:ff:fe:ff:ff:ee:37
A:    0
B:    3 (0x3)
Generator (uncompressed):
    04:db:4f:f1:0e:c0:57:e9:ae:26:b0:7d:02:80:b7:
    f4:34:1d:a5:d1:b1:ea:e0:6c:7d:9b:2f:2f:6d:9c:
    56:28:a7:84:41:63:d0:15:be:86:34:40:82:aa:88:
    d9:5e:2f:9d
Order: 
    00:ff:ff:ff:ff:ff:ff:ff:ff:ff:ff:ff:fe:26:f2:
    fc:17:0f:69:46:6a:74:de:fd:8d
Cofactor:  1 (0x1)

# 3. mostrare il contenuto del file
cat ec.key.alice 
-----BEGIN EC PRIVATE KEY-----
MFwCAQEEGErUDfK3gJxVWaiS06OOAG2PFtvgHZxARKAHBgUrgQQAH6E0AzIABGzQ
P/NMrC3VD+ZwUFHGJSHkLUlJQtRU9gfvpm3vi5WgZLNxDIDisBPJtjtIqoWOow==
-----END EC PRIVATE KEY-----
```

Per estrarre la chiave pubblica dalla chiave privata precedentemente creata è possibile eseguire il seguente messaggio:

```sh
openssl ec -in ec.key.alice -pubout -out ec.pubkey.alice
read EC key
writing EC key
```
Il processo di firma e verifica resta invariato rispetto a prima, cambia semplicemente il tipo di chiavi utilizzate, non si usa RSA come in precedenza, ma curve ellittiche.

```sh

# 1. generare la firma da memorizzare in ecsign
openssl pkeyutl -sign -in plain -out ecsign -inkey ec.key.alice 

# 2. verifico la firma
openssl pkeyutl -verify -in plain -inkey ec.key.alice -sigfile ecsign
Signature Verified Successfully


```

### 2.6 Prestazioni

**test RSA**

```sh

openssl speed rsa512 \
> && openssl speed rsa1024 \
> && openssl speed rsa2048 \
> && openssl speed rsa4096

                  sign    verify    sign/s verify/s
rsa  512 bits 0.000074s 0.000008s  13554.5 128084.7
rsa 1024 bits 0.000212s 0.000014s   4716.2  70377.9
rsa 2048 bits 0.001053s 0.000042s    949.6  23656.6
rsa 4096 bits 0.009187s 0.000187s    108.8   5348.9

```

la complesità delle operazioni dipende dal numero di bit con valore 1 negli esponenti E e D, dove E rappresenta l'esponente pubblico, mentre D rappresenta l'esponente privato. Nell'implementazione standard l'esponente pubblico è 65537 come visto in precedenza, questo è un numero con tanti bit ad 1 rendendo le operazioni più semplici. Nel processo di firma e verifica, l'esponente E viene utilizzato per decifrare, ecco il perché della differenza di risultati.

**test RSA, DSA, ECDSA**

```sh

openssl speed rsa1024 \
> && openssl speed dsa1024 \
> && openssl speed ecdsap160

                                sign    verify    sign/s verify/s
rsa 1024 bits                0.000146s 0.000012s   6839.0  82177.4
dsa 1024 bits                0.000239s 0.000180s   4187.2   5542.2
160 bits ecdsa (secp160r1)   0.0006s     0.0007s   1790.8   1500.1


```

da questa analisi di massima si nota che DSA è molto più lento a parità di lunghezza della chiave, inoltre nonostante una chiave di soli 160 bit l'algoritmo a curve ellittiche è nettamente più lento degli altri due metodi.

**test RSA2018, DSA2048, ECDSA256**

```sh

openssl speed rsa2048 \
> && openssl speed dsa2048 \
> && openssl speed ecdsap256

                              sign    verify    sign/s verify/s
rsa 2048 bits             0.000730s 0.000036s   1370.4  27433.2
dsa 2048 bits             0.000596s 0.000503s   1677.9   1989.7
256 bits ecdsa (nistp256)   0.0000s   0.0001s  22842.9   6978.0


```

**test RSA2048, DSA2048, AES128,SHA256**

```sh

openssl speed rsa2048 \
> && openssl speed dsa2048 \
> && openssl speed aes-128-cbc \
> && openssl speed sha256

                  sign    verify    sign/s verify/s
rsa 2048 bits 0.000748s 0.000037s   1336.8  27150.4
dsa 2048 bits 0.000590s 0.000513s   1695.4   1950.8

---

Doing aes-128 cbc for 3s on 16 size blocks: 22639706 aes-128 cbc's in 2.99s
Doing aes-128 cbc for 3s on 64 size blocks: 6746347 aes-128 cbc's in 2.98s
Doing aes-128 cbc for 3s on 256 size blocks: 1763078 aes-128 cbc's in 2.99s
Doing aes-128 cbc for 3s on 1024 size blocks: 1010034 aes-128 cbc's in 2.99s
Doing aes-128 cbc for 3s on 8192 size blocks: 102634 aes-128 cbc's in 2.94s
Doing aes-128 cbc for 3s on 16384 size blocks: 63265 aes-128 cbc's in 2.99s

The 'numbers' are in 1000s of bytes per second processed.
type             16 bytes     64 bytes    256 bytes   1024 bytes   8192 bytes  16384 bytes
aes-128 cbc     121148.93k   144887.99k   150952.50k   345911.31k   285978.82k   346666.81k

---

Doing sha256 for 3s on 16 size blocks: 10029654 sha256's in 2.97s
Doing sha256 for 3s on 64 size blocks: 5404949 sha256's in 2.96s
Doing sha256 for 3s on 256 size blocks: 3035423 sha256's in 2.97s
Doing sha256 for 3s on 1024 size blocks: 1007572 sha256's in 2.98s
Doing sha256 for 3s on 8192 size blocks: 137003 sha256's in 2.97s
Doing sha256 for 3s on 16384 size blocks: 68918 sha256's in 2.96s

The 'numbers' are in 1000s of bytes per second processed.
type             16 bytes     64 bytes    256 bytes   1024 bytes   8192 bytes  16384 bytes
sha256           54031.81k   116863.76k   261639.15k   346226.08k   377888.41k   381470.44k


```

## Algoritmi di digest

### Calcolare e verificare un messaggio di digest

Per effettuare i digest richiesti lanciare il comando 


```sh

openssl dgst -md5 -out MD5dgst msg \
> && openssl dgst -sha1 -out SHA1dgst msg \
> && openssl dgst -sha1 -out SHA1dgst msg \
> && openssl dgst -sha256 -out SHA256dgst msg \
> && openssl dgst -sha3-256 -out SHA3-256dgst msg

```

verifichiamo come cambiano i vari digest eliminando il punto esclamativo.

```sh

echo $(cat msg) | cut -c1-56 | openssl dgst -md5 | cut -c10- \ 
> && cat MD5dgst | cut -c11-

cb0339a7dfe988945788d5597b31d633
31b047795a155ff6be701e37012a9bf4

---

echo $(cat msg) | cut -c1-56 | openssl dgst -sha1 | cut -c10- 
> && cat SHA1dgst | cut -c12-

082ec7c84a8b300759821985cbed9dffd71fb9b0
e79e769b86676ac2748873215d1793a0a47ee64f

---

echo $(cat msg) | cut -c1-56 | openssl dgst -sha256 | cut -c10- \
> && cat SHA256dgst | cut -c14-

e9b651a102fee8a6ee8354fd7caff31dce604c7d624205222fe47022ae23f611
e11ebb0fde8110f74768bbb3914c9f1d76bfdfc190c1d2d43da0e5aef44f65ba

```

confrontando i vari messaggi si può facilmente intuire che una modifica anche solo di un carattere cambia dtrasticamente il digest.

