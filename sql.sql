create table pessoa (
	id serial primary key,
	nome varchar(255)
);

explain analyze select nome from pessoa;


QUERY PLAN                                                                                                          
-------------------------------------------------------------------------------------------------------------------+
Seq Scan on pessoa  (cost=0.00..157982.20 rows=10110120 width=9) (actual time=0.016..3011.796 rows=10110039 loops=1)
Planning Time: 0.068 ms                                                                                             
Execution Time: 3638.215 ms                                                                                         



create table pessoa (
	id serial primary key,
	nome varchar(255)
);

CREATE OR REPLACE FUNCTION inserir_registro(nome text) RETURNS void AS $$
BEGIN
    INSERT INTO pessoa (nome) VALUES (nome);
END;
$$ LANGUAGE plpgsql;

DO $$ 
DECLARE
    contador INT := 1;
   	nome text := '';
BEGIN
    LOOP
    	nome := gerar_texto_aleatorio();
		PERFORM inserir_registro(nome);

        contador := contador + 1;

        IF contador > 10000000 THEN
            EXIT;
        END IF;

    END LOOP;
END 
$$ LANGUAGE plpgsql;



explain analyze select id from pessoa where id = 100000;

QUERY PLAN                                                                                                             
-----------------------------------------------------------------------------------------------------------------------+
Index Only Scan using pessoa_pkey on pessoa  (cost=0.43..8.45 rows=1 width=4) (actual time=1.883..1.884 rows=1 loops=1)
  Index Cond: (id = 100000)                                                                                            
  Heap Fetches: 1                                                                                                      
Planning Time: 0.229 ms                                                                                                
Execution Time: 9.018 ms                                                                                               



explain analyze select id, nome from pessoa where id = 1000;

QUERY PLAN                                                                                                           
---------------------------------------------------------------------------------------------------------------------+
Index Scan using pessoa_pkey on pessoa  (cost=0.43..8.45 rows=1 width=13) (actual time=11.473..11.476 rows=1 loops=1)
  Index Cond: (id = 1000)                                                                                            
Planning Time: 0.160 ms                                                                                              
Execution Time: 11.520 ms                                                                                            



create table registro (
	id serial primary key,
	nome varchar(255)
);

CREATE OR REPLACE FUNCTION inserir_registro_2(nome text) RETURNS void AS $$
BEGIN
    INSERT INTO registro (nome) VALUES (nome);
END;
$$ LANGUAGE plpgsql;


DO $$ 
DECLARE
    contador INT := 1;
   	nome text := '';
BEGIN
    LOOP
    	nome := gerar_texto_aleatorio();
		PERFORM inserir_registro_2(nome);

        contador := contador + 1;

        IF contador > 10000000 THEN
            EXIT;
        END IF;

    END LOOP;
END 
$$ LANGUAGE plpgsql;


explain analyze select id from registro where nome = 'a%';

QUERY PLAN                                                                                                              
------------------------------------------------------------------------------------------------------------------------+
Gather  (cost=1000.00..109352.23 rows=1 width=4) (actual time=360.222..366.416 rows=0 loops=1)                          
  Workers Planned: 2                                                                                                    
  Workers Launched: 2                                                                                                   
  ->  Parallel Seq Scan on registro  (cost=0.00..108352.13 rows=1 width=4) (actual time=320.956..320.956 rows=0 loops=3)
        Filter: ((nome)::text = 'a%'::text)                                                                             
        Rows Removed by Filter: 3333667                                                                                 
Planning Time: 1.101 ms                                                                                                 
Execution Time: 366.431 ms                                                                                              



CREATE INDEX nome_indice
ON registro (nome);

select *
FROM pg_indexes
WHERE tablename = 'registro';

schemaname|tablename|indexname    |tablespace|indexdef                                                             
----------+---------+-------------+----------+---------------------------------------------------------------------+
public    |registro |registro_pkey|          |CREATE UNIQUE INDEX registro_pkey ON public.registro USING btree (id)
public    |registro |nome_indice  |          |CREATE INDEX nome_indice ON public.registro USING btree (nome)       


explain analyze select id from registro where nome = 'b%';


QUERY PLAN                                                                                                          
--------------------------------------------------------------------------------------------------------------------+
Index Scan using nome_indice on registro  (cost=0.43..8.45 rows=1 width=4) (actual time=0.043..0.043 rows=0 loops=1)
  Index Cond: ((nome)::text = 'b%'::text)                                                                           
Planning Time: 0.968 ms                                                                                             
Execution Time: 0.057 ms                                                                                            