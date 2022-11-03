#! /bin/bash



# configuration color show ...
GREEN='\e[0;32m'; YELLOW='\e[1;33m'; RED='\e[1;31m'; BLUE='\e[0;34m'; END='\e[0m';
RED(){ echo -e  "${RED}$1${END}"; }
GREEN(){ echo -e  "${GREEN}$1${END}"; }
YELLOW(){ echo -e  "${YELLOW}$1${END}"; }
BLUE() { echo -e  "${BLUE}$1${END}"; }


INSTALL_ROOT_PATH="$(cd `dirname $0` && pwd)"
KUBEADM_INSTALL_INFO="${INSTALL_ROOT_PATH}/kubeadm_install_info.log"
KUBENETERS_CLUSTER_TOKEN=""


STARTTIME=`date +%Y%m%d_%H:%M:%S`
STARTTIME_S=`date +%s`




function generate_k8s_install_conf()
{
	local_ip=$(ip r | grep src | grep eth0 | awk '{print $NF}')
	#echo $local_ip

	cat <<EOF | sudo tee ${INSTALL_ROOT_PATH}/kubeadm_init.conf
apiVersion: kubeadm.k8s.io/v1beta3
bootstrapTokens:
- groups:
  - system:bootstrappers:kubeadm:default-node-token
  token: abcdef.0123456789abcdef
  ttl: 24h0m0s
  usages:
  - signing
  - authentication
kind: InitConfiguration
localAPIEndpoint:
  advertiseAddress: ${local_ip}
  bindPort: 6443
nodeRegistration:
  kubeletExtraArgs:
    volume-plugin-dir: "/opt/libexec/kubernetes/kubelet-plugins/volume/exec/"
  criSocket: unix:///var/run/containerd/containerd.sock
  imagePullPolicy: IfNotPresent
  name: $(hostname)
  taints:
  - effect: "NoSchedule"
    key: "node-role.kubernetes.io/master"
---
apiServer:
  timeoutForControlPlane: 4m0s
apiVersion: kubeadm.k8s.io/v1beta3
certificatesDir: /etc/kubernetes/pki
clusterName: kubernetes
controllerManager: {}
dns: {}
etcd:
  local:
    dataDir: /var/lib/etcd
imageRepository: registry.cn-hangzhou.aliyuncs.com/google_containers
kind: ClusterConfiguration
kubernetesVersion: 1.24.0
networking:
  dnsDomain: cluster.local
  serviceSubnet: 10.96.0.0/12
  podSubnet: 10.244.0.0/16
scheduler: {}

EOF
}


function install_k8s_cluster_master()
{
	generate_k8s_install_conf
	
	kubeadm reset -f && sleep 5
	kubeadm reset -f && sleep 5
	
	kubeadm init --config  ${INSTALL_ROOT_PATH}/kubeadm_init.conf 2>&1 | tee ${KUBEADM_INSTALL_INFO}
	rm -rf $HOME/.kube
	mkdir -p $HOME/.kube
	sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
	sudo chown $(id -u):$(id -g) $HOME/.kube/config

	kubectl get node -owide
	endTime=`date +%Y%m%d_%H:%M:%S`
	endTime_s=`date +%s`
	sumTime=$((${endTime_s} - ${STARTTIME_S}))

	echo "$startTime ---> $endTime" "Total:$sumTime seconds"
}





function install_k8s_cni()
{
	net_interface_name=$(ls /sys/class/net |grep -v lo)

	cd ${INSTALL_ROOT_PATH}
	rm -rf  calico.yaml  calico.yaml.orig
	curl https://docs.projectcalico.org/manifests/calico.yaml -O

	k8s_cni_config=$(ls ${INSTALL_ROOT_PATH} | grep -w 'calico.yaml' )
	
	if [[ ! -z ${k8s_cni_config} ]]; then
		# CALICO_IPV4POOL_CIDR 快速查找位置，更改为你的pod网段
		YELLOW "CALICO_IPV4POOL_CIDR 快速查找位置，更改为你的pod网段"
		echo
		
		# # bgp快速查找位置，等号后面更改为你的网卡名，比如ens33,eth0
		# # – name: IP_AUTODETECTION_METHOD
		# # value: “interface=eth0”
		# YELLOW "bgp快速查找位置，等号后面更改为你的网卡名，比如ens33,eth0"
		# YELLOW "– name: IP_AUTODETECTION_METHOD"
		# YELLOW "value: \"interface=${net_interface_name}\""
		
		editdiff ${INSTALL_ROOT_PATH}/calico.yaml
		
		echo "modify calico.yaml success ^_^"
		kubectl apply -f  ${INSTALL_ROOT_PATH}/calico.yaml
		YELLOW "kubernets cluster cni install finish ^_^"
	fi
}



function init_k8s_os()
{
	k8s_role_name=${1}
	echo "init_k8s_system: k8s role -- ${k8s_role_name}"

	if [[ ${k8s_role_name} == "master" ]]; then
		# 初始化 k8s master节点系统环境
		bash ${INSTALL_ROOT_PATH}/init_k8s_system.sh
	fi
}



function main()
{
	# 初始化k8s所有节点的系统环境
#	init_k8s_os	 master
	
	# 安装kubernetes cluster master
	install_k8s_cluster_master
	
	# 安装 calico 网络插件
	install_k8s_cni
	
	#显示k8s集群
	kubectl get node
}



main $@
