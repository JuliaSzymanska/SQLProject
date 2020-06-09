CREATE DATABASE siec_hoteli;

CREATE TABLE miasto(
id_miasta INT NOT NULL PRIMARY KEY IDENTITY(10,2),
nazwa_miasta VARCHAR(50) NOT NULL,
nazwa_kraju VARCHAR(50) NOT NULL,
);
GO

CREATE TABLE hotel (
id_hotelu INT NOT NULL PRIMARY KEY IDENTITY(100,1),
nazwa_hotelu VARCHAR(70) NOT NULL,
id_miasta INT NOT NULL  FOREIGN KEY REFERENCES miasto (id_miasta),
adres_hotelu VARCHAR(100) NOT NULL,
cena_bazowa_za_pokoj MONEY NOT NULL,
cena_za_polaczenie_telefoniczne MONEY NOT NULL,
CONSTRAINT check_cena_bazowa_za_pokoj CHECK (cena_bazowa_za_pokoj > 0),
CONSTRAINT check_cena_za_polaczenie_telefoniczne CHECK (cena_za_polaczenie_telefoniczne > 0)
);
GO

CREATE TABLE pokoj (
id_pokoju INT NOT NULL PRIMARY KEY IDENTITY(100, 1),
id_hotelu INT NOT NULL FOREIGN KEY REFERENCES hotel (id_hotelu),
numer_pokoju INT,
numer_telefonu_pokoju CHAR(5) NOT NULL UNIQUE,
liczba_pomieszczen INT NOT NULL,
liczba_przewidzianych_osob INT NOT NULL,
UNIQUE(numer_pokoju, id_hotelu),
CONSTRAINT check_liczba_pomieszczen CHECK (liczba_pomieszczen > 0),
CONSTRAINT ckeck_liczba_przewidzianych_osob CHECK (liczba_przewidzianych_osob > 0),
CONSTRAINT check_numer_telefonu CHECK (numer_telefonu_pokoju LIKE '[0-9][0-9][0-9][0-9][0-9]'),
);
GO

CREATE TABLE usluga (
id_uslugi INT NOT NULL PRIMARY KEY IDENTITY(1,1),
nazwa_uslugi VARCHAR(50) NOT NULL,
cena_uslugi MONEY NOT NULL,
CONSTRAINT check_cena_uslugi CHECK (cena_uslugi > 0),
);
GO

CREATE TABLE klient (
id_klienta INT NOT NULL PRIMARY KEY IDENTITY(1000,1),
imie_klienta VARCHAR(20),
nazwisko_klienta VARCHAR(40) NOT NULL, 
pesel_klienta CHAR(9) NOT NULL,
adres_zamieszkania VARCHAR(100) NOT NULL,
numer_telefonu_klienta CHAR(9) UNIQUE NOT NULL,
CONSTRAINT check_pesel_klienta CHECK (pesel_klienta LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9)'),
CONSTRAINT check_numer_telefonu_klienta CHECK (numer_telefonu_klienta LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
);
GO

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
GO

CREATE TABLE usluga_dla_rezerwacji (
id_uslugi INT NOT NULL FOREIGN KEY REFERENCES usluga (id_uslugi), 
id_rezerwacji INT NOT NULL FOREIGN KEY REFERENCES rezerwacja (id_rezerwacji)
PRIMARY KEY (id_uslugi, id_rezerwacji)
);
GO

CREATE TABLE sprzatanie (
id_sprzatania INT NOT NULL PRIMARY KEY IDENTITY(1,1),
id_pokoju INT NOT NULL FOREIGN KEY REFERENCES pokoj (id_pokoju),
data_rozpoczecia_sprzatania DATETIME NOT NULL,
data_zakonczenia_sprzatania DATETIME DEFAULT GETDATE(), 
rodzaj_sprzatania VARCHAR(10),
CONSTRAINT check_data_sprzatania CHECK (data_rozpoczecia_sprzatania < data_zakonczenia_sprzatania),
CONSTRAINT check_data_zakonczenia_sprzatania CHECK (data_zakonczenia_sprzatania <= GETDATE()),
CONSTRAINT check_rodzaj_sprzatania CHECK (UPPER(rodzaj_sprzatania) IN ('PODSTAWOWE', 'PELNE'))
);
GO

CREATE TABLE rozmowy_telefoniczne (
id_rozmowy_telefonicznej INT NOT NULL PRIMARY KEY IDENTITY(100,1),
id_pokoju INT NOT NULL FOREIGN KEY REFERENCES pokoj (id_pokoju),
numer_telefonu VARCHAR(9) NOT NULL,
godzina_rozpoczecia_rozmowy TIME NOT NULL,
data_zakonczenia_rozmowy DATETIME DEFAULT GETDATE(),
CONSTRAINT check_data_rozmowy CHECK (godzina_rozpoczecia_rozmowy < cast(data_zakonczenia_rozmowy as time(0))),
CONSTRAINT check_data_zakonczenia_rozmowy CHECK (data_zakonczenia_rozmowy <= GETDATE()),
CONSTRAINT check_numer_telefonu_rozmowcy CHECK (numer_telefonu NOT LIKE '%^(0-9)%')
);
GO


--1. Wyœwietl liczbê pokoi w ka¿dym z hoteli. Na koñcu dodaj podsumowanie ile jest ³¹cznie pokoi. 
SELECT COUNT(*) as 'Liczba pokoi', nazwa_hotelu FROM pokoj p, hotel h
WHERE p.id_hotelu = h.id_hotelu
GROUP BY ROLLUP(nazwa_hotelu)
ORDER BY [Liczba pokoi]

--2. Wyœwietl nazwê hotelu, cenê bazow¹ za pokój, nazwê miasta przy tworzeniu rankingu hoteli na podstawie ceny bazowej za 
-- pokój bez przeskoku.  
SELECT nazwa_hotelu, cena_bazowa_za_pokoj, nazwa_miasta,
DENSE_RANK() OVER (ORDER BY cena_bazowa_za_pokoj DESC) AS 'Ranking cen pokoi'
FROM hotel h, miasto m
WHERE h.id_miasta = m.id_miasta

--3. Wyœwietl œredni¹ cenê po³¹czeñ telefonicznych hoteli dla miasta zaokr¹glone do drugiej liczby po przecinku wraz z nazw¹ miasta, 
-- posortowane po œredniej.
SELECT DISTINCT nazwa_miasta, ROUND(AVG(cena_za_polaczenie_telefoniczne) OVER (PARTITION BY nazwa_miasta), 2) as 'Srednia cena polaczen telefonicznych'
FROM hotel h, miasto m
WHERE h.id_miasta = m.id_miasta
ORDER BY [Srednia cena polaczen telefonicznych] DESC

--4. Zlicz w ilu krajach s¹ rozmieszczone hotele.
SELECT COUNT(DISTINCT m.nazwa_kraju) as 'Liczba krajów' FROM miasto m, hotel h
WHERE h.id_miasta = m.id_miasta

-- 5. Wyœwietl nazwy krajów, w których zlokalizowane s¹ hotele posortowane malej¹co. 
SELECT DISTINCT m.nazwa_kraju FROM miasto m, hotel h
WHERE h.id_miasta = m.id_miasta
ORDER BY nazwa_kraju DESC

-- 6. Wyœwietl liczbê pokoi dla których nie przewidziano rezerwacji. 
SELECT COUNT(id_pokoju) as 'Liczba pokoi bez rezerwacji' FROM pokoj
WHERE id_pokoju NOT IN (SELECT id_pokoju FROM rezerwacja)

-- 7. Wyœwietl piêæ najbli¿szych rezerwacji. 
SELECT top 5 id_rezerwacji, data_rezerwacji, liczba_dni_rezerwacji
FROM rezerwacja
GROUP BY data_rezerwacji, id_rezerwacji, liczba_dni_rezerwacji
ORDER BY data_rezerwacji ASC

-- 8. Wyœwietl wszystkie rezerwacje (id_rezerwacji, data_rezerwacji, liczba_dni_rezerwacji) dla klienta o nazwisku Kowalczyk.
SELECT id_rezerwacji, data_rezerwacji, liczba_dni_rezerwacji
FROM rezerwacja r, klient k
WHERE r.id_klienta = k.id_klienta AND k.nazwisko_klienta = 'KOWALCZYK'
GROUP BY data_rezerwacji, id_rezerwacji, liczba_dni_rezerwacji
ORDER BY data_rezerwacji ASC
GO

-- 9. Wyœwietl wszystkie us³ugi, które s¹ zarejestrowane dla rezerwacji dla klienta o nazwisku 'Dudziak'. 
SELECT DISTINCT u.nazwa_uslugi FROM usluga u, usluga_dla_rezerwacji ur, klient k, rezerwacja r
WHERE ur.id_uslugi = u.id_uslugi
AND ur.id_rezerwacji = r.id_rezerwacji
AND r.id_klienta = k.id_klienta
AND k.nazwisko_klienta LIKE 'Dudziak'

-- 10. Wyœwietl imiona, nazwiska, numery telefonów klietów, których imiê koñczy siê na literkê 'a'.
SELECT imie_klienta, nazwisko_klienta, numer_telefonu_klienta FROM klient
WHERE imie_klienta LIKE '%a'

-- 11. Wyœwietl imiona, nazwiska, adresy klientów, którzy mieszkaj¹ w Hiszpani. 
SELECT imie_klienta, nazwisko_klienta, adres_zamieszkania FROM klient
WHERE adres_zamieszkania LIKE '%Hiszpania%'

-- 12. Wyœwietl id_rezerwacji, licza_dni_rezerwacji, data_rezerwacji oraz datê wymeldowania jako data_wymeldowania. 
SELECT id_rezerwacji, liczba_dni_rezerwacji, data_rezerwacji, DATEADD(DAY, liczba_dni_rezerwacji, data_rezerwacji) AS data_wymeldowania
FROM rezerwacja
ORDER BY liczba_dni_rezerwacji

-- 13. Wyœwietl wszystkie rezerwacje przewidziane na miesi¹c lipiec. 
SELECT id_rezerwacji, liczba_dni_rezerwacji, data_rezerwacji
FROM rezerwacja
WHERE MONTH(data_rezerwacji) = 7
ORDER BY id_rezerwacji

-- 14. Wyœwietl id_sprzatania, id_pokoju, czas trwania sprzatania jako czas_trwania wszystkich pe³nych sprz¹tañ. 
SELECT id_sprzatania, id_pokoju, CAST((data_zakonczenia_sprzatania - data_rozpoczecia_sprzatania) AS TIME(0)) AS czas_trwania FROM sprzatanie
WHERE rodzaj_sprzatania = 'Pelne'

-- 15. Wyœwietl nazwê hotelu, nazwê miasta, nazwê pañstwa dla hoteli, które maj¹ iloœæ zarejestrowanych pokoi wiêksz¹ ni¿ 5.
SELECT h.nazwa_hotelu, m.nazwa_miasta, m.nazwa_kraju, (SELECT COUNT(id_pokoju) FROM pokoj p WHERE p.id_hotelu = h.id_hotelu) as liczba_pokoi FROM hotel h, miasto m
WHERE h.id_miasta = m.id_miasta
AND (SELECT COUNT(id_pokoju) FROM pokoj p WHERE p.id_hotelu = h.id_hotelu) > 5

-- 16. Wyœwietl wszystkie rozmowy telefoniczne, które trwa³y d³u¿ej ni¿ 5 minut.
SELECT * FROM rozmowy_telefoniczne rt
WHERE DATEDIFF(MINUTE, godzina_rozpoczecia_rozmowy, CAST(data_zakonczenia_rozmowy AS TIME)) > 5

-- 17. Wyœwietl id_rezerwacji oraz data_rezerwacji dla wszystkich rezerwacji odbywaj¹cych siê po 15 sierpnia 2020 roku. 
SELECT id_rezerwacji, data_rezerwacji FROM rezerwacja 
WHERE data_rezerwacji > CONVERT(DATE, '2020/08/15')

-- 18. Wyœwietl wszystkich klientów, których numer telefonu zaczyna siê od liczby '6' i koñczy siê na liczbê 2, ich imiê i nazwisko 
-- po³¹cz w jednej kolumnie o nazwie imie_i_nazwisko. 
SELECT CONCAT(imie_klienta, ' ', nazwisko_klienta) AS imie_i_nazwisko, numer_telefonu_klienta FROM klient
WHERE numer_telefonu_klienta LIKE '6%2'

--19. Podwy¿sz wszystkim hotelom cenê bazow¹ za pokój o 5%.
UPDATE hotel
SET cena_bazowa_za_pokoj = 1.05 * cena_bazowa_za_pokoj

--20. Utwórz pust¹ tabelê archiwum_rezerwacji na podstawie tabeli rezerwacja pomijaj¹c kolumnê id_rezerwacji. 
SELECT id_pokoju, id_klienta, liczba_dni_rezerwacji, data_rezerwacji INTO archiwum_rezerwacji 
FROM rezerwacja
WHERE 1 = 0
GO

--21. Dodaj do tabeli archiwum_rezerwacji kolumnê id_rezerwacji typu ca³kowitego unikatowego oraz cena_rezerwacji typu MONEY oraz kolumnê id_rezerwacji_arch 
-- typu ca³kowitego przyrostowego od 10000 co 1 bêd¹ca kluczem g³ównym. 
ALTER TABLE archiwum_rezerwacji
ADD id_rezerwacji INT UNIQUE
GO

ALTER TABLE archiwum_rezerwacji 
ADD cena_rezerwacji MONEY,
	id_rezerwacji_arch INT PRIMARY KEY IDENTITY(1000, 1)
GO

--22. Na kolumny za³ó¿ ograniczenia takie jak przy tabeli rezerwacja, przy czym data_rezerwacji musi byæ przed aktualn¹ dat¹.
-- W tabeli rezerwacja zdejmij restrykcjê dotycz¹c¹ daty rezerwacji (data_rezerwacji musi byæ dat¹ póŸniejsz¹ ni¿ aktualna data). 
-- Dodaj do tabeli rezerwacja 6 rekordy z dat¹ rezerwacji, która ju¿ siê odby³a. Dla nowo utworzonych rezerwacji dodaj us³ugi. 
ALTER TABLE archiwum_rezerwacji 
ADD CONSTRAINT check_liczba_dni_rezerwacji_arch CHECK (liczba_dni_rezerwacji > 0),
	CONSTRAINT check_data_rezerwacji_arch CHECK (data_rezerwacji < GETDATE()),
	CONSTRAINT id_pokoju_arch_foreign_key FOREIGN KEY (id_pokoju) REFERENCES pokoj (id_pokoju),
	CONSTRAINT id_kleinta_arch_foreign_key FOREIGN KEY (id_klienta) REFERENCES klient (id_klienta)
GO

ALTER TABLE rezerwacja
DROP check_data_rezerwacji;
GO

INSERT INTO rezerwacja VALUES (123, 1003, 8, '2020/05/02');
INSERT INTO rezerwacja VALUES (104, 1000, 4, '2020/01/05');
INSERT INTO rezerwacja VALUES (121, 1002, 3, '2020/02/16');
INSERT INTO rezerwacja VALUES (146, 1010, 5, '2020/04/22');
INSERT INTO rezerwacja VALUES (155, 1013, 12, '2020/02/11');
INSERT INTO rezerwacja VALUES (160, 1021, 5, '2020/02/25');
GO

INSERT INTO usluga_dla_rezerwacji VALUES (6, 1032);
INSERT INTO usluga_dla_rezerwacji VALUES (4, 1032);
INSERT INTO usluga_dla_rezerwacji VALUES (1, 1033);
INSERT INTO usluga_dla_rezerwacji VALUES (5, 1033);
INSERT INTO usluga_dla_rezerwacji VALUES (3, 1034);
INSERT INTO usluga_dla_rezerwacji VALUES (6, 1034);
INSERT INTO usluga_dla_rezerwacji VALUES (1, 1035);
INSERT INTO usluga_dla_rezerwacji VALUES (2, 1035);
INSERT INTO usluga_dla_rezerwacji VALUES (5, 1035);
INSERT INTO usluga_dla_rezerwacji VALUES (6, 1035);
INSERT INTO usluga_dla_rezerwacji VALUES (1, 1036);
INSERT INTO usluga_dla_rezerwacji VALUES (2, 1036);
INSERT INTO usluga_dla_rezerwacji VALUES (5, 1036);
INSERT INTO usluga_dla_rezerwacji VALUES (1, 1037);
INSERT INTO usluga_dla_rezerwacji VALUES (3, 1037);
INSERT INTO usluga_dla_rezerwacji VALUES (6, 1037);
GO

-- 23. Przenieœ z tabeli rezerwacja te rekordy, które maja przesz³¹ datê do tabeli archiwum_rezerwacji. 
INSERT INTO archiwum_rezerwacji (id_pokoju, id_klienta, liczba_dni_rezerwacji, data_rezerwacji, id_rezerwacji)
SELECT id_pokoju, id_klienta, liczba_dni_rezerwacji, data_rezerwacji, id_rezerwacji FROM rezerwacja
WHERE data_rezerwacji < GETDATE()
GO

--24. Dodaj synonim dla tabeli archiwum_rezerwacji ustawiaj¹c jego wartoœæ na arch oraz dla tabeli rozmowy_telefoniczne na wartoœæ tel. 
-- W tabeli archiwum_rezerwacji ustaw wartoœci kolumny cena_rezerwacji na wartoœæ iloczynu cena_bazowa_za_pokoj razy liczba_dni_rezerwacji.
CREATE SYNONYM arch FOR archiwum_rezerwacji;
CREATE SYNONYM tel FOR rozmowy_telefoniczne;
GO

UPDATE arch
SET cena_rezerwacji = h.cena_bazowa_za_pokoj * p.liczba_pomieszczen * p.liczba_przewidzianych_osob * a.liczba_dni_rezerwacji FROM hotel h, arch a, pokoj p
WHERE a.id_pokoju = p.id_pokoju
	AND p.id_hotelu = h.id_hotelu
GO

--25. Dodaj funkcjê zwracaj¹c¹ wspó³czynnik z jakim trzeba bêdzie pomno¿yæ cenê za po³¹czenie telefoniczne. Funkcja ma przyjmowaæ dwa argumenty: 
-- numer_telefonu, id_pokoju. Jeœli numer telefonu, na który zosta³o wykonane po³¹czenie nale¿y do któregoœ z pokoi w hotelu z którego wykonano po³¹czenie 
-- (na podstawie id_pokoju uzyskujemy id_hotelu z którego wykonano po³¹czenie) wtedy wspó³czynnik ustawiany jest na 0. Dla numeru telefonu pokoju znajduj¹cego 
-- siê w innym hotelu wspó³czynnik ustawiany jest na 0.5, dla numerów telefonów spoza hotelu wspó³czynnik ustawiany jest na 1. 
CREATE OR ALTER FUNCTION oblicz_wspoczynnik 
(
	@numer_telefonu VARCHAR(9), 
	@id_pokoju INT
)
RETURNS FLOAT(2)
AS BEGIN
      DECLARE @wspolczynnik FLOAT(2); 
	  
      IF EXISTS (SELECT * FROM pokoj p WHERE p.numer_telefonu_pokoju = @numer_telefonu
	  AND p.id_hotelu = (SELECT id_hotelu FROM pokoj p WHERE p.id_pokoju = @id_pokoju)) 
		BEGIN
			SET @wspolczynnik = 0.00
		END
	  ELSE IF EXISTS (SELECT * FROM pokoj p WHERE @numer_telefonu = p.numer_telefonu_pokoju
	  AND p.id_hotelu != (SELECT id_hotelu FROM pokoj p WHERE @id_pokoju = p.id_pokoju))
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

-- 26. Dodaj do tabeli rezerwacja kolumnê cena_za_telefon typu zmiennoprzecinkowego z dwoma miejscami po przecinku. Wstaw do nowo 
-- utworzonej kolumny cena_za_polaczenie_telefoniczne pomno¿on¹ przez ró¿nicê minut pomiêdzy godzin¹ rozpoczêcia a godzin¹ zakoñczenia
-- rozmowy razy cena_za_polaczenie_telefoniczne razy wspo³czynnik obliczony na podstawie funkcji oblicz_wspolczynnik. 
ALTER TABLE archiwum_rezerwacji
ADD cena_za_telefon MONEY
GO

UPDATE arch
SET cena_za_telefon = t.suma_cen
FROM 
    (
        SELECT ar.id_pokoju,SUM(DATEDIFF(MINUTE, rt.godzina_rozpoczecia_rozmowy,CAST(rt.data_zakonczenia_rozmowy as time)) * h.cena_za_polaczenie_telefoniczne *  dbo.oblicz_wspoczynnik(rt.numer_telefonu, rt.id_pokoju)) suma_cen
        FROM tel rt, hotel h, pokoj p, arch ar
        WHERE ar.id_pokoju = p.id_pokoju
	AND rt.id_pokoju = p.id_pokoju
	AND p.id_hotelu = h.id_hotelu
        GROUP BY ar.id_pokoju
    ) t
WHERE t.id_pokoju = arch.id_pokoju

-- 27. Usuñ z tabeli rozmowy_telefoniczne wszystkie rozmowy, które by³y wykonane z pokoi, których id znajduje siê w tabeli o synonimie arch. 
DELETE FROM rozmowy_telefoniczne
WHERE id_pokoju IN (SELECT id_pokoju FROM arch)

--28. Dodaj do tabeli archiwum_rezerwacji kolumnê cena_za_uslugi typu zmiennoprzecinkowego z dwoma miejscami po przecinku. 
-- Wstaw do nowo utworzonej kolumny cena_uslugi pomno¿on¹ razy liczba_dni_rezerwacji.
ALTER TABLE archiwum_rezerwacji
ADD cena_za_uslugi MONEY
GO

UPDATE arch
SET cena_za_uslugi = t.suma_cen * liczba_dni_rezerwacji
FROM 
    (
        SELECT ur.id_rezerwacji ,SUM(u.cena_uslugi) suma_cen
        FROM arch ar, usluga_dla_rezerwacji ur, usluga u
        WHERE ar.id_rezerwacji = ur.id_rezerwacji
		AND ur.id_uslugi = u.id_uslugi
        GROUP BY ur.id_rezerwacji
    ) t
WHERE t.id_rezerwacji = arch.id_rezerwacji
GO

--29. Usuñ z tabeli  usluga_dla_rezerwacji wszystkie rekordy dla rejestracji z przesz³¹ dat¹. Usuñ z tabeli rezerwacja wszystkie rekordy, które maj¹ przesz³¹ datê 
-- rezerwacji. Na³ó¿ ponownie restrykcjê na tabelê rezerwacja, by data_rezerwacji mog³a byæ tylko dat¹ póŸniejsz¹ ni¿ aktualna data. 
DELETE FROM usluga_dla_rezerwacji WHERE id_rezerwacji IN (SELECT id_rezerwacji FROM rezerwacja WHERE data_rezerwacji < GETDATE())
GO

DELETE FROM rezerwacja WHERE data_rezerwacji < GETDATE()
GO

ALTER TABLE rezerwacja
ADD CONSTRAINT check_data_rezerwacji CHECK (data_rezerwacji > GETDATE());
GO

--30. We wszystkich trzech nowo wprowadzonych kolumnach zamien NULL na 0.
UPDATE arch
SET cena_rezerwacji = 0
FROM arch
WHERE cena_rezerwacji IS NULL
GO

UPDATE arch
SET cena_za_telefon = 0
FROM arch
WHERE cena_za_telefon IS NULL
GO

UPDATE arch
SET cena_za_telefon = 0
FROM arch
WHERE cena_za_uslugi IS NULL
GO

-- 31. Dodaj do tabeli archiwum_rezerwacji kolumnê cena_calkowita typu zmiennoprzecinkowego z dwoma miejscami po przecinku. 
-- Wstaw do nowo utworzonej kolumny sumê kolumn cena_za_uslugi, cena_za_telefon, cena_rezerwacji. 
ALTER TABLE archiwum_rezerwacji
ADD cena_calkowita MONEY
GO

UPDATE arch
SET cena_calkowita = cena_za_uslugi + cena_za_telefon + cena_rezerwacji
FROM arch
SELECT * FROM arch
GO

-- 32. Wyœwietl 3 hotele, które zarobi³y najwiêcej na dotychczasowych rezerwacjach. 
SELECT TOP 3 h.nazwa_hotelu, ROUND(SUM(a.cena_calkowita), 2) AS zarobki FROM arch a, pokoj p, hotel h
WHERE a.id_pokoju = p.id_pokoju
AND p.id_hotelu = h.id_hotelu
GROUP BY h.nazwa_hotelu

-- 33. Wyœwietl ile ka¿dy klient zap³aci³ za rezerwacje, które jak dot¹d siê odby³y. Na koñcu dodaj podsumowanie ile ³¹cznie wydali klienci. 
SELECT k.id_klienta, ROUND(SUM(a.cena_calkowita), 2) AS wydatki FROM arch a, klient k
WHERE a.id_klienta = k.id_klienta
GROUP BY ROLLUP(k.id_klienta)
