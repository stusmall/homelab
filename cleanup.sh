#!/bin/sh
kubectl delete namespaces argocd
kubectl delete customresourcedefinitions.apiextensions.k8s.io applications.argoproj.io
kubectl delete customresourcedefinitions.apiextensions.k8s.io applicationsets.argoproj.io
kubectl delete customresourcedefinitions.apiextensions.k8s.io appprojects.argoproj.io
kubectl delete customresourcedefinitions.apiextensions.k8s.io elasticmapsservers.maps.k8s.elastic.co
kubectl delete customresourcedefinitions.apiextensions.k8s.io elasticsearchautoscalers.autoscaling.k8s.elastic.co
kubectl delete customresourcedefinitions.apiextensions.k8s.io elasticsearches.elasticsearch.k8s.elastic.co
kubectl delete customresourcedefinitions.apiextensions.k8s.io packageregistries.packageregistry.k8s.elastic.co
kubectl delete customresourcedefinitions.apiextensions.k8s.io agents.agent.k8s.elastic.co
kubectl delete customresourcedefinitions.apiextensions.k8s.io beats.beat.k8s.elastic.co
kubectl delete customresourcedefinitions.apiextensions.k8s.io apmservers.apm.k8s.elastic.co
kubectl delete customresourcedefinitions.apiextensions.k8s.io autoopsagentpolicies.autoops.k8s.elastic.co
kubectl delete customresourcedefinitions.apiextensions.k8s.io enterprisesearches.enterprisesearch.k8s.elastic.co
kubectl delete customresourcedefinitions.apiextensions.k8s.io kibanas.kibana.k8s.elastic.co
kubectl delete customresourcedefinitions.apiextensions.k8s.io logstashes.logstash.k8s.elastic.co
kubectl delete customresourcedefinitions.apiextensions.k8s.io stackconfigpolicies.stackconfigpolicy.k8s.elastic.co
