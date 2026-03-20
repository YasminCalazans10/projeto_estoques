SELECT
    data_mes,
    filial,
    cidade,
    uf,
    regiao,
    centro_distribuicao,
    familia,
    valor_estoque_total,
    taxa_ruptura_pct,
    giro_estoque,
    dias_cobertura_medio
FROM estoques.vm_kpis_estoques_mensal
ORDER BY data_mes;
