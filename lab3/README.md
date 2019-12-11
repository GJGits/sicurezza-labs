# 1. Applicazione della crittografia: integrità
## 1.1 Autenticazione di messaggio (Message Authentication Code)
### 1.1.1 Creazione manuale di un keyed digest

Per creare il file `msg` eseguire il seguente comando

```sh
$ touch msg && echo "Questo è un messaggio di prova per la creazione di un keyed-digest!" >> msg && touch key && echo "1234567890987654" >> key
```

In questo primo esercizio è richiesto di calcolare un keyed digest in maniera manuale, cioè senza l'utilizzo di funzioni built-in.

```sh

$ cat key msg key | openssl dgst -sha256

(stdin)= acb9ff39c7b39402311fcd8b82bdefcb1c90e77d7d5505eba4cef196a669b839

```

Ricordiamo che hmac necessita di una chiave non troppo più piccola di un blocco e che con il comando precedente non viene creato un file di output. Per verificarlo Bob deve essere a conoscenza della chiave simmetrica. Una volta ottenuto il messaggio quello che Bob deve fare è:

- decifrare l'hmac
- calcolare l'hash del messaggio ricevuto
- confrontare hash ricevuto con hash calcolato

Per utilizzare invece la funzione built-in bisogna eseguire il seguente comando

```sh

$ openssl dgst -sha256 -out msg.hmac -hmac 1234567890987654 msg && cat msg.hmac

HMAC-SHA256(msg)= 407644c924b16beb39a6d071ca7aab8a3a97ef9c08717861b3c59c9f9a86a314
```
due possibili applicazioni sono

- autenticazione tramite keyed-digest
- autenticazione e integrità

Per verificare l'hmac generato in precedenze eseguire il comando

```sh

$ openssl dgst -sha256 -out msg.hmac2 -hmac 1234567890987654 msg \
> && diff msg.hmac msg.hmac2 -s \
> && rm msg.hmac2
Files msg.hmac and msg.hmac2 are identical

```

Per non modificare il file iniziale creo un file `msg2`.

```sh

$ touch msg2 && cat msg | cut -c-20 msg >> msg2 && openssl dgst -sha256 -out msg2.hmac -hmac 1234567890987654 msg2 && diff msg.hmac msg2.hmac -s && rm msg2.hmac && rm msg2

< HMAC-SHA256(msg)= 407644c924b16beb39a6d071ca7aab8a3a97ef9c08717861b3c59c9f9a86a314
---
> HMAC-SHA256(msg2)= cc81b470b75cb611a4c765f04e2fec955d69292c9fc9b7d07a34a7a10359d8ac
```

come si nota i due hmac non coincidono. Un attaccante in questo caso se non conosce la chiave non può calcolare l'hash.

## 1.2 Authenticated Encryption with Associated Data (AEAD)

Per ottenere gli algoritmi richiesti è possibile utilizzare il seguente comando

```sh
$ openssl list -cipher-algorithms | egrep 'CCM|GCM|OCB|EAX'
```

Per eseguire lo script proposto posizionarsi nella cartella `lab3` ed eseguire il seguente comando dopo essersi assicurati che lo script `aes-gcm.py` sia eseguibile.

```sh
$ ./aes-gcm.py -e plain aad cipher tag -K 12345678909876543212345678900987 -iv 09876543211234567890098765432112
```

Anche in questo caso invece di alterare il file principale creo un secondo file `plain2` al quale apporto delle modifiche per poi effettuare le verifiche richieste.

```sh
$ touch plain2 && echo "Bob, forse questo è ancora più segreto" >> plain2 && ./aes-gcm.py -e plain2 aad ciphertext2 tag2 -K 12345678909876543212345678900987 -iv 09876543211234567890098765432112

```

lanciando il comando `diff` su chiper/chiphertext2 e su tag/tag2 ci si accorge che i file non coincidono. Proviamo ora ad effettuare la funzione inversa. In un primo caso utilizziamo i file corretti (chiper,tag,aad), nel secondo caso invece utilizziamo (chipher, tag2, aad) che dovrebbe generare un errore.

```sh

$ ./aes-gcm.py -d plain3 aad cipher tag -K 12345678909876543212345678900987 -iv 09876543211234567890098765432112
12345678909876543212345678900987
Decryption successfully completed.

$ diff plain3 plain -s
Files plain3 and plain are identical

$ ./aes-gcm.py -d plain4 aad cipher tag2 -K 12345678909876543212345678900987 -iv 09876543211234567890098765432112
12345678909876543212345678900987
Decryption Traceback (most recent call last):
  File "./aes-gcm.py", line 119, in <module>
    main()
  File "./aes-gcm.py", line 110, in main
    open(sys.argv[5],"rb").read()
  File "./aes-gcm.py", line 49, in decrypt
    return decryptor.update(ciphertext) + decryptor.finalize()
  File "/usr/lib/python3/dist-packages/cryptography/hazmat/primitives/ciphers/base.py", line 198, in finalize
    data = self._ctx.finalize()
  File "/usr/lib/python3/dist-packages/cryptography/hazmat/backends/openssl/ciphers.py", line 170, in finalize
    raise InvalidTag
cryptography.exceptions.InvalidTag

```

Creiamo un nuovo file contenente gli associated data e salviamolo in `aad2`. Ripetiamo quindi le due operazioni precedenti utilizzando ora questo file. Per comodità il plain generato sarà sempre diverso per poter osservare alla fine tutte le differenze.

```sh

$ ./aes-gcm.py -d plain5 aad2 cipher tag -K 12345678909876543212345678900987 -iv 09876543211234567890098765432112
12345678909876543212345678900987
Decryption Traceback (most recent call last):
  File "./aes-gcm.py", line 119, in <module>
    main()
  File "./aes-gcm.py", line 110, in main
    open(sys.argv[5],"rb").read()
  File "./aes-gcm.py", line 49, in decrypt
    return decryptor.update(ciphertext) + decryptor.finalize()
  File "/usr/lib/python3/dist-packages/cryptography/hazmat/primitives/ciphers/base.py", line 198, in finalize
    data = self._ctx.finalize()
  File "/usr/lib/python3/dist-packages/cryptography/hazmat/backends/openssl/ciphers.py", line 170, in finalize
    raise InvalidTag
cryptography.exceptions.InvalidTag

$ ./aes-gcm.py -d plain6 aad2 cipher tag2 -K 12345678909876543212345678900987 -iv 09876543211234567890098765432112
12345678909876543212345678900987
Decryption Traceback (most recent call last):
  File "./aes-gcm.py", line 119, in <module>
    main()
  File "./aes-gcm.py", line 110, in main
    open(sys.argv[5],"rb").read()
  File "./aes-gcm.py", line 49, in decrypt
    return decryptor.update(ciphertext) + decryptor.finalize()
  File "/usr/lib/python3/dist-packages/cryptography/hazmat/primitives/ciphers/base.py", line 198, in finalize
    data = self._ctx.finalize()
  File "/usr/lib/python3/dist-packages/cryptography/hazmat/backends/openssl/ciphers.py", line 170, in finalize
    raise InvalidTag
cryptography.exceptions.InvalidTag


```

Queste prove sembrerebbero confermare che se la tripla (cipher, aad, tag) non è corretta allora lo script darà errore. Per testare le prestazioni è stato creato un apposito script in linea con quello creato nel lab2. Dopo essersi assicurati che il file `testSpeed` sia presente nella cartella e che esso abbia i permesse necessari per essere eseguito, lanciare il seguente comando:

```console

root@kali:~/Desktop/sicurezza-labs/lab3# ./testSpeed 
#### CIPHER TIME TEST ON file-lg.txt ####
12345678909876543212345678900987
Encryption successfully completed.

real	0m0.289s
user	0m0.191s
sys	0m0.063s
#### CIPHER TIME TEST ON file-m.txt ####
12345678909876543212345678900987
Encryption successfully completed.

real	0m0.187s
user	0m0.133s
sys	0m0.023s
#### CIPHER TIME TEST ON file-s.txt ####
12345678909876543212345678900987
Encryption successfully completed.

real	0m0.171s
user	0m0.136s
sys	0m0.009s
#### CIPHER TIME TEST ON file-xs.txt ####
12345678909876543212345678900987
Encryption successfully completed.

real	0m0.205s
user	0m0.138s
sys	0m0.009s

```

## 1.3 Firma digitale

Per mantenere la separazione tra i vari laboratori creo anche in questa cartella una coppia di chiavi per Alice come suggerito.

```console

root@kali:~/Desktop/sicurezza-labs/lab3# openssl genrsa -out rsa.key.alice 2048 && openssl rsa -in rsa.key.alice -pubout -out rsa.pubkey.alice 
Generating RSA private key, 2048 bit long modulus (2 primes)
..........................+++++
.........................+++++
e is 65537 (0x010001)
writing RSA key

```

Scarichiamo quindi il file richiesto

```console

root@kali:~/Desktop/sicurezza-labs/lab3# wget http://cacr.uwaterloo.ca/hac/about/chap11.pdf
--2019-12-06 14:24:05--  http://cacr.uwaterloo.ca/hac/about/chap11.pdf
Resolving cacr.uwaterloo.ca (cacr.uwaterloo.ca)... 129.97.140.120
Connecting to cacr.uwaterloo.ca (cacr.uwaterloo.ca)|129.97.140.120|:80... connected.
HTTP request sent, awaiting response... 200 OK
Length: 526851 (515K) [application/pdf]
Saving to: ‘chap11.pdf’

chap11.pdf        100%[=============>] 514.50K   267KB/s    in 1.9s    

2019-12-06 14:24:08 (267 KB/s) - ‘chap11.pdf’ saved [526851/526851]

```

Per firmare e verificare il file i passaggi sono i seguenti:

- Alice firma il file (utilizzando il comando dgst o pkeyutl)
- Alice invia a Bob il file, la firma e la sua chiave pubblica
- Bob calcola il dgst del file e lo confronta con la firma decifrata con la chiave pubblica
- se coincidono OK altrimenti ALARM!

Questi passaggi in comandi si traducono nel seguente modo:

```console

root@kali:~/Desktop/sicurezza-labs/lab3# openssl dgst -sha256 -out sign -sign rsa.key.alice chap11.pdf

# Bob IP
root@kali:~/Desktop/sicurezza-labs/lab3# scp sign rsa.pubkey.alice chap11.pdf 10.0.2.5:/root/Desktop/

# su Bob
root@kali:~/Desktop openssl dgst -sha256 -verify rsa.pubkey.alice -signature sign chap11.pdf

```

> Sembrerebbe che l'operazione di sign con la funzione `pkeyutl` funziona se il file passato ad `-in` è un hash, se si prova ad utilizzare la funzione sign di tale libreria sul file chap11.pdf si otterrà un messaggio d'errore.

La verifica di una firma si basa sul procedimento illustrato sopra, se viene modificato il messaggio o la firma quel che si ottiene un disaccoppiamento dei digest che non essendo identici generano errore.

## 2 Applicazioni della crittografia asimmetrica: chiavi di messaggio

Supponiamo che Alice e Bob vogliano comunicare in maniera privata e che il file `rsa.key.alice` contenga la chiave almeno la chiave privata visto la nomenclatura utilizzata fino ad adesso e considerato il comando utilizzato. Alice compie i seguenti passi

- sceglie una chiave che memorizza nel file `aeskey`
- cifra il file chap12.pdf con questa chiave utilizzando aes-128-cbc ed un vettore di inizializzazione pari a 0
- cifra con la chiave pubblica contenuta in `rsa.key.alice` la chiave `aeskey` generata in precedenza e la memorizza nel file `aeskey.rsa`.
- a questo punto Alice invia a Bob il file cifrato, la chiave simmetrica (quella da lei creata e memorizzata in *aeskey*) in maniera cifrata e la coppia di chiavi memorizzate in `rsa.key.alice`. Di seguito vengono elencati i vari errori commessi dalla inesperta Alice

- Utilizzare un vettore di inizializzazione nullo per cifrare con AES, non il più grande errore, ma non una grande idea.
- Inviare le chiavi in chiaro a Bob, il file `rsa.key.alice` contiene la parte privata della coppia che appunto dovrebbe rimanere privata, se invece il file contenesse solo la parte pubblica della chiave allora Bob non potrebbe decifrare la chiave simmetrica scelta da Alice. Il problema risiede nello scambio delle chiavi, Alice e Bob devono trovare un modo sicuro per scambiarsi la chiave simmetrica con la quale comunicheranno da li in avanti. Per poter far ciò si può utilizzare Diffie-Hellman. Qui un link che spiega come poter utilizzare questa procedera con openssl ![openssl Diffie-Hellman](https://sandilands.info/sgordon/diffie-hellman-secret-key-exchange-with.openssl).

