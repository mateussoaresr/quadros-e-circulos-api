#!/bin/bash
set -e

# Executa as migrations antes de iniciar o servidor
bundle exec rails db:migrate

# Executa o comando passado (ex: rails server)
exec "$@"
