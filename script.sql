USE [DBPayroll]
GO
/****** Object:  Table [dbo].[tblEmployee]    Script Date: 07/14/2017 00:20:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblEmployee](
	[EmpID] [int] IDENTITY(1,1) NOT NULL,
	[LName] [varchar](50) NOT NULL,
	[FName] [varchar](50) NOT NULL,
	[SSN] [char](9) NOT NULL,
	[DoH] [date] NOT NULL,
	[Address] [varchar](50) NOT NULL,
	[City] [varchar](50) NOT NULL,
	[State] [char](2) NOT NULL,
	[Zip] [char](5) NOT NULL,
	[Email] [varchar](50) NOT NULL,
	[Phone] [char](10) NOT NULL,
	[PayRate] [money] NOT NULL,
 CONSTRAINT [tblEmployee_pk] PRIMARY KEY CLUSTERED 
(
	[EmpID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tblTimesheet]    Script Date: 07/14/2017 00:20:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblTimesheet](
	[EmpID] [int] NOT NULL,
	[ShiftType] [char](2) NOT NULL,
	[StartDate] [date] NOT NULL,
	[EndDate] [date] NOT NULL,
	[TotalHours] [decimal](18, 2) NOT NULL,
	[OTHours] [decimal](18, 2) NOT NULL,
	[HolidayHours] [decimal](18, 2) NOT NULL,
	[NetPay] [money] NOT NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tblShifts]    Script Date: 07/14/2017 00:20:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblShifts](
	[EmpID] [int] NOT NULL,
	[Date] [date] NOT NULL,
	[ShiftStart] [time](7) NOT NULL,
	[ShiftEnd] [time](7) NOT NULL,
	[HoursWorked] [decimal](18, 2) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tblEmployeeDetail]    Script Date: 07/14/2017 00:20:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblEmployeeDetail](
	[EmpID] [int] IDENTITY(1,1) NOT NULL,
	[EmpCat] [int] NOT NULL,
	[PTOHours] [decimal](18, 2) NOT NULL,
	[MedInsDeduction] [money] NOT NULL,
	[DentInsDeduction] [money] NOT NULL,
 CONSTRAINT [tblEmployeeDetail_pk] PRIMARY KEY CLUSTERED 
(
	[EmpID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  StoredProcedure [dbo].[NewTimesheet]    Script Date: 07/14/2017 00:20:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[NewTimesheet](
@LName varchar(50),
@FName varchar(50),
@ShiftType char(2),
@StartDate date,
@EndDate date,
@OTHours decimal(18,2),
@HolidayHours decimal(18,2)
)
AS
BEGIN
INSERT INTO tblTimesheet(
EmpID,
ShiftType, 
StartDate, 
EndDate, 
TotalHours, 
OTHours, 
HolidayHours,
NetPay
)
SELECT e.EmpID, @ShiftType, @StartDate, @EndDate, SUM(HoursWorked) , 
@OTHours, @HolidayHours, 
CASE WHEN ed.EmpCat = 1 
THEN (SUM(HoursWorked) * PayRate) 
ELSE (e.PayRate / 24) 
END
FROM tblEmployee e INNER JOIN tblEmployeeDetail ed ON e.EmpID = ed.EmpID 
inner join tblShifts on e.EmpID = tblShifts.EmpID
WHERE LName=@LName AND FName=@FName AND Date > @StartDate AND Date < 
@EndDate
GROUP BY e.EmpID, ed.EmpCat, e.PayRate
END
GO
/****** Object:  StoredProcedure [dbo].[NewShift]    Script Date: 07/14/2017 00:20:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[NewShift](
@LName varchar(50),
@FName varchar(50),
@Date date,
@ShiftStart time,
@ShiftEnd time,
@HoursWorked decimal(18,2)
)
AS
BEGIN

INSERT INTO tblShifts(
EmpID,
Date,
ShiftStart,
ShiftEnd,
HoursWorked
)


SELECT EmpID, @Date, @ShiftStart, @ShiftEnd, @HoursWorked
FROM tblEmployee WHERE LName=@LName AND FName=@FName

END
GO
/****** Object:  StoredProcedure [dbo].[InsertNewEmployee]    Script Date: 07/14/2017 00:20:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[InsertNewEmployee]
(
@LName varchar(50),
@FName varchar(50),
@SSN char(9), 
@DoH date,
@Address varchar(50),
@City varchar(50),
@State char(2),
@Zip char(5),
@Email varchar(50),
@Phone char(10), 
@PayRate money,
@EmpCat int,
@PTOHours decimal(18,2),
@MedInsDeduction money,
@DentInsDeduction money
)

AS
BEGIN
INSERT INTO tblEmployee(
[LName],
[FName],
[SSN],
[DoH],
[Address],
[City],
[State],
[Zip],
[Email],
[Phone],
[PayRate]
) VALUES(
@LName,
@FName,
@SSN,
@DoH,
@Address,
@City,
@State,
@Zip,
@Email,
@Phone,
@PayRate
)

INSERT INTO tblEmployeeDetail(
[EmpCat],
[PTOHours],
[MedInsDeduction],
[DentInsDeduction]
)
VALUES(
@EmpCat,
@PTOHours,
@MedInsDeduction, 
@DentInsDeduction
)

END
GO
/****** Object:  ForeignKey [shipment_status_shipment]    Script Date: 07/14/2017 00:20:02 ******/
ALTER TABLE [dbo].[tblEmployeeDetail]  WITH CHECK ADD  CONSTRAINT [shipment_status_shipment] FOREIGN KEY([EmpID])
REFERENCES [dbo].[tblEmployee] ([EmpID])
GO
ALTER TABLE [dbo].[tblEmployeeDetail] CHECK CONSTRAINT [shipment_status_shipment]
GO
/****** Object:  ForeignKey [shipmet_details_shipment]    Script Date: 07/14/2017 00:20:02 ******/
ALTER TABLE [dbo].[tblShifts]  WITH CHECK ADD  CONSTRAINT [shipmet_details_shipment] FOREIGN KEY([EmpID])
REFERENCES [dbo].[tblEmployee] ([EmpID])
GO
ALTER TABLE [dbo].[tblShifts] CHECK CONSTRAINT [shipmet_details_shipment]
GO
/****** Object:  ForeignKey [shipment_shipment_type]    Script Date: 07/14/2017 00:20:02 ******/
ALTER TABLE [dbo].[tblTimesheet]  WITH CHECK ADD  CONSTRAINT [shipment_shipment_type] FOREIGN KEY([EmpID])
REFERENCES [dbo].[tblEmployee] ([EmpID])
GO
ALTER TABLE [dbo].[tblTimesheet] CHECK CONSTRAINT [shipment_shipment_type]
GO
