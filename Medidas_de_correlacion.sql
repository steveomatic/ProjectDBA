CREATE VIEW std_dev_nota_tema AS
SELECT asignatura_id, usuario, tema, nota, STDDEV(nota) OVER (ORDER BY nota) "StdDev" from notas_alu_por_tema ORDER BY tema;