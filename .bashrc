#
# ~/.bashrc
#

export KUBECONFIG=$(echo $(ls ~/.kube/config.d/* 2>/dev/null) | sed 's/ /:/g')

eval "$(zoxide init bash)"
eval "$(starship init bash)"
