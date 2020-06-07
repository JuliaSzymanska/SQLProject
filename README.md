# SQLProject

Baza danych systemu zarządzania hotelami. 

### Założenia
1.	Hotele zlokalizowane są w różnych miastach, różnych państw. 
2.	W jednym mieście może znajdować się wiele hoteli tej samej sieci. 
3.	W każdym hotelu znajduje się wiele pokoi. 
4.	Cena za wynajęcie pokoju jest zależna od liczby pomieszczeń w pokoju oraz liczby osób przewidzianych na pokój. 
5.	Dla każdej rezerwacji pokoju rejestrowany jest wynajmującym. 
6.	Klient rezerwuje pokój na określoną datę oraz określoną liczbę dni. 
7.	Klient przy rezerwacji może zdecydować się na dodatkowe usługi: miejsce parkingowe, miejsce garażowe, śniadania, pełne wyżywienie, wykupienie karnetu na basen, wykupienie karnetu na siłownię.
8.	Cena rezerwacji jest zależna ceny bazowej ceny za pokój, od liczby dni na jakie została wykonana rezerwacja, od terminu (okres wakacyjny oraz świąteczny podwyższają cenę) oraz od usług dodatkowych o ile wystąpiły. 
9.	Po sprzątnięciu każdego pokoju, rejestrowana jest data sprzątania wraz z godziną rozpoczęcia, data zakończenia sprzątania wraz z godziną, rodzaj sprzątania (pełne – po wykwaterowaniu klientów, podstawowe – podczas rezerwacji pokoju). 
10.	Rozmowy wykonywane przez telefon hotelowy są rejestrowane. Zapisywana jest data wykonania połączenia wraz z godziną rozpoczęcia i godziną zakończenia, numer telefonu, na który wykonano połączenie oraz id pokoju.  Przy nowej rezerwacji pokoju, rozmowy dla tego pokoju są zerowane.
11.	Rozmowy wykonane przez telefon hotelowy są płatne z ustaloną z góry ceną dla każdego hotelu inną. Połączenia wewnątrz hotelu (z innym pokojem w tym hotelu) są darmowe. Połączenia z innymi hotelami są płatne ze zniżką 50%, pozostałe połączenia są w pełni płatne. 
12. Przy wykwaterowaniu rezerwacja zostaje przeniesiona do historii rezerwacji wraz z opłatą jaką klient musiał wnieść za rezerwację, usługi dodatkowe oraz rozmowy telefoniczne. 

### Tabele
* Miasto
* Hotel
* Pokój
* Usługa
* Klient
* Rezerwacja 
* Usługa dla rezerwacji
* Sprzątanie
* Rozmowy telefoniczne
* Archiwum rezerwacji

