namespace: demo1
flow:
  name: CreateVM
  inputs:
    - host: 10.0.46.10
    - username: "Capa1\\1011-capa1user"
    - password: Automation123
    - datacenter: Capa1 Datacenter
    - image: Ubuntu
    - folder: Students/Shweta
    - prefix_list: 'A-,B-,C-'
  workflow:
    - generate_uuid:
        do:
          io.cloudslang.demo.uuid: []
        publish:
          - uuid: '${"shweta-"+uuid}'
        navigate:
          - SUCCESS: substring
    - substring:
        do:
          io.cloudslang.base.strings.substring:
            - origin_string: '${uuid}'
            - end_index: '13'
        publish:
          - id: '${new_string}'
        navigate:
          - SUCCESS: clone_vm
          - FAILURE: FAILURE
    - clone_vm:
        parallel_loop:
          for: prefix in prefix_list
          do:
            io.cloudslang.vmware.vcenter.vm.clone_vm:
              - host: '${host}'
              - user: '${username}'
              - password:
                  value: '${password}'
                  sensitive: true
              - vm_source_identifier: name
              - vm_source: '${image}'
              - datacenter: '${datacenter}'
              - vm_name: '${prefix+id}'
              - vm_folder: '${folder}'
              - mark_as_template: 'false'
              - trust_all_roots: 'true'
              - x_509_hostname_verifier: allow_all
        navigate:
          - SUCCESS: power_on_vm
          - FAILURE: FAILURE
    - power_on_vm:
        parallel_loop:
          for: prefix in prefix_list
          do:
            io.cloudslang.vmware.vcenter.power_on_vm:
              - host: '${host}'
              - user: '${username}'
              - password:
                  value: '${password}'
                  sensitive: true
              - vm_identifier: name
              - vm_name: '${prefix+id}'
              - trust_all_roots: 'true'
              - x_509_hostname_verifier: allow_all
        navigate:
          - SUCCESS: wait_for_vm_info
          - FAILURE: FAILURE
    - wait_for_vm_info:
        parallel_loop:
          for: prefix in prefix_list
          do:
            io.cloudslang.vmware.vcenter.util.wait_for_vm_info:
              - host: '${host}'
              - user: '${username}'
              - password:
                  value: '${password}'
                  sensitive: true
              - vm_identifier: name
              - vm_name: '${prefix+id}'
              - datacenter: '${datacenter}'
              - trust_all_roots: 'true'
              - x_509_hostname_verifier: allow_all
        publish:
          - ip_list: '${str([str(x["ip"]) for x in branches_context])}'
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: FAILURE
  outputs:
    - ip_list: '${ip_list}'
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      generate_uuid:
        x: 279
        y: 88
      substring:
        x: 436
        y: 86
        navigate:
          9b28b3ac-8363-bfd7-fdb4-e129b0d95100:
            targetId: 0bbd84e8-1097-d13c-c4ea-a521ac803efc
            port: FAILURE
      clone_vm:
        x: 608
        y: 72
        navigate:
          d4d3478a-cdfc-b0d0-f34e-2e5098fd64f8:
            targetId: 0bbd84e8-1097-d13c-c4ea-a521ac803efc
            port: FAILURE
      power_on_vm:
        x: 745
        y: 72
        navigate:
          9b020223-ad1b-7663-b283-8686b0974640:
            targetId: 0bbd84e8-1097-d13c-c4ea-a521ac803efc
            port: FAILURE
      wait_for_vm_info:
        x: 927
        y: 68
        navigate:
          68280934-25e3-604e-f511-b8f8606eee0e:
            targetId: e8e85ca2-642f-ba9b-d63d-c8452f1469c4
            port: SUCCESS
          36f7c0dd-810c-f3cf-44c4-f98ee342c9d8:
            targetId: 0bbd84e8-1097-d13c-c4ea-a521ac803efc
            port: FAILURE
    results:
      FAILURE:
        0bbd84e8-1097-d13c-c4ea-a521ac803efc:
          x: 453
          y: 357
      SUCCESS:
        e8e85ca2-642f-ba9b-d63d-c8452f1469c4:
          x: 637
          y: 375
