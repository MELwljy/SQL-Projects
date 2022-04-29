-- Execute(All or Selection) - > Command + Shift + Enter.
-- Execute Current Statement - > Command + Enter.

-- Student(Sid,Sname,Sage,Ssex)
-- Sid 学生编号,Sname 学生姓名,Sage 出生年月,Ssex 学生性别
SELECT * FROM Student;
-- Course(Cid,CnAmE,TId)
-- Cid 课程编号,Cname 课程名称,TId 教师编号
SELECT * FROM Course;
-- Teacher(TId,Tname)
-- TId 教师编号,TNAME 教师姓名
SELECT * FROM Teacher;
-- SC(Sid,Cid,SCore)
-- Sid 学生编号,Cid 课程编号,SCore 分数
SELECT * FROM SC;

-- 1. 查询" 01 "课程比" 02 "课程成绩高的学生的信息及课程分数
SELECT * FROM Student 
JOIN
	(SELECT T1.Sid FROM
		((SELECT * FROM SC WHERE Cid=1) AS T1 
		JOIN
		(SELECT * FROM SC WHERE Cid=2) AS T2
		ON T1.Sid=T2.Sid)
WHERE t1.SCore > t2.SCore) AS A
ON A.Sid=Student.Sid;
        
-- 1.1 查询同时存在" 01 "课程和" 02 "课程的情况

SELECT T1.Sid as Sid,T1.SCore as SCore1, T2.SCore as SCore2 
FROM (SELECT * FROM SC WHERE Cid=1) AS T1 
JOIN (SELECT * FROM SC WHERE Cid=2) AS T2
ON T1.Sid=T2.Sid;

-- 1.2 查询存在" 01 "课程但可能不存在" 02 "课程的情况(不存在时显示为 null )
SELECT T1.Sid as Sid,T1.SCore as SCore1, T2.SCore as SCore2 
FROM (SELECT * FROM SC WHERE Cid=1) AS T1 
lEFT JOIN (SELECT * FROM SC WHERE Cid=2) AS T2
ON T1.Sid=T2.Sid;

-- 1.3 查询不存在" 01 "课程但存在" 02 "课程的情况
SELECT * FROM SC
WHERE Sid NOT IN (SELECT Sid FROM SC WHERE SC.Cid='01') AND Cid='02';


-- 2. 查询平均成绩大于等于 60 分的同学的学生编号和学生姓名和平均成绩

SELECT ST.Sid, Sname,avg_SCore FROM Student AS ST
JOIN
(SELECT Sid, AVG(SCore) AS avg_SCore FROM SC
GROUP BY Sid
HAVING AVG(SCore)>=60)  AS S
ON ST.Sid= S.Sid;

-- 3. 查询在 SC 表存在成绩的学生信息
SELECT DISTINCT(SC.Sid),ST.Sname,ST.Sage,ST.Ssex FROM SC
RIGHT JOIN (SELECT * FROM Student) AS ST
ON SC.Sid=ST.Sid;

SELECT DISTINCT student.*
FROM student,SC
WHERE student.Sid=SC.Sid;

-- 4. 查询所有同学的学生编号、学生姓名、选课总数、所有课程的总成绩(没成绩的显示为 null )
SELECT student.Sid,student.Sname,S.total_course,S.total_SCore FROM Student
LEFT JOIN
(SELECT Sid,COUNT(Cid) AS total_course,SUM(SCore) AS total_SCore FROM SC
GROUP BY Sid) AS S
ON S.Sid=Student.Sid;

SELECT student.Sid,student.Sname,t1.sumSCore,t1.coursecount
FROM student ,(
SELECT SC.Sid,SUM(SC.SCore)AS sumSCore ,COUNT(SC.Cid) AS coursecount
FROM SC 
GROUP BY SC.Sid) AS t1
WHERE student.Sid =t1.Sid;

-- 4.1 查有成绩的学生信息
SELECT student.Sid,student.Sname,S.total_course,S.total_SCore FROM Student
JOIN
(SELECT Sid,COUNT(Cid) AS total_course,SUM(SCore) AS total_SCore FROM SC
GROUP BY Sid) AS S
ON S.Sid=Student.Sid;

-- 5. 查询「李」姓老师的数量
SELECT count(*) FROM teacher WHERE tname like '李%';

-- 6. 查询学过「张三」老师授课的同学的信息
SELECT * FROM Student
JOIN(
SELECT Sid FROM SC
JOIN
(SELECT Cid FROM Course, (SELECT * FROM Teacher
WHERE Tname= '张三') as TN
WHERE Course.Tid=TN.Tid) as T
On SC.Cid=T.CId) as B
On B.Sid=Student.Sid;

SELECT Student.*
FROM Student
WHERE Sid IN(
SELECT Sid
FROM Teacher,Course,SC
WHERE Teacher.Tid=Course.Tid AND Course.Cid=SC.Cid AND Tname='张三');


-- 7. 查询没有学全所有课程的同学的信息
SELECT Student.* FROM Student
JOIN
(SELECT COUNT(DISTINCT cid) AS course_taken ,SID FROM SC
GROUP BY Sid
HAVING course_taken !=(SELECT COUNT(DISTINCT cid) AS total_course FROM Course))AS A
ON A.Sid= Student.Sid;

-- 8. 查询至少有一门课与学号为" 01 "的同学所学相同的同学的信息
SELECT distinct student.* FROM Student 
JOIN
(SELECT DISTINCT(sid) FROM SC
WHERE cid IN (SELECT DISTINCT(Cid) FROM SC WHERE Sid= 1))AS A
ON Student.sid=A.sid;


SELECT DISTINCT student.*
FROM  sc ,student
WHERE sc.CId IN (SELECT CId FROM sc WHERE sc.SId='01')
AND   sc.SId=student.SId;

-- 9. 查询和" 01 "号的同学学习的课程完全相同的其他同学的信息
Select Student.*
from Student
where Student.Sid in
(select SC.Sid
from SC
where SC.Sid not in   #选出所选课程是01所选课程子集的学生（逆向，选出包含01未选课程的同学再取反），再选出和01选课数相等的学生
(select SC.Sid from SC where SC.Cid not in(select SC.Cid from SC where SC.Sid='01')) and Sid <> '01'
group by Sid
having count(Cid)=(select count(Cid) from SC where Sid ='01'));


-- 10. 查询没学过"张三"老师讲授的任一门课程的学生姓名

Select Sname from Student
WHERE SID NOT IN(
Select sid from SC
where Cid = (Select Cid from Course
join teacher on course.Tid=teacher.Tid
where Tname="张三"));


-- 11. 查询两门及其以上不及格课程的同学的学号，姓名及其平均成绩

select Student.Sid,Student.Sname,Avg_Score
from Student join
(SELECT SId, AVG(score) AS Avg_Score
      FROM SC
      WHERE score < 60 
      GROUP BY SId
      HAVING COUNT(*) >= 2) as A
on Student.Sid=A.Sid;
      

-- 12. 检索" 01 "课程分数小于 60，按分数降序排列的学生信息
select student.*
from student,sc
where sc.CId ='01'
and   sc.score<60
and   student.SId=sc.SId;


-- 13. 按平均成绩从高到低显示所有学生的所有课程的成绩以及平均成绩
#simple
select sid,
     sum(case when cid=01 then score else null end) as score_01,
    sum(case when cid=02 then score else null end) as score_02,
    sum(case when cid=03 then score else null end) as score_03,
    avg(score) 
from sc  
group by sid
order by avg(score) desc;


-- 14. 查询各科成绩最高分、最低分和平均分：

-- 以如下形式显示：课程 ID，课程 name，最高分，最低分，平均分，及格率，中等率，优良率，优秀率
-- 及格为>=60，中等为：70-80，优良为：80-90，优秀为：>=90
-- 要求输出课程号和选修人数，查询结果按人数降序排列，若人数相同，按课程号升序排列
SELECT sc.cid,course.Cname,max(sc.score) as '最高分',min(sc.score) as '最低分',
AVG(sc.score) as '平均分',count(sc.CId) as '选修人数',
SUM(case when sc.score>=60 then 1 else 0 end)/count(sc.CId) as '及格率',
SUM(case when sc.score>=70 and sc.score<80 then 1 else 0 end)/count(sc.CId) as '中等率',
SUM(case when sc.score>=80 and sc.score<90 then 1 else 0 end)/count(sc.CId) as '优良率',
SUM(case when sc.score>=90 then 1 else 0 end)/count(sc.CId) as '优秀率'
from sc,course WHERE sc.CId=course.CId 
GROUP BY cid,course.Cname
ORDER BY '选修人数' DESC,sc.cid;

-- 15. 按各科成绩进行排序，并显示排名， SCore 重复时保留名次空缺
SELECT CId,sid,score, RANK() OVER (ORDER BY score DESC) AS Ranking
FROM SC
ORDER BY Ranking;

-- 15.1 按各科成绩进行排序，并显示排名， Score 重复时合并名次
SELECT cid,SId,score,dense_RANK() OVER (partition by cid ORDER BY score DESC) AS Ranking
FROM SC;


-- 16. 查询学生的总成绩，并进行排名，总分重复时保留名次空缺

SELECT SId, SUM(score) AS ScoreSum, RANK() OVER (ORDER BY SUM(score) DESC) AS Ranking
FROM SC
GROUP BY SId
ORDER BY ScoreSum DESC;

-- 区别RANK，DENSE_RANK和ROW_NUMBER
-- RANK并列跳跃排名，并列即相同的值，相同的值保留重复名次，遇到下一个不同值时，跳跃到总共的排名。
-- DENSE_RANK并列连续排序，并列即相同的值，相同的值保留重复名次，遇到下一个不同值时，依然按照连续数字排名。
-- ROW_NUMBER连续排名，即使相同的值，依旧按照连续数字进行排名。

-- 16.1 查询学生的总成绩，并进行排名，总分重复时不保留名次空缺

SELECT SId AS StudentID, SUM(score) AS ScoreSum, DENSE_RANK() OVER (ORDER BY SUM(score) DESC) AS Ranking
FROM SC
GROUP BY SId
ORDER BY ScoreSum DESC;



-- 17. 统计各科成绩各分数段人数：课程编号，课程名称，[100-85]，[85-70]，[70-60]，[60-0] 及所占百分比
SELECT course.cname,A.* FROM course
JOIN
(SELECT sc.cid,
SUM(CASE WHEN sc.score>85 AND sc.score<=100 THEN 1 ELSE 0 END)/COUNT(*) AS '[85-100]',
SUM(CASE WHEN sc.score>70 AND sc.score<=85 THEN 1 ELSE 0 END)/COUNT(*) AS '[70-85]',
SUM(CASE WHEN sc.score>60 AND sc.score<=70 THEN 1 ELSE 0 END)/COUNT(*) AS '[60-70]',
SUM(CASE WHEN sc.score<=60 THEN 1 ELSE 0 END)/COUNT(*) AS '[0-60]'
FROM sc,course
GROUP BY sc.cid) AS A
ON A.cid=course.cid;


-- 18. 查询各科成绩前三名的记录
SELECT CId, SId, Ranking
FROM (SELECT CId, SId, RANK() OVER (PARTITION BY CId ORDER BY score DESC) AS Ranking
      FROM SC) AS T
WHERE Ranking <= 3;


-- 不使用窗口函数
SELECT sc.SId, sc.CId, sc.score
FROM SC 
WHERE (SELECT COUNT(T.score)
       FROM SC AS T
       WHERE T.CId = sc.CId AND T.score > sc.score) <= 2;
       
-- 19. 查询每门课程被选修的学生数
Select cid,count(*) from sc
group by cid; 


-- 20. 查询出只选修两门课程的学生学号和姓名
SELECT student.sname,student.sid FROM student
join (Select sc.sid,count(*) from sc
group by sc.sid having count(*)=2) as A 
on student.sid=A.sid;


SELECT  Sname,SId
FROM Student
WHERE SId IN (SELECT SId
              FROM SC
              GROUP BY SId
              HAVING COUNT(*) = 2);
              
-- 21. 查询男生,女生人数
select Ssex,count(*) from student
group by Ssex;

-- 22. 查询名字中含有「风」字的学生信息
Select * from student
where sname like "%风%";

-- 23. 查询同名同性学生名单，并统计同名人数
select sname,count(*) as 人数
from student
group by sname
having count(*)>=2;


-- 24. 查询 1990 年出生的学生名单
Select * from student
where year(sage)=1990;

-- 25. 查询每门课程的平均成绩，结果按平均成绩降序排列，平均成绩相同时，按课程编号升序排列
SELECT cid,AVG(score) FROM sc GROUP BY CId ORDER BY AVG(score),CId;


-- 26. 查询平均成绩大于等于 85 的所有学生的学号、姓名和平均成绩
SELECT ANY_VALUE(student.sname) AS student_name,student.sid, AVG(score) FROM SC, Student
WHERE student.sid=sc.sid
GROUP BY sc.sid
HAVING AVG(score)>=85;

SELECT student.sname, A.* FROM student 
JOIN (SELECT student.sid, AVG(score) FROM SC, Student
WHERE student.sid=sc.sid
GROUP BY sc.sid
HAVING AVG(score)>=85) AS A
ON student.sid=A.sid; 

-- Error 1055
-- 当对一个或多个字段进行分组后，所查询的字段（即select后跟的字段名），必须是分组所依据的字段和经过聚合函数聚合后的新字段。
-- 这个逻辑是合理的：之所以要分组就是要探究该组内的信息，既然是组内信息，就必须对全组数据进行统一处理，单独拎出来某一个数据是不合理的

-- Error 1111 WHERE子句中不可以使用集函数
-- Invalid use of group function即“集函数的无效用法”
-- 错句示例：SELECT sname AS '优秀学生姓名',AVG(score) as '平均成绩' FROM `grade_info` WHERE AVG(score)>90 GROUP BY sno;
-- 正确写法：SELECT sname AS '优秀学生姓名',AVG(score) as '平均成绩' FROM `grade_info` GROUP BY sno HAVING AVG(score) > 90 ;


-- 27. 查询课程名称为「数学」，且分数低于 60 的学生姓名和分数
SELECT student.sname,sc.score FROM course,student,sc
WHERE sc.score<60 AND course.cname='数学' and COUrse.cid=sc.Cid and STUdent.sid=sc.Sid;

-- 28. 查询所有学生的课程及分数情况（存在学生没成绩，没选课的情况）
SELECT student.sname,sc.sid, course.cname,sc.score FROM student
LEFT JOIN sc ON student.sid =sc.SId
LEFT JOIN course ON sc.cid=course.cid;


-- 29. 查询任何一门课程成绩在 70 分以上的姓名、课程名称和分数
SELECT student.sname,course.cname,sc.score
FROM sc
JOIN student on student.sid =sc.SId
JOIN course on sc.cid=course.cid
WHERE sc.score>70;

-- 30. 查询不及格的课程？？
SELECT * FROM sc
WHERE score<60;

-- 31. 查询课程编号为 01 且课程成绩在 80 分以上的学生的学号和姓名
SELECT SC.SId,Student.Sname FROM sc,student
WHERE student.sid=sc.sid AND cid=01 AND score >=80;

-- 32. 求每门课程的学生人数
SELECT cid,COUNT(DISTINCT sid) FROM SC
GROUP BY cid;

-- 33. 成绩不重复，查询选修「张三」老师所授课程的学生中，成绩最高的学生信息及其成绩
Select student.* from student, sc,course,teacher
where student.sid=sc.sid and SC.cid=course.cid and course.tid=Teacher.tid and tname='张三' 
order by sc.score desc limit 1;

-- 34. 成绩有重复的情况下，查询选修「张三」老师所授课程的学生中，成绩最高的学生信息及其成绩
Select student.* from student, sc,course,teacher
where student.sid=sc.sid and SC.cid=course.cid and course.tid=Teacher.tid and tname='李四' 
and sc.score=(Select max(sc.score) from teacher,SC,course
where SC.cid=course.cid and course.tid=Teacher.tid and tname='李四');

-- 35. 查询不同课程成绩相同的学生的学生编号、课程编号、学生成绩

select distinct s1.SId,s1.CId,s1.Score
from SC s1 join SC s2
on s1.CId != s2.CId and s1.score = s2.score
group by s1.SId,s1.CId,s1.Score;

select distinct s1.SId,s1.CId,s1.Score
from SC s1 left join SC s2 on s1.sid=s2.sid and S1.cid <> S2.cid and S1.score=S2.score;


-- 36. 查询每门功成绩最好的前两名
-- 使用窗口函数
SELECT CId, SId, Ranking
FROM (SELECT CId, SId, RANK() OVER (PARTITION BY CId ORDER BY score DESC) AS Ranking
      FROM SC) AS T
WHERE Ranking <= 2;

-- 不使用窗口函数
SELECT sc.SId, sc.CId, sc.score
FROM SC 
WHERE (SELECT COUNT(T.score)
       FROM SC AS T
       WHERE T.CId = sc.CId AND T.score > sc.score) <= 1;


       
SELECT s1.* FROM sc s1 WHERE
(SELECT COUNT(1) FROM sc s2 WHERE
s1.cid=s2.cid AND s2.score>=s1.score)<=2
ORDER BY s1.cid,s1.score DESC;
       
(select CId,score,sid from SC where CId = '01' order by score desc limit 2)
union all
(select CId,score,sid from SC where CId = '02' order by score desc limit 2)
union all
(select CId,score,sid from SC where CId = '03' order by score desc limit 2);

-- 37. 统计每门课程的学生选修人数（超过 5 人的课程才统计）。
SELECT cid,count(*) as 选修人数 FROM SC
GROUP BY cid
HAVING count(*)>=5;


-- 38. 检索至少选修两门课程的学生学号
SELECT SId,COUNT(*) AS Num_Courses FROM SC
GROUP BY SId
HAVING COUNT(*)>=2;


-- 39. 查询选修了全部课程的学生信息
SELECT student.*
FROM Student
WHERE student.SId IN (SELECT Student.SId
                  FROM Student, SC
                  WHERE SC.SId = Student.SId
                  GROUP BY SC.SId
                  HAVING COUNT(*) = (SELECT DISTINCT COUNT(*) FROM Course));
                  
-- 40. 查询各学生的年龄，只按年份来算
select student.sid, student.sname,student.ssex,
year(now())-year(sage) as '按年份计算'  
from student;


-- 41. 按照出生日期来算，当前月日 < 出生年月的月日则，年龄减一
select student.sid, student.sname,student.ssex, sage,
timestampdiff(year,sage,now()) as '按月日计算',  
year(now())-year(sage) as '按年份计算'  
from student;

select student.sid, student.sname,student.ssex, sage,
case when month(curdate())<month(sage) then (year(now())-year(sage)) -1
else  year(now())-year(sage) end as '按月日计算',
year(now())-year(sage) as '按年份计算'
from student;

-- 42. 查询本周过生日的学生
Select * from student
where weekofyear(Sage)=weekofyear(curdate());

-- 43. 查询下周过生日的学生
Select * from student
where weekofyear(Sage)=weekofyear(curdate())+1;

-- 44. 查询本月过生日的学生
Select * from student
where month(Sage)=month(curdate());

-- 45. 查询下月过生日的学生
Select * from student
where month(Sage)=month(curdate())+1;