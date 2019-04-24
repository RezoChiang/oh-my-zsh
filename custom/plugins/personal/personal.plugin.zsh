# Basic use for my personal.
SU_CMD='/usr/bin/su'
if [ ! -f $SU_CMD ]; then
   SU_CMD=`whereis su | awk '{print $2}'`
fi

alias su2="${SU_CMD}"
alias h="history 100"
# alias find="find -path .git -o -path .svn -prune -o "
alias tailf="tail -f"
# 2018/12/06 - 习惯于freebsd的 ee
alias ee="vim"

# 2018/03/21 - 使用着色的diff
if [[ -f $(which colordiff) ]]; then
    alias diff="colordiff -Nur"
fi

local zsh_personal_plugin_path="$(cd "$(dirname "$0")" && pwd)"

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

# 示例配置, 可供参考
ssh_servers_alias "example_ssh"
# 注意 安全起见, 形如 *.ssh.conf 的是被git排除掉的
ssh_servers_alias "servers.ssh"
ssh_servers_alias "localhost.ssh"

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
