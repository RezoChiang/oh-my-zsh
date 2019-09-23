# 2019/04/24 - 初始化个人电脑的工作目录, 建立常用链接
function init_pc(){
    local username="$(whoami)"
    if [ "x$1" != "x" ]; then
        username="${1}"
    fi
    local uid=$(id -u ${username} 2> /dev/null)
    if [ -z "${uid}" ]; then
        echo "ERROR: user ${username} not valid"
        return
    fi
    local home_dir="/home/${username}"
    if [ $uid = 0 ]; then
        home_dir="/root"
    fi
    local dirs="
${home_dir}/mnt/p1
${home_dir}/mnt/p2
${home_dir}/mnt/p3
${home_dir}/.gws_data/private
${home_dir}/.gws_data/config_backup
${home_dir}/.gws_temp
${home_dir}/.gws_download
${home_dir}/.will_trash
${home_dir}/.local/share/Trash
"
    # 2019/04/24 - for short datapath
    if [ $uid != 0 ] && [ ! -d "/data" ]; then
        sudo ln -sf "${home_dir}/.gws_data" "/data"
    elif [ -d "/data" ]; then
        echo "/data has exists. will not change"
    fi
    # 2019/04/25 - for short datapath
    if [ $uid != 0 ] && [ ! -d "/temp" ]; then
        sudo ln -sf "${home_dir}/.gws_temp" "/temp"
    elif [ -d "/temp" ]; then
        echo "/temp has exists. will not change"
    fi

    if [ ! -d "${home_dir}/tmp" ]; then
        ln -sf "${home_dir}/.gws_temp" "${home_dir}/tmp"
    fi
    if [ ! -d "${home_dir}/files" ]; then
        ln -sf "${home_dir}/.gws_data" "${home_dir}/files"
    fi
    if [ ! -d "${home_dir}/Trash" ]; then
        ln -sf "${home_dir}/.local/share/Trash" "${home_dir}/Trash"
    fi
    if [ ! -d "${home_dir}/.Trash" ]; then
        ln -sf "${home_dir}/.local/share/Trash" "${home_dir}/.Trash"
    fi
    if [ ! -d "${home_dir}/Downloads" ]; then
        ln -sf "${home_dir}/.gws_download" "${home_dir}/Downloads"
    fi

    for dir in `echo $dirs | tr '\r\n' ' '`; do
        if [ ! -d "${dir}" ]; then
            mkdir -p "${dir}"
            echo "create ${dir}"
        fi
    done
}

# 2019/09/20 - 初始化go项目目录
function init_proj_go(){
    local proj_path=$1
    if [[ "$proj_path" = "" ]]; then
        proj_path=$(pwd)
    fi
    mkdir -p "$proj_path/src" "$proj_path/bin" "$proj_path/pkg"
    export GOPATH=$proj_path
}

# 2019/09/23 - 初始化PHP与docker项目目录
function init_proj_php_with_docker(){
    local proj_name=$1
    if [[ "$proj_name" = "" ]]; then
        echo "create project base structure with one command."
        echo "usage: $0 project_name"
    fi
    local proj_path=$2
    if [[ "$proj_path" = "" ]]; then
        proj_path=$(pwd)
    fi
    mkdir -p "$proj_path/$proj_name/src" \
          "$proj_path/$proj_name/docker" \
          "$proj_path/$proj_name/db" \
          "$proj_path/$proj_name/db_backup" \
          "$proj_path/$proj_name/doc" \
          "$proj_path/$proj_name/conf/nginx" \
          "$proj_path/$proj_name/log/nginx"
    touch "$proj_path/$proj_name/.giti"
    touch "$proj_path/$proj_name/readme.org"
}

# 2018/03/22 - 重写su 因为可能使用 su username的形式
function su(){
    local username=$1
    local os=`uname -s | tr '[:upper:]' '[:lower:]'`
    if [[ "$username" = "" ]]; then
        if [[ "$os" = 'freebsd' ]]; then
            username=toor
        fi
    fi
    su2 $username
}

# 2018/03/20 - freebsd 的 mv 与 linux的mv命令不一样,要分开处理
function trash(){
    local target="${HOME}/.local/share/Trash"
    if [[ ! -d $target && ! -h $target ]]; then
        mkdir -p $target
    fi

    local link_target="${HOME}/.Trash"
    if [[ ! -e $link_target ]]; then
        ln -sf $target $link_target
    fi

    link_target="${HOME}/Trash"
    if [[ ! -e $link_target ]]; then
        ln -sf $target $link_target
    fi

    local date_stamp=`date "+%Y%m%d"`
    # local op_prefix=`cat /dev/urandom | strings |tr -dc '[:alnum:]' |fold -w 32 | head -n 1`
    local op_prefix=`date "+%H_%M_%S.%N"`
    link_target="${HOME}/Trash/${date_stamp}/${op_prefix}"
    if [[ ! -d $link_target ]]; then
        mkdir -p $link_target
    fi

    for i in $@; do
        if [[ -e $i ]]; then
            mv -i $i $link_target
        fi
    done
}
# 2018/03/21 - 设置ssh使用的ip及alias, 可使用多个配置
# 修改后调用可重载配置
function ssh_servers_alias(){
    if [[ "${1}" = "" ]]; then
        echo "useage: $0 conf_file"
        return
    fi
    local conf_path="${zsh_personal_plugin_path}/${1}.conf"
    if [[  -f $conf_path ]]; then
        source $conf_path
    else
        # echo "${conf_path} not found"
        return
    fi

    local ip=''
    local script=''
    for s in `echo $SERVERS | tr '\r\n' ' '`; do
        if [[ -n "$s" ]]; then
            ip="echo \$$(echo ${s})"
            ip=`eval ${ip}`
            script="alias 2${s}=\"ssh ${SSH_OPT} ${SSH_USER}@${ip}\""
            # echo $script
            eval $script
        fi
    done
}

# 2018/03/21 - 设置ssh使用的ip及alias, 可使用多个配置
# 2019/09/12 -
# 修改后调用可重载配置
function servers_alias(){
    if [[ "${1}" = "" ]]; then
        echo "Load ${SSH_HOSTS} and export hostname with server ip"
        echo "eg. ${0} default export hosts in ${zsh_personal_plugin_path}/default.hosts"
        return;
    fi
    local file=$1
    if [[ ! -f $file ]]; then
        file="${zsh_personal_plugin_path}/${file}.hosts"
    fi
    if [[ ! -f $file ]]; then
        echo "${file} not found"
        return;
    fi
    if [[ -z $all_servers ]]; then
        all_servers=''
    else
        unset $(echo $all_servers)
    fi
    if [[ -z $all_server_alias ]]; then
        all_server_alias=''
    else
        unalias $(echo $all_server_alias)
    fi
    local export_script=''
    local alias_script=''
    while read -r host
    do
        if [[ -z $host ]] || [[ ${host:0:1} == "#" ]] ; then
            continue
        fi
        # local name=$(echo $host | tr "[\-]" "[\_]" | awk '{print $1}')
        local name=$(echo $host | sed "s/-//g" | awk '{print $1}')
        local ip=$(echo $host | awk '{print $2}')
        local port=$(echo $host | awk '{print $3}')
        local user=$(echo $host | awk '{print $4}')
        if [[ -z $port ]]; then
            port=$SSH_PORT
        fi
        if [[ -z $user ]]; then
            user=$SSH_USER
        fi
        export_script+="export $name=$ip "
        alias_script+=" alias 2$name=\"ssh $SSH_OPT -p$port $user@$ip\" "
        all_servers+=" $name "
        all_server_alias+=" 2$name "
    done < $file
    eval $export_script
    eval $alias_script
}

# 2018/03/23 - 覆盖原有命令,支持freebsd
open_command () {
    emulate -L zsh
    setopt shwordsplit
    local open_cmd
    case "$OSTYPE" in
        (darwin*) open_cmd='open'  ;;
        (cygwin*) open_cmd='cygstart'  ;;
        (freebsd*) open_cmd='xdg-open'  ;;
        (linux*) open_cmd='xdg-open'  ;;
        (msys*) open_cmd='start ""'  ;;
        (*) echo "Platform $OSTYPE not supported"
            return 1 ;;
    esac
    if [[ "$OSTYPE" == darwin* ]]
    then
        $open_cmd "$@" &> /dev/null
    else
        nohup $open_cmd "$@" &> /dev/null
    fi
}

# # 2018/09/18 - 增加从上游合并
function upgrade_omz_upstream() {
    env ZSH=$ZSH sh $ZSH/tools/upgrade_from_upstream.sh
}
