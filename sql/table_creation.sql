 CREATE TABLE users ( 
 user_id INTEGER PRIMARY KEY, 
 signup_date DATE, 
 acquisition_channel VARCHAR(50), 
 city_tier VARCHAR(20), 
 device_type VARCHAR(20), 
 dominant_genre VARCHAR(50), 
 secondary_genre VARCHAR(50), 
 podcast_adopter BOOLEAN, 
 engagement_propensity FLOAT, 
 plan_type VARCHAR(20) 
 );

 CREATE TABLE tracks ( 
 track_id INTEGER PRIMARY KEY, 
 genre VARCHAR(50), 
 language VARCHAR(50), 
 duration_sec INTEGER, 
 artist_id INTEGER, 
 is_podcast BOOLEAN 
 );

 CREATE TABLE sessions ( 
 session_id INTEGER PRIMARY KEY, 
 user_id INTEGER, 
 session_date DATE, 
 session_start TIMESTAMP, 
 device_type VARCHAR(20), 
 num_plays_declared INTEGER 
 );

 CREATE TABLE plays ( 
 play_id INTEGER PRIMARY KEY, 
 session_id INTEGER, 
 user_id INTEGER, 
 track_id INTEGER, 
 play_timestamp TIMESTAMP, 
 play_duration_sec INTEGER, 
 completion_pct FLOAT, 
 skipped BOOLEAN 
 ); 