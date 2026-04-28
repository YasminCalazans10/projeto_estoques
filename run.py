"""
Ponto de entrada (Entry Point) da aplicação.
Arquivo principal onde a execução do servidor web Flask é iniciada.
"""
from app import create_app

# Cria a instância da aplicação utilizando a fábrica (App Factory)
app = create_app()

if __name__ == '__main__':
    # Inicia o servidor local de desenvolvimento (modo debug ativado para testes via CLI)
    app.run(debug=True)
