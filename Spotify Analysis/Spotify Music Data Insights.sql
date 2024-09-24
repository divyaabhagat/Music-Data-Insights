use db1;
select count(*) from spotify;
select count(distinct album) from spotify;
select distinct Album_type from spotify;
select max(Duration_min) from spotify;
select min(Duration_min) from spotify;
select * from spotify where Duration_min=0;
delete from spotify 
where Duration_min=0;
select distinct most_playedon from spotify;
-- Retrieve the names of all tracks that have more than 1 billion streams.--
select distinct * from spotify where Stream >= 1000000000;
select distinct count(*) from spotify where Stream >= 1000000000;
-- List all albums along with their respective artists.--
select Album, Artist from spotify;

-- Get the total number of comments for tracks where licensed = TRUE.--
SELECT distinct Licensed from spotify;	
select * from spotify where Licensed=0;
select sum(Comments) from spotify where Licensed='TRUE';

-- Find all tracks that belong to the album type single.
select distinct Album_type from spotify;
select count(Track) from spotify where Album_type='single';

-- Count the total number of tracks by each artist.
select Artist,count(track) as Total_no_songs from spotify group by Artist order by 2; 
-- Calculate the average danceability of tracks in each album.
select album, avg(Danceability) as Avg_Danceability from spotify group by album order by 2;
-- Find the top 5 tracks with the highest energy values.
select track, energy from spotify order by 2 desc limit 5;
-- List all tracks along with their views and likes where official_video = TRUE.
select track,views,likes from spotify where official_video = 'TRUE' ;
-- For each album, calculate the total views of all associated tracks.
select album,track,sum(views) from spotify group by 1,2 order by 3 desc;
-- Retrieve the track names that have been streamed on Spotify more than YouTube.

select * from 
(select track,
coalesce(sum(case when most_playedon='Youtube' then stream end),0) as Stream_on_Youtube,
coalesce(sum(case when most_playedon='Spotify' then stream end),0) as Stream_on_Spotify
from spotify group by 1) as T1
where Stream_on_Spotify > Stream_on_Youtube
and Stream_on_Youtube>0;

-- Find the top 3 most-viewed tracks for each artist using window functions.
explain analyze
with ranking_artist as
(select artist,track,sum(views) as total_views,
dense_rank() over (partition by artist order by sum(views) desc) as ranking
from spotify
group by 1,2
order by 1,3 desc)
select * from ranking_artist
where ranking<=3;
CREATE INDEX artist_index ON spotify(artist(100));


-- Write a query to find tracks where the liveness score is above the average.--
select track,liveness from spotify where liveness>(select avg (liveness) from spotify);
select avg (liveness) from spotify;
select track from spotify where liveness>0;

-- Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.
WITH t2
AS
(SELECT 
	album,
	MAX(energy) as highest_energy,
	MIN(energy) as lowest_energery
FROM spotify
GROUP BY 1
)
SELECT 
	album,
	highest_energy - lowest_energery as energy_diff
FROM t2
ORDER BY 2 DESC;

-- Find tracks where the energy-to-liveness ratio is greater than 1.2.
SELECT
    track,
    energy,
    liveness,
    (energy / liveness) AS energy_to_liveness_ratio
FROM
    spotify 
WHERE
    liveness > 0  
    AND (energy / liveness) > 1.2;
    
-- Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.

explain analyze
select
    track,
    views,
    likes,
    SUM(likes) OVER (ORDER BY views DESC) AS cumulative_likes
FROM spotify;