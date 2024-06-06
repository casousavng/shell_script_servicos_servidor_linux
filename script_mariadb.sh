#!/bin/bash

# Solicitar senha sudo usando yad
PASSWORD_PROMPT=$(yad --form --title="Autenticação Requerida" --text="\nPor favor, insira sua senha\n [com permissões SUDO]\n\n ATENÇÃO: USAR APENAS EM MODO LIVE\n" --undecorated --text-align=center --width=300 --height=100 --borders=5 --field="Senha:H" --hide-text --button="OK:0" --button="Cancelar:1")

# Separar a senha do campo de prompt do yad
SUDO_PASSWORD=$(echo "$PASSWORD_PROMPT" | awk -F'|' '{print $1}')

if [ $? -ne 0 ] || [ -z "$SUDO_PASSWORD" ]; then
    yad --error --title="ERRO" --text="  \n\n A SENHA NÃO FOI FORNECIDA. \n\n O Script vai Encerrar. \n\n " --undecorated --text-align=center
    exit 1
fi

# Função para verificar o status do serviço
verificar_status() {
    echo "$SUDO_PASSWORD" | sudo -S systemctl is-active --quiet "$1"
    if [ $? -eq 0 ]; then
        echo "ativo"
    else
        echo "inativo"
    fi
}

# Função para iniciar o serviço e exibir notificação
iniciar_servico() {
    echo "$SUDO_PASSWORD" | sudo -S systemctl start "$1"
    sleep 5
    echo "$SUDO_PASSWORD" | sudo -S mysql -e "CREATE DATABASE teste_db;"
    echo "$SUDO_PASSWORD" | sudo -S mysql -e "CREATE USER 'developer'@'localhost' IDENTIFIED BY 'developer';"
    echo "$SUDO_PASSWORD" | sudo -S mysql -e "GRANT ALL PRIVILEGES ON teste_db.* TO 'developer'@'localhost';"
    echo "$SUDO_PASSWORD" | sudo -S mysql -e "FLUSH PRIVILEGES;"
    if echo "$SUDO_PASSWORD" | sudo -S systemctl is-active --quiet "$1"; then
        yad --title="Sucesso" --text="\n\n  O serviço '$1' foi ativado com sucesso.\n\nLogIn a usar no phpMyAdmin\n\nUtilizador: developer \n Password: developer  " --timeout=6 --undecorated --no-buttons --text-align=center --width=300 --height=50
    else
        yad --title="Erro" --text="\n\n Ocorreu um erro ao ativar o serviço '$1'.\n Tente Novamente... " --timeout=2 --undecorated --no-buttons --text-align=center --width=300 --height=50
    fi
}

# Função para parar o serviço e exibir notificação
parar_servico() {
    echo "$SUDO_PASSWORD" | sudo -S systemctl stop "$1"
    if echo "$SUDO_PASSWORD" | sudo -S systemctl is-active --quiet "$1"; then
        yad --title="Erro" --text="\n\nNão foi possivel desativar o serviço '$1'." --timeout=2 --undecorated --no-buttons --text-align=center --width=300 --height=50
    else
        yad --title="Sucesso" --text="\n\nO serviço '$1' foi desativado com sucesso." --timeout=2 --undecorated --no-buttons --text-align=center --width=300 --height=50
    fi
}

while true; do
    # Obter status atual de cada serviço
    status_mariadb=$(verificar_status mariadb)

    # Definir o texto dos botões com base no status
    if [ "$status_mariadb" = "ativo" ]; then
        btn_mariadb="Desativar MariaDB em modo LIVE"
    else
        btn_mariadb="Ativar MariaDB em modo LIVE"
    fi

    # Exibir caixa de diálogo com botões para cada serviço
    resposta=$(yad --form --title="Ativação do serviço MariaDB" --text="\n\nATIVAÇÃO DO SERVIÇO MARIADB\nEM MODO LIVE" --text-align=center --undecorated \
        --width=300 --height=100 --borders=10 \
        --field=" :LBL" \
        --button="$btn_mariadb:1" \
        --button="Sair:0")

    # Interpretar a resposta e executar as ações correspondentes
    case $? in
        1)
            if [ "$status_mariadb" = "ativo" ]; then
                parar_servico mariadb
            else
                echo "$SUDO_PASSWORD" | sudo -S cp /etc/script/50-server.cnf /etc/mysql/mariadb.conf.d/
                echo "$SUDO_PASSWORD" | sudo -S mysql_install_db --user=mysql --datadir=/tmp/mysql
                iniciar_servico mariadb
            fi
            ;;
        0)
            exit 0
            ;;
    esac
done
