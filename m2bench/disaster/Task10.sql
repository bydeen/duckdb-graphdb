INSTALL json;
INSTALL spatial;
LOAD json;
LOAD spatial;

.timer on

CREATE TEMPORARY TABLE eqk AS (
    SELECT earthquake_id, time, coordinates
    FROM earthquake
    WHERE time >= '2020-06-01 00:00:00'
    AND time < '2020-06-01 02:00:00'
);

CREATE TEMPORARY TABLE roadnodes AS (
    SELECT eqk.earthquake_id AS eqk_id, site_id AS site_id
    FROM site, eqk
    WHERE site.properties->>'type' = 'roadnode'
    AND ST_DWithin(
        ST_GeomFromGeoJSON(to_json(site.geometry))::GEOMETRY,
        eqk.coordinates::GEOMETRY,
        5000
    )
);

SELECT COUNT(*)
FROM cypher ('MATCH (n:roadnode)-[r:road]->(m:roadnode) RETURN n.site_id'), roadnodes
WHERE "n.site_id" = roadnodes.site_id;