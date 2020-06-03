CREATE DATABASE siec_hoteli;

CREATE TABLE miasto(
id_miasta INT NOT NULL PRIMARY KEY IDENTITY(10,2),
nazwa_miasta VARCHAR(50) NOT NULL,
nazwa_kraju VARCHAR(50) NOT NULL,
);

CREATE TABLE hotel (
id_hotelu INT NOT NULL PRIMARY KEY IDENTITY(100,1),
nazwa_hotelu VARCHAR(70) NOT NULL,
id_miasta INT NOT NULL  FOREIGN KEY REFERENCES miasto (id_miasta),
adres_hotelu VARCHAR(100) NOT NULL,
cena_bazowa_za_pokoj INT NOT NULL,
cena_za_polaczenie_telefoniczne FLOAT(2) NOT NULL,
CONSTRAINT check_cena_bazowa_za_pokoj CHECK (cena_bazowa_za_pokoj > 0),
CONSTRAINT cena_za_polaczenie_telefoniczne CHECK (cena_za_polaczenie_telefoniczne > 0)
);

CREATE TABLE pokoj (
id_pokoju INT NOT NULL PRIMARY KEY IDENTITY(100,1),
id_hotelu INT NOT NULL FOREIGN KEY REFERENCES hotel (id_hotelu),
numer_telefonu_pokoju CHAR(5) NOT NULL UNIQUE,
liczba_pomieszczen INT NOT NULL,
liczba_przewidzianych_osob INT NOT NULL,
CONSTRAINT check_liczba_pomieszczen CHECK (liczba_pomieszczen > 0),
CONSTRAINT ckeck_liczba_przewidzianych_osob CHECK (liczba_przewidzianych_osob > 0),
CONSTRAINT check_numer_telefonu CHECK (numer_telefonu_pokoju LIKE '[0-9][0-9][0-9][0-9][0-9]'),
);

CREATE TABLE usluga (
id_uslugi INT NOT NULL PRIMARY KEY IDENTITY(1,1),
nazwa_uslugi VARCHAR(50) NOT NULL,
cena_uslugi INT NOT NULL,
CONSTRAINT check_cena_uslugi CHECK (cena_uslugi > 0),
);

CREATE TABLE klient (
id_klienta INT NOT NULL PRIMARY KEY IDENTITY(1000,1),
imie_klienta VARCHAR(20),
nazwisko_klienta VARCHAR(40) NOT NULL, 
pesel_klienta CHAR(9) NOT NULL,
adres_zamieszkania VARCHAR(100) NOT NULL,
numer_telefonu_klienta CHAR(9) UNIQUE,
CONSTRAINT check_pesel CHECK (pesel_klienta LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9)'),
CONSTRAINT check_numer_telefonu_klienta CHECK (numer_telefonu_klienta LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
);

CREATE TABLE rezerwacja (
id_rezerwacji INT NOT NULL IDENTITY(1000,1),
id_pokoju INT NOT NULL FOREIGN KEY REFERENCES pokoj (id_pokoju),
id_klienta INT NOT NULL FOREIGN KEY REFERENCES klient (id_klienta),
liczba_dni_rezerwacji INT NOT NULL,
data_rezerwacji DATE NOT NULL, 
CONSTRAINT check_liczba_dni_rezerwacji CHECK (liczba_dni_rezerwacji > 0),
CONSTRAINT check_data_rezerwacji CHECK (data_rezerwacji > GETDATE()),
CONSTRAINT id_primary_key PRIMARY KEY (id_rezerwacji)
);

CREATE TABLE usluga_dla_pokoju (
id_uslugi INT NOT NULL FOREIGN KEY REFERENCES usluga (id_uslugi), 
id_pokoju INT NOT NULL FOREIGN KEY REFERENCES pokoj (id_pokoju)
PRIMARY KEY (id_uslugi, id_pokoju)
);

CREATE TABLE sprzatanie (
id_sprzatania INT NOT NULL PRIMARY KEY IDENTITY(1,1),
id_pokoju INT NOT NULL FOREIGN KEY REFERENCES pokoj (id_pokoju),
data_rozpoczecia_sprzatania DATETIME NOT NULL,
data_zakonczenia_sprzatania DATETIME DEFAULT GETDATE(), 
rodzaj_sprzatania VARCHAR(10),
CONSTRAINT check_data_sprzatania CHECK (data_rozpoczecia_sprzatania < data_zakonczenia_sprzatania),
CONSTRAINT check_data_zakonczenia_sprzatania CHECK (data_zakonczenia_sprzatania < GETDATE()),
CONSTRAINT check_rodzaj_sprzatania CHECK (UPPER(rodzaj_sprzatania) IN ('PODSTAWOWE', 'PELNE'))
);

CREATE TABLE rozmowy_telefoniczne (
id_rozmowy_telefonicznej INT NOT NULL PRIMARY KEY IDENTITY(100,1),
id_pokoju INT NOT NULL FOREIGN KEY REFERENCES pokoj (id_pokoju),
numer_telefonu VARCHAR(9) NOT NULL,
godzina_rozpoczecia_rozmowy TIME NOT NULL,
data_zakonczenia_rozmowy DATETIME DEFAULT GETDATE(),
CONSTRAINT check_data_rozmowy CHECK (godzina_rozpoczecia_rozmowy < cast(data_zakonczenia_rozmowy as time(0))),
CONSTRAINT check_data_zakonczenia_rozmowy CHECK (data_zakonczenia_rozmowy < GETDATE()),
CONSTRAINT check_numer_telefonu_rozmowcy CHECK (numer_telefonu NOT LIKE '%^(0-9)%')
);

INSERT INTO miasto VALUES ('Warszawa', 'Polska');
INSERT INTO miasto VALUES ('Krakow','Polska');
INSERT INTO miasto VALUES ('Paryz','Francja');
INSERT INTO miasto VALUES ('Lyon','Francja');
INSERT INTO miasto VALUES ('Londyn','Wielka Brytania');
INSERT INTO miasto VALUES ('Madryt','Hiszpania');
INSERT INTO miasto VALUES ('Barcelona','Hiszpania');
SELECT * FROM miasto

INSERT INTO hotel VALUES ('Eden Hotel', 10, 'Ogrodowa 15, 95-130', 130, 1.20);
INSERT INTO hotel VALUES ('Kryszztal Hotel', 10, 'Pilsudzkiego 134, 91-354', 150, 1.25);
INSERT INTO hotel VALUES ('Botaniczny Hotel', 12, 'Gorska 1a, 12-302', 145, 1.30);
INSERT INTO hotel VALUES ('Garden Hotel', 18, 'Webber St 15, 5-132', 160, 1.50);
INSERT INTO hotel VALUES ('Central Hotel', 18, 'Waterloo Rd 285, 213-1', 170, 1.55);
INSERT INTO hotel VALUES ('Cristallo Hotel', 20, 'Calle de Segovia 150, 123-432', 150, 1.65);
INSERT INTO hotel VALUES ('Aurora Hotel', 20, 'Calle de la Madera 5, 783-853', 155, 1.60);
INSERT INTO hotel VALUES ('Alcazar Hotel', 20, 'Calle de Velazquez 342, 100-002', 175, 1.70);
INSERT INTO hotel VALUES ('Ibis Hotel', 14, 'Rue Froissart 1, 002-12', 175, 1.60);
INSERT INTO hotel VALUES ('Park Hotel', 14, 'Rue de Turbigo 12, 013-97', 170, 1.55);
INSERT INTO hotel VALUES ('Soft Hotel', 16, 'Rue Servient 17, 452-00', 165, 1.75);
SELECT * FROM hotel

INSERT INTO pokoj VALUES (100, '04245', 3, 6);
INSERT INTO pokoj VALUES (100, '04123', 2, 4);
INSERT INTO pokoj VALUES (100, '18642', 1, 2);
INSERT INTO pokoj VALUES (100, '12643', 2, 5);
INSERT INTO pokoj VALUES (100, '97465', 2, 4);
INSERT INTO pokoj VALUES (100, '18964', 3, 6);
INSERT INTO pokoj VALUES (101, '85435', 1, 1);
INSERT INTO pokoj VALUES (101, '16434', 4, 9);
INSERT INTO pokoj VALUES (101, '14567', 5, 14);
INSERT INTO pokoj VALUES (102, '58964', 3, 6);
INSERT INTO pokoj VALUES (102, '19756', 2, 6);
INSERT INTO pokoj VALUES (102, '18965', 2, 5);
INSERT INTO pokoj VALUES (102, '86576', 2, 6);
INSERT INTO pokoj VALUES (103, '16789', 3, 7);
INSERT INTO pokoj VALUES (103, '24549', 3, 5);
INSERT INTO pokoj VALUES (103, '18976', 2, 5);
INSERT INTO pokoj VALUES (104, '18653', 1, 2);
INSERT INTO pokoj VALUES (105, '15345', 1, 1);
INSERT INTO pokoj VALUES (105, '12432', 2, 5);
INSERT INTO pokoj VALUES (106, '13549', 3, 7);
INSERT INTO pokoj VALUES (108, '13230', 3, 8);
INSERT INTO pokoj VALUES (108, '10986', 1, 1);
INSERT INTO pokoj VALUES (108, '34977', 1, 2);
INSERT INTO pokoj VALUES (109, '19769', 3, 7);
INSERT INTO pokoj VALUES (109, '68633', 2, 4);
INSERT INTO pokoj VALUES (110, '37976', 1, 3);
SELECT * FROM pokoj

INSERT INTO usluga VALUES ('Miejsce parkingowe', 10);
INSERT INTO usluga VALUES ('Miejsce garazowe', 50);
INSERT INTO usluga VALUES ('Sniadania', 20);
INSERT INTO usluga VALUES ('Pelne wyzywienie', 100);
INSERT INTO usluga VALUES ('Karnet na silownie', 25);
INSERT INTO usluga VALUES ('Karnet na basen', 40);
SELECT * FROM usluga

INSERT INTO klient VALUES ('Maciej', 'Kowalczyk', '185392323', 'Politechniki 12 92-431 Lodz Polska', '123456789');
INSERT INTO klient VALUES ('Magdalena', 'Nowak', '659302954', 'Morskie Oko 132 12-432 Zakopane Polska', '484850983');
INSERT INTO klient VALUES ('Mariusz', 'Adamczyk', '995432511', 'Palacowa 156 13-561 Warszawa Polska', '603859231');
INSERT INTO klient VALUES ('Anne', 'Kiff', '343255631', 'Fine St 111 3-432 Londyn Wielka Brytania', '057294382');
INSERT INTO klient VALUES ('Stefano', 'Umber', '203589431', 'Santa 1-451 Madryt Hiszpania', '653254324');
SELECT * FROM klient

INSERT INTO rezerwacja VALUES (101, 1000, 5, '2020/12/25');
INSERT INTO rezerwacja VALUES (102, 1004, 10, '2020/08/06');
INSERT INTO rezerwacja VALUES (123, 1003, 2, '2020/05/30');
INSERT INTO rezerwacja VALUES (115, 1000, 10, '2020/09/12');
INSERT INTO rezerwacja VALUES (102, 1001, 7, '2021/12/01');
INSERT INTO rezerwacja VALUES (123, 1002, 8, '2020/08/07');
INSERT INTO rezerwacja VALUES (102, 1001, 4, '2020/07/01');
INSERT INTO rezerwacja VALUES (126, 1003, 5, '2020/10/15');
INSERT INTO rezerwacja VALUES (120, 1000, 3, '2020/06/10');
SELECT * FROM rezerwacja

INSERT INTO usluga_dla_pokoju VALUES (1, 100);
INSERT INTO usluga_dla_pokoju VALUES (4, 124);
INSERT INTO usluga_dla_pokoju VALUES (5, 106);
INSERT INTO usluga_dla_pokoju VALUES (6, 123);
INSERT INTO usluga_dla_pokoju VALUES (4, 106);
INSERT INTO usluga_dla_pokoju VALUES (3, 121);
INSERT INTO usluga_dla_pokoju VALUES (5, 121);
INSERT INTO usluga_dla_pokoju VALUES (1, 104);
SELECT * FROM usluga_dla_pokoju

INSERT INTO sprzatanie VALUES (100, '2020/05/15 12:00:00', '2020/05/15 14:30:00', 'Pelne');
INSERT INTO sprzatanie VALUES (115, '2020/05/19 09:00:00', '2020/05/19 09:30:00', 'Podstawowe');
INSERT INTO sprzatanie VALUES (103, '2020/05/20 18:00:00', '2020/05/20 19:55:00', 'Pelne');
INSERT INTO sprzatanie VALUES (110, '2020/05/01 18:00:00', '2020/05/02 12:30:00', 'Pelne');
INSERT INTO sprzatanie VALUES (100, '2020/03/05 11:00:00', '2020/03/05 11:45:00', 'Podstawowe');
INSERT INTO sprzatanie VALUES (100, '2020/05/04 18:00:00', '2020/05/04 19:50:00', 'Podstawowe');
SELECT * FROM sprzatanie

INSERT INTO rozmowy_telefoniczne VALUES (123, '205947321', '15:30:45', '2020/05/03 15:32:04');
INSERT INTO rozmowy_telefoniczne VALUES (104, '97465', '10:21:05', '2020/05/02 11:01:37');
INSERT INTO rozmowy_telefoniczne VALUES (121, '04123', '18:11:40', '2020/02/16 18:14:09');
INSERT INTO rozmowy_telefoniczne VALUES (126, '197495427', '06:13:42', '2020/05/04 06:15:55');
SELECT * FROM rozmowy_telefoniczne


--1. Wyœwietlenie liczby pokoi w ka¿dym z hoteli.
SELECT COUNT(*) as 'Liczba pokoi', nazwa_hotelu FROM pokoj p, hotel h
WHERE p.id_hotelu = h.id_hotelu
GROUP BY nazwa_hotelu

--2. Wyœwietlenie nazwy hotelu, ceny bazowej za pokój, nazwa miasta przy tworzeniu rankingu hoteli na podstawie cen pokoi bez przeskoku. 
SELECT nazwa_hotelu, cena_bazowa_za_pokoj, nazwa_miasta,
DENSE_RANK() OVER (ORDER BY cena_bazowa_za_pokoj DESC) AS 'Ranking cen pokoi'
FROM hotel h, miasto m
WHERE h.id_miasta = m.id_miasta

--3. Wyœwietlenie œredniej ceny po³¹czeñ telefonicznych hoteli dla miasta zaokr¹glone do drugiej liczby po przecinku wraz z nazw¹ miasta.
SELECT nazwa_miasta, ROUND(AVG(cena_za_polaczenie_telefoniczne) OVER (PARTITION BY nazwa_miasta), 2) as 'Srednia cena polaczen telefonicznych'
FROM hotel h, miasto m
WHERE h.id_miasta = m.id_miasta
ORDER BY m.nazwa_miasta

--4. Utwórz pust¹ tabelê archiwum_rezerwacji na podstawie tabeli rezerwacja pomijaj¹c kolumnê id_rezerwacji. 
SELECT id_pokoju, id_klienta, liczba_dni_rezerwacji, data_rezerwacji INTO archiwum_rezerwacji 
FROM rezerwacja
WHERE 1 = 0

--5. Dodaj do tabeli archiwum_rezerwacji kolumnê cena_rezerwacji typu ca³kowitego oraz kolumnê id_rezerwacji_arch typu ca³kowitego przyrostowego 
-- od 10000 co 1 bêd¹ca kluczem g³ównym. 
ALTER TABLE archiwum_rezerwacji 
ADD cena_rezerwacji INT,
	id_rezerwacji_arch INT PRIMARY KEY IDENTITY(10000,1)

--6. Na kolumny za³ó¿ ograniczenia takie jak przy tabeli rezerwacja, przy czym data_rezerwacji musi byæ przed aktualn¹ dat¹.
ALTER TABLE archiwum_rezerwacji 
ADD CONSTRAINT check_liczba_dni_rezerwacji_arch CHECK (liczba_dni_rezerwacji > 0),
	CONSTRAINT check_data_rezerwacji_arch CHECK (data_rezerwacji < GETDATE()),
	CONSTRAINT id_pokoju_arch_foreign_key FOREIGN KEY (id_pokoju) REFERENCES pokoj (id_pokoju),
	CONSTRAINT id_kleinta_arch_foreign_key FOREIGN KEY (id_klienta) REFERENCES klient (id_klienta)

--7. W tabeli rezerwacja zdejmij restrykcjê dotycz¹c¹ daty rezerwacji (data_rezerwacji musi byæ dat¹ póŸniejsz¹ ni¿ aktualna data).
ALTER TABLE rezerwacja
DROP check_data_rezerwacji;

--8. Dodaj do tabeli rezerwacja 3 rekordy z dat¹ rezerwacji, która ju¿ siê odby³a.
INSERT INTO rezerwacja VALUES (123, 1003, 8, '2020/05/02');
INSERT INTO rezerwacja VALUES (104, 1000, 4, '2020/01/05');
INSERT INTO rezerwacja VALUES (121, 1002, 3, '2020/02/16');

--9. Przenieœ z tabeli rezerwacja te rekordy, które maja przesz³¹ datê do tabeli archiwum_rezerwacji. 
INSERT INTO archiwum_rezerwacji (id_pokoju, id_klienta, liczba_dni_rezerwacji, data_rezerwacji)
SELECT id_pokoju, id_klienta, liczba_dni_rezerwacji, data_rezerwacji FROM rezerwacja
WHERE data_rezerwacji < GETDATE()

--10. Usuñ z tabeli rezerwacja wszystkie rekordy, które maj¹ przesz³¹ datê rezerwacji. Na³ó¿ ponownie restrykcjê na tabelê rezerwacja by data_rezerwacji mog³a byæ 
-- tylko dat¹ póŸniejsz¹ ni¿ aktualna data. 
DELETE FROM rezerwacja WHERE data_rezerwacji < GETDATE()

ALTER TABLE rezerwacja
ADD CONSTRAINT check_data_rezerwacji CHECK (data_rezerwacji > GETDATE());

--11. Dodaj synonim dla tabeli archiwum_rezerwacji ustawiaj¹c jego wartoœæ na arch oraz dla tabeli rozmowy_telefoniczne na wartoœæ tel.
CREATE SYNONYM arch FOR archiwum_rezerwacji;
CREATE SYNONYM tel FOR rozmowy_telefoniczne;


--12. W tabeli archiwum_rezerwacji ustaw wartoœci kolumny cena_rezerwacji na wartoœæ iloczynu cena_bazowa_za_pokoj razy liczba_dni_rezerwacji.
SELECT * FROM arch
UPDATE arch
SET cena_rezerwacji = h.cena_bazowa_za_pokoj * a.liczba_dni_rezerwacji FROM hotel h, arch a, pokoj p
WHERE a.id_pokoju = p.id_pokoju
	AND p.id_hotelu = h.id_hotelu

--13. Dodaj funkcjê zwracaj¹c¹ wspó³czynnik z jakim trzeba bêdzie pomno¿yæ cenê za po³¹czenie telefoniczne. Funkcja ma przyjmowaæ dwa argumenty: 
-- numer_telefonu, id_pokoju. Jeœli numer telefonu, na który zosta³o wykonane po³¹czenie nale¿y do któregoœ z pokoi w hotelu z którego wykonano po³¹czenie 
-- (na podstawie id_pokoju uzyskujemy id_hotelu z którego wykonano po³¹czenie) wtedy wspó³czynnik ustawiany jest na 0. Dla numeru telefonu pokoju znajduj¹cego 
-- siê w innym hotelu wspó³czynnik ustawiany jest na 0.5, dla numerów telefonów spoza hotelu wspó³czynnik ustawiany jest na 1. 

GO
CREATE FUNCTION obliczWspoczynnik 
(
	@numer_telefonu VARCHAR, 
	@id_pokoju INT
)
RETURNS FLOAT(2)
AS BEGIN
      DECLARE @wspolczynnik FLOAT(2); 
	  
      IF EXISTS (SELECT * FROM pokoj p WHERE p.numer_telefonu_pokoju = @numer_telefonu
	  AND p.id_hotelu = (SELECT id_hotelu FROM pokoj p WHERE 104 = p.id_pokoju)) 
		BEGIN
			SET @wspolczynnik = 0.00
		END
	  ELSE IF EXISTS (SELECT * FROM pokoj p WHERE p.numer_telefonu_pokoju = @numer_telefonu
	  AND p.id_hotelu != (SELECT id_hotelu FROM pokoj p WHERE 104 = p.id_pokoju)) 
		BEGIN
			SET @wspolczynnik = 0.50
	    END
	  ELSE
		BEGIN
			SET @wspolczynnik = 1.00
		END
    RETURN @wspolczynnik; 
END; 
GO

--14. Dodaj do tabeli rezerwacja kolumnê cena_za_telefon typu zmiennoprzecinkowego z dwoma miejscami po przecinku. Wstaw do nowo utworzonej kolumny 
-- cena_za_polaczenie_telefoniczne pomno¿on¹ przez ró¿nicê minut pomiêdzy godzin¹ rozpoczêcia a godzin¹ zakoñczenia rozmowy. 
ALTER TABLE arch
ADD cena_za_telefon FLOAT(2)

UPDATE arch
SET cena_za_telefon = t.suma_cen
FROM 
    (
        SELECT ar.id_pokoju,SUM(DATEDIFF(MINUTE, rt.godzina_rozpoczecia_rozmowy,CAST(rt.data_zakonczenia_rozmowy as time)) * h.cena_za_polaczenie_telefoniczne) suma_cen
        FROM tel rt, hotel h, pokoj p, arch ar
        WHERE ar.id_pokoju = p.id_pokoju
	AND rt.id_pokoju = p.id_pokoju
	AND p.id_hotelu = h.id_hotelu
        GROUP BY ar.id_pokoju
    ) t
WHERE t.id_pokoju = arch.id_pokoju
SELECT * FROM arch;

UPDATE arch
SET cena_za_telefon = dbo.obliczWspoczynnik(rt.numer_telefonu, rt.id_pokoju)
FROM arch ar, tel rt
WHERE ar.id_pokoju = rt.id_pokoju
SELECT * FROM arch;
SELECT * FROM tel;
SELECT * FROM pokoj
SELECT dbo.obliczWspoczynnik('12643', 120)
SELECT dbo.obliczWspoczynnik('12643', 104)

--
--
--UPDATE archiwum_rezerwacji
--IF (SELECT COUNT(*) FROM pokoj, archiwum_rezerwacji ar 
--WHERE ar.numer_telefonu = p.numer_telefonu_pokoju
--AND 

--SELECT 1 FROM pokoj p, archiwum_rezerwacji ar WHERE p.numer_telefonu_pokoju = ar.numer_telefonu

--IF EXISTS (SELECT * FROM pokoj p,rozmowy_telefoniczne rt WHERE rt.numer_telefonu = p.numer_telefonu_pokoju) 
--BEGIN
--   SELECT 0 
--END
--ELSE
--BEGIN
--    SELECT 1
--END





--15. Dodaj do tabeli archiwum_rezerwacji kolumnê cena_za_uslugi typu zmiennoprzecinkowego z dwoma miejscami po przecinku. 
-- Wstaw do nowo utworzonej kolumny  cena_uslugi pomno¿on¹ razy liczba_dni_rezerwacji.
ALTER TABLE arch
ADD cena_za_uslugi FLOAT(2)

UPDATE arch
SET cena_za_uslugi = t.suma_cen
FROM 
    (
        SELECT up.id_pokoju ,SUM(u.cena_uslugi) suma_cen
        FROM arch ar, usluga_dla_pokoju up, usluga u
        WHERE ar.id_pokoju = up.id_pokoju
		AND up.id_uslugi = u.id_uslugi
        GROUP BY up.id_pokoju
    ) t
WHERE t.id_pokoju = arch.id_pokoju
SELECT * FROM arch

--16. Dodaj do tabeli archiwum_rezerwacji kolumnê cena_calkowita typu zmiennoprzecinkowego z dwoma miejscami po przecinku. 
-- Wstaw do nowo utworzonej kolumny sumê kolumn cena_za_uslugi, cena_za_telefon, cena_rezerwacji. 
ALTER TABLE arch
ADD cena_calkowita FLOAT(2)

UPDATE arch
SET cena_calkowita = cena_za_uslugi + cena_za_telefon + cena_rezerwacji
FROM arch
SELECT * FROM arch

