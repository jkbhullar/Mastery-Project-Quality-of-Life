USE master;
GO

DROP DATABASE IF EXISTS qol;
GO

CREATE DATABASE qol;
GO

USE qol;
GO





drop table if exists Question;

drop table if exists IncomePerCapita;

drop table if exists Race;

drop table if exists Location;

drop table if exists Breakout;
go


create table Breakout (
    BreakoutID          INT             Primary Key Identity (1,1),
    Breakout            nvarchar(50)    Null,
    BreakoutCategory    nvarchar(50)    Null,
    CONSTRAINT unq_Breakout UNIQUE (BreakoutID, Breakout, BreakoutCategory)
);
GO

create table Location (
    LocationID          INT             Primary Key Identity (1,1),
    [State]             nvarchar(50)    Null, 
    Population2000       INT             Null,  
    Population2010       INT             Null,
    CONSTRAINT unq_Location UNIQUE (LocationID, [State], Population2000, Population2010)
); 
GO 

create table IncomePerCapita (
    IncomeCapitaID      INT             Primary Key Identity (1,1),
    stateAbbr           nvarchar(50)    Null,
    Year                INT             Null,
    IncomePerCapita     INT             Null,
    LocationID          INT             Null, 
    CONSTRAINT fk_capita_LocationID
        FOREIGN KEY (LocationID)
        REFERENCES Location(LocationID),
);
GO

create table Race (
    RaceID              INT               Primary Key Identity (1,1),
    stateAbbr           nvarchar(50)      Null,
    race                nvarchar(100)     Null,
    totalRacePopulation  INT              Null,
    LocationID            INT             Null,
    CONSTRAINT fk_race_LocationID
        FOREIGN KEY (LocationID)
        REFERENCES Location(LocationID),
);
GO

create table Question (
    QuestionID          INT             Primary Key Identity(1,1),
    Question            nvarchar(100)   Null,
    ValueType           nvarchar(50)    Null,
    [Value]             Decimal(3,1)    Null,
    [Year]              INT             Null,  --from risk factors table 
    SampleSize          INT             Null,
    BreakoutID          INT             Null, 
    LocationID          INT             Null,
    CONSTRAINT fk_BreakoutID 
        FOREIGN KEY (BreakoutID)
        REFERENCES Breakout(BreakoutID),
    CONSTRAINT fk_LocationID
        FOREIGN KEY (LocationID)
        REFERENCES Location(LocationID),
    CONSTRAINT unq_Question UNIQUE (QuestionID, Question, ValueType, [Value], [Year], SampleSize, BreakoutID, LocationID)
);
GO



insert into Breakout(Breakout, BreakoutCategory)
Select DISTINCT breakout, breakoutCategory
from risk_factors_clean


insert into Location([State], Population2000, Population2010)
Select DISTINCT  state, totalStatePop2000, totalStatePop2010
from totalStatePops


insert into IncomePerCapita (stateAbbr, Year, IncomePerCapita, LocationID)
select distinct stateAbbr, Year, IncomePerCapita, L.LocationID
from Capita as C
    JOIN Location AS L on C.stateAbbr = L.State


insert into Race(stateAbbr, race, totalRacePopulation, LocationID)
select distinct stateAbbr, race, totalPopByRace, L.LocationID 
from racePopulations as R
    JOIN Location AS L on R.stateAbbr = L.State


insert into Question(Question, ValueType, [Value], rfc.[Year], SampleSize, BreakoutID, LocationID)
select  rfc.Question, rfc.dataValueType, rfc.dataValues, rfc.Year, rfc.sampleSize, Br.BreakoutID, L.LocationID
from risk_factors_clean AS RFC
    JOIN Breakout as Br on RFC.breakout = Br.Breakout
    LEFT JOIN Location as L on RFC.StateAbbr = L.[State] 
GO



