# Sharding automático no PostgreSQL com Citus

Este repositório disponibiliza uma estrutura de contêineres para implantar um ambiente PostgreSQL com distribuição de dados (sharding) entre instâncias utilizando Citus.

O ambiente possui três contêineres:

- `coordinator`: Instância principal onde os dados são gerenciados
- `worker-101`: Instância responsável por armazenar parte dos shards distribuídos pelo coordinator
- `worker-102`: Instância responsável por armazenar parte dos shards distribuídos pelo coordinator

As três instâncias são baseadas na imagem `citusdata/citus`, que corresponde a uma imagem do PostgreSQL configurada com a extensão do Citus.

## Citus

Citus é uma extensão do PostgreSQL que transforma uma instância convencional em um banco de dados distribuído. Ele adiciona um nó **coordinator** responsável por planejar e rotear as consultas, e múltiplos nós **workers** que armazenam e processam os dados em paralelo, mantendo total compatibilidade com SQL padrão.

## Sharding

Sharding é uma técnica de particionamento horizontal que divide os dados de uma tabela em fragmentos menores chamados **shards**, distribuídos entre múltiplos nós. Cada nó armazena apenas uma parte dos dados, permitindo que leituras e escritas ocorram em paralelo.

No Citus, o coordinator recebe as consultas e as roteia para os workers responsáveis pelos shards correspondentes. A distribuição é feita com base em uma **coluna de distribuição** (no caso, `id`), e cada shard é mapeado para um intervalo de valores dessa coluna.

## Teste com ambiente PostgreSQL

### Inicialização

Para implantar o ambiente, utilize o comando:

```bash
docker compose up -d --build
```

Para verificar se os contêineres foram inicializados corretamente, verifique o status com `docker ps -a`.

### Configuração das instâncias

Na instância coordenadora, acesse a ferramenta `psql` com o comando:

```bash
docker exec -it coordinator psql -U postgres
```

Dentro do prompt, adicione `worker-101` e `worker-102` ao cluster com os comandos:

```sql
-- Configura a própria instância como coordenadora
SELECT citus_set_coordinator_host('coordinator', 5432);

-- Configura o primeiro worker como nó do cluster
SELECT * from citus_add_node('worker-101', 5432);

-- Configura o segundo worker como nó do cluster
SELECT * from citus_add_node('worker-102', 5432);
```

Para verificar se os nós foram configurados, utilize o comando:

```sql
SELECT * FROM citus_get_active_worker_nodes();
```

### Criação e distribuição de uma tabela

No mesmo prompt, crie uma tabela:

```sql
CREATE TABLE usuarios (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    data_nascimento DATE NOT NULL,
    email VARCHAR(255) NOT NULL,
    telefone VARCHAR(255) NOT NULL
);
```

Para fazer a distribuição da tabela entre os workers, utilize o comando:

```sql
SELECT create_distributed_table('usuarios', 'id');
```

### Inserção de dados

Popule a tabela com o seguinte comando:

```sql
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
```

### Validação

```sql
SELECT * FROM citus_tables;
SHOW citus.shard_count;
SET citus.shard_count TO 32;
SELECT * from pg_dist_shard;
SELECT * FROM citus_shards;
```

## Principais referências

- [Citus: Sharding your first table](https://www.cybertec-postgresql.com/en/citus-sharding-your-first-table/)
- [Clusters Citus de vários nós no Ubuntu ou Debian](https://learn.microsoft.com/pt-br/postgresql/citus/multi-node-ubuntu-debian?view=citus-14)
- [Create and modify distributed objects (DDL)](https://learn.microsoft.com/en-us/postgresql/citus/reference-ddl?view=citus-14)
- [Citus cluster metadata reference](https://learn.microsoft.com/en-us/postgresql/citus/api-metadata?view=citus-14)
- [Scaling Horizontally on PostgreSQL: Citus’s Impact on Database Architecture](https://demirhuseyinn-94.medium.com/scaling-horizontally-on-postgresql-cituss-impact-on-database-architecture-295329c72c62)
- [Database Sharding - System Design](https://www.geeksforgeeks.org/system-design/database-sharding-a-system-design-concept/)
