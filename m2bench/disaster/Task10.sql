INSTALL json;
-- INSTALL spatial;
INSTALL '/home/dbs/Desktop/mxmdb/graphdb/duckdb_spatial/build/release/extension/spatial/spatial.duckdb_extension';
LOAD json;
LOAD '/home/dbs/Desktop/mxmdb/graphdb/duckdb_spatial/build/release/extension/spatial/spatial.duckdb_extension';

DROP TABLE IF EXISTS eqk;
DROP TABLE IF EXISTS roadnodes;

.timer on

CREATE TABLE eqk AS (
    SELECT earthquake_id, time, coordinates
    FROM earthquake
    WHERE time >= '2020-06-01 00:00:00'
    AND time < '2020-06-01 02:00:00'
);
SELECT COUNT(*) FROM eqk;

-- CREATE TABLE roadnodes AS (
--     SELECT eqk.earthquake_id AS eqk_id, site_id AS site_id
--     FROM site, eqk
--     WHERE site.properties->>'type' = 'roadnode'
--     AND ST_Centroid(
--         ST_GeomFromGeoJSON(to_json(site.geometry))::GEOMETRY,
--         eqk.coordinates::GEOMETRY,
--         5000
--     )
-- );

CREATE TABLE roadnodes AS (
    SELECT eqk.earthquake_id AS eqk_id, site_id AS site_id,
        ST_Centroid(ST_GeomFromGeoJSON(Roadnode.data->>'geometry')::GEOMETRY) AS centroid,
        Earthquake.coordinates::GEOMETRY AS eg, ST_DistanceSpherical(centroid, eg) AS dist
    FROM
        (SELECT * FROM eqk) AS Earthquake,
        (SELECT * FROM site WHERE properties->>'type' = 'roadnode') AS Roadnode
    WHERE dist <= 5
);
SELECT COUNT(*) FROM roadnodes;

-- SELECT COUNT(*)
-- FROM cypher ('MATCH (n:roadnode)-[r:road]->(m:roadnode) RETURN n.site_id'), roadnodes
-- WHERE "n.site_id" = roadnodes.site_id;

SELECT COUNT(*)
FROM cypher ('MATCH (n:roadnode)-[r:road]->(m:roadnode) WHERE n.sitd_id IN (SELECT site_id FROM roadnodes) RETURN n.site_id');