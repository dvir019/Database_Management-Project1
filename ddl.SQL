CREATE TABLE Character
(
    CharacterName VARCHAR(40) PRIMARY KEY,
    Role          VARCHAR(40) NOT NULL,
    HairColor     VARCHAR(40) NOT NULL
);

CREATE TABLE Magician
(
    CharacterName VARCHAR(40) PRIMARY KEY,
    WandNumber    VARCHAR(40) UNIQUE NOT NULL,
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
    -- TODO: Two tables or attribute, and check cover
    FOREIGN KEY (Manager) REFERENCES Magician (CharacterName)
);

CREATE TABLE HeterogeneousInstitution
(
    InstitutionName VARCHAR(40) PRIMARY KEY,
    FOREIGN KEY (InstitutionName) REFERENCES AcademicInstitution ON DELETE CASCADE
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
    HouseName         VARCHAR(40) PRIMARY KEY,
    Color             VARCHAR(40)        NOT NULL,
    NumberOfResidents INTEGER            NOT NULL,
    BelongsTo         VARCHAR(40)        NOT NULL,
    HeadOfHouse       VARCHAR(40) UNIQUE NOT NULL,

    FOREIGN KEY (BelongsTo) REFERENCES HeterogeneousInstitution (InstitutionName) ON DELETE CASCADE,
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
    Year       INTEGER     NOT NULL
        CHECK (Year >= 0 AND Year <= 9999),
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
    FOREIGN KEY (HostTeamHouse, HostedTeamHouse, Year) REFERENCES Games (HostTeamHouse, HostedTeamHouse, Year),
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