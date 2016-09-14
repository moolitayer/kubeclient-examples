#!/usr/bin/env ruby
require 'kubeclient'

# Following the example from http://kubernetes.io/docs/user-guide/jobs/ with kubeclient

job_client = Kubeclient::Client.new('http://localhost:8080/apis/batch' , 'v1', ssl_options: { verify_ssl: 0 })

JOB = {
  'apiVersion' => 'batch/v1',
  'metadata' => {
    'name' => 'pi',
    'namespace' => 'default'
  },
  'spec'     => {
    'template' => {
      'metadata' => {
        'name' => 'pi'
      },
      'spec'    => {
        'containers'   => [
          {
            'name'    => 'pi',
            'image'   => 'perl',
            'command' => ['perl',  '-Mbignum=bpi', '-wle', 'print bpi(2000)']
          }
        ],
        'restartPolicy' => 'Never'
      }
    }
  }
}

job = Kubeclient::Resource.new(JOB)
job_client.create_job(job)

client = Kubeclient::Client.new('http://localhost:8080/api' , 'v1', ssl_options: { verify_ssl: 0 })

# Wait for job completion
sleep 20

job_pod = client.get_pods(label_selector: 'job-name=pi').first
res = client.get_pod_log(job_pod.metadata.name, job_pod.metadata.namespace)
puts "result: #{res}"


job_client.delete_job(job.metadata.name, job.metadata.namespace)
client.get_pods.each {|x| client.delete_pod(x.metadata.name, x.metadata.namespace) }
