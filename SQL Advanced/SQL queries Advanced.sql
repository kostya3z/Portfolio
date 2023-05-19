---

SELECT COUNT(p.id)
FROM stackoverflow.posts as p
join stackoverflow.post_types as pt on
    p.post_type_id=pt.id
WHERE (p.score > 300 or p.favorites_count >=100) and pt.type = 'Question'

---

with nt as(
select p.creation_date::date,
        count(p.id) as total
from stackoverflow.posts as p
join stackoverflow.post_types as pt on p.post_type_id=pt.id
where (p.creation_date::date between '2008-11-01' and '2008-11-18') and pt.type = 'Question'
group by p.creation_date::date)

select round(avg(total))
from nt

---

select count(distinct u.id)
from stackoverflow.users as u
left join stackoverflow.badges as b 
    on u.id=b.user_id
where u.creation_date::date=b.creation_date::date

---

select count(distinct p.id)
from stackoverflow.posts as p
join stackoverflow.users as u
    on p.user_id=u.id
where p.id in (select post_id
               from stackoverflow.votes)
and u.display_name = 'Joel Coehoorn'

---

select *,
    row_number() over (order by id desc)
from stackoverflow.vote_types
order by id

---

with type_v as (select *
from stackoverflow.vote_types
where name = 'Close')

select v.user_id,
        count(post_id)
from stackoverflow.votes as v
join type_v as tv
    on v.vote_type_id=tv.id
group by v.user_id
order by count(post_id) desc, user_id desc
limit 10

---

with nt as (select u.id,
        count(b.id) as cnt
from stackoverflow.users as u
left join stackoverflow.badges as b
    on u.id=b.user_id
where b.creation_date::date between '2008-11-15' and '2008-12-15'
group by u.id)

select *,
        dense_rank() over (order by cnt desc)
from nt
order by cnt desc, id
limit 10

---

select title,
        user_id,
        score,
        round(avg(score) over (partition by user_id))
from stackoverflow.posts
where title is not null and score <> 0

---

with nt as (select u.id as u_b,
        count(b.id) as cnt
from stackoverflow.users as u
left join stackoverflow.badges as b
    on u.id=b.user_id
group by u.id)

select title
from nt
left join stackoverflow.posts as p
    on nt.u_b=p.user_id
where (nt.cnt > 1000) and p.title is not null

---

select id,
        sum(views) as qnt,
        case
            when sum(views) >=350 then 1
            when sum(views) <100 then 3
            else 2
        end
from stackoverflow.users
where location like '%United States%' and views<>0
group by id

---

with nt as (select id,
        sum(views) as qnt,
        case
            when sum(views) >=350 then 1
            when sum(views) <100 then 3
            else 2
        end as rate
        from stackoverflow.users
where location like '%United States%' and views<>0
group by id),

rang as (select *,
        dense_rank() over (partition by rate order by qnt desc) as pos
from nt)

select id,
        rate,
        qnt
from rang
where pos = 1
order by qnt desc, id

---

with nt as (select extract(day from creation_date::timestamp) as day,
        count(id) as qnt
from stackoverflow.users
where date_trunc('month',creation_date)::date = '2008-11-01'
group by extract(day from creation_date::timestamp))

select *,
        sum(qnt) over (order by day)
from nt

---

select distinct p.user_id,
        min(p.creation_date) over (partition by p.user_id) - u.creation_date
from stackoverflow.posts as p
left join stackoverflow.users as u
    on u.id=p.user_id

---

select date_trunc('month', creation_date)::date,
        sum(views_count)
from stackoverflow.posts
group by date_trunc('month', creation_date)::date
order by sum(views_count) desc

---

select display_name,
        count(distinct p.user_id) 
from stackoverflow.posts as p
join stackoverflow.post_types as pt
    on p.post_type_id=pt.id
join stackoverflow.users as u
    on p.user_id=u.id
where pt.type = 'Answer' and
    p.creation_date::date between u.creation_date::date and (u.creation_date::date + interval '1 month')
group by display_name
having count(p.id) > 100
order by display_name 

---

select date_trunc('month', p.creation_date)::date,
        count(p.id)
from stackoverflow.posts as p
join stackoverflow.users as u
    on p.user_id=u.id
where p.user_id in (select distinct p.user_id
from stackoverflow.posts as p
join stackoverflow.users as u
    on p.user_id=u.id
where u.creation_date::date between '2008-09-01' and '2008-09-30' 
    and p.creation_date::date between '2008-12-01' and '2008-12-31')
group by date_trunc('month', p.creation_date)::date
order by date_trunc('month', p.creation_date)::date desc

---

select user_id,
        creation_date,
        views_count,
        sum(views_count) over (partition by user_id order by user_id, creation_date)
from stackoverflow.posts
order by user_id, creation_date

---

with nt as (select user_id,
        count(distinct creation_date::date) as qnt
from stackoverflow.posts
where creation_date::date between '2008-12-01' and '2008-12-07'
group by user_id)

select round(avg(qnt))
from nt

---

with nt as (select date_trunc('month', creation_date)::date as cd,
        count(id) as qnt
from stackoverflow.posts
where creation_date::date between '2008-09-01' and '2008-12-31'
group by date_trunc('month', creation_date)::date)

select extract(month from cd),
        qnt,
        round(((qnt::numeric/ lag(qnt) over (order by current_date)) - 1) * 100,2)
from nt

---

with nt as (select user_id,
        count(id)
from stackoverflow.posts
group by user_id
order by count(id) desc
limit 1)

select extract(week from creation_date::date),
        max(creation_date)
from stackoverflow.posts
where user_id = (select user_id from nt) and creation_date::date between '2008-10-01' and '2008-10-31'
group by extract(week from creation_date::date)

