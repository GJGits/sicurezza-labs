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
