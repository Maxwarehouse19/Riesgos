ALTER TABLE ALTCHKPOINT ADD [ValorDifMaximo] [decimal](7, 2) NOT NULL DEFAULT 0

UPDATE ALTCHKPOINT SET [ValorDifMaximo]  = [ValorDifMinimo]
UPDATE ALTCHKPOINT SET [ValorDifMinimo] = 5

select * from ALTCHKPOINT
