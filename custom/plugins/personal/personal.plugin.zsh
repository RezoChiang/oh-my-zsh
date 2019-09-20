#
# 自定义插件, 集成了一些常用功能和使用习惯的设置
# 2019/09/12 - 重构
# 2018/09/18 - 新建
#
alias h="history 100"
# alias find="find -path .git -o -path .svn -prune -o "
alias tailf="tail -f"
# 2018/12/06 - 习惯于freebsd的 ee
alias ee="vim"
# 重定义su命令
SU_CMD='/usr/bin/su'
if [ ! -f $SU_CMD ]; then
   SU_CMD=`whereis ssh | awk '{print $2}'`
fi
alias su2="${SU_CMD}"

# 2018/03/21 - 使用着色的diff
if [[ -f $(which colordiff) ]]; then
    alias diff="colordiff -Nur"
fi

local zsh_personal_plugin_path="$(cd "$(dirname "$0")" && pwd)"

# 2019/06/05 - 增加python环境变量, 优先系统, 再个人
if [ -d "$HOME/.local/bin" ] ; then
    export PATH="$PATH:$HOME/.local/bin"
fi

# 2019/09/12 - 从文件读取和设置变量
function zreload(){
    # 2019/09/12 - 加载默认环境变量文件.
    local file="${zsh_personal_plugin_path}/default.vars.zsh"
    if [[  -f $file ]]; then
        source $file
    fi
    # 2019/09/12 -  加载默认函数库
    local file="${zsh_personal_plugin_path}/default.functions.zsh"
    if [[  -f $file ]]; then
        source $file
    fi
    # 2019/09/12 - 开启后启动速度明显变慢, 所以手动开启
    # servers_alias default
}

# 2019/09/12 - 加载自定义配置
zreload
# # 示例配置, 可供参考
# ssh_servers_alias "example_ssh"
# # 注意 安全起见, 形如 *.ssh.conf 的是被git排除掉的
# ssh_servers_alias "servers.ssh"
# ssh_servers_alias "localhost.ssh"

# cenv "default.vars"
