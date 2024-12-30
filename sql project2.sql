/*project -3:"Unlocking IT Company Growth: A Comprehensive Employee and Revenue Analysis"
-------------------------------------------------------------------------------------------------------*/
select * from employee_growth_data_related;
select * from revenue_project_data_related;
/*Employee Contribution to Revenue:
Identify the top-performing employees who have contributed to the highest revenue over the years.
Analyze which departments these employees belong to and whether specific departments contribute more to revenue generation.*/
select e.employee_id,e.name,e.department,sum(r.revenue_usd)
from employee_growth_data_related as e
inner join revenue_project_data_related as r
on e.Employee_ID=r.Employee_ID
group by e.employee_id,e.name,e.Department
order by sum(r.Revenue_USD) desc
limit 10;
/*Promotion vs. Performance Impact:

Analyze if employees who received more promotions have a higher performance score.
Does the number of promotions correlate with their salary and years in the company?*/
select employee_id,name,avg(years_in_company),avg(salary_usd),sum(performance_score),sum(Promotions)
from employee_growth_data_related
group by Employee_ID,name
order by sum(Performance_Score) desc,sum(Promotions) desc;
/*Revenue Trends by Employee Demographics:

Evaluate revenue trends based on employee demographics like gender and age group.
Determine whether a specific age group or gender dominates revenue-generating projects.*/
select e.gender,case
when e.age between 20 and 29 then '20-29'
when e.age between 30 and 39 then '30-39'
when e.age between 40 and 49 then '40-49'
when e.age between 50 and 59 then '50-59'
else '60-70' end as age_group,sum(r.revenue_usd)
from employee_growth_data_related as e
inner join revenue_project_data_related as r
on e.Employee_ID=r.Employee_ID
group by e.gender,age_group
order by sum(r.Revenue_USD) desc;
/*Client Growth Analysis:

Examine the relationship between the number of new clients acquired and the contribution of specific employees.
Identify which departments or employees consistently work on projects associated with client acquisition.*/
select e.employee_id,e.name,sum(r.new_clients),e.Performance_Score
from employee_growth_data_related as e
inner join revenue_project_data_related as r
on e.Employee_ID=r.Employee_ID
group by e.employee_id,e.name,e.Performance_Score
order by sum(r.New_Clients) desc;
/*Profitability vs. Employee Performance:

Analyze how employee performance scores impact project profitability.*/
select e.employee_id,e.Performance_Score,sum(r.profit_usd)
from employee_growth_data_related as e
inner join revenue_project_data_related as r
on e.Employee_ID=r.Employee_ID 
group by e.Employee_ID,e.Performance_Score
order by sum(r.Profit_USD) desc;
/*Market Share Growth Analysis:

Evaluate the relationship between employee contributions and the company’s market share growth over different years and quarters.*/

    WITH revenue AS (
    SELECT 
        e.Employee_ID,
        e.Name,
        SUM(r.Revenue_USD) AS Total_Revenue_USD,
        LAG(r.Market_Share_Percent) OVER (ORDER BY r.Year, r.Quarter) AS Previous_Market_Share,
        r.Market_Share_Percent - LAG(r.Market_Share_Percent) OVER (ORDER BY r.Year, r.Quarter) AS Market_Share_Growth
    FROM 
        Employee_Growth_Data_Related AS e
    JOIN 
        Revenue_Project_Data_Related AS r 
        ON e.Employee_ID = r.Employee_ID
    GROUP BY 
        e.Employee_ID, e.Name, r.Year, r.Quarter, r.Market_Share_Percent
)
SELECT 
    Employee_ID,
    Name,
    Total_Revenue_USD,
    Previous_Market_Share,
    Market_Share_Growth
FROM 
    revenue
ORDER BY 
    Total_Revenue_USD DESC;
    /*Employee Retention vs. Revenue Growth:

Examine whether retaining long-term employees (more years in the company) has positively influenced revenue growth.*/
with revenue as(
select sum(r.revenue_usd) as sum_usd,e.Years_in_Company,e.Employee_ID,r.year,
lag(sum(r.revenue_usd)) over(partition by e.Years_in_Company order by r.year) as prev_year,
sum(r.Revenue_USD)-lag(sum(r.revenue_usd)) over(partition by e.Years_in_Company order by r.year) as growth,
case  when e.age between 20 and 30 then '20-30'
when e.age between 30 and 40 then '30-40'
when e.age between 40 and 50 then '40-50'
when e.age between 50 and 60 then '50-60'
else  '60+' end as age_group 
from employee_growth_data_related as e
join revenue_project_data_related as r
on e.Employee_ID=r.Employee_ID
group by e.Years_in_Company,age_group,r.year,e.Employee_ID)
select Years_in_Company,prev_year,growth,age_group,employee_id,year
from revenue
order by age_group,years_in_company;
/*Departmental Success Metrics:

Compare departments in terms of average revenue contribution, satisfaction scores, and project completion.*/
with department as(
select e.department,avg(r.Revenue_USD) as avg_revenue,avg(r.Employee_Satisfaction_Score) as avg_satisfaction,sum(r.Number_of_Projects) as projects,
rank() over( order by avg(r.Revenue_USD) desc,avg(r.Employee_Satisfaction_Score) desc) as rank_
from employee_growth_data_related as e
join revenue_project_data_related as r
on e.Employee_ID=r.Employee_ID
group by e.Department)
select department,avg_satisfaction,avg_revenue,rank_,projects
from department
order by avg_revenue desc,avg_satisfaction desc;
/*Employee Productivity Insights:

Rank employees based on a composite productivity score (e.g., revenue contribution, performance score, and satisfaction score).
Provide actionable recommendations on rewarding top performers and supporting underperformers.*/
select e.employee_id,e.name,sum(e.Performance_Score),sum(r.Revenue_USD),e.Department,
rank() over(partition by e.department order by sum(e.Performance_Score) desc ,sum(r.Revenue_USD) desc) as rank_
from employee_growth_data_related as e
inner join revenue_project_data_related as r
on e.Employee_ID=r.Employee_ID
group by e.Employee_ID,e.name,e.department
order by sum(e.Performance_Score) desc,sum(r.Revenue_USD) desc;
/*Identifying Hidden Talent:

Identify employees with high performance but lower-than-average salaries or fewer promotions.*/
select employee_id,name,salary_usd,Performance_Score,avg(salary_usd),avg(Performance_Score),
case when Salary_USD<avg(salary_usd) then 'lower-salary'
when Performance_Score< avg(Performance_Score) then 'lower-salary'
when Salary_USD<avg(salary_usd) and Performance_Score<avg(Performance_Score)then 'lower-salary and fewer promotion'
else 'perfect-salary' end as category
from employee_growth_data_related 
group by employee_id,name,salary_usd,Performance_Score
order by Performance_Score desc ;
/*Diversity and Inclusion Impact:

Analyze the impact of gender and age diversity on revenue and project outcomes.*/
select e.gender,sum(r.revenue_usd),sum(r.number_of_projects),
case when e.age between 20 and 29 then '20-29'
when e.age between 30 and 39 then '30-39'

when e.age between 40 and 49 then '40-49'
when e.age between 50 and 59 then '50-59'
else '60+' end as age_group
from employee_growth_data_related as e
inner join revenue_project_data_related as r
on e.Employee_ID=r.Employee_ID
group by e.gender,age_group
order by sum(r.revenue_usd) desc,sum(r.number_of_projects) desc;
/**Diversity and Inclusion Impact:

Analyze the impact of gender and age diversity on revenue and project outcomes.*/
with diversity as(
select count(distinct e.employee_id),sum(r.revenue_usd) as sum_revenue,sum(r.number_of_projects) as sum_projects,e.department,
sum(case when e.gender='male' then 1 end) *1.0/count(distinct e.employee_id) as male_,
sum(case when e.gender='female' then 1 end) *1.0/count(distinct e.employee_id) as female_,
sum(case when e.gender='non-binary' then 1 end) *1.0/count(distinct e.employee_id) as non_binary_,
sum(case when e.age between 20 and 30 then 1 end)*1.0/count(distinct e.employee_id) as young_,
sum(case when e.age between 30 and 40 then 1 end)*1.0/count(distinct e.employee_id) as midage_,
sum(case when e.age between 40 and 50 then 1 end)*1.0/count(distinct e.employee_id) as age_40_to_50_ratio_,
sum(case when e.age >50 then 1 end)*1.0/count(distinct e.employee_id) as age_50_plus_ratio
from employee_growth_data_related as e
join revenue_project_data_related as r
on e.Employee_ID=r.Employee_ID
group by e.department)

select sum_revenue,sum_projects,department,case when male_>0.5 then 'male-dominated'
when female_>0.5 then 'female-dominated'
when non_binary_>0.5 then 'non-binary-dominated'
else 'equally-dominated' end as gender_,
case when young_>0.5 then 'young-group'
when midage_>0.5 then 'midage-group'
when age_50_plus_ratio>0.5 then 'sinear-group'
else 'mix-age-group' end as age_

from diversity
order by sum_revenue,sum_projects;
/* Problem Statement:
Identify trends in employee turnover by analyzing the relationship between employee tenure, performance scores, promotions, and salary progression. 
What are the key factors contributing to higher churn, and how can the company proactively retain high-performing employees?*/

with trends as(
select e.name,e.salary_usd,e.promotions,e.Performance_Score ,sum(r.revenue_usd) as revenue,
case when e.Performance_Score>=4 and e.promotions<3 then 'high-perfomer and not promotion'
when e.Performance_Score<3 and e.promotions>3 then 'low-perfomer and high promotion'
when e.salary_usd< avg(e.Salary_USD) and e.Performance_Score>=5 then 'high-perfomer and low salary'
else null end as category
from employee_growth_data_related as  e
inner join revenue_project_data_related as r
on e.Employee_ID=r.Employee_ID
group by e.name,e.Salary_USD,e.Promotions,e.Performance_Score)
select name,salary_usd,promotions,performance_score,revenue,category
from trends

order by revenue;
/* Skill Gap Analysis
Problem Statement:
Identify departments or teams with skill gaps by analyzing underperforming projects and comparing them with the 
average performance of other teams. Provide recommendations for training or hiring to address these gaps.*/
select e.department,sum(e.Performance_Score),sum(r.revenue_usd),avg(e.Performance_Score),
case when sum(e.Performance_Score)<avg(e.Performance_Score) then 'under-perfoming' end as category,
rank() over(order by sum(e.performance_score) desc,sum(r.revenue_usd) desc) as rank_
from employee_growth_data_related as e
inner join revenue_project_data_related as r
on e.Employee_ID=r.Employee_ID
group by e.department
order by sum(Performance_Score) desc,sum(r.Revenue_USD) desc;
/*Revenue Impact of High-Performance Employees
Problem Statement:
Determine the revenue impact  of high-performing employees. 
Identify how their performance and involvement in projects influence overall company revenue and outcomes.*/
with employee as(
select e.employee_id,sum(e.Performance_Score)as performance,e.department,sum(r.Revenue_USD) as revenue,sum(r.Number_of_Projects) as projects,
rank() over(partition by e.department order by sum(e.Performance_Score) desc ) as rank_,
 SUM(SUM(r.Revenue_USD)) OVER (PARTITION BY e.Department ) AS department_total_revenue

from employee_growth_data_related as e
inner join revenue_project_data_related as r
on e.Employee_ID=r.Employee_ID
group by e.employee_id,e.department)
select employee_id,department, performance,projects,rank_,revenue,department_total_revenue
from employee
where rank_<=5
order by department,performance desc,projects desc;
/*Problem Statement:
Identify which departments contribute the most to overall revenue generation. Evaluate whether
 these departments are receiving sufficient resources (budget, employees, etc.) compared to their contributions.*/
 
with employee as(SELECT 
        e.department,
        COUNT(DISTINCT e.employee_id) AS count_employee,
        SUM(r.revenue_usd) AS total_revenue,
        SUM(r.IT_Budget_USD) AS total_it_budget,
        SUM(SUM(r.revenue_usd)) OVER (PARTITION BY e.department) AS revenue_department,
        SUM(SUM(r.IT_Budget_USD)) OVER (PARTITION BY e.department) AS it_budget,
        COUNT(COUNT(distinct e.employee_id)) OVER (PARTITION BY e.department) AS employee_count_partition
    FROM 
        employee_growth_data_related AS e
    INNER JOIN 
        revenue_project_data_related AS r
    ON 
        e.employee_id = r.employee_id
    GROUP BY 
        e.department)

SELECT 
    department,
    revenue_department,
    it_budget,
    count_employee
FROM 
    employee
ORDER BY 
    count_employee desc, revenue_department DESC;
/*Hiring Strategy Optimization
Problem Statement:
Evaluate the relationship between new hires’ performance scores, their time to achieve proficiency, 
and their contribution to project success or revenue. Recommend hiring strategies based on these findings.*/
with employee as(
select e.employee_id,sum(r.revenue_usd),sum(r.profit_usd),e.performance_score,
extract(year from current_date())-extract(year from e.joining_date) as year_difference,
case when extract(year from current_date())-extract(year from e.joining_date)<=2 then 'new hiring'
else 'experiened-employee' end as category,sum(sum(r.profit_usd)) over(partition by e.Employee_ID)as contribution
from employee_growth_data_related as e
inner join revenue_project_data_related as r
on e.Employee_ID=r.Employee_ID
group by e.employee_id,category,year_difference,e.performance_score)
select employee_id,contribution,category,year_difference,performance_score
from employee
where category='new hiring'
order by contribution desc;
/*Department Collaboration Synergy
Problem Statement:
Identify which department  lead to the most successful projects. 
Recommend ways to encourage cross-departmental collaboration.*/
with employee as(
select e.department,sum(r.revenue_usd),sum(r.profit_usd),sum(r.number_of_projects),
sum(sum(r.revenue_usd)) over(partition by e.department) as revenue_,
sum(sum(r.profit_usd)) over(partition by e.department) as profit_,
sum(sum(r.number_of_projects)) over(partition by e.department) as projects_
from employee_growth_data_related as e
inner join revenue_project_data_related as r
on e.Employee_ID=r.Employee_ID
group by e.department)
select department,revenue_,profit_,projects_
from employee
order by profit_ desc;
/*Diversity and Leadership Roles
Problem Statement:
Analyze the representation of diverse groups (e.g., gender, age) in leadership roles. 
Determine whether diverse leadership correlates with better project outcomes or higher revenue.*/

WITH employee AS (
    SELECT 
        e.employee_id,
        e.gender,
        e.age,
        e.department,
        SUM(r.revenue_usd) AS revenue_usd,
        SUM(r.profit_usd) AS profit_usd,
        SUM(r.number_of_projects) AS number_of_projects,
        SUM(r.new_clients) AS new_clients,
        SUM(SUM(r.revenue_usd)) OVER (PARTITION BY e.department) AS revenue_,
        SUM(SUM(r.profit_usd)) OVER (PARTITION BY e.department) AS profit_,
        SUM(SUM(r.number_of_projects)) OVER (PARTITION BY e.department) AS projects_,
        SUM(SUM(r.new_clients)) OVER (PARTITION BY e.department) AS new_clients_,
        CASE 
            WHEN e.age BETWEEN 20 AND 30 THEN '20-30'
            WHEN e.age BETWEEN 30 AND 40 THEN '30-40'
            WHEN e.age BETWEEN 40 AND 50 THEN '40-50'
            WHEN e.age BETWEEN 50 AND 60 THEN '50-60'
            ELSE '60+'
        END AS age_category
    FROM 
        employee_growth_data_related AS e
    INNER JOIN 
        revenue_project_data_related AS r 
    ON 
        e.employee_id = r.employee_id
    GROUP BY 
        e.employee_id, e.gender, e.age, e.department
),
k AS (
    SELECT 
        age_category, 
        SUM(revenue_usd) AS revenue_age_category,
        SUM(profit_usd) AS profit_age_category,
        SUM(number_of_projects) AS projects_age_category,
        SUM(new_clients) AS new_clients_age_category
    FROM 
        employee
    GROUP BY 
        age_category
)
SELECT 
    e.employee_id,
    e.age,
   
   
    
   
    e.age_category,
    k.revenue_age_category,
    k.profit_age_category,
    k.projects_age_category,
    k.new_clients_age_category
FROM 
    employee AS e
JOIN 
    k 
ON 
    e.age_category = k.age_category
ORDER BY k.profit_age_category
     desc;
 