USE [ITI-GP]
GO
/****** Object:  StoredProcedure [dbo].[exam_correction]    Script Date: 2/26/2024 2:59:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[exam_correction] 
    @ExamId INT, 
    @StudentId INT
AS
BEGIN
    DECLARE @Grade INT

	update Student_Exam_Quest 
    set Std_Qs_Grade = CASE WHEN q.Model_ans_txt = SA.Std_Ans THEN 1 ELSE 0 END
    FROM 
        Student_Exam_Quest SA
    JOIN 
        Question q ON SA.Question_Id = q.Question_ID
    WHERE 
        SA.Ex_ID = @ExamId AND SA.Std_Id = @StudentId;


	-- Calculate the Sum of questions grade and store it in the variable
	select @Grade =sum(Std_Qs_Grade)
	FROM Student_Exam_Quest SA
	WHERE SA.Ex_ID = @ExamID AND SA.Std_Id = @StudentId;

    -- Inserting the grade directly into the STD_Exam_Grade table
    INSERT INTO STD_Exam_Grade (Std_ID, EX_ID, Grade) 
    VALUES (@StudentId, @ExamId, @Grade)

    -- Displaying the grade
    SELECT @Grade AS [Your Grade is]
END