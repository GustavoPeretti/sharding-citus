-- Inicialização do cluster Citus

SELECT citus_set_coordinator_host('coordinator', 5432);

SELECT * from citus_add_node('worker-101', 5432);
SELECT * from citus_add_node('worker-102', 5432);

-- Criação da tabela distribuída e inserção de dados

CREATE TABLE usuarios (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    data_nascimento DATE NOT NULL,
    email VARCHAR(255) NOT NULL,
    telefone VARCHAR(255) NOT NULL
);

SELECT create_distributed_table('usuarios', 'id');

INSERT INTO usuarios (
    nome,
    data_nascimento,
    email,
    telefone
)
SELECT
    'Usuario ' || g,
    CURRENT_DATE,
    'user' || g || '@email.com',
    '(49)99999-' || g
FROM generate_series(1,100000) g;
