/*
-- Zaman Yolculuðu Rezervasyon Sistemi Veritabaný

-- 1. Veritabaný Oluþturulmasý
CREATE DATABASE TimeTravelSystem;
GO

USE TimeTravelSystem;
GO

-- 2. Tablolarýn Oluþturulmasý
-- Zaman makineleri tablosu
CREATE TABLE TimeMachines (
    MachineID INT PRIMARY KEY IDENTITY(1,1),
    MachineName NVARCHAR(50) NOT NULL,
    Capacity INT NOT NULL,
    LastMaintenanceDate DATE NOT NULL
);

-- Yolcular tablosu
CREATE TABLE Travelers (
    TravelerID INT PRIMARY KEY IDENTITY(1,1),
    FullName NVARCHAR(100) NOT NULL,
    BirthYear INT NOT NULL,
    ContactInfo NVARCHAR(100)
);

-- Yolculuklar tablosu
CREATE TABLE Journeys (
    JourneyID INT PRIMARY KEY IDENTITY(1,1),
    JourneyDate DATE NOT NULL,
    DestinationYear INT NOT NULL,
    MachineID INT NOT NULL,
    FOREIGN KEY (MachineID) REFERENCES TimeMachines(MachineID)
);

-- Rezervasyonlar tablosu
CREATE TABLE Reservations (
    ReservationID INT PRIMARY KEY IDENTITY(1,1),
    JourneyID INT NOT NULL,
    TravelerID INT NOT NULL,
    ReservationDate DATE NOT NULL DEFAULT GETDATE(),
    FOREIGN KEY (JourneyID) REFERENCES Journeys(JourneyID),
    FOREIGN KEY (TravelerID) REFERENCES Travelers(TravelerID)
);

-- Zaman makineleri
INSERT INTO TimeMachines (MachineName, Capacity, LastMaintenanceDate) VALUES
('Ceres', 5, '2025-01-01'),
('Pallas', 3, '2024-12-20'),
('Juno', 8, '2024-11-13'),
('Vesta', 1, '2025-11-25'),
('Iris', 4, '2025-01-28');

-- Yolcular
INSERT INTO Travelers (FullName, BirthYear, ContactInfo) VALUES
('Sýla Ýldeniz', 2002, 'silaildeniz@example.com'),
('Çaðatay Ulusoy', 1990, 'cagatayulusoy@example.com'),
('Albert Einstein', 1879, 'einstein@relativity.com'),
('Alper Gezeravcý', 1979, 'alpergezeravci@relativity.com'),
('Arda Türkmen', 1975, 'ardaturkmen@relativity.com');

-- Yolculuklar
INSERT INTO Journeys (JourneyDate, DestinationYear, MachineID) VALUES
('2025-01-10', 3025, 1),
('2025-02-01', 1945, 2),
('2025-03-15', 2050, 3),
('2025-04-01', 2100, 4),
('2025-05-01', 2080, 5);

-- Rezervasyonlar
INSERT INTO Reservations (JourneyID, TravelerID) VALUES
(1, 1),
(1, 2),
(2, 3),
(3, 4),
(4, 5);
    --ÝÇ ÝÇE SELECT SORGULARI
-- Sorgu 1: Her yolculuk için toplam rezervasyon sayýsýný listeleme
SELECT J.JourneyID, J.DestinationYear, COUNT(R.ReservationID) AS TotalReservations
FROM Journeys J
LEFT JOIN Reservations R ON J.JourneyID = R.JourneyID
GROUP BY J.JourneyID, J.DestinationYear;

-- Sorgu 2: En çok yolcu taþýyan zaman makinesi
SELECT TM.MachineName, COUNT(R.ReservationID) AS TotalPassengers
FROM TimeMachines TM
JOIN Journeys J ON TM.MachineID = J.MachineID
JOIN Reservations R ON J.JourneyID = R.JourneyID
GROUP BY TM.MachineName
ORDER BY TotalPassengers DESC;

-- Sorgu 3: Belirli bir yolcunun yaptýðý tüm yolculuklarý listeleme
SELECT T.FullName, J.JourneyDate, J.DestinationYear, TM.MachineName
FROM Travelers T
JOIN Reservations R ON T.TravelerID = R.TravelerID
JOIN Journeys J ON R.JourneyID = J.JourneyID
JOIN TimeMachines TM ON J.MachineID = TM.MachineID
WHERE T.FullName = 'Sýla Ýldeniz';




-- Yolculuk ve toplam rezervasyon sayýsýný listeleyen View Örneði

CREATE VIEW vw_JourneyDetails AS
SELECT 
    J.JourneyID, 
    J.JourneyDate, 
    J.DestinationYear, 
    TM.MachineName, 
    COUNT(R.ReservationID) AS TotalReservations
FROM 
    Journeys J
LEFT JOIN 
    TimeMachines TM ON J.MachineID = TM.MachineID
LEFT JOIN 
    Reservations R ON J.JourneyID = R.JourneyID
GROUP BY 
    J.JourneyID, 
    J.JourneyDate, 
    J.DestinationYear, 
    TM.MachineName;
	
	--Zaman Makinesi ve Yolculuk Bilgileri Görünümü
	CREATE VIEW vw_TimeMachineJourneys AS
SELECT 
    TM.MachineName, 
    J.JourneyDate, 
    J.DestinationYear
FROM 
    TimeMachines TM
JOIN 
    Journeys J ON TM.MachineID = J.MachineID;
	
	--Rezervasyon Detaylarýný Gösteren View
	CREATE VIEW vw_ReservationDetails AS
SELECT 
    T.FullName, 
    J.JourneyDate, 
    J.DestinationYear, 
    TM.MachineName
FROM 
    Travelers T
JOIN 
    Reservations R ON T.TravelerID = R.TravelerID
JOIN 
    Journeys J ON R.JourneyID = J.JourneyID
JOIN 
    TimeMachines TM ON J.MachineID = TM.MachineID;

	--FUNCTÝON ÖRNEKLERÝ
	-- Yolculuk Sayýsý Hesaplayan Fonksiyon
	
CREATE FUNCTION GetJourneyCountByMachine (@MachineID INT)
RETURNS INT
AS
BEGIN
    DECLARE @JourneyCount INT;
    
    -- JourneyCount deðiþkenine, belirtilen MachineID için yolculuk sayýsýný atama
    SELECT @JourneyCount = COUNT(*) 
    FROM Journeys
    WHERE MachineID = @MachineID;
    
    -- JourneyCount deðiþkenini döndürme
    RETURN @JourneyCount;
END;
GO

-- Fonksiyonu çaðýrma
SELECT dbo.GetJourneyCountByMachine(1) AS JourneyCount;

--Yolcunun yaþýný hesaplama

CREATE FUNCTION GetTravelerAge (@TravelerID INT)
RETURNS INT
AS
BEGIN
    DECLARE @Age INT;
    
    -- Yolcunun doðum yýlýna göre yaþýný hesaplama
    SELECT @Age = DATEDIFF(YEAR, BirthYear, GETDATE()) 
    FROM Travelers
    WHERE TravelerID = @TravelerID;

    -- Yaþý geri döndürme
    RETURN @Age;
END;
GO

-- Fonksiyonu kullanma
SELECT dbo.GetTravelerAge(1) AS Age;

-- Zaman Makinesinin Bakým Durumu
CREATE FUNCTION GetMachineMaintenanceAge (@MachineID INT)
RETURNS INT
AS
BEGIN
    DECLARE @MaintenanceAge INT;
    
    -- Zaman makinesinin bakým tarihinden bugüne kadar olan gün farkýný hesaplama
    SELECT @MaintenanceAge = DATEDIFF(DAY, LastMaintenanceDate, GETDATE()) 
    FROM TimeMachines
    WHERE MachineID = @MachineID;

    -- Bakým yaþý (gün cinsinden) geri döndürme
    RETURN @MaintenanceAge;
END;
GO

-- Fonksiyonu kullanma
SELECT dbo.GetMachineMaintenanceAge(1) AS MaintenanceAge;

--TRÝGGER
--  Yeni yolculuk Ekleme
CREATE TRIGGER trg_UpdateMachineMaintenance
ON Journeys
AFTER INSERT
AS
BEGIN
    UPDATE TimeMachines
    SET LastMaintenanceDate = GETDATE()
    WHERE MachineID IN (SELECT MachineID FROM inserted);
END;

-- Yeni bir yolculuk ekleyerek trigger'ý test edebilirsiniz
INSERT INTO Journeys (JourneyDate, DestinationYear, MachineID) VALUES ('2025-04-01', 2100, 1);

-- Rezervasyon Yapýldýðýnda Zaman Makinesi Kapasitesini Azaltma
CREATE TRIGGER trg_UpdateMachineCapacity
ON Reservations
AFTER INSERT
AS
BEGIN
    UPDATE TimeMachines
    SET Capacity = Capacity - 1
    WHERE MachineID IN (SELECT MachineID FROM Journeys WHERE JourneyID IN (SELECT JourneyID FROM inserted));
END;

-- Trigger'ý test etme
INSERT INTO Reservations (JourneyID, TravelerID) VALUES (1, 3);

-- Rezervasyon Silindiðinde Kapasitenin Artmasý
CREATE TRIGGER trg_RestoreMachineCapacity
ON Reservations
AFTER DELETE
AS
BEGIN
    UPDATE TimeMachines
    SET Capacity = Capacity + 1
    WHERE MachineID IN (SELECT MachineID FROM Journeys WHERE JourneyID IN (SELECT JourneyID FROM deleted));
END;

-- Trigger'ý test etme
DELETE FROM Reservations WHERE ReservationID = 1;

--  Stored Procedure Örneði
--Zaman Makinesiyle Yapýlan Yolculuklarý Listeleme
CREATE PROCEDURE GetJourneysByMachine
    @MachineID INT
AS
BEGIN
    SELECT J.JourneyID, J.JourneyDate, J.DestinationYear
    FROM Journeys J
    WHERE J.MachineID = @MachineID;
END;

EXEC GetJourneysByMachine @MachineID = 1;


-- Yolcuya Ait Rezervasyonlarý Listeleme 
CREATE PROCEDURE GetReservationsByTraveler
    @TravelerID INT
AS
BEGIN
    SELECT J.JourneyDate, J.DestinationYear, TM.MachineName
    FROM Reservations R
    JOIN Journeys J ON R.JourneyID = J.JourneyID
    JOIN TimeMachines TM ON J.MachineID = TM.MachineID
    WHERE R.TravelerID = @TravelerID;
END;

-- Prosedürü çaðýrma
EXEC GetReservationsByTraveler @TravelerID = 1;

--Yolculuk Ekleme
CREATE PROCEDURE AddNewJourney
    @JourneyDate DATE, 
    @DestinationYear INT, 
    @MachineID INT
AS
BEGIN
    INSERT INTO Journeys (JourneyDate, DestinationYear, MachineID)
    VALUES (@JourneyDate, @DestinationYear, @MachineID);
END;

-- Prosedürü çaðýrma
EXEC AddNewJourney @JourneyDate = '2025-07-01', @DestinationYear = 2090, @MachineID = 2;
*/


