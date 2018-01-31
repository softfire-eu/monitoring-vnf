  <img src="https://www.softfire.eu/wp-content/uploads/SoftFIRE_Logo_Fireball-300x300.png" width="120"/>

  Copyright © 2016-2018 [SoftFIRE](https://www.softfire.eu/) and [TU Berlin](http://www.av.tu-berlin.de/next_generation_networks/).
  Licensed under [Apache v2 License](http://www.apache.org/licenses/LICENSE-2.0).

# Monitoring Resources as a VNF

Monitoring Resources as a VNF provides Zabbix Server as a VNF deployed within the NSD. This project shows an example of nsd including Zabbix Server as a VNF.

## Tutorial for creating Zabbix Server as a VNF in an NSD

The example of the nsd is uploaded in this project. It contains the nsd yaml file and the scripts for each VNF. Installation of zabbix server script is needed for zabbix server VNF. All the other VNFs will need a script for installing and configuring the zabbix agent.


The structure of the zabbix server VNF descriptor in the nsd yaml file should be similar to the below example:
```yaml
    zabbixserver: #VNF1
        type: openbaton.type.VNF
        properties:
          ID: zabbix-server
          vendor: FOKUS
          version: 1.0
          endpoint: generic
          type: zabbix
          configurations:
            configurationParameters:
              - name: zabbix
            name: zabbixserver-configuration
          deploymentFlavour:
            - flavour_key: m1.small
        requirements:
          - virtualLink: softfire-internal
          - vdu: VDU3
        interfaces:
          lifecycle: # lifecycle
            INSTANTIATE:
              - install.sh
```

The most important parameters should be configured in the zabbix server VNF descriptor example are: type, ConfigurationParameters, and the lifecycle INSTANTIATE script (install.sh) to install and configure the zabbix server.

For all other VNFs who will need to be monitored, a lifecycle event CONFIGURE script (zabbix_configure_agent.sh) should be added to install and configure zabbix agent as shown in example below:

```yaml
    iperf-client:
      type: openbaton.type.VNF
      properties:
        ID: client-vnf
        vendor: FOKUS
        version: 1.0
        type: client
        deploymentFlavour:
          - flavour_key: m1.small

        endpoint: generic
      requirements:
         - virtualLink: Server-Network
         - vdu: VDU1
      interfaces:
          lifecycle: # lifecycle
            INSTANTIATE:
              - install.sh
            CONFIGURE:
              - zabbix_configure_agent.sh
```

In the nsd yaml, the relation dependency should be provided to let zabbix server be ready first then configure the zabbix agent in the monitored VNFs as the example shown below:

```yaml
relationships_template:
  rel1: 
    type: tosca.nodes.relationships.ConnectsTo
    source: zabbixserver
    target: iperf-client
    parameters:
        - softfire-internal_floatingIp
        - name
```

For the relation dependency, the zabbixserver should be the source and other VNFs should be the target. Also adding the floating ip and the name paramaters is a must, as the zabbix_agent_configuration script will be based on them.

For this solution, Ubuntu-14.04 image should be used for the zabbix-server VNF. That can be configured in the nsd yaml in the VDU part by adding the artifacts paramter including the image file required as shown in the example below. This way will add more flexibility in using different images per the VNFs.

```yaml
    VDU2: # This VDU is used by other VNF
      type: tosca.nodes.nfv.VDU
      properties:
        scale_in_out: 2
      requirements:
        - virtual_link: CP2
      artifacts:
        VDU2Image:
          type: tosca.artifacts.Deployment.Image.VM
          file: Ubuntu-16.04
    VDU3: # This VDU is used by the zabbix server
      type: tosca.nodes.nfv.VDU
      properties:
        scale_in_out: 2
      requirements:
        - virtual_link: CP3
      artifacts:
        VDU3Image:
          type: tosca.artifacts.Deployment.Image.VM
          file: Ubuntu-14.04

```

To use the above configuration option, the configuration of the image name in the TOSCA-Metadat/Metadata.yaml file should be removed and be as the exmaple below:


```yaml

name: Iperf Example
description: Iperf Example.
provider: FOKUS
nfvo_version: 5.0.1
image:
    upload: false

vim_types:
    - openstack
```

## Technical Requirements

## Issue tracker

Issues and bug reports should be posted to the GitHub Issue Tracker of this project

# What is SoftFIRE?

SoftFIRE provides a set of technologies for building a federated experimental platform aimed at the construction and experimentation of services and functionalities built on top of NFV and SDN technologies.
The platform is a loose federation of already existing testbed owned and operated by distinct organizations for purposes of research and development.

SoftFIRE has three main objectives: supporting interoperability, programming and security of the federated testbed.
Supporting the programmability of the platform is then a major goal and it is the focus of the SoftFIRE’s Second Open Call.

## Licensing and distribution
Copyright © [2016-2018] SoftFIRE project

Licensed under the Apache License, Version 2.0 (the "License");

you may not use this file except in compliance with the License.
You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

