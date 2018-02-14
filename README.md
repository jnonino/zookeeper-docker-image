# Zookeeper Docker Image

This Docker Image creates a Zookeeper node that can form a Zookeeper Cluster in combination to other Zookeeper nodes.

# Start Zookeeper Cluster

In order to start Zookeeper cluster, you need to run the first node using the following command:  

    docker run --name zk1 --network data-processing jnonino/zookeeper-docker-image  

Then, you need to obtain the IP address of that node, you can doing by running this command:  

    docker inspect zk1 | grep IPAddress  

You can run as many nodes as you want by running the following commands. You should always run an odd number of nodes, usually three or five.  

    docker run --name zk2 jnonino/zookeeper-docker-image <IP_ANOTHER_ZOOKEEPER_NODE>:2181  
    docker run --name zk3 jnonino/zookeeper-docker-image <IP_ANOTHER_ZOOKEEPER_NODE>:2181  
    docker run --name zk4 jnonino/zookeeper-docker-image <IP_ANOTHER_ZOOKEEPER_NODE>:2181  
    docker run --name zk5 jnonino/zookeeper-docker-image <IP_ANOTHER_ZOOKEEPER_NODE>:2181  

