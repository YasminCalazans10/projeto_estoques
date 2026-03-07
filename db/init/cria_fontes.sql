-- Executar este arquivo no PgAdmin conectado ao banco bi_dw.
-- Objetivo: criar um DW simulado com 3 dominios (vendas, produtos, estoques)
-- com granularidade mensal, 5 anos de historico, filiais brasileiras e VMs para consumo.

BEGIN;

CREATE SCHEMA IF NOT EXISTS vendas AUTHORIZATION bi_user;
CREATE SCHEMA IF NOT EXISTS produtos AUTHORIZATION bi_user;
CREATE SCHEMA IF NOT EXISTS estoques AUTHORIZATION bi_user;

-- =====================================================
-- LIMPEZA CONTROLADA PARA REEXECUCAO DO SCRIPT
-- =====================================================

DROP MATERIALIZED VIEW IF EXISTS vendas.vm_kpis_vendas_mensal;
DROP MATERIALIZED VIEW IF EXISTS produtos.vm_kpis_produtos_mensal;
DROP MATERIALIZED VIEW IF EXISTS estoques.vm_kpis_estoques_mensal;

DROP TABLE IF EXISTS vendas.fato_vendas_mensal CASCADE;
DROP TABLE IF EXISTS vendas.dim_tempo_mes CASCADE;
DROP TABLE IF EXISTS vendas.dim_canal CASCADE;
DROP TABLE IF EXISTS vendas.dim_segmento_cliente CASCADE;
DROP TABLE IF EXISTS vendas.dim_filial CASCADE;

DROP TABLE IF EXISTS produtos.fato_produtos_mensal CASCADE;
DROP TABLE IF EXISTS produtos.dim_tempo_mes CASCADE;
DROP TABLE IF EXISTS produtos.dim_categoria CASCADE;
DROP TABLE IF EXISTS produtos.dim_fornecedor CASCADE;
DROP TABLE IF EXISTS produtos.dim_filial CASCADE;

DROP TABLE IF EXISTS estoques.fato_estoques_mensal CASCADE;
DROP TABLE IF EXISTS estoques.dim_tempo_mes CASCADE;
DROP TABLE IF EXISTS estoques.dim_centro_distribuicao CASCADE;
DROP TABLE IF EXISTS estoques.dim_familia_produto CASCADE;
DROP TABLE IF EXISTS estoques.dim_filial CASCADE;

-- ==========================
-- ESQUEMA: VENDAS
-- ==========================

CREATE TABLE vendas.dim_tempo_mes (
    id_tempo SERIAL PRIMARY KEY,
    data_mes DATE NOT NULL UNIQUE,
    ano INT NOT NULL,
    mes INT NOT NULL,
    nome_mes VARCHAR(20) NOT NULL
);

CREATE TABLE vendas.dim_filial (
    id_filial SERIAL PRIMARY KEY,
    filial VARCHAR(80) NOT NULL,
    cidade VARCHAR(80) NOT NULL,
    uf CHAR(2) NOT NULL,
    regiao VARCHAR(20) NOT NULL,
    porte VARCHAR(20) NOT NULL,
    UNIQUE (filial)
);

CREATE TABLE vendas.dim_canal (
    id_canal SERIAL PRIMARY KEY,
    canal VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE vendas.dim_segmento_cliente (
    id_segmento SERIAL PRIMARY KEY,
    segmento VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE vendas.fato_vendas_mensal (
    id_fato BIGSERIAL PRIMARY KEY,
    id_tempo INT NOT NULL REFERENCES vendas.dim_tempo_mes(id_tempo),
    id_filial INT NOT NULL REFERENCES vendas.dim_filial(id_filial),
    id_canal INT NOT NULL REFERENCES vendas.dim_canal(id_canal),
    id_segmento INT NOT NULL REFERENCES vendas.dim_segmento_cliente(id_segmento),
    receita_bruta NUMERIC(14,2) NOT NULL,
    desconto NUMERIC(14,2) NOT NULL,
    custo NUMERIC(14,2) NOT NULL,
    quantidade_itens INT NOT NULL,
    pedidos INT NOT NULL
);

-- ==========================
-- ESQUEMA: PRODUTOS
-- ==========================

CREATE TABLE produtos.dim_tempo_mes (
    id_tempo SERIAL PRIMARY KEY,
    data_mes DATE NOT NULL UNIQUE,
    ano INT NOT NULL,
    mes INT NOT NULL,
    nome_mes VARCHAR(20) NOT NULL
);

CREATE TABLE produtos.dim_filial (
    id_filial SERIAL PRIMARY KEY,
    filial VARCHAR(80) NOT NULL,
    cidade VARCHAR(80) NOT NULL,
    uf CHAR(2) NOT NULL,
    regiao VARCHAR(20) NOT NULL,
    porte VARCHAR(20) NOT NULL,
    UNIQUE (filial)
);

CREATE TABLE produtos.dim_categoria (
    id_categoria SERIAL PRIMARY KEY,
    categoria VARCHAR(80) NOT NULL UNIQUE
);

CREATE TABLE produtos.dim_fornecedor (
    id_fornecedor SERIAL PRIMARY KEY,
    fornecedor VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE produtos.fato_produtos_mensal (
    id_fato BIGSERIAL PRIMARY KEY,
    id_tempo INT NOT NULL REFERENCES produtos.dim_tempo_mes(id_tempo),
    id_filial INT NOT NULL REFERENCES produtos.dim_filial(id_filial),
    id_categoria INT NOT NULL REFERENCES produtos.dim_categoria(id_categoria),
    id_fornecedor INT NOT NULL REFERENCES produtos.dim_fornecedor(id_fornecedor),
    produtos_ativos INT NOT NULL,
    novos_produtos INT NOT NULL,
    produtos_descontinuados INT NOT NULL,
    preco_medio NUMERIC(10,2) NOT NULL,
    custo_medio NUMERIC(10,2) NOT NULL,
    vendas_unidades INT NOT NULL
);

-- ==========================
-- ESQUEMA: ESTOQUES
-- ==========================

CREATE TABLE estoques.dim_tempo_mes (
    id_tempo SERIAL PRIMARY KEY,
    data_mes DATE NOT NULL UNIQUE,
    ano INT NOT NULL,
    mes INT NOT NULL,
    nome_mes VARCHAR(20) NOT NULL
);

CREATE TABLE estoques.dim_filial (
    id_filial SERIAL PRIMARY KEY,
    filial VARCHAR(80) NOT NULL,
    cidade VARCHAR(80) NOT NULL,
    uf CHAR(2) NOT NULL,
    regiao VARCHAR(20) NOT NULL,
    porte VARCHAR(20) NOT NULL,
    UNIQUE (filial)
);

CREATE TABLE estoques.dim_centro_distribuicao (
    id_cd SERIAL PRIMARY KEY,
    centro_distribuicao VARCHAR(80) NOT NULL UNIQUE
);

CREATE TABLE estoques.dim_familia_produto (
    id_familia SERIAL PRIMARY KEY,
    familia VARCHAR(80) NOT NULL UNIQUE
);

CREATE TABLE estoques.fato_estoques_mensal (
    id_fato BIGSERIAL PRIMARY KEY,
    id_tempo INT NOT NULL REFERENCES estoques.dim_tempo_mes(id_tempo),
    id_filial INT NOT NULL REFERENCES estoques.dim_filial(id_filial),
    id_cd INT NOT NULL REFERENCES estoques.dim_centro_distribuicao(id_cd),
    id_familia INT NOT NULL REFERENCES estoques.dim_familia_produto(id_familia),
    estoque_medio_unidades INT NOT NULL,
    movimentacoes_saida INT NOT NULL,
    rupturas INT NOT NULL,
    dias_cobertura NUMERIC(8,2) NOT NULL,
    valor_estoque NUMERIC(14,2) NOT NULL
);

-- ==========================
-- CARGA DAS DIMENSOES
-- ==========================

INSERT INTO vendas.dim_tempo_mes (data_mes, ano, mes, nome_mes)
SELECT
    gs::date AS data_mes,
    EXTRACT(YEAR FROM gs)::INT AS ano,
    EXTRACT(MONTH FROM gs)::INT AS mes,
    TO_CHAR(gs, 'TMMonth') AS nome_mes
FROM generate_series(
    date_trunc('month', CURRENT_DATE) - INTERVAL '59 months',
    date_trunc('month', CURRENT_DATE),
    INTERVAL '1 month'
) AS gs;

INSERT INTO produtos.dim_tempo_mes (data_mes, ano, mes, nome_mes)
SELECT
    gs::date AS data_mes,
    EXTRACT(YEAR FROM gs)::INT AS ano,
    EXTRACT(MONTH FROM gs)::INT AS mes,
    TO_CHAR(gs, 'TMMonth') AS nome_mes
FROM generate_series(
    date_trunc('month', CURRENT_DATE) - INTERVAL '59 months',
    date_trunc('month', CURRENT_DATE),
    INTERVAL '1 month'
) AS gs;

INSERT INTO estoques.dim_tempo_mes (data_mes, ano, mes, nome_mes)
SELECT
    gs::date AS data_mes,
    EXTRACT(YEAR FROM gs)::INT AS ano,
    EXTRACT(MONTH FROM gs)::INT AS mes,
    TO_CHAR(gs, 'TMMonth') AS nome_mes
FROM generate_series(
    date_trunc('month', CURRENT_DATE) - INTERVAL '59 months',
    date_trunc('month', CURRENT_DATE),
    INTERVAL '1 month'
) AS gs;

-- Filiais em varias cidades do Brasil
INSERT INTO vendas.dim_filial (filial, cidade, uf, regiao, porte) VALUES
('Filial Sao Paulo Centro', 'Sao Paulo', 'SP', 'Sudeste', 'Grande'),
('Filial Campinas', 'Campinas', 'SP', 'Sudeste', 'Media'),
('Filial Rio Capital', 'Rio de Janeiro', 'RJ', 'Sudeste', 'Grande'),
('Filial Belo Horizonte', 'Belo Horizonte', 'MG', 'Sudeste', 'Grande'),
('Filial Curitiba', 'Curitiba', 'PR', 'Sul', 'Media'),
('Filial Porto Alegre', 'Porto Alegre', 'RS', 'Sul', 'Media'),
('Filial Florianopolis', 'Florianopolis', 'SC', 'Sul', 'Media'),
('Filial Salvador', 'Salvador', 'BA', 'Nordeste', 'Grande'),
('Filial Recife', 'Recife', 'PE', 'Nordeste', 'Media'),
('Filial Fortaleza', 'Fortaleza', 'CE', 'Nordeste', 'Media'),
('Filial Goiania', 'Goiania', 'GO', 'Centro-Oeste', 'Media'),
('Filial Brasilia', 'Brasilia', 'DF', 'Centro-Oeste', 'Grande');

INSERT INTO produtos.dim_filial (filial, cidade, uf, regiao, porte)
SELECT filial, cidade, uf, regiao, porte FROM vendas.dim_filial;

INSERT INTO estoques.dim_filial (filial, cidade, uf, regiao, porte)
SELECT filial, cidade, uf, regiao, porte FROM vendas.dim_filial;

INSERT INTO vendas.dim_canal (canal)
VALUES ('E-commerce'), ('Loja Fisica'), ('Marketplace'), ('Televendas'), ('App Mobile');

INSERT INTO vendas.dim_segmento_cliente (segmento)
VALUES ('B2C'), ('B2B'), ('Premium'), ('Atacado'), ('Varejo Regional');

INSERT INTO produtos.dim_categoria (categoria)
VALUES
('Eletronicos'), ('Moveis'), ('Papelaria'), ('Informatica'),
('Eletrodomesticos'), ('Esporte'), ('Casa e Decoracao'), ('Perifericos');

INSERT INTO produtos.dim_fornecedor (fornecedor)
VALUES
('Fornecedor Alpha'), ('Fornecedor Beta'), ('Fornecedor Gama'), ('Fornecedor Delta'),
('Fornecedor Omega'), ('Fornecedor Prime'), ('Fornecedor Nexus'), ('Fornecedor Orion'),
('Fornecedor Atlas'), ('Fornecedor Sigma');

INSERT INTO estoques.dim_centro_distribuicao (centro_distribuicao)
VALUES ('CD Sao Paulo'), ('CD Campinas'), ('CD Belo Horizonte'), ('CD Curitiba'), ('CD Recife'), ('CD Goiania');

INSERT INTO estoques.dim_familia_produto (familia)
VALUES
('Linha Premium'), ('Linha Essencial'), ('Linha Corporativa'), ('Linha Residencial'),
('Linha Escolar'), ('Linha Gamer'), ('Linha Mobilidade'), ('Linha Office');

-- ==========================
-- CARGA DAS FATOS
-- 10.000 linhas por tabela fato
-- ==========================

INSERT INTO vendas.fato_vendas_mensal (
    id_tempo, id_filial, id_canal, id_segmento, receita_bruta, desconto, custo, quantidade_itens, pedidos
)
SELECT
    (1 + FLOOR(RANDOM() * 60))::INT,
    (1 + FLOOR(RANDOM() * 12))::INT,
    (1 + FLOOR(RANDOM() * 5))::INT,
    (1 + FLOOR(RANDOM() * 5))::INT,
    ROUND((10000 + RANDOM() * 90000)::NUMERIC, 2),
    ROUND((500 + RANDOM() * 15000)::NUMERIC, 2),
    ROUND((6000 + RANDOM() * 65000)::NUMERIC, 2),
    (10 + FLOOR(RANDOM() * 200))::INT,
    (5 + FLOOR(RANDOM() * 80))::INT
FROM generate_series(1, 10000);

INSERT INTO produtos.fato_produtos_mensal (
    id_tempo, id_filial, id_categoria, id_fornecedor, produtos_ativos, novos_produtos,
    produtos_descontinuados, preco_medio, custo_medio, vendas_unidades
)
SELECT
    (1 + FLOOR(RANDOM() * 60))::INT,
    (1 + FLOOR(RANDOM() * 12))::INT,
    (1 + FLOOR(RANDOM() * 8))::INT,
    (1 + FLOOR(RANDOM() * 10))::INT,
    (80 + FLOOR(RANDOM() * 420))::INT,
    (1 + FLOOR(RANDOM() * 20))::INT,
    (0 + FLOOR(RANDOM() * 12))::INT,
    ROUND((50 + RANDOM() * 1450)::NUMERIC, 2),
    ROUND((30 + RANDOM() * 1000)::NUMERIC, 2),
    (100 + FLOOR(RANDOM() * 2000))::INT
FROM generate_series(1, 10000);

INSERT INTO estoques.fato_estoques_mensal (
    id_tempo, id_filial, id_cd, id_familia, estoque_medio_unidades,
    movimentacoes_saida, rupturas, dias_cobertura, valor_estoque
)
SELECT
    (1 + FLOOR(RANDOM() * 60))::INT,
    (1 + FLOOR(RANDOM() * 12))::INT,
    (1 + FLOOR(RANDOM() * 6))::INT,
    (1 + FLOOR(RANDOM() * 8))::INT,
    (500 + FLOOR(RANDOM() * 5000))::INT,
    (200 + FLOOR(RANDOM() * 4000))::INT,
    (0 + FLOOR(RANDOM() * 200))::INT,
    ROUND((5 + RANDOM() * 90)::NUMERIC, 2),
    ROUND((50000 + RANDOM() * 950000)::NUMERIC, 2)
FROM generate_series(1, 10000);

-- ==========================
-- INDICES PARA PERFORMANCE
-- ==========================

CREATE INDEX idx_fv_tempo ON vendas.fato_vendas_mensal(id_tempo);
CREATE INDEX idx_fv_filial ON vendas.fato_vendas_mensal(id_filial);
CREATE INDEX idx_fp_tempo ON produtos.fato_produtos_mensal(id_tempo);
CREATE INDEX idx_fp_filial ON produtos.fato_produtos_mensal(id_filial);
CREATE INDEX idx_fe_tempo ON estoques.fato_estoques_mensal(id_tempo);
CREATE INDEX idx_fe_filial ON estoques.fato_estoques_mensal(id_filial);

-- ==========================
-- VMs DE CONSUMO (MATERIALIZED VIEWS)
-- Incluem colunas de filtro: tempo, filial e dimensoes de negocio
-- ==========================

CREATE MATERIALIZED VIEW vendas.vm_kpis_vendas_mensal AS
WITH base AS (
    SELECT
        t.data_mes,
        f2.filial,
        f2.cidade,
        f2.uf,
        f2.regiao,
        c.canal,
        s.segmento,
        SUM(f.receita_bruta) AS receita_bruta,
        SUM(f.desconto) AS desconto_total,
        SUM(f.custo) AS custo_total,
        SUM(f.quantidade_itens) AS itens_vendidos,
        SUM(f.pedidos) AS pedidos
    FROM vendas.fato_vendas_mensal f
    JOIN vendas.dim_tempo_mes t ON t.id_tempo = f.id_tempo
    JOIN vendas.dim_filial f2 ON f2.id_filial = f.id_filial
    JOIN vendas.dim_canal c ON c.id_canal = f.id_canal
    JOIN vendas.dim_segmento_cliente s ON s.id_segmento = f.id_segmento
    GROUP BY t.data_mes, f2.filial, f2.cidade, f2.uf, f2.regiao, c.canal, s.segmento
)
SELECT
    data_mes,
    filial,
    cidade,
    uf,
    regiao,
    canal,
    segmento,
    receita_bruta,
    desconto_total,
    (receita_bruta - desconto_total) AS receita_liquida,
    custo_total,
    ROUND(((receita_bruta - desconto_total - custo_total) / NULLIF((receita_bruta - desconto_total), 0)) * 100, 2) AS margem_bruta_pct,
    ROUND((receita_bruta - desconto_total) / NULLIF(pedidos, 0), 2) AS ticket_medio,
    ROUND(itens_vendidos::NUMERIC / NULLIF(pedidos, 0), 2) AS itens_por_pedido,
    ROUND((
        ((receita_bruta - desconto_total) - LAG(receita_bruta - desconto_total) OVER (PARTITION BY filial ORDER BY data_mes))
        / NULLIF(LAG(receita_bruta - desconto_total) OVER (PARTITION BY filial ORDER BY data_mes), 0)
    ) * 100, 2) AS crescimento_receita_pct
FROM base;

CREATE MATERIALIZED VIEW produtos.vm_kpis_produtos_mensal AS
WITH base AS (
    SELECT
        t.data_mes,
        f2.filial,
        f2.cidade,
        f2.uf,
        f2.regiao,
        c.categoria,
        fr.fornecedor,
        SUM(f.produtos_ativos) AS produtos_ativos,
        SUM(f.novos_produtos) AS novos_produtos,
        SUM(f.produtos_descontinuados) AS descontinuados,
        AVG(f.preco_medio) AS preco_medio,
        AVG(f.custo_medio) AS custo_medio,
        SUM(f.vendas_unidades) AS unidades_vendidas
    FROM produtos.fato_produtos_mensal f
    JOIN produtos.dim_tempo_mes t ON t.id_tempo = f.id_tempo
    JOIN produtos.dim_filial f2 ON f2.id_filial = f.id_filial
    JOIN produtos.dim_categoria c ON c.id_categoria = f.id_categoria
    JOIN produtos.dim_fornecedor fr ON fr.id_fornecedor = f.id_fornecedor
    GROUP BY t.data_mes, f2.filial, f2.cidade, f2.uf, f2.regiao, c.categoria, fr.fornecedor
)
SELECT
    data_mes,
    filial,
    cidade,
    uf,
    regiao,
    categoria,
    fornecedor,
    produtos_ativos,
    novos_produtos,
    descontinuados,
    unidades_vendidas,
    ROUND((novos_produtos::NUMERIC / NULLIF(produtos_ativos, 0)) * 100, 2) AS taxa_lancamento_pct,
    ROUND((descontinuados::NUMERIC / NULLIF(produtos_ativos, 0)) * 100, 2) AS taxa_descontinuacao_pct,
    ROUND(((preco_medio - custo_medio) / NULLIF(custo_medio, 0)) * 100, 2) AS markup_medio_pct,
    ROUND(unidades_vendidas::NUMERIC / NULLIF(produtos_ativos, 0), 2) AS demanda_media_por_produto,
    ROUND((
        (unidades_vendidas - LAG(unidades_vendidas) OVER (PARTITION BY filial ORDER BY data_mes))
        / NULLIF(LAG(unidades_vendidas) OVER (PARTITION BY filial ORDER BY data_mes), 0)
    ) * 100, 2) AS crescimento_unidades_pct
FROM base;

CREATE MATERIALIZED VIEW estoques.vm_kpis_estoques_mensal AS
WITH base AS (
    SELECT
        t.data_mes,
        f2.filial,
        f2.cidade,
        f2.uf,
        f2.regiao,
        cd.centro_distribuicao,
        fp.familia,
        SUM(f.estoque_medio_unidades) AS estoque_medio_unidades,
        SUM(f.movimentacoes_saida) AS movimentacoes_saida,
        SUM(f.rupturas) AS rupturas,
        AVG(f.dias_cobertura) AS dias_cobertura_medio,
        SUM(f.valor_estoque) AS valor_estoque_total
    FROM estoques.fato_estoques_mensal f
    JOIN estoques.dim_tempo_mes t ON t.id_tempo = f.id_tempo
    JOIN estoques.dim_filial f2 ON f2.id_filial = f.id_filial
    JOIN estoques.dim_centro_distribuicao cd ON cd.id_cd = f.id_cd
    JOIN estoques.dim_familia_produto fp ON fp.id_familia = f.id_familia
    GROUP BY t.data_mes, f2.filial, f2.cidade, f2.uf, f2.regiao, cd.centro_distribuicao, fp.familia
)
SELECT
    data_mes,
    filial,
    cidade,
    uf,
    regiao,
    centro_distribuicao,
    familia,
    estoque_medio_unidades,
    movimentacoes_saida,
    rupturas,
    ROUND(dias_cobertura_medio, 2) AS dias_cobertura_medio,
    valor_estoque_total,
    ROUND((rupturas::NUMERIC / NULLIF((movimentacoes_saida + rupturas), 0)) * 100, 2) AS taxa_ruptura_pct,
    ROUND(movimentacoes_saida::NUMERIC / NULLIF(estoque_medio_unidades, 0), 2) AS giro_estoque,
    ROUND((
        (valor_estoque_total - LAG(valor_estoque_total) OVER (PARTITION BY filial ORDER BY data_mes))
        / NULLIF(LAG(valor_estoque_total) OVER (PARTITION BY filial ORDER BY data_mes), 0)
    ) * 100, 2) AS variacao_valor_estoque_pct
FROM base;

CREATE INDEX idx_vm_vendas_data_mes ON vendas.vm_kpis_vendas_mensal(data_mes);
CREATE INDEX idx_vm_vendas_filial ON vendas.vm_kpis_vendas_mensal(filial);
CREATE INDEX idx_vm_produtos_data_mes ON produtos.vm_kpis_produtos_mensal(data_mes);
CREATE INDEX idx_vm_produtos_filial ON produtos.vm_kpis_produtos_mensal(filial);
CREATE INDEX idx_vm_estoques_data_mes ON estoques.vm_kpis_estoques_mensal(data_mes);
CREATE INDEX idx_vm_estoques_filial ON estoques.vm_kpis_estoques_mensal(filial);

COMMIT;

-- Atualizacao das VMs (quando necessario):
-- REFRESH MATERIALIZED VIEW vendas.vm_kpis_vendas_mensal;
-- REFRESH MATERIALIZED VIEW produtos.vm_kpis_produtos_mensal;
-- REFRESH MATERIALIZED VIEW estoques.vm_kpis_estoques_mensal;
