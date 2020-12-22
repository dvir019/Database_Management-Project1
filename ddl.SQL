CREATE TABLE Character
(
    CharacterName VARCHAR(40) PRIMARY KEY,
    Role          VARCHAR(40) NOT NULL,
    HairColor     VARCHAR(40) NOT NULL
);

CREATE TABLE Magician
(
    CharacterName VARCHAR(40) PRIMARY KEY,
    WandNumber    INTEGER UNIQUE NOT NULL
        CHECK (WandNumber > 0),
    FOREIGN KEY (CharacterName) REFERENCES Character ON DELETE CASCADE
);

CREATE TABLE NotMagician
(
    CharacterName VARCHAR(40) PRIMARY KEY,
    LoyalTo       VARCHAR(40),

    FOREIGN KEY (CharacterName) REFERENCES Character ON DELETE CASCADE,
    FOREIGN KEY (LoyalTo) REFERENCES Character (CharacterName) --TODO: ON DELETE SET NULL (not possible
);

CREATE TABLE Feelings
(
    FeltBy        VARCHAR(40) NOT NULL,
    FeltTo        VARCHAR(40) NOT NULL,
    Emotion       CHAR(4)     NOT NULL
        CHECK (Emotion = 'love' OR Emotion = 'hate'),
    ExtremeMoment VARCHAR(40) NOT NULL,

    PRIMARY KEY (FeltBy, FeltTo),
    FOREIGN KEY (FeltBy) REFERENCES Character (CharacterName) ON DELETE CASCADE,
    FOREIGN KEY (FeltTo) REFERENCES Character (CharacterName)
);

CREATE TABLE Magic
(
    MagicWord       VARCHAR(40) PRIMARY KEY,
    DifficultyLevel INTEGER     NOT NULL
        CHECK (DifficultyLevel >= 1 AND DifficultyLevel <= 5),
    Description     VARCHAR(40) NOT NULL
);

CREATE TABLE MagicCast
(
    CastedBy    VARCHAR(40) NOT NULL,
    DateAndTime DATETIME    NOT NULL,
    MagicUsed   VARCHAR(40) NOT NULL,

    PRIMARY KEY (CastedBy, DateAndTime),
    FOREIGN KEY (CastedBy) REFERENCES Magician (CharacterName) ON DELETE CASCADE,-- TODO cascade?
    FOREIGN KEY (MagicUsed) REFERENCES Magic (MagicWord) ON DELETE CASCADE       -- TODO cascade?
);

CREATE TABLE AcademicInstitution
(
    InstitutionName VARCHAR(40) PRIMARY KEY,
    Manager         VARCHAR(40) UNIQUE NOT NULL,

    FOREIGN KEY (Manager) REFERENCES Magician (CharacterName)
);

CREATE TABLE HeterogeneousInstitution
(
    InstitutionName VARCHAR(40) PRIMARY KEY,
    FOREIGN KEY (InstitutionName) REFERENCES AcademicInstitution
        ON DELETE CASCADE
);

CREATE TABLE HomogeneousInstitution
(
    InstitutionName VARCHAR(40) PRIMARY KEY,
    FOREIGN KEY (InstitutionName) REFERENCES AcademicInstitution ON DELETE CASCADE
);

CREATE TABLE MembersOfHomogeneous
(
    MagicianName    VARCHAR(40) PRIMARY KEY,
    InstitutionName VARCHAR(40) NOT NULL,

    FOREIGN KEY (MagicianName) REFERENCES Magician (CharacterName) ON DELETE CASCADE,
    FOREIGN KEY (InstitutionName) REFERENCES HomogeneousInstitution ON DELETE CASCADE
);

CREATE TABLE Houses
(
    HouseName   VARCHAR(40) PRIMARY KEY,
    Color       VARCHAR(40)        NOT NULL,
    BelongsTo   VARCHAR(40)        NOT NULL,
    HeadOfHouse VARCHAR(40) UNIQUE NOT NULL,

    FOREIGN KEY (BelongsTo) REFERENCES HeterogeneousInstitution (InstitutionName)
        ON DELETE CASCADE,
    FOREIGN KEY (HeadOfHouse) REFERENCES Magician (CharacterName)
);

CREATE TABLE MembersOfHouses
(
    MagicianName VARCHAR(40) PRIMARY KEY,
    HouseName    VARCHAR(40) NOT NULL,

    FOREIGN KEY (MagicianName) REFERENCES Magician (CharacterName) ON DELETE CASCADE,
    FOREIGN KEY (HouseName) REFERENCES Houses ON DELETE CASCADE
);

CREATE TABLE Teams
(
    TeamHouse  VARCHAR(40) NOT NULL,
    Year       INTEGER     NOT NULL,
    BroomModel VARCHAR(40) NOT NULL,

    PRIMARY KEY (TeamHouse, Year),
    FOREIGN KEY (TeamHouse) REFERENCES Houses (HouseName) ON DELETE CASCADE
);

CREATE TABLE TeamPlayers
(
    TeamHouse      VARCHAR(40) NOT NULL,
    Year           INTEGER     NOT NULL,
    PlayerName     VARCHAR(40) NOT NULL,
    PlayerPosition VARCHAR(40) NOT NULL
        CHECK (PlayerPosition = 'Keeper' OR
               PlayerPosition = 'Beater' OR
               PlayerPosition = 'Chaser' OR
               PlayerPosition = 'Seeker'),
    PRIMARY KEY (TeamHouse, Year, PlayerName),
    FOREIGN KEY (TeamHouse, Year) REFERENCES Teams (TeamHouse, Year) ON DELETE CASCADE,
    FOREIGN KEY (PlayerName) REFERENCES Magician (CharacterName)
);

CREATE TABLE Games
(
    HostTeamHouse   VARCHAR(40) NOT NULL,
    HostedTeamHouse VARCHAR(40) NOT NULL,
    Year            INTEGER     NOT NULL,
    HostScore       INTEGER     NOT NULL,
    HostedScore     INTEGER     NOT NULL,

    PRIMARY KEY (HostTeamHouse, HostedTeamHouse, Year),
    FOREIGN KEY (HostTeamHouse, Year) REFERENCES Teams (TeamHouse, Year) ON DELETE CASCADE,
    FOREIGN KEY (HostedTeamHouse, Year) REFERENCES Teams (TeamHouse, Year) -- TODO: אם זה אפשרי, לשנות בקובץ לניתן לטפל כך כבר ברמת ה-דדל
);

CREATE TABLE Watchers
(
    WatcherName     VARCHAR(40) NOT NULL,
    HostTeamHouse   VARCHAR(40) NOT NULL,
    HostedTeamHouse VARCHAR(40) NOT NULL,
    Year            INTEGER     NOT NULL,
    EnjoymentLevel  INTEGER     NOT NULL
        CHECK (EnjoymentLevel >= 1 AND EnjoymentLevel <= 7),

    PRIMARY KEY (WatcherName, HostTeamHouse, HostedTeamHouse, Year),
    FOREIGN KEY (HostTeamHouse, HostedTeamHouse, Year) REFERENCES
        Games (HostTeamHouse, HostedTeamHouse, Year),
    FOREIGN KEY (WatcherName) REFERENCES Character (CharacterName) ON DELETE CASCADE
);


DROP TABLE Watchers;
DROP TABLE Games;
DROP TABLE TeamPlayers;
DROP TABLE Teams;
DROP TABLE MembersOfHouses;
DROP TABLE Houses;
DROP TABLE MembersOfHomogeneous;
DROP TABLE HomogeneousInstitution;
DROP TABLE HeterogeneousInstitution;
DROP TABLE AcademicInstitution;
DROP TABLE MagicCast;
DROP TABLE Magic;
DROP TABLE Feelings;
DROP TABLE NotMagician;
DROP TABLE Magician;
DROP TABLE Character;


-- ********************************************** VIEWS ************************************************


CREATE TABLE Test1
(
    Name    VARCHAR(10) PRIMARY KEY,
    LoyalTO VARCHAR(20)
);

INSERT INTO Test1 (Name, LoyalTO)
VALUES ('avi', 'red'),
       ('ben', 'red'),
       ('c', 'blue'),
       ('d', 'purple'),
       ('e', 'red'),
       ('f', 'blue');

SELECT NM.LoyalTo, COUNT(*) AS NumLoyals
FROM Test1 NM
GROUP BY NM.LoyalTo
HAVING COUNT(*) >= 2


CREATE TABLE Names
(
    Name VARCHAR(10) PRIMARY KEY
);

CREATE TABLE Inst
(
    InstName VARCHAR(40) PRIMARY KEY,
    Manager  VARCHAR(10),
    FOREIGN KEY (Manager) REFERENCES Names (Name)
);

INSERT INTO Names (Name)
VALUES ('blue'),
       ('red'),
       ('purple');

INSERT INTO Inst (InstName, Manager)
VALUES ('acad2', 'blue');

INSERT INTO Test1 (Name, LoyalTO)
VALUES ('h', 'purple');

SELECT M.Name
FROM Names M,
     (SELECT NM.LoyalTo, COUNT(*) AS NumLoyals
      FROM Test1 NM
      GROUP BY NM.LoyalTo
      HAVING COUNT(*) >= 2) as NM2,
     Inst AI
WHERE M.Name = NM2.LoyalTo
  AND M.Name = AI.Manager

CREATE TABLE Spells
(
    CastedBy    VARCHAR(10),
    DateAndTime DATETIME,
    FOREIGN KEY (CastedBy) REFERENCES Names (Name)
);

INSERT INTO Spells (CastedBy, DateAndTime)
VALUES ('blue', '2004-07-09 09:08'),
       ('purple', '2017-01-01 09:10');

DELETE
FROM Spells
WHERE CastedBy = 'blue'

CREATE VIEW TestView --LeaderMagicianFirstMagicDate
AS
SELECT M.Name, CONVERT(date, MC.DateAndTime) AS FirstMagic
FROM Names M,
     (SELECT NM.LoyalTo, COUNT(*) AS NumLoyals
      FROM Test1 NM
      GROUP BY NM.LoyalTo
      HAVING COUNT(*) >= 2) as NM2,
     Inst AI,
     Spells MC
WHERE M.Name = NM2.LoyalTo
  AND M.Name = AI.Manager
  AND M.Name = MC.CastedBy
  AND MC.DateAndTime = (select MIN(MC2.DateAndTime)
                        FROM Spells MC2
                        WHERE M.Name = MC2.CastedBy)


-- ***************************** FINAL ***************************
CREATE VIEW LeaderMagicianFirstMagicDate
AS
SELECT M.CharacterName, CONVERT(date, MC.DateAndTime) AS FirstMagic
FROM Magician M,
     (SELECT NM.LoyalTo, COUNT(*) AS NumLoyals
      FROM NotMagician NM
      GROUP BY NM.LoyalTo
      HAVING COUNT(*) >= 10) as NM2,
     AcademicInstitution AI,
     MagicCast MC
WHERE M.CharacterName = NM2.LoyalTo
  AND M.CharacterName = AI.Manager
  AND M.CharacterName = MC.CastedBy
  AND MC.DateAndTime = (SELECT MIN(MC2.DateAndTime)
                        FROM MagicCast MC2
                        WHERE M.CharacterName = MC2.CastedBy)
--**********************************************************************


/*
SELECT NM.LoyalTo, COUNT(*) AS NumLoyals
FROM NotMagician NM
GROUP BY NM.LoyalTo
HAVING COUNT(*) >= 10
 */

/*
SELECT *
FROM Test1
WHERE EXISTS(SELECT * FROM Magician)
  AND LoyalTO = ALL (SELECT CharacterName FROM Magician)
 */

CREATE VIEW LivingInMovie
AS
SELECT M.CharacterName
FROM Magician M
WHERE EXISTS(SELECT *
             FROM Feelings F1
             WHERE M.CharacterName = F1.FeltBy
               AND F1.Emotion = 'love')
  AND NOT EXISTS(SELECT *
                 FROM Feelings F2
                 WHERE M.CharacterName = F2.FeltBy
                   AND F2.Emotion = 'hate')
  AND EXISTS(SELECT *
             FROM Feelings F3
             WHERE M.CharacterName = F3.FeltTo
               AND F3.Emotion = 'hate')
  AND NOT EXISTS(SELECT *
                 FROM Feelings F4
                 WHERE M.CharacterName = F4.FeltTo
                   AND F4.Emotion = 'love')

CREATE TABLE Emotions
(
    FeltBy  VARCHAR(10),
    FeltTo  VARCHAR(10),
    Emotion VARCHAR(40),

    PRIMARY KEY (FeltBy, FeltTo)
);

INSERT INTO Emotions (FeltBy, FeltTo, Emotion)
VALUES ('blue', 'dani', 'hate'),
       ('x', 'blue', 'hate');
/*
CREATE VIEW LiveInMovie2
AS
SELECT M.Name
FROM Names M
WHERE EXISTS(SELECT *
             FROM Emotions F1
             WHERE M.Name = F1.FeltBy
               AND F1.Emotion = 'love')
  AND NOT EXISTS(SELECT *
                 FROM Emotions F2
                 WHERE M.Name = F2.FeltBy
                   AND F2.Emotion = 'hate')
  AND EXISTS(SELECT *
             FROM Emotions F3
             WHERE M.Name = F3.FeltTo
               AND F3.Emotion = 'hate')
  AND NOT EXISTS(SELECT *
                 FROM Emotions F4
                 WHERE M.Name = F4.FeltTo
                   AND F4.Emotion = 'love')

 */

/*
SELECT DISTINCT CONVERT(date, MC.DateAndTime)
FROM MagicCast MC


SELECT DISTINCT MC.MagicUsed
FROM MagicCast MC,
     (SELECT DISTINCT CONVERT(date, DateAndTime) as date
      FROM MagicCast) AS dates
WHERE EXISTS(SELECT *
             FROM MagicCast
             WHERE CONVERT(date, MC.DateAndTime) = dates.date
               AND MC.MagicUsed = MagicUsed)

 */

CREATE TABLE LiveMovie2
(
    CharacterName VARCHAR(10) PRIMARY KEY
);

CREATE TABLE UsefulMagics
(
    MagicUsed VARCHAR(40) PRIMARY KEY
);

CREATE TABLE Spells2
(
    CastedBy    VARCHAR(10),
    DateAndTime DATETIME,
    MagicUsed   VARCHAR(40),
    PRIMARY KEY (CastedBy, DateAndTime)
);

INSERT INTO LiveMovie2 (CharacterName)
VALUES ('avi'),
       ('gal'),
       ('moshe')

INSERT INTO UsefulMagics (MagicUsed)
VALUES ('abra'),
       ('kadabra')

INSERT INTO Spells2 (CastedBy, DateAndTime, MagicUsed)
VALUES /*('gal', '1985-02-10 09:00', 'abra'), ,
       ('avi', '2005-10-09 09:10', 'hoppa'),
       ('avi', '2000-07-09 09:25', 'abra'),
       ('gal', '2000-07-10 09:50', 'kadabra'),
       ('gal', '1985-07-10 09:50', 'abra'),
         */
    ('moshe', '2010-08-01 09:27', 'kadabra'),
    ('moshe', '2010-08-01 09:28', 'kadabra')

/*
CREATE VIEW Mashehu
AS
SELECT ABC.CharacterName, SUM(ABC.TimesUsed) a
FROM (SELECT LIM.CharacterName, VUM.MagicUsed, COUNT(*) AS TimesUsed
      FROM LiveMovie2 LIM,
           UsefulMagics VUM,
           Spells2 MC
      WHERE MC.CastedBy = LIM.CharacterName
        AND MC.MagicUsed = VUM.MagicUsed
      GROUP BY LIM.CharacterName, VUM.MagicUsed) AS ABC
GROUP BY ABC.CharacterName
ORDER BY a DESC
OFFSET (0) ROWS;

INSERT INTO Spells2 (CastedBy, DateAndTime, MagicUsed)
VALUES ('y', '2011-03-11 19:10', 'abra'),
       ('avi', '2005-10-09 09:10', 'hoppa'),
       ('avi', '2000-07-09 09:25', 'abra'),
       ('gal', '2000-07-10 09:50', 'kadabra'),
       ('gal', '1985-07-10 09:50', 'abra');

 */

/*
CREATE VIEW UsefullMagics2
AS
SELECT MagicUsed
FROM Spells2
    EXCEPT (SELECT MC.MagicUsed
            FROM Spells2 MC,
                 (SELECT DISTINCT CONVERT(date, DateAndTime) as date
                  FROM Spells2) AS Dates
            WHERE NOT EXISTS(SELECT *
                             FROM Spells2 MC2
                             WHERE CONVERT(date, MC2.DateAndTime) = Dates.date
                               AND MC.MagicUsed = MC2.MagicUsed))

 */

-- dsgsdgsdgsdsdsdgsdgsdgsdgsdgsdgsdgsdgdsg


CREATE VIEW VeryUsableMagics
AS
SELECT MagicUsed
FROM MagicCast
    EXCEPT (SELECT DISTINCT MC.MagicUsed
            FROM MagicCast MC,
                 (SELECT DISTINCT CONVERT(date, DateAndTime) as Date
                  FROM MagicCast) AS Dates
            WHERE NOT EXISTS(SELECT *
                             FROM MagicCast MC2
                             WHERE CONVERT(date, MC2.DateAndTime) = Dates.Date
                               AND MC.MagicUsed = MC2.MagicUsed))


CREATE VIEW MovieMagicianTotalUsableMagic
AS
SELECT IndividualUsableMagicCount.CharacterName,
       SUM(IndividualUsableMagicCount.TimesUsed) AS TotalUsableMagicCount
FROM (SELECT LIM.CharacterName, VUM.MagicUsed, COUNT(*) AS TimesUsed
      FROM LivingInMovie LIM,
           VeryUsableMagics VUM,
           MagicCast MC
      WHERE MC.CastedBy = LIM.CharacterName
        AND MC.MagicUsed = VUM.MagicUsed
      GROUP BY LIM.CharacterName, VUM.MagicUsed) AS IndividualUsableMagicCount
GROUP BY IndividualUsableMagicCount.CharacterName
ORDER BY TotalUsableMagicCount DESC
OFFSET (0) ROWS;


SELECT T.LoyalTO
FROM Test1 T
    EXCEPT (SELECT T2.LoyalTO FROM Test1 T2 WHERE T2.LoyalTO = 'red')

SELECT *
FROM Test1,
     Test1 t


SELECT DISTINCT MC.MagicUsed
FROM MagicCast MC,
     (SELECT DISTINCT CONVERT(date, DateAndTime) as date
      FROM MagicCast) AS dates
WHERE NOT EXISTS(SELECT *
                 FROM MagicCast
                 WHERE CONVERT(date, MC.DateAndTime) = dates.date
                   AND MC.MagicUsed = MagicUsed)








