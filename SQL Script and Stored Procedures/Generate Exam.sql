USE [ITI-GP]
GO
/****** Object:  StoredProcedure [dbo].[generate_exam]    Script Date: 2/26/2024 2:58:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[generate_exam]    
    @Crs_ID INT,
    @num_mcq INT = 7,
    @num_tf INT = 3,
    @Exam_ID INT OUTPUT -- Output parameter to return the generated exam ID
AS
BEGIN
    BEGIN TRY
        IF (@Crs_ID IS NULL OR @num_mcq IS NULL OR @num_tf IS NULL)
            RAISERROR('Crs_ID, num_mcq, num_tf are required', 16, 1)
        ELSE
        BEGIN
            CREATE TABLE #ExamTemp(QID INT);

            INSERT INTO #ExamTemp(QID)
            SELECT TOP (@num_tf) Question_Id 
            FROM Question
            WHERE Quest_type = 0 AND Question.Crs_ID = @Crs_ID
            ORDER BY NEWID();

            INSERT INTO #ExamTemp (QID)
            SELECT TOP (@num_mcq) Question_Id 
            FROM Question
            WHERE Quest_type = 1 AND Question.Crs_ID = @Crs_ID
            ORDER BY NEWID();

            DECLARE @NewExamID TABLE (ID INT);

            INSERT INTO Exam (Ex_Date, Crs_Id, Ex_NoQuestions, Ex_grade)
            OUTPUT INSERTED.Ex_Id INTO @NewExamID(ID)
            VALUES (GETDATE(), @Crs_ID, @num_mcq + @num_tf , @num_mcq + @num_tf);
			    
    

            SELECT @Exam_ID = ID FROM @NewExamID;

            INSERT INTO Exam_question (Ex_Id, Question_Id)
            SELECT @Exam_ID, QID
            FROM #ExamTemp;

            -- Set the output parameter with the generated exam ID
            SET @Exam_ID = @Exam_ID;

            SELECT @Exam_ID AS exam_ID;
        END
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