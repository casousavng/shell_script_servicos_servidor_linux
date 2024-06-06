#!/bin/bash

# Solicitar senha sudo usando yad
PASSWORD_PROMPT=$(yad --form --title="Autenticação Requerida" --text="\nPor favor, insira sua senha\n [com permissões SUDO]\n" --undecorated --text-align=center --width=300 --height=100 --borders=5 --field="Senha:H" --hide-text --button="OK:0" --button="Cancelar:1")

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
    if echo "$SUDO_PASSWORD" | sudo -S systemctl is-active --quiet "$1"; then
        yad --title="Sucesso" --text="\n\nO serviço '$1' foi ativado com sucesso." --timeout=2 --undecorated --no-buttons --text-align=center --width=300 --height=50
    else
        yad --title="Erro" --text="\n\nNão foi possível ativar o serviço '$1'." --timeout=2 --undecorated --no-buttons --text-align=center --width=300 --height=50
    fi
}

# Função para parar o serviço e exibir notificação
parar_servico() {
    echo "$SUDO_PASSWORD" | sudo -S systemctl stop "$1"
    if echo "$SUDO_PASSWORD" | sudo -S systemctl is-active --quiet "$1"; then
        yad --title="Erro" --text="\n\nNão foi possível desativar o serviço '$1'." --timeout=2 --undecorated --no-buttons --text-align=center --width=300 --height=50
    else
        yad --title="Sucesso" --text="\n\nO serviço '$1' foi desativado com sucesso." --timeout=2 --undecorated --no-buttons --text-align=center --width=300 --height=50
    fi
}

while true; do

    # Obter status atual de cada serviço
    status_docker=$(verificar_status docker)
    status_mariadb=$(verificar_status mariadb)
    status_nginx=$(verificar_status nginx)
    status_phpmyadmin=$(verificar_status php8.2-fpm)

    # Definir o texto dos botões com base no status
    if [ "$status_docker" = "ativo" ]; then
        btn_docker="Desativar Docker"
    else
        btn_docker="Ativar Docker"
    fi

    if [ "$status_mariadb" = "ativo" ]; then
        btn_mariadb="Desativar MariaDB"
    else
        btn_mariadb="Ativar MariaDB"
    fi

    if [ "$status_nginx" = "ativo" ]; then
        btn_nginx="Desativar Nginx / NginxUI"
    else
        btn_nginx="Ativar Nginx / NginxUI"
    fi

    if [ "$status_phpmyadmin" = "ativo" ]; then
        btn_phpmyadmin="Desativar PHP Service"
    else
        btn_phpmyadmin="Ativar PHP Service"
    fi

    # Exibir caixa de diálogo com botões para cada serviço
    resposta=$(yad --form --title="Gerenciamento de Serviços" --text="[ GESTOR DE SERVIÇOS PARA UTILIZAÇÃO DO SERVIDOR VIRTUAL ]\n" --text-align=center --undecorated \
        --width=300 --height=200 --borders=20 \
        --field="Clique AQUI para testar o seu website (http://localhost):BTN" "xdg-open http://localhost" \
        --field="Clique AQUI para aceder a pasta do seu website (/var/www/developer):BTN" "xdg-open /var/www/developer" \
        --field="Clique AQUI para aceder ao seu Gestor de BD phpMyAdmin (http://localhost/phpMyAdmin/):BTN" "xdg-open http://localhost/phpMyAdmin/" \
        --field="Clique AQUI para aceder ao Gestor do seu servidor Nginx-UI (http://localhost:9000):BTN" "xdg-open http://localhost:9000" \
        --field="| Utilizar MariaDB em modo Live (Script de correção em caso de Falha na Ativação) |:BTN" "bash -c '/etc/script/script_mariadb.sh'" \
        --field=" :LBL" \
        --button="$btn_docker:1" \
        --button="$btn_mariadb:2" \
        --button="$btn_nginx:3" \
        --button="$btn_phpmyadmin:4" \
        --button="Sair:0")

    # Interpretar a resposta e executar as ações correspondentes
    case $? in
        1)
            if [ "$status_docker" = "ativo" ]; then
                parar_servico docker
                parar_servico docker.socket
                parar_servico containerd
            else
                iniciar_servico docker
                #iniciar_servico docker.socket
            fi
            ;;
        2)
            if [ "$status_mariadb" = "ativo" ]; then
                parar_servico mariadb
            else
                iniciar_servico mariadb
            fi
            ;;
        3)
            if [ "$status_nginx" = "ativo" ]; then
                parar_servico nginx
                parar_servico nginx-ui
            else
                iniciar_servico nginx
                iniciar_servico nginx-ui
                echo "$SUDO_PASSWORD" | sudo -S systemctl restart nginx
            fi
            ;;
        4)
            if [ "$status_phpmyadmin" = "ativo" ]; then
                parar_servico php8.2-fpm
            else
                iniciar_servico php8.2-fpm
            fi
            ;;
        0)
            exit 0
            ;;
    esac
done
