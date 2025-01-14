USE [ITI-GP]
GO
/****** Object:  StoredProcedure [dbo].[exam_answer]    Script Date: 2/26/2024 2:59:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[exam_answer]
    @exam_ID INT,
    @st_ID  INT,
	@q_ID INT, 
	@answer VARCHAR(300)
AS
BEGIN
DECLARE @std_name VARCHAR(50)
SET @std_name = 
			(SELECT Student.Std_FName FROM Student 
			WHERE Student.Std_Id = @st_ID)
    BEGIN TRY
        IF (@exam_ID IS NULL OR @st_ID IS NULL OR @q_ID IS NULL )
            RAISERROR('exam_ID, this data are required', 16, 1)
        ELSE
            -- Insert the answers into the answers table
            INSERT INTO Student_Exam_Quest(Ex_ID,Std_Id,Question_ID,Std_Ans,Ans_Date)
            VALUES (@exam_ID,@st_ID,@q_ID,@answer,GETDATE())

            SELECT 'All your answers has been registered for exam id ' + CAST(@exam_ID AS VARCHAR) + ' and the student name is '+ @std_name
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT @ErrorMessage = ERROR_MESSAGE(),
               @ErrorSeverity = ERROR_SEVERITY(),
               @ErrorState = ERROR_STATE();

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;