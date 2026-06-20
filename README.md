# Sharding automático no PostgreSQL com Citus

Este repositório disponibiliza uma estrutura de contêineres para implantar um ambiente PostgreSQL com distribuição de dados (sharding) entre instâncias utilizando Citus.

O ambiente possui três contêineres:

- `coordinator`: Instância principal onde os dados são gerenciados
- `worker-101`: Instância responsável por armazenar parte dos shards distribuídos pelo coordinator
- `worker-102`: Instância responsável por armazenar parte dos shards distribuídos pelo coordinator

As três instâncias são baseadas na imagem `citusdata/citus`, que corresponde a uma imagem do PostgreSQL configurada com a extensão do Citus.

## Inicialização

Para implantar o ambiente, utilize o comando:

```bash
docker compose up -d --build
```

Para verificar se os contêineres foram inicializados corretamente, verifique o status com `docker ps -a`.

## Configuração das instâncias

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

## Criação e distribuição de uma tabela

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

## Inserção e verificação de dados

Popule a tabela com os seguintes registros:

```sql
INSERT INTO usuarios (nome, data_nascimento, email, telefone) VALUES
('João Silva', '1990-05-12', 'joao.silva@email.com', '(11) 98765-1234'),
('Maria Oliveira', '1988-09-23', 'maria.oliveira@email.com', '(21) 99876-2345'),
('Carlos Souza', '1995-01-15', 'carlos.souza@email.com', '(31) 97654-3456'),
('Ana Pereira', '1992-07-08', 'ana.pereira@email.com', '(41) 96543-4567'),
('Pedro Santos', '1985-12-30', 'pedro.santos@email.com', '(51) 95432-5678'),
('Juliana Costa', '1998-03-19', 'juliana.costa@email.com', '(61) 94321-6789'),
('Lucas Almeida', '1991-11-02', 'lucas.almeida@email.com', '(71) 93210-7890'),
('Fernanda Rocha', '1994-06-25', 'fernanda.rocha@email.com', '(81) 92109-8901'),
('Ricardo Lima', '1987-08-14', 'ricardo.lima@email.com', '(91) 91098-9012'),
('Camila Martins', '1999-02-10', 'camila.martins@email.com', '(47) 99987-0123'),
('Bruno Gomes', '1993-04-17', 'bruno.gomes@email.com', '(48) 98876-1234'),
('Patricia Ferreira', '1986-10-28', 'patricia.ferreira@email.com', '(49) 97765-2345'),
('Rafael Barbosa', '1997-01-05', 'rafael.barbosa@email.com', '(54) 96654-3456'),
('Larissa Carvalho', '2000-09-12', 'larissa.carvalho@email.com', '(55) 95543-4567'),
('Gustavo Ribeiro', '1991-12-21', 'gustavo.ribeiro@email.com', '(62) 94432-5678'),
('Beatriz Moreira', '1996-05-07', 'beatriz.moreira@email.com', '(63) 93321-6789'),
('Thiago Mendes', '1989-07-29', 'thiago.mendes@email.com', '(64) 92210-7890'),
('Aline Castro', '1994-11-11', 'aline.castro@email.com', '(65) 91109-8901'),
('Diego Nunes', '1992-02-03', 'diego.nunes@email.com', '(66) 90098-9012'),
('Vanessa Teixeira', '1988-08-18', 'vanessa.teixeira@email.com', '(67) 98987-0123');
```

## Principais referências

- [Citus: Sharding your first table](https://www.cybertec-postgresql.com/en/citus-sharding-your-first-table/)
- [Clusters Citus de vários nós no Ubuntu ou Debian
](https://learn.microsoft.com/pt-br/postgresql/citus/multi-node-ubuntu-debian?view=citus-14)
