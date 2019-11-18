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

> Per quanto riguarda DES la chiave deve essere da 64 bit quindi la chiave precedente è stata riadattata.

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


