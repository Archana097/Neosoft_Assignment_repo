create database Neosoft_ArchanaDB

Use Neosoft_ArchanaDB;

CREATE TABLE Country (
    Row_Id INT PRIMARY KEY IDENTITY(1,1),
    CountryName NVARCHAR(100) NOT NULL
);

CREATE TABLE State (
    Row_Id INT PRIMARY KEY IDENTITY(1,1),
    CountryId INT NOT NULL,
    StateName NVARCHAR(100) NOT NULL,
    CONSTRAINT FK_Country_State FOREIGN KEY (CountryId) REFERENCES Country(Row_Id)
);

CREATE TABLE City (
    Row_Id INT PRIMARY KEY IDENTITY(1,1),
    StateId INT NOT NULL,
    CityName NVARCHAR(100) NOT NULL,
    CONSTRAINT FK_State_City FOREIGN KEY (StateId) REFERENCES State(Row_Id)
);
CREATE TABLE EmployeeMaster (
    Row_Id INT PRIMARY KEY IDENTITY(1,1),
    EmployeeCode AS RIGHT('00' + CAST(Row_Id AS VARCHAR(8)), 3),
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50),
    CountryId INT NOT NULL,
    StateId INT NOT NULL,
    CityId INT NOT NULL,
    EmailAddress VARCHAR(100) NOT NULL UNIQUE,
    MobileNumber VARCHAR(15) NOT NULL UNIQUE,
    PanNumber VARCHAR(12) NOT NULL UNIQUE,
    PassportNumber VARCHAR(20) NOT NULL UNIQUE,
    ProfileImage NVARCHAR(100),
    Gender TINYINT,
    IsActive BIT NOT NULL,
    DateOfBirth DATE NOT NULL,
    DateOfJoinee DATE,
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
    UpdatedDate DATETIME,
    IsDeleted BIT NOT NULL DEFAULT 0,
    DeletedDate DATETIME,
    CONSTRAINT FK_Country FOREIGN KEY (CountryId) REFERENCES Country(Row_Id),
    CONSTRAINT FK_State FOREIGN KEY (StateId) REFERENCES State(Row_Id),
    CONSTRAINT FK_City FOREIGN KEY (CityId) REFERENCES City(Row_Id)
);


--Drop table EmployeeMaster;

--sp_columns EmployeeMaster;



-- Insert values into Country table
INSERT INTO Country (CountryName) VALUES 
('United States'), 
('India'), 
('Canada');

-- Insert values into State table
INSERT INTO State (CountryId, StateName) VALUES 
(1, 'California'), 
(1, 'Texas'), 
(2, 'Maharashtra'), 
(2, 'Karnataka'), 
(3, 'Ontario'), 
(3, 'British Columbia');

-- Insert values into City table
INSERT INTO City (StateId, CityName) VALUES 
(1, 'Los Angeles'), 
(1, 'San Francisco'), 
(2, 'Houston'), 
(2, 'Dallas'), 
(3, 'Mumbai'), 
(3, 'Pune'), 
(4, 'Bangalore'), 
(4, 'Mysore'), 
(5, 'Toronto'), 
(5, 'Ottawa'), 
(6, 'Vancouver'), 
(6, 'Victoria'); 


--Select * from Country;
--Select * from State;
--Select * from City;



-- Insert Employee
CREATE PROCEDURE stp_Emp_InsertEmployee
    @FirstName NVARCHAR(50),
    @LastName NVARCHAR(50),
    @CountryId INT,
    @StateId INT,
    @CityId INT,
    @EmailAddress VARCHAR(100),
    @MobileNumber VARCHAR(15),
    @PanNumber VARCHAR(12),
    @PassportNumber VARCHAR(20),
    @ProfileImage NVARCHAR(100),
    @Gender TINYINT,
    @IsActive BIT,
    @DateOfBirth DATE,
    @DateOfJoinee DATE
AS
BEGIN
    INSERT INTO EmployeeMaster (FirstName, LastName, CountryId, StateId, CityId, EmailAddress, MobileNumber, PanNumber, PassportNumber, ProfileImage, Gender, IsActive, DateOfBirth, DateOfJoinee, CreatedDate)
    VALUES (@FirstName, @LastName, @CountryId, @StateId, @CityId, @EmailAddress, @MobileNumber, @PanNumber, @PassportNumber, @ProfileImage, @Gender, @IsActive, @DateOfBirth, @DateOfJoinee, GETDATE());
END;

-- Delete Employee
CREATE PROCEDURE stp_Emp_DeleteEmployee
    @EmployeeCode INT
AS
BEGIN
    UPDATE EmployeeMaster
    SET 
        IsDeleted = 1,
        DeletedDate = GETDATE()
    WHERE EmployeeCode = @EmployeeCode;
END;

-- Get All Employees
CREATE PROCEDURE stp_Emp_GetAllEmployees
AS
BEGIN
    SELECT * FROM EmployeeMaster
    WHERE IsDeleted = 0;
END;

Create PROCEDURE stp_Emp_GetEmployeeByID
    @EmployeeCode varchar(10)
AS
BEGIN
    Select * from EmployeeMaster
    WHERE EmployeeCode = @EmployeeCode
	AND IsDeleted = 0;;
END;


-- Update Employee Master
CREATE PROCEDURE stp_Emp_UpdateEmployeeByCode
	@EmployeeCode VARCHAR(10),
    @FirstName NVARCHAR(50),
    @LastName NVARCHAR(50),
    @CountryId INT,
    @StateId INT,
    @CityId INT,
    @EmailAddress VARCHAR(100),
    @MobileNumber VARCHAR(15),
    @PanNumber VARCHAR(12),
    @PassportNumber VARCHAR(20),
    @ProfileImage NVARCHAR(100),
    @Gender TINYINT,
    @IsActive BIT,
    @DateOfBirth DATE,
    @DateOfJoinee DATE
AS
BEGIN
    Update EmployeeMaster 
			Set 
				FirstName = @FirstName, 
				LastName =  @LastName, 
				CountryId = @CountryId,
				StateId = @StateId,
				CityId = @CityId,
				EmailAddress = @EmailAddress,
				MobileNumber  = @MobileNumber, 
				PanNumber = @PanNumber,
				PassportNumber = @PassportNumber, 
				ProfileImage = @ProfileImage,
				Gender = @Gender,
				IsActive = @IsActive,
				DateOfBirth = @DateOfBirth,
				DateOfJoinee = @DateOfJoinee
				Where EmployeeCode = @EmployeeCode;
END;




--ALTER TABLE Country
--ADD IsDeleted BIT DEFAULT 0;

--Update Country
--Set IsDeleted = 0
--Where IsDeleted is null;

--Alter table State
--Add IsDeleted Bit Default 0;

--Update State
--Set IsDeleted = 0
--Where IsDeleted is null;

--Alter table City
--Add IsDeleted Bit Default 0;

--Update City
--Set IsDeleted = 0
--Where IsDeleted is null;

CREATE PROCEDURE stp_GetCountries
AS
BEGIN
    SELECT Row_Id, CountryName FROM Country WHERE IsDeleted = 0;
END;


Alter PROCEDURE stp_GetStates
    @CountryId INT
AS
BEGIN
    SELECT Row_Id, CountryId,StateName FROM State WHERE CountryId = @CountryId AND IsDeleted = 0;
END;

Alter PROCEDURE stp_GetCities
    @StateId INT
AS
BEGIN
    SELECT Row_Id,StateId,CityName FROM City WHERE StateId = @StateId AND IsDeleted = 0;
END;

Create Procedure stp_Get_All_Cities
As
Begin
	Select Row_Id,StateId,CityName from City
	Where IsDeleted = 0;
End

Create Procedure stp_Get_All_States
As
Begin
	Select Row_Id,CountryId,StateName from State
	Where IsDeleted = 0;
End

--Validation for Duplicate Email
Alter PROCEDURE stp_Emp_CheckDuplicateEmail
    @EmailAddress VARCHAR(50),
	@EmployeeCode Varchar(10) = Null
AS
BEGIN
	SELECT COUNT(1)
	FROM EmployeeMaster 
    WHERE EmailAddress = @EmailAddress
	AND (@EmployeeCode is Null and @EmployeeCode = @EmployeeCode)
	or ( EmployeeCode <> @EmployeeCode and EmailAddress =@EmailAddress)
	And IsDeleted = 0;
END;

--Validation for Duplicate MobileNumber
Alter PROCEDURE stp_Emp_CheckDuplicateMobileNumber
    @MobileNumber VARCHAR(100),
	@EmployeeCode Varchar(10) = Null
AS
BEGIN
    SELECT COUNT(1)
    FROM EmployeeMaster
    WHERE MobileNumber = @MobileNumber 
	AND (@EmployeeCode is Null and @EmployeeCode = @EmployeeCode)
	or ( EmployeeCode <> @EmployeeCode and MobileNumber =@MobileNumber)
	And IsDeleted = 0;
END;

--Validation for Duplicate PanNumber
Alter PROCEDURE stp_Emp_CheckDuplicatePanNumber
    @PanNumber VARCHAR(100),
	@EmployeeCode Varchar(10) = Null
AS
BEGIN
    SELECT COUNT(1)
    FROM EmployeeMaster
    WHERE PanNumber = @PanNumber
	AND (@EmployeeCode is Null and @EmployeeCode = @EmployeeCode)
	or ( EmployeeCode <> @EmployeeCode and PanNumber =@PanNumber)
	And IsDeleted = 0;
END;

--Validation for Duplicate PassportNumber
ALter PROCEDURE stp_Emp_CheckDuplicatePassportNumber
    @PassportNumber VARCHAR(100),
	@EmployeeCode Varchar(10) = Null
AS
BEGIN
    SELECT COUNT(1)
    FROM EmployeeMaster
    WHERE PassportNumber = @PassportNumber
	AND (@EmployeeCode is Null and @EmployeeCode = @EmployeeCode)
	or ( EmployeeCode <> @EmployeeCode and PassportNumber =@PassportNumber)
	And IsDeleted = 0;
END;



--exec stp_GetStates 1;

--INSERT INTO
--			EmployeeMaster (FirstName, LastName, CountryId, StateId, CityId, EmailAddress, MobileNumber, PanNumber, PassportNumber, ProfileImage, Gender, IsActive, DateOfBirth, DateOfJoinee, CreatedDate)
--    VALUES 
--		   ('Arjun',--@FirstName,
--		    'Kshatriya',--@LastName,
--			2,--@CountryId,
--			2,--@StateId,
--			2,--@CityId,
--			'Email@Gmail.com',--@EmailAddress,
--			'97987897897',--@MobileNumber,
--			'CGKJYU9878',--@PanNumber,
--			'2398749237597',--@PassportNumber,
--			'ProfileImage',--@ProfileImage,
--			1, --@Gender,
--			1,--@IsActive,
--			GETDATE(),--@DateOfBirth,
--			GETDATE(),--@DateOfJoinee,
--			GETDATE()
--			);

--exec stp_Emp_GetAllEmployees;

--exec stp_Get_All_States;
--exec stp_Get_All_Cities;


--EXEC sp_help stp_Emp_InsertEmployee;

--Select * From EmployeeMaster;
--Select * from Country;
--Select * from State;
--Select * from City;

--exec sp_columns EmployeeMaster;

SELECT COUNT(1)
    FROM EmployeeMaster
    WHERE EmailAddress = 'FStayNight@rediffmail.com';



exec stp_Emp_CheckDuplicateEmail 'FateStayNight@rediffmail.com'
	stp_Emp_CheckDuplicatePassportNumber




	Update EmployeeMaster
	Set IsDeleted = 0
	Where Row_Id = 8;


	Declare @EmailAddress varchar(30) = 'FateStayNight@rediffmail.com';
	Declare @EmployeeCode varchar(10) = '008';
	SELECT COUNT(1)
    FROM EmployeeMaster
    WHERE EmailAddress = @EmailAddress
	--And EmployeeCode = @EmployeeCode
	AND (@EmployeeCode is Null and @EmployeeCode = @EmployeeCode)
	or ( EmployeeCode <> @EmployeeCode and EmailAddress =@EmailAddress)
	And IsDeleted = 0;


Alter PROCEDURE EmailDuplicate (@EmailAddress Varchar(30), @EmployeeCode varchar(50) = NULL) 
AS
BEGIN
    SELECT COUNT(1)
	FROM EmployeeMaster 
    WHERE EmailAddress = @EmailAddress
    AND (@EmployeeCode IS NULL OR @EmployeeCode <> @EmployeeCode)
	And IsDeleted = 0
END;

exec EmailDuplicate 'FateStayNight@rediffmail.com','007';


exec EmailDuplicate 'FateStayNight@rediffmail.com','009';


exec stp_Emp_CheckDuplicateEmail 'FateStayNight@rediffmail.com','008';


-- C:\Users\user\Documents\SQL Server Management Studio

