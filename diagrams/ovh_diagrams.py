# type:ignore
from diagrams import Diagram, Cluster, Edge
from diagrams.programming.framework import Vercel, NextJs
from diagrams.k8s.rbac import User, SA
from diagrams.k8s.network import SVC
from diagrams.k8s.compute import Deploy, Pod, RS
from diagrams.k8s.infra import Node
from diagrams.onprem.database import PostgreSQL


with Diagram("Kubernetes without AUTO-SCALLING", show=False, direction="TB"):
    user = User("Client")
    sa = SA("Admin")

    with Cluster("OVH"):
        deploy = Deploy("kubectl")
        rs = RS("Replicatset")
        service_loadbalancer = SVC("Load Balancer")


        with Cluster("Node Front End"):
            node_fe = Node("Discovery Node")
            nextjs = NextJs("Nextjs 15")
            pods = [
                Pod("Pod1"),
                Pod("Pod2"),
                Pod("Pod3")
            ]

            nextjs >> pods >> node_fe

        service_loadbalancer >> node_fe
        service_loadbalancer << node_fe

        with Cluster("Node Supabase"):
            node_sb = Node("Discovery Node")
            sgbd = PostgreSQL("Supabase SH")

            pods = Pod("Pod1")

            sgbd >> pods >> node_sb
        
        sa >> Edge(color="blue", style="dotted") >> deploy >> Edge(color="blue", style="dotted") >> rs >> Edge(color="blue", style="dotted") >> [
            node_fe,
            node_sb
        ]
        cluster_id = SVC("ClusterIP")

        node_fe - Edge(color="red") - cluster_id >> Edge(color="red") >> node_sb
        cluster_id - Edge(color="red") - node_sb
        cluster_id >> Edge(color="red") >> node_fe



    user >> service_loadbalancer
    user << service_loadbalancer