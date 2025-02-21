# type:ignore
from diagrams import Diagram, Cluster, Edge
from diagrams.programming.framework import Vercel, NextJs
from diagrams.k8s.rbac import User, SA
from diagrams.k8s.network import SVC
from diagrams.k8s.compute import Deploy, Pod, RS
from diagrams.k8s.infra import Node
from diagrams.onprem.database import PostgreSQL
from diagrams.gcp.compute import ComputeEngine
from diagrams.aws.storage import ElasticBlockStoreEBSVolume


with Diagram("Kubernetes without AUTO-SCALLING", show=False, direction="TB"):
    user = User("Client")
    sa = SA("Admin")

    with Cluster("OVH"):
        deploy = Deploy("kubectl")
        rs = RS("Replicatset")
        service_loadbalancer = SVC("Load Balancer")


        with Cluster("KUBERNETES CLUSTER"):
            node_fe = Node("Discovery Node")
            nextjs = NextJs("Nextjs 15")
            pods = [
                Pod("Pod1"),
                Pod("Pod2"),
                Pod("Pod3"),
                Pod("Pod4"),
                Pod("Pod5")
            ]

            node_fe >> pods << nextjs
        
        sa >> rs >> deploy >> node_fe
        service_loadbalancer >> node_fe


        with Cluster("VM INSTANCE"):
            supabase = PostgreSQL("Supabase")
            vm = ComputeEngine("VM")

            vm >> supabase >> vm

            node_fe >> vm

        with Cluster("S3 STORAGE (AUTO SCALE)"):
            s3 = ElasticBlockStoreEBSVolume("S3 STORAGE")

            s3 >> vm >> s3


    user >> service_loadbalancer
    user << service_loadbalancer