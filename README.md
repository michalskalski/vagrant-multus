## Vagrant file for testing Multi-homed pod cni

Setup simple cluster of kubernetes with 1 master and 2 nodes. 

* clone repository

    $ git clone https://github.com/michalskalski/vagrant-multus.git

* setup VMs

    $ cd vagrant-multus
    $ vagrant up

* wait till script finish VMs provisioning, log in to master VM and initialize k8s cluster

    $ vagrant ssh master
    $ sudo kubeadm init --apiserver-advertise-address 10.14.0.11 --pod-network-cidr 10.244.0.0/16

* follow instructions from output of above command

    $ mkdir -p $HOME/.kube
    $ sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    $ sudo chown $(id -u):$(id -g) $HOME/.kube/config

* log in to other 2 nodes and join them to k8s cluster with token from kubeadm init output

    $ vagrant ssh node1
    $ sudo kubeadm join --token [TOKEN] 10.14.0.11:6443
    $ vagrant ssh node2
    $ sudo kubeadm join --token [TOKEN] 10.14.0.11:6443

* on master node initialize cni plugin 

    $ kubectl apply -f /vagrant/files/rbac.yaml
    $ kubectl apply -f /vagrant/files/multus.yaml

* wait till cluster will be ready, you should see similar output

    [vagrant@master ~]$ kubectl get pods --namespace=kube-system
    NAME                             READY     STATUS    RESTARTS   AGE
    etcd-master                      1/1       Running   0          36m
    kube-apiserver-master            1/1       Running   0          36m
    kube-controller-manager-master   1/1       Running   0          36m
    kube-dns-2425271678-qvdpb        3/3       Running   0          43m
    kube-multus-ds-1g2bd             2/2       Running   0          41m
    kube-multus-ds-bpx23             2/2       Running   0          41m
    kube-proxy-20xw5                 1/1       Running   0          42m
    kube-proxy-7rjct                 1/1       Running   0          43m
    kube-proxy-xnskc                 1/1       Running   0          42m
    kube-scheduler-master            1/1       Running   0          36m

* create pod

    $ kubectl apply -f /vagrant/files/busybox.yaml

* verify that container has 2 interfaces in different networks

    $ [vagrant@master ~]$ kubectl exec busybox -it ip a
    1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue qlen 1
        link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
        inet 127.0.0.1/8 scope host lo
           valid_lft forever preferred_lft forever
        inet6 ::1/128 scope host
           valid_lft forever preferred_lft forever
    3: eth0@if8: <BROADCAST,MULTICAST,UP,LOWER_UP,M-DOWN> mtu 1450 qdisc noqueue
        link/ether 0a:58:0a:f4:01:02 brd ff:ff:ff:ff:ff:ff
        inet 10.244.1.2/24 scope global eth0
           valid_lft forever preferred_lft forever
        inet6 fe80::cca8:7aff:fe4c:8148/64 scope link
           valid_lft forever preferred_lft forever
    4: net0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue
        link/ether 0a:58:0a:e6:00:64 brd ff:ff:ff:ff:ff:ff
        inet 10.230.0.100/24 scope global net0
           valid_lft forever preferred_lft forever
        inet6 fe80::858:aff:fee6:64/64 scope link
           valid_lft forever preferred_lft forever
