DROP FUNCTION check_distance(a geometry, b geometry , kef float );
CREATE FUNCTION  check_distance(a geometry, b geometry , kef float  DEFAULT 0.5)
RETURNS float 
LANGUAGE plpgsql
AS $$
    DECLARE
   ln  geometry;
   pnt   geometry;
  maxDistance float;
   dist float;
   v record;
   u record;
BEGIN
  maxDistance = 0.0; 
 	for v in (   Select st_union( ST_Boundary(geom) )as ln   From  (SELECT (ST_DumpRings((ST_Dump(a)).geom)).*) as d2    ) loop
              		for u in(with  segments AS (
                     Select    ST_PointN(geom, generate_series(1, ST_NPoints(geom)-1)) as sp  ,
                  					 ST_PointN(geom, generate_series(2, ST_NPoints(geom)  )) as ep
                     FROM  ( Select  (ST_Dump(ST_Boundary(ST_CollectionExtract(st_intersection(a,b),3)))).geom  )AS peresech) 
                     SELECT   geoloc   pnt 
						FROM (select (ST_Dump (ST_LineInterpolatePoints( ST_MakeLine(sp,ep), kef))).geom   as geoloc  From segments)  g )  loop
            				dist =max (st_distance(v.ln, u.pnt));
						if dist > maxDistance then
						maxDistance = dist;
 					end if;
             end loop;
    end loop;
      return maxDistance;
END;$$;
