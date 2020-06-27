% definizione insegnamenti
insegnamento(project_management,muzzetto,14).
insegnamento(fondamenti_ict,pozzato,14).
insegnamento(linguaggi_markup,gena,20).
insegnamento(gestione_qualita,tomatis,10).
insegnamento(ambienti_sviluppo_linguaggi_clientside_web,micalizio,20).


insegnamento(progettazione_grafica,terranova,10).
insegnamento(progettazione_basi_dati,mazzei,20).
insegnamento(strumenti_metodi_interazione_social,giordani,14).
insegnamento(acquisizione_elaborazione_immagini_statiche,zanchetta,14).
insegnamento(accessibilita_usabilita,gena,14).


insegnamento(marketing_digitale,muzzetto,10).
insegnamento(elementi_fotografia,vargiu,10).
insegnamento(risorse_digitali,boiolo,10).
insegnamento(tecnologie_server_side,damiano,20).
insegnamento(tecniche_strumenti_marketing,zanchetta,10).

insegnamento(introduzione_social_media,suppini,14).
insegnamento(acquisizione_elaborazione_suono,valle,10).
insegnamento(acquisizione_elaborazione_immagini_digitali,ghidelli,20).
insegnamento(comunicazione_pubblicitaria,gabardi,14).
insegnamento(semiologia_multimedialita,santangelo,10).

insegnamento(crossmedia,taddeo,20).
insegnamento(grafica_3d,gribaudo,20).
insegnamento(progettazione_mobile_1,pozzato,10).
insegnamento(progettazione_mobile_2,schifanella,10).
insegnamento(gestione_risorse_umane,lombardo,10).

insegnamento(vincoli_giuridici,travostino,10).


%Definizione delle 24 settimane
settimana(1..24).

%Definizione delle settimane fulltime 
settimana_fulltime(7;16).
settimana(S) :- settimana_fulltime(S).

%ordinamento settimana fulltime
n_settimana_fulltime(1, S) :- settimana_fulltime(S), not S1 < S : settimana_fulltime(S1). 
n_settimana_fulltime(N + 1, S) :- n_settimana_fulltime(N, S1), settimana_fulltime(S), S1 < S, not S2 < S: S1 < S2, settimana_fulltime(S2). 

%Definizione giorni settimane standard. Coppia(S,G): S è la settimana, G il giorno
giorno(S,5):-settimana(S).
giorno(S,6):-settimana(S).

%Definizione giorni settimane fulltime. Coppia(S,G): S è la settimana, G il giorno
giorno(S,1):-settimana_fulltime(S).
giorno(S,2):-settimana_fulltime(S).
giorno(S,3):-settimana_fulltime(S).
giorno(S,4):-settimana_fulltime(S).

%Definiamo le ore disponibili in base al giorno (Lunedì-Venerdì 8 ore, Sabato 4 o 5 ore)
orarioGiorno(S, G, 8) :- giorno(S,G), G >= 1, G <=5.
orarioGiorno(S, G, 4); orarioGiorno(S, G, 5) :- giorno(S, G), G = 6.


%Corso,Settimana,Giorno,OraInizio,Durata

%Il primo giorno nelle prime due ore c'è la presentazione del master
slot_assegnato(presentazione_master, 1, 5, 1, 2).

% definisco i due recuperi delle lezioni che durano due ore
2 { slot_assegnato(recupero_lezioni, S, G, 1, 2) : orarioGiorno(S, G, _) } 2.


% faccio in modo che la fascia oraria sia compresa nel blocco che è delimitato
0 { slot_assegnato(C,S,G,O,D) : O=1..Limite-1, D=2..4, O + D <= Limite + 1 } 1 :- insegnamento(C,_,_), orarioGiorno(S, G, Limite).


%vincolo che fa in modo che la somma degli slot sia uguale al totale delle ore del corso
:- insegnamento(C,_,Tot), not Tot = #sum{ D, S, G  : slot_assegnato(C,S,G,O,D)}.


% vincolo che fa si che non ci siano due corsi che si sovrappongono
%se due corsi sono propedeutici, alcuni vincoli sono già espressi altrove
:-  slot_assegnato(C1, S, G, O1, D1), 
    slot_assegnato(C2, S, G, O2, D2), 
    not inf_propedeutico(C1, C2),
    not inf_propedeutico(C2, C1),
    C1 != C2,
    O1 < O2,
    O1 + D1 > O2.

% questo slot fa si che due corsi propedeutici non si sovrappongano nello stesso giorno
:-  slot_assegnato(C1, S, G, O1, D1), 
    slot_assegnato(C2, S, G, O2, D2), 
    inf_propedeutico(C1, C2),
    C1 != C2,
    O1 < O2,
    O1 + D1 > O2.


:-  slot_assegnato(C1, S, G, O, _), 
    slot_assegnato(C2, S, G, O, _), 
    C1 < C2. 


% chi insegna è un professore
professore(Prof) :- insegnamento(_, Prof, _).

% si specifica che un prof. in una giornata non deve insegnare più di 4 ore
:- professore(Prof), orarioGiorno(Week, Day, _), 
   5 #sum{D, C : insegnamento(C, Prof, _), slot_assegnato(C, Week, Day,_, D) }.


%predicati utilizzati per la propedeuticità
non_soddisfa_propedeutico(C1, C2) :- propedeutico(C1, C2),
                                    C1 != C2,
                                    S1 > S2, 
                                    slot_assegnato(C1, S1, _, _, _), slot_assegnato(C2, S2, _, _, _).

non_soddisfa_propedeutico(C1, C2) :-propedeutico(C1, C2),
                                    C1 != C2,
                                    G1 > G2, 
                                    slot_assegnato(C1, S, G1, _, _), slot_assegnato(C2, S, G2, _, _).

non_soddisfa_propedeutico(C1, C2) :- propedeutico(C1, C2),
                                    C1 != C2,
                                    O1 > O2, 
                                    slot_assegnato(C1, S, G, O1, _), slot_assegnato(C2, S, G, O2, _).


%Vincoli per propedeuticità 
:- non_soddisfa_propedeutico(A, B).

propedeutico(fondamenti_ict, ambienti_sviluppo_linguaggi_clientside_web).
propedeutico(ambienti_sviluppo_linguaggi_clientside_web, progettazione_mobile_1).
propedeutico(progettazione_mobile_1, progettazione_mobile_2).
propedeutico(progettazione_basi_dati, tecnologie_server_side).
propedeutico(linguaggi_markup, ambienti_sviluppo_linguaggi_clientside_web).

propedeutico(project_management, marketing_digitale).
propedeutico(marketing_digitale, tecniche_strumenti_marketing).
propedeutico(project_management, strumenti_metodi_interazione_social).
propedeutico(project_management, progettazione_grafica).
propedeutico(acquisizione_elaborazione_immagini_statiche, elementi_fotografia).

propedeutico(elementi_fotografia, acquisizione_elaborazione_immagini_digitali).
propedeutico(acquisizione_elaborazione_immagini_statiche, grafica_3d).

% regola di inferenza utilizzata per eliminare determinati vincoli
inf_propedeutico(C1, C2) :- propedeutico(C1, C2).
inf_propedeutico(C1, C3) :- inf_propedeutico(C1, C2), inf_propedeutico(C2, C3).

%La prima ora dell’insegnamento “Accessibilità e usabilita…” deve essere inferiore all’ultima ora dell’insegnamento “Linguaggi markup”
% se non riesco a dimostrare che esiste uno slot per linguaggi markup che è maggiore di accessibilità usabilita, allora fallisce
lezione_successiva(linguaggi_markup, accessibilita_usabilita) :- 
   S1 > S2, 
   slot_assegnato(linguaggi_markup, S1, _, _, _), slot_assegnato(accessibilita_usabilita, S2, _, _, _).

lezione_successiva(linguaggi_markup, accessibilita_usabilita) :- 
   G1 > G2, 
   slot_assegnato(linguaggi_markup, S, G1, _, _), slot_assegnato(accessibilita_usabilita, S, G2, _, _).

lezione_successiva(linguaggi_markup, accessibilita_usabilita) :- 
    O1 > O2, 
   slot_assegnato(linguaggi_markup, S, G, O1, _), slot_assegnato(accessibilita_usabilita, S, G, O2, _).

:- not lezione_successiva(linguaggi_markup, accessibilita_usabilita).


%Insegnamento Progect management deve finire entro la prima settimana fulltime.
% se dimostro che esiste uno slot con una settimana maggiore, allora è un errore
:- slot_assegnato(project_management, LastWeek, _, _,_), n_settimana_fulltime(1, N), LastWeek > N.



% si aggiunge infine il professore che insegna
% per gli slot che non sono insegnamenti, si introduce una costante speciale
slot_completo(C,S,G,O,D, P) :- slot_assegnato(C,S,G,O,D), insegnamento(C, P ,_).
slot_completo(C,S,G,O,D, nessuno) :- slot_assegnato(C,S,G,O,D), not insegnamento(C, _ ,_).

#show slot_completo/6.
%#show ultimoSlot/3.
%#show primoSlot/3.
%#show primaOra/4.
%#show ultimaOra/4.
%#show n_settimana_fulltime/2.
