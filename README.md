# Gestor de Serviços para Servidor Virtual

Este script em Bash foi criado para facilitar a gestão de serviços essenciais num servidor virtual, utilizando o `systemd` e a interface gráfica `yad` para proporcionar uma experiência de utilizador intuitiva. Através deste script, é possível iniciar e parar serviços como Docker, MariaDB, Nginx, e PHP-FPM, bem como aceder rapidamente a ferramentas importantes de desenvolvimento e gestão.

## Funcionalidades

1. **Verificação do Status dos Serviços**: O script verifica se os serviços Docker, MariaDB, Nginx e PHP-FPM estão ativos ou inativos, mostrando o estado atual antes de qualquer ação.

2. **Iniciar e Parar Serviços**: Com um simples clique, é possível iniciar ou parar os serviços mencionados acima. Após a execução da ação, uma notificação é exibida para informar se a operação foi bem-sucedida ou se houve algum erro.

3. **Acesso Rápido a Ferramentas Web**:
    - Testar o website local (`http://localhost`)
    - Aceder à pasta do website (`/var/www/developer`)
    - Aceder ao phpMyAdmin (`http://localhost/phpMyAdmin`)
    - Aceder ao Nginx-UI (`http://localhost:9000`)

## Como Funciona

O script exibe uma janela de diálogo com botões para cada serviço e ferramenta web. O estado atual de cada serviço é verificado e exibido, permitindo ao utilizador tomar ações conforme necessário. As ações disponíveis incluem:

- Ativar ou desativar o Docker e Docker.socket
- Ativar ou desativar o MariaDB
- Ativar ou desativar o Nginx e Nginx-UI
- Ativar ou desativar o PHP-FPM

Cada botão de serviço no diálogo reflete o estado atual do serviço correspondente (ativo ou inativo). Quando um botão é clicado, o script executa a ação apropriada (iniciar ou parar o serviço) e exibe uma notificação com o resultado da operação.

## Exemplo de Utilização

Para executar este script, certifique-se de que tem os privilégios de superusuário e que as dependências necessárias (`systemd` e `yad`) estão instaladas. Guarde o script num ficheiro, por exemplo `gestor_servicos.sh`, dê permissões de execução e execute-o:

```bash
chmod +x gestor_servicos.sh
sudo ./gestor_servicos.sh
```

## Dependências

- `systemd`: Para gerir o estado dos serviços.
- `yad`: Para exibir a interface gráfica de diálogo e notificações.

## Nota

Este script foi desenvolvido para simplificar a gestão de serviços num ambiente de servidor virtual, proporcionando uma interface gráfica amigável e acessível. Se encontrar qualquer problema ou tiver sugestões para melhorias, sinta-se à vontade para abrir um "issue" ou "pull request" no repositório.
