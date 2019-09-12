# 2019/09/12 - For hub github authorization.
export GITHUB_USER="your_github_username"
export GITHUB_PASSWORD="your_github_token"

# 2019/09/12 - for wget/curl proxy setting
export http_proxy="host:port"
export https_proxy="host:port"
export ftp_proxy="host:port"

# 2019/09/12 - for ssh/scp
export SSH_USER="your_username"
export SSH_OPT=" -4C"
# # 2019/09/12 - see ./example.hosts, ./default.hosts will be loaded if exists.
export SSH_HOSTS="/path/to/host/file"

# 2019/09/12 - for ansible config environment variables.
# 2019/09/12 - https://docs.ansible.com/ansible/latest/reference_appendices/config.html#environment-variables
export ANSIBLE_CONFIG="/path/to/ansible/hosts"
