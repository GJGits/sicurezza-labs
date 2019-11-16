# Laboratorio n.2

## 1 Algoritmi di cifratura simmetrica

### 1.1    Cifratura simmetrica

Provate a cifrare un blocco di dati col comando OpenSSLenc. Scegliete una chiave di 32 cifre esadecimali escrivetela qui

```
ex-key=67890987654321234567890987654321
```

Usate AES (con chiave di 128 bit) per cifrare il fileptextcon la chiave da voi scelta. Il messaggio cifrato deveessere salvato in un file chiamato ctext.aes128.Scoprite la stringhe di comando OpenSSL da usare per svolgere l’operazione richiesta e scrivetela sotto.  Fatein modo che il comando visualizzi la chiave e l’IV (se l’algoritmo usa un IV) effettivamente usati:

```
openssl enc -aes128 -e -K 67890987654321234567890987654321 -iv 67890987654321234567890987654312 -in ptext -out ctext.aes128 -p

// Output:

salt=C32725B9097F0000
key=67890987654321234567890987654321
iv =67890987654321234567890987654312

``` 
