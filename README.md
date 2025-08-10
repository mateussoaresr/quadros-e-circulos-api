# Quadros e Círculos API

API Rails para manipulação de frames e círculos, com Docker para facilitar o ambiente.

---

## Pré-requisitos

- Docker instalado ([guia oficial](https://docs.docker.com/get-docker/))
- Docker Compose (já incluído no Docker Desktop)
- Variável de ambiente `POSTGRES_PASSWORD` definida localmente (exemplo: no `.env`)

---

## Como rodar a aplicação via Docker

1. **Clone o repositório**

```bash
git clone <URL-do-repositorio>
cd quadros-e-circulos-api
```

## 2. Criando o arquivo `.env` com senha do banco

Para o PostgreSQL funcionar, você precisa definir a senha do banco:

```bash
echo "POSTGRES_PASSWORD=sua_senha_super_secreta" > .env
```

## 3. Build e start da aplicação

```bash
docker compose up --build
```

### Isso vai:

- Construir a imagem do app Rails

- Subir o container do PostgreSQL com senha configurada

- Rodar as migrations (se seu entrypoint estiver configurado para isso)

- Subir o servidor Rails na porta 3001 do seu host

## 4. Acessando a API

```bash
http://localhost:3001
```

## 6. Testando via Swagger (OpenAPI)

```bash
http://localhost:3001/api-docs
```

### Lá você poderá:

- Ver toda a documentação dos endpoints

- Fazer testes interativos de requisições

