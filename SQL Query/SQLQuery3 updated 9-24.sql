-- Create User Table
CREATE TABLE [User] (
    UserId INT PRIMARY KEY IDENTITY(1,1),
    Username VARCHAR(255) UNIQUE NOT NULL,
    Password VARCHAR(255) NOT NULL
);

-- Create Planet Table
CREATE TABLE Planet (
    PlanetId INT PRIMARY KEY IDENTITY(1,1),
    DistanceFromSun BIGINT
);

-- Create Spacecraft Table
CREATE TABLE Spacecraft (
    CraftId INT PRIMARY KEY IDENTITY(1,1),
    Type VARCHAR(255),
    Speed INT
);

-- Create Account Table
CREATE TABLE Account (
    AccountId INT PRIMARY KEY IDENTITY(1,1),
    UserId INT NOT NULL,
    SpaceBuxBalance INT,
    FOREIGN KEY (UserId) REFERENCES [User](UserId)
);

-- Create Trip Table
CREATE TABLE Trip (
    TripId INT PRIMARY KEY IDENTITY(1,1),
    SpacecraftId INT,
    OriginPlanet INT,
    DestinationPlanet INT,
    FlightDate DATETIME,
    FOREIGN KEY (SpacecraftId) REFERENCES Spacecraft(CraftId),
    FOREIGN KEY (OriginPlanet) REFERENCES Planet(PlanetId),
    FOREIGN KEY (DestinationPlanet) REFERENCES Planet(PlanetId)
);

-- Create Flight Table
CREATE TABLE Flight (
    FlightId INT PRIMARY KEY IDENTITY(1,1),
    AccountId INT,
    TripId INT,
    FOREIGN KEY (AccountId) REFERENCES Account(AccountId),
    FOREIGN KEY (TripId) REFERENCES Trip(TripId)
);


alter table Planet
add PlanetImageURL text;

alter table Planet
add PlanetName varchar(255);

alter table Planet
alter column DistanceFromSun decimal(8, 2);

alter table Trip
add TripDistance decimal(10, 2);

-- Views: --
-- ~~User and account together:

create view vw_UserAccountInfo
as
select
    u.UserId, 
    u.Username, 
    a.AccountId, 
    a.SpaceBuxBalance
from 
    [User] u
join 
    Account a on u.UserId = a.UserId;


-- ~~Available spacecract dropdown:

create view vw_AvailableSpacecraft
as
select
    CraftId, 
    Type, 
    Speed
from 
    Spacecraft;


-- ~~Trip detail output:

create view vw_TripDetails
as 
select 
    t.TripId, 
    t.FlightDate, 
    s.Type as SpacecraftType, 
    s.Speed as SpacecraftSpeed, 
    p1.PlanetName as OriginPlanet, 
    p2.PlanetName as DestinationPlanet,
    ABS(p1.DistanceFromSun - p2.DistanceFromSun) as TripDistance -- Calculate distance between planets
from 
    Trip t
join 
    Spacecraft s on t.SpacecraftId = s.CraftId
join 
    Planet p1 on t.OriginPlanet = p1.PlanetId
join 
    Planet p2 on t.DestinationPlanet = p2.PlanetId;


-- ~~User trip history:

create view vw_UserTripHistory
as
select
    u.Username, 
    t.FlightDate, 
    s.Type as SpacecraftType, 
    p1.PlanetName as OriginPlanet, 
    p2.PlanetName as DestinationPlanet
from 
    [User] u
join 
    Account a on u.UserId = a.UserId
join 
    Flight f on a.AccountId = f.AccountId
join 
    Trip t on f.TripId = t.TripId
join 
    Spacecraft s on t.SpacecraftId = s.CraftId
join 
    Planet p1 on t.OriginPlanet = p1.PlanetId
join 
    Planet p2 ON t.DestinationPlanet = p2.PlanetId;

-- ~~~~~~~~~~~~
-- Triggers: --
-- ~~Update SpaceBux balance after payment:

create trigger trg_UpdateBalanceAfterTrip
on Flight
after insert
as 
begin
    -- Declare variables for calculating the trip cost
    declare @TripDistance decimal(10, 2);
    declare @TripCost int;
    declare @AccountId int;

    -- Retrieve the TripDistance and AccountId from the inserted row
    select 
        @TripDistance = t.TripDistance, 
        @AccountId = f.AccountId
    from 
        Flight f
    join 
        Trip t on f.TripId = t.TripId
    where 
        f.FlightId in (select FlightId from inserted);

    -- Calculate the trip cost based on the distance
    set @TripCost = 10 + (1.33 * @TripDistance * 10);

    -- Update the SpaceBuxBalance in the Account table
    update Account
    set SpaceBuxBalance = SpaceBuxBalance - @TripCost
    where AccountId = @AccountId;
end;


-- ~~Delete user info:

create trigger trg_DeleteUser
on [User]
after delete
as
begin
    -- Delete related records from Account
    delete from Account
    where UserId in (select UserId from deleted);

    -- Delete related records from Flight based on AccountId
    delete from Flight
    where AccountId in (select AccountId from Account where UserId in (select UserId from deleted));

    -- Delete from Trip 
    delete from Trip
    where TripId in (select TripId from Flight where AccountId in (select AccountId from Account where UserId in (select UserId from deleted)));
end;








insert into Planet (PlanetName, DistanceFromSun, PlanetImageURL)
values 
('Pluto', 39.5, 'https://imgs.search.brave.com/UZ_oK95Zv-egg-C0fChBnc4R4VzXSluFuhRAzKEK7aE/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9zY2ll/bmNlLm5hc2EuZ292/L3dwLWNvbnRlbnQv/dXBsb2Fkcy8yMDIz/LzA5L0JJR19QX0NP/TE9SXzJfVFJVRV9D/T0xPUjFfMTk4MC5q/cGc_dz00MDk2JmZv/cm1hdD1qcGVn'),
('Merucry', 0.39, 'https://imgs.search.brave.com/ghGXDhPZFDe-1yFfwQM2RQd2wgl77y6dUQQOXVV7IOQ/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly90NC5m/dGNkbi5uZXQvanBn/LzAyLzczLzg0LzEx/LzM2MF9GXzI3Mzg0/MTE1NV92NERJVldo/ckpOMDFNdHRHa2tH/Q29xS3NKdGFNTW9Z/OC5qcGc'),
('Venus', 0.72, 'https://imgs.search.brave.com/ZjxY0Ugij8XHGoAM68KfwqPK_9Rd5Wb7UEZzdBO28mE/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9pbWFn/ZXMtYXNzZXRzLm5h/c2EuZ292L2ltYWdl/L1BJQTAwMjcxL1BJ/QTAwMjcxfmxhcmdl/LmpwZz93PTE5MjAm/aD0xOTIwJmZpdD1j/bGlwJmNyb3A9ZmFj/ZXMsZm9jYWxwb2lu/dA'), 
('Earth', 1, 'https://imgs.search.brave.com/vUBZ3V-aSNeh7-o0hQsWPmdcv5bKmCxPxwCKP0C3wC8/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly91cGxv/YWQud2lraW1lZGlh/Lm9yZy93aWtpcGVk/aWEvY29tbW9ucy82/LzYwL0VhcnRoX2Zy/b21fU3BhY2UuanBn'), 
('Mars', 1.52, 'https://imgs.search.brave.com/HnihwKONgKs8rpuMZAb6ppWCoRkpj_3azWQTDXD8fb0/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly93d3cu/ZXNhLmludC92YXIv/ZXNhL3N0b3JhZ2Uv/aW1hZ2VzL2VzYV9t/dWx0aW1lZGlhL2lt/YWdlcy8yMDA3LzAy/L3RydWUtY29sb3Vy/X2ltYWdlX29mX21h/cnNfc2Vlbl9ieV9v/c2lyaXMvOTk2OTcw/NS0yLWVuZy1HQi9U/cnVlLWNvbG91cl9p/bWFnZV9vZl9NYXJz/X3NlZW5fYnlfT1NJ/UklTX2FydGljbGUu/anBn'),
('Jupiter', 5.20, 'https://imgs.search.brave.com/ob1Ocn8-aAFFeLftxISO6Lh-vAeypNu6vUPJT2jTbdE/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly90NC5m/dGNkbi5uZXQvanBn/LzAyLzU5LzA3LzQ1/LzM2MF9GXzI1OTA3/NDU2N19qejRxQ0tW/eHQwaWpJZ05OSThU/aldZN1k1ajNReEZk/Vy5qcGc'),
('Saturn', 9.54, 'https://imgs.search.brave.com/PRbg3wWU9tJBm-3GCyr_g5ADyOl8wLNCuensWxr4UzY/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly93d3cu/dHJlZWh1Z2dlci5j/b20vdGhtYi9BN0VX/WVA2bHRGb2VpeUYt/NWM0M09VdVVibVk9/LzI4NXgwL2ZpbHRl/cnM6bm9fdXBzY2Fs/ZSgpOm1heF9ieXRl/cygxNTAwMDApOnN0/cmlwX2ljYygpL19f/b3B0X19hYm91dGNv/bV9fY29ldXNfX3Jl/c291cmNlc19fY29u/dGVudF9taWdyYXRp/b25fX21ubl9faW1h/Z2VzX18yMDE3X18w/OV9fc2F0dXJuX2Vu/dGlyZV9wbGFuZXQt/MjkzOTY2Yzc2MjEx/NGM5N2I4Y2NmYmZl/ZWE0NzhkYjkuanBn'), 
('Uranus', 19.22, 'https://imgs.search.brave.com/qYu06kP5cGXVsbyifkqpmLr8nO-O6TadOQYhS9zw8ZY/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9tZWRp/YS5pc3RvY2twaG90/by5jb20vaWQvMTMy/MjE2MjM4My9waG90/by9wbGFuZXQtaXNv/bGF0ZWQtb24tYS1i/bGFjay1iYWNrZ3Jv/dW5kLmpwZz9zPTYx/Mng2MTImdz0wJms9/MjAmYz1lZEJ3c0hM/RHlGR2VNNlhEMm5T/ZXEzekU4VnFYNHhQ/ZDVmMUJmWV9mWmtv/PQ'),
('Neptune', 30.06, 'https://imgs.search.brave.com/zlspb8YeWVvFSXgJVKGLr4LliivAqV1CeDmffgR2F3w/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly90My5m/dGNkbi5uZXQvanBn/LzAzLzI4LzY2LzI0/LzM2MF9GXzMyODY2/MjQ4M19rTG51UGxj/SWdRUUNDTmJiWFpN/S3VEdVNHZUZ5VGRx/My5qcGc'); 



tools to make handling database easier, views, triggers, delete user shoudld delete all info, view with account and user tables together, view with trip spacecraft planet where we show speed and trip details