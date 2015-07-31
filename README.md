# rdr
ruby-defined-router


RDR e` un router definito via software, scritto in ruby.
Ruby riceve i pacchetti dalla rete tramite libpcap e li processa, mentre il kernel rimane a guardare.

Per evitare interferenze: togliere gli ip dalle interfacce, disattivare bridging, togliere firewall.

Eseguire come root per forgiare le risposte.

Per installare i prerequisiti:
# sh setup.sh

Modifica a /var/lib/gems/2.1.0/gems/pcaprub-0.12.0/ext/pcaprub_c/pcaprub.c
riga 500~, dopo l'open

  /// ENRICO
  pcap_setdirection(rbp, PCAP_D_IN);

poi dare un make da dentro pcaprub_c e make install

cp /var/lib/gems/2.1.0/gems/pcaprub-0.12.0/ext/pcaprub_c/pcaprub_c.so /var/lib/gems/2.1.0/gems/pcaprub-0.12.0/lib/pcaprub_c.so
cp /var/lib/gems/2.1.0/gems/pcaprub-0.12.0/ext/pcaprub_c/pcaprub_c.so /var/lib/gems/2.1.0/extensions/x86_64-linux/2.1.0/pcaprub-0.12.0/pcaprub_c.so
