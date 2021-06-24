// place all the files in the db import folder

// load movies
:auto USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM 'file:///movies.csv' AS row
FIELDTERMINATOR '|'
CREATE (:Movies {movieId: row.movieId, title: row.title, rating_mean: row.rating_mean});

CREATE INDEX ON :Movies(movieId);

// load genres
:auto USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM 'file:///genres.csv' AS row
FIELDTERMINATOR '|'
CREATE (:Genres {genre: row.genre});

// create relationships between movies and genres
:auto USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM 'file:///movies_genres.csv' AS row
FIELDTERMINATOR '|'
MATCH (movie:Movies {movieId: row.movieId})
MATCH (genre:Genres {genre: row.genres})
MERGE (movie)-[:GENRES]->(genre);

// create relationships between movies
:auto USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM 'file:///movies_similarity.csv' AS row
FIELDTERMINATOR '|'
MATCH (movie1:Movies {movieId: row.movieId})
MATCH (movie2:Movies {movieId: row.sim_moveId})
MERGE (movie1)-[:SIMILAR {relevance: row.relevance}]->(movie2);

// get similar movies
MATCH path = (m1:Movies)-[s:SIMILAR]->(m2:Movies)
WHERE m1.movieId =~''
RETURN m1.title, m2.title, m2.rating_mean

// get similar movies and filter on genre and sort them on ratings
MATCH path = (m1:Movies)-[s:SIMILAR]->(m2:Movies),
(m2)-[:GENRES]->(g:Genres),
WHERE g.genre =~''
RETURN m1.title, m2.title, m2.rating_mean
ORDER BY m2.rating_mean descending
// LIMIT 3
